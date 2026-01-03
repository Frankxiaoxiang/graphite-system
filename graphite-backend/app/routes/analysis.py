"""
数据分析API路由
提供数据查询、清洗和回归分析功能
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import text
from app import db
from app.utils.decorators import role_required
from app.utils.data_cleaning import clean_analysis_data, generate_cleaning_report
import numpy as np
from scipy import stats
from app.models.analysis_config import AnalysisConfig
from datetime import datetime

# 创建蓝图（不设置url_prefix，在__init__.py中统一设置）
analysis_bp = Blueprint('analysis', __name__)

# 字段元数据（中文名称和单位）
# ✅ 2025-12-31 修正：根据数据库实际字段和用户反馈修正所有字段映射
FIELD_METADATA = {
    # 碳化参数
    'carbon_max_temp': {'label': '碳化最高温度', 'unit': '℃'},
    'carbon_total_time': {'label': '碳化总时长', 'unit': 'min'},
    'carbon_yield_rate': {'label': '碳化成碳率', 'unit': '%'},  # ✅ 修正：从"碳化收率"改为"碳化成碳率"
    
    # 石墨化参数
    'graphite_max_temp': {'label': '石墨化最高温度', 'unit': '℃'},
    'graphite_total_time': {'label': '石墨化总时长', 'unit': 'min'},
    'graphite_yield_rate': {'label': '石墨化收率', 'unit': '%'},
    'inner_foaming_thickness': {'label': '卷内发泡厚度', 'unit': 'μm'},
    'outer_foaming_thickness': {'label': '卷外发泡厚度', 'unit': 'μm'},
    'shrinkage_ratio': {'label': '收缩比', 'unit': '%'},  # ✅ 修正：从成品参数移至石墨化参数
    
    # 成品参数
    'thermal_conductivity': {'label': '导热系数', 'unit': 'W/m·K'},
    'avg_density': {'label': '平均密度', 'unit': 'g/cm³'},
    'avg_thickness': {'label': '平均厚度', 'unit': 'μm'},
    'specific_heat': {'label': '比热', 'unit': 'J/g·K'},  # ✅ 新增：补充缺失字段
    'cohesion': {'label': '内聚力', 'unit': 'gf'},  # ✅ 修正：从 MPa 改为 gf
    'peel_strength': {'label': '剥离力', 'unit': 'gf'},  # ✅ 修正：从"剥离强度 (N/cm)"改为"剥离力 (gf)"
    'bond_strength': {'label': '结合力', 'unit': 'gf'},  # ✅ 新增：补充缺失字段
    
    # PI膜参数
    'pi_film_thickness': {'label': 'PI膜厚度', 'unit': 'μm'},
    
    # 基本参数
    'graphite_model': {'label': '石墨型号', 'unit': ''}
}


@analysis_bp.route('/data', methods=['GET'])
@jwt_required()
@role_required(['admin', 'engineer'])
def get_analysis_data():
    """
    获取分析数据（使用 v_experiment_full 视图）
    """
    # ===== 调试打印开始 =====
    print("=" * 60)
    print("📊 [DEBUG] get_analysis_data 函数被调用")
    print(f"📊 [DEBUG] 请求参数: {dict(request.args)}")
    print("=" * 60)
    
    try:
        # 1. 获取必填参数
        x_field = request.args.get('x_field')
        y_field = request.args.get('y_field')
        
        print(f"📊 [DEBUG] x_field={x_field}, y_field={y_field}")
        
        if not x_field or not y_field:
            print("❌ [DEBUG] 缺少必填字段")
            return jsonify({
                'error': 'Missing required fields',
                'message': '请选择X轴和Y轴字段'
            }), 400
        
        # 2. 验证字段是否存在（白名单检查，防止SQL注入）
        if x_field not in FIELD_METADATA or y_field not in FIELD_METADATA:
            print(f"❌ [DEBUG] 字段不存在: x_field={x_field}, y_field={y_field}")
            return jsonify({
                'error': 'Invalid field',
                'message': '选择的字段不存在'
            }), 400
        
        print("✅ [DEBUG] 字段验证通过")
        
        # 3. 构建基础 SQL
        query = f"""
            SELECT 
                experiment_code,
                {x_field} as x_value,
                {y_field} as y_value
            FROM v_experiment_full
            WHERE {x_field} IS NOT NULL 
              AND {y_field} IS NOT NULL
              AND status IN ('submitted', 'completed')
        """
        
        print(f"📊 [DEBUG] 基础SQL构建完成")
        
        # 4. 动态添加筛选条件
        filters = []
        params = {}

        # 日期筛选
        date_start = request.args.get('date_start')
        print(f"📊 [DEBUG] date_start 原始值: {repr(date_start)}")
        if date_start and date_start.strip():
            filters.append("experiment_date >= :date_start")
            params['date_start'] = date_start
            print(f"✅ [DEBUG] 添加 date_start 筛选: {date_start}")

        date_end = request.args.get('date_end')
        print(f"📊 [DEBUG] date_end 原始值: {repr(date_end)}")
        if date_end and date_end.strip():
            filters.append("experiment_date <= :date_end")
            params['date_end'] = date_end
            print(f"✅ [DEBUG] 添加 date_end 筛选: {date_end}")

        # PI 膜型号筛选
        pi_film_model = request.args.get('pi_film_model')
        print(f"📊 [DEBUG] pi_film_model 原始值: {repr(pi_film_model)}")
        if pi_film_model:
            models = [m.strip() for m in pi_film_model.split(',') if m.strip()]
            print(f"📊 [DEBUG] 解析后的 models: {models}")
            if models:
                placeholders = ','.join([f':model_{i}' for i in range(len(models))])
                filters.append(f"pi_film_model IN ({placeholders})")
                for i, model in enumerate(models):
                    params[f'model_{i}'] = model
                print(f"✅ [DEBUG] 添加 pi_film_model 筛选: {models}")

        # ✅ 石墨型号筛选
        graphite_model = request.args.get('graphite_model')
        print(f"📊 [DEBUG] graphite_model 原始值: {repr(graphite_model)}")
        if graphite_model:
            models = [m.strip() for m in graphite_model.split(',') if m.strip()]
            print(f"📊 [DEBUG] 解析后的 graphite models: {models}")
            if models:
                placeholders = ','.join([f':graphite_model_{i}' for i in range(len(models))])
                filters.append(f"graphite_model IN ({placeholders})")
                for i, model in enumerate(models):
                    params[f'graphite_model_{i}'] = model
                print(f"✅ [DEBUG] 添加 graphite_model 筛选: {models}")

        # ✅ 烧结地点筛选 - 新增这部分！
        sintering_location = request.args.get('sintering_location')
        print(f"📊 [DEBUG] sintering_location 原始值: {repr(sintering_location)}")
        if sintering_location:
            locations = [loc.strip() for loc in sintering_location.split(',') if loc.strip()]
            print(f"📊 [DEBUG] 解析后的 locations: {locations}")
            if locations:
                placeholders = ','.join([f':location_{i}' for i in range(len(locations))])
                filters.append(f"sintering_location IN ({placeholders})")
                for i, loc in enumerate(locations):
                    params[f'location_{i}'] = loc
                print(f"✅ [DEBUG] 添加 sintering_location 筛选: {locations}")

        # 拼接 SQL
        if filters:
            query += " AND " + " AND ".join(filters)
            print(f"✅ [DEBUG] 添加了 {len(filters)} 个筛选条件")
        else:
            print("ℹ️ [DEBUG] 无额外筛选条件")

        # ===== 打印最终SQL =====
        print("=" * 60)
        print("📊 [DEBUG] 最终SQL查询:")
        print(query)
        print(f"📊 [DEBUG] 参数字典: {params}")
        print("=" * 60)

        # 5. 执行查询
        try:
            result = db.session.execute(text(query), params)
            raw_data = [dict(row._mapping) for row in result]
            print(f"✅ [DEBUG] SQL执行成功，返回 {len(raw_data)} 条数据")
            
            if len(raw_data) > 0:
                print(f"📊 [DEBUG] 第一条数据示例: {raw_data[0]}")
        except Exception as sql_error:
            print("=" * 60)
            print(f"❌ [DEBUG] SQL执行失败")
            print(f"   错误类型: {type(sql_error).__name__}")
            print(f"   错误信息: {str(sql_error)}")
            print("=" * 60)
            import traceback
            traceback.print_exc()
            raise
        
        # 6. 数据清洗
        exclude_zero = request.args.get('exclude_zero', 'true').lower() == 'true'
        enable_outlier = request.args.get('enable_outlier_detection', 'true').lower() == 'true'
        outlier_method = request.args.get('outlier_method', 'iqr')
        
        print(f"📊 [DEBUG] 数据清洗参数: exclude_zero={exclude_zero}, enable_outlier={enable_outlier}, method={outlier_method}")
        
        cleaned_result = clean_analysis_data(
            raw_data,
            exclude_zero=exclude_zero,
            enable_outlier_detection=enable_outlier,
            outlier_method=outlier_method
        )
        
        print(f"✅ [DEBUG] 数据清洗完成，有效数据: {len(cleaned_result['data'])} 条")
        
        # 7. 生成报告
        cleaning_report = generate_cleaning_report(cleaned_result['statistics'])
        
        print("✅ [DEBUG] 分析报告生成成功")
        print("=" * 60)
        
        return jsonify({
            'data': cleaned_result['data'],
            'metadata': {
                'x_field': x_field,
                'x_label': FIELD_METADATA[x_field]['label'],
                'x_unit': FIELD_METADATA[x_field]['unit'],
                'y_field': y_field,
                'y_label': FIELD_METADATA[y_field]['label'],
                'y_unit': FIELD_METADATA[y_field]['unit']
            },
            'statistics': cleaned_result['statistics'],
            'cleaning_report': cleaning_report
        }), 200
    
    except Exception as e:
        import traceback
        print("=" * 60)
        print("❌ [DEBUG] 数据分析查询失败")
        print(f"   错误类型: {type(e).__name__}")
        print(f"   错误信息: {str(e)}")
        print("   完整堆栈:")
        traceback.print_exc()
        print("=" * 60)
        
        return jsonify({
            'error': 'Data retrieval failed',
            'message': str(e),
            'error_type': type(e).__name__
        }), 500


@analysis_bp.route('/linear-regression', methods=['POST'])
@jwt_required()
@role_required(['admin', 'engineer'])
def linear_regression():
    """
    执行线性回归分析
    
    Request Body:
        {
            "data": [
                {"x": 2400, "y": 1050},
                {"x": 2600, "y": 1280},
                ...
            ]
        }
    
    Returns:
        {
            "equation": "y = 0.52x - 195.6",
            "slope": 0.52,
            "intercept": -195.6,
            "r_squared": 0.956,
            "p_value": 0.0001,
            "n": 25,
            "predictions": [...],
            "quality_assessment": {...}
        }
    """
    try:
        # 1. 获取数据
        request_data = request.get_json()
        data_points = request_data.get('data', [])
        
        if not data_points:
            return jsonify({
                'error': 'No data provided',
                'message': '没有提供数据点'
            }), 400
        
        # 2. 提取X和Y值（只使用有效数据）
        valid_points = [p for p in data_points if isinstance(p, dict) and 'x' in p and 'y' in p]
        
        if len(valid_points) < 2:
            return jsonify({
                'error': 'Insufficient data',
                'message': '数据点不足，至少需要2个点进行回归分析',
                'data_count': len(valid_points)
            }), 400
        
        x_values = np.array([p['x'] for p in valid_points], dtype=float)
        y_values = np.array([p['y'] for p in valid_points], dtype=float)
        
        # 3. 边缘情况检查
        if np.all(x_values == x_values[0]):
            return jsonify({
                'error': 'No variance in X',
                'message': 'X轴数据无变化，无法计算回归方程',
                'x_value': float(x_values[0])
            }), 400
        
        if np.all(y_values == y_values[0]):
            return jsonify({
                'error': 'No variance in Y',
                'message': 'Y轴数据无变化，无法计算回归方程',
                'y_value': float(y_values[0])
            }), 400
        
        # 4. 执行线性回归
        try:
            slope, intercept, r_value, p_value, std_err = stats.linregress(x_values, y_values)
        except Exception as e:
            return jsonify({
                'error': 'Regression calculation failed',
                'message': f'回归计算失败: {str(e)}'
            }), 500
        
        # 5. 计算R²
        r_squared = r_value ** 2
        
        # 6. 生成回归方程字符串
        if intercept >= 0:
            equation = f"y = {slope:.4f}x + {intercept:.4f}"
        else:
            equation = f"y = {slope:.4f}x - {abs(intercept):.4f}"
        
        # 7. 生成预测点（用于绘制回归线）
        x_min, x_max = np.min(x_values), np.max(x_values)
        x_range = x_max - x_min
        x_pred = np.linspace(x_min - 0.1 * x_range, x_max + 0.1 * x_range, 50)
        y_pred = slope * x_pred + intercept
        
        predictions = [
            {'x': float(x), 'y': float(y)}
            for x, y in zip(x_pred, y_pred)
        ]
        
        # 8. 质量评估
        quality_assessment = {
            'fit_quality': _assess_fit_quality(r_squared),
            'significance': _assess_significance(p_value)
        }
        
        # 9. 返回结果
        return jsonify({
            'equation': equation,
            'slope': float(slope),
            'intercept': float(intercept),
            'r_squared': float(r_squared),
            'p_value': float(p_value),
            'std_err': float(std_err),
            'n': len(valid_points),
            'predictions': predictions,
            'quality_assessment': quality_assessment
        }), 200
    
    except Exception as e:
        return jsonify({
            'error': 'Analysis failed',
            'message': str(e)
        }), 500


def _assess_fit_quality(r_squared: float) -> str:
    """评估拟合质量"""
    if r_squared >= 0.9:
        return 'excellent'
    elif r_squared >= 0.75:
        return 'good'
    elif r_squared >= 0.5:
        return 'fair'
    else:
        return 'poor'


def _assess_significance(p_value: float) -> str:
    """评估显著性"""
    if p_value < 0.001:
        return 'highly_significant'
    elif p_value < 0.05:
        return 'moderately_significant'
    else:
        return 'not_significant'


@analysis_bp.route('/field-options', methods=['GET'])
@jwt_required()
def get_field_options():
    """
    获取可用于分析的字段列表
    
    Returns:
        {
            'fields': [
                {
                    'value': 'graphite_max_temp',
                    'label': '石墨化最高温度',
                    'unit': '℃',
                    'category': 'process'
                },
                ...
            ]
        }
    """
    fields = []
    
    # 分类定义
    categories = {
        'carbonization': '碳化参数',
        'graphitization': '石墨化参数',
        'product': '成品参数',
        'pi_film': 'PI膜参数',
        'rolling': '压延参数',
        'basic': '基本参数'
    }
    
    # ✅ 字段分类修正（2025-12-31）
    field_categories = {
        # 碳化参数
        'carbon_max_temp': 'carbonization',
        'carbon_total_time': 'carbonization',
        'carbon_yield_rate': 'carbonization',
        
        # 石墨化参数
        'graphite_max_temp': 'graphitization',
        'graphite_total_time': 'graphitization',
        'graphite_yield_rate': 'graphitization',
        'inner_foaming_thickness': 'graphitization',
        'outer_foaming_thickness': 'graphitization',
        'shrinkage_ratio': 'graphitization',  # ✅ 修正：从product移至graphitization
        
        # 成品参数
        'thermal_conductivity': 'product',
        'avg_density': 'product',
        'avg_thickness': 'product',
        'specific_heat': 'product',  # ✅ 新增
        'cohesion': 'product',
        'peel_strength': 'product',
        'bond_strength': 'product',  # ✅ 新增
        
        # PI膜参数
        'pi_film_thickness': 'pi_film',
        
        # 基本参数
        'graphite_model': 'basic'
    }
    
    for field_name, metadata in FIELD_METADATA.items():
        fields.append({
            'value': field_name,
            'label': metadata['label'],
            'unit': metadata['unit'],
            'category': field_categories.get(field_name, 'other'),
            'category_label': categories.get(field_categories.get(field_name, 'other'), '其他')
        })
    
    return jsonify({'fields': fields}), 200

# ========================================
# 配置管理 API
# ========================================

@analysis_bp.route('/configs', methods=['POST'])
@jwt_required()
@role_required(['admin', 'engineer'])
def save_config():
    """
    保存分析配置
    
    Request Body:
        {
            "name": "石墨化温度 vs 比热",
            "description": "研究石墨化温度对比热的影响（可选）",
            "config": {
                "x_axis": {
                    "field": "graphite_max_temp", 
                    "label": "石墨化最高温度", 
                    "unit": "℃"
                },
                "y_axis": {
                    "field": "specific_heat", 
                    "label": "比热", 
                    "unit": "J/g·K"
                },
                "filters": {
                    "date_start": "2024-01-01",
                    "date_end": "2024-12-31",
                    "pi_film_models": ["GH-100"],
                    "graphite_models": ["SGF-010"],
                    "sintering_locations": ["DG"]
                },
                "cleaning_options": {
                    "exclude_zero": true,
                    "enable_outlier_detection": true,
                    "outlier_method": "iqr"
                }
            }
        }
    
    Returns:
        {
            "id": 1,
            "name": "...",
            "message": "配置保存成功"
        }
    """
    try:
        # 1. 获取当前用户
        current_user_id = get_jwt_identity()
        
        # 2. 获取请求数据
        data = request.get_json()
        name = data.get('name')
        description = data.get('description', '')
        config_data = data.get('config')
        
        # 3. 验证必填字段
        if not name or not config_data:
            return jsonify({
                'error': 'Missing required fields',
                'message': '配置名称和配置数据不能为空'
            }), 400
        
        # 4. 验证配置数据结构
        required_keys = ['x_axis', 'y_axis']
        if not all(key in config_data for key in required_keys):
            return jsonify({
                'error': 'Invalid config structure',
                'message': '配置数据必须包含 x_axis 和 y_axis'
            }), 400
        
        # 5. 检查配置名称是否重复（同一用户）
        existing = AnalysisConfig.query.filter_by(
            name=name,
            created_by=current_user_id
        ).first()
        
        if existing:
            return jsonify({
                'error': 'Config name exists',
                'message': f'配置名称"{name}"已存在，请使用其他名称'
            }), 400
        
        # 6. 创建配置记录
        # ✅ JSON字段会自动保存所有新字段：
        #    - filters.graphite_models
        #    - y_axis.field = 'specific_heat' 或 'bond_strength' 等
        config = AnalysisConfig(
            name=name,
            description=description,
            config_data=config_data,
            created_by=current_user_id
        )
        
        db.session.add(config)
        db.session.commit()
        
        print(f"✅ 配置保存成功: ID={config.id}, name={config.name}, user={current_user_id}")
        
        return jsonify({
            'id': config.id,
            'name': config.name,
            'message': '配置保存成功'
        }), 201
    
    except Exception as e:
        db.session.rollback()
        print(f"❌ 保存配置失败: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'error': 'Save failed',
            'message': str(e)
        }), 500


@analysis_bp.route('/configs', methods=['GET'])
@jwt_required()
@role_required(['admin', 'engineer'])
def get_configs():
    """
    获取用户的分析配置列表
    
    Query Parameters:
        - page: 页码（默认1）
        - per_page: 每页数量（默认20）
    
    Returns:
        {
            "configs": [
                {
                    "id": 1,
                    "name": "...",
                    "description": "...",
                    "config": {
                        "x_axis": {...},
                        "y_axis": {...},
                        "filters": {
                            "graphite_models": ["SGF-010"],
                            ...
                        },
                        "cleaning_options": {...}
                    },
                    "view_count": 10,
                    "last_run_at": "2024-12-30T10:30:00",
                    "created_at": "2024-12-29T08:00:00"
                }
            ],
            "total": 5,
            "page": 1,
            "per_page": 20
        }
    """
    try:
        # 1. 获取当前用户
        current_user_id = get_jwt_identity()
        
        # 2. 获取分页参数
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        # 3. 查询用户的配置（按创建时间倒序）
        query = AnalysisConfig.query.filter_by(created_by=current_user_id)
        
        # 4. 分页
        pagination = query.order_by(AnalysisConfig.created_at.desc()).paginate(
            page=page,
            per_page=per_page,
            error_out=False
        )
        
        # 5. 转换为字典
        configs = [config.to_dict() for config in pagination.items]
        
        print(f"✅ 查询配置列表成功: user={current_user_id}, count={len(configs)}")
        
        return jsonify({
            'configs': configs,
            'total': pagination.total,
            'page': page,
            'per_page': per_page,
            'pages': pagination.pages
        }), 200
    
    except Exception as e:
        print(f"❌ 查询配置列表失败: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'error': 'Query failed',
            'message': str(e)
        }), 500


@analysis_bp.route('/configs/<int:config_id>', methods=['GET'])
@jwt_required()
@role_required(['admin', 'engineer'])
def get_config(config_id):
    """
    获取单个配置详情
    
    同时更新查看次数和最后运行时间
    
    Returns:
        {
            "id": 1,
            "name": "...",
            "description": "...",
            "config": {
                "x_axis": {...},
                "y_axis": {"field": "specific_heat", ...},
                "filters": {"graphite_models": ["SGF-010"], ...}
            },
            "view_count": 11,
            "last_run_at": "2024-12-30T10:30:00"
        }
    """
    try:
        # 1. 获取当前用户
        current_user_id = get_jwt_identity()
        
        # 2. 查询配置
        config = AnalysisConfig.query.filter_by(
            id=config_id,
            created_by=current_user_id
        ).first()
        
        if not config:
            return jsonify({
                'error': 'Config not found',
                'message': '配置不存在或无权访问'
            }), 404
        
        # 3. 更新查看次数和最后运行时间
        config.view_count += 1
        config.last_run_at = datetime.utcnow()
        db.session.commit()
        
        print(f"✅ 查询配置成功: ID={config_id}, view_count={config.view_count}")
        
        return jsonify(config.to_dict()), 200
    
    except Exception as e:
        db.session.rollback()
        print(f"❌ 查询配置失败: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'error': 'Query failed',
            'message': str(e)
        }), 500


@analysis_bp.route('/configs/<int:config_id>', methods=['DELETE'])
@jwt_required()
@role_required(['admin', 'engineer'])
def delete_config(config_id):
    """
    删除分析配置
    
    Returns:
        {
            "message": "配置删除成功"
        }
    """
    try:
        # 1. 获取当前用户
        current_user_id = get_jwt_identity()
        
        # 2. 查询配置
        config = AnalysisConfig.query.filter_by(
            id=config_id,
            created_by=current_user_id
        ).first()
        
        if not config:
            return jsonify({
                'error': 'Config not found',
                'message': '配置不存在或无权访问'
            }), 404
        
        # 3. 删除配置
        config_name = config.name
        db.session.delete(config)
        db.session.commit()
        
        print(f"✅ 配置删除成功: ID={config_id}, name={config_name}")
        
        return jsonify({
            'message': '配置删除成功'
        }), 200
    
    except Exception as e:
        db.session.rollback()
        print(f"❌ 删除配置失败: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'error': 'Delete failed',
            'message': str(e)
        }), 500


@analysis_bp.route('/configs/<int:config_id>', methods=['PUT'])
@jwt_required()
@role_required(['admin', 'engineer'])
def update_config(config_id):
    """
    更新分析配置
    
    Request Body:
        {
            "name": "新的配置名称（可选）",
            "description": "新的描述（可选）",
            "config": {
                "x_axis": {...},
                "y_axis": {...},
                "filters": {
                    "graphite_models": ["SGF-015"],
                    ...
                },
                "cleaning_options": {...}
            }
        }
    
    Returns:
        {
            "id": 1,
            "name": "...",
            "message": "配置更新成功"
        }
    """
    try:
        # 1. 获取当前用户
        current_user_id = get_jwt_identity()
        
        # 2. 查询配置
        config = AnalysisConfig.query.filter_by(
            id=config_id,
            created_by=current_user_id
        ).first()
        
        if not config:
            return jsonify({
                'error': 'Config not found',
                'message': '配置不存在或无权访问'
            }), 404
        
        # 3. 获取更新数据
        data = request.get_json()
        
        # 4. 更新字段
        if 'name' in data:
            # 检查新名称是否重复
            new_name = data['name']
            existing = AnalysisConfig.query.filter_by(
                name=new_name,
                created_by=current_user_id
            ).filter(AnalysisConfig.id != config_id).first()
            
            if existing:
                return jsonify({
                    'error': 'Config name exists',
                    'message': f'配置名称"{new_name}"已存在'
                }), 400
            
            config.name = new_name
        
        if 'description' in data:
            config.description = data['description']
        
        if 'config' in data:
            # ✅ JSON字段会自动保存所有更新的字段
            config.config_data = data['config']
        
        # 5. 保存更新
        db.session.commit()
        
        print(f"✅ 配置更新成功: ID={config_id}, name={config.name}")
        
        return jsonify({
            'id': config.id,
            'name': config.name,
            'message': '配置更新成功'
        }), 200
    
    except Exception as e:
        db.session.rollback()
        print(f"❌ 更新配置失败: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'error': 'Update failed',
            'message': str(e)
        }), 500