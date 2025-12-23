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

# 创建蓝图（不设置url_prefix，在__init__.py中统一设置）
analysis_bp = Blueprint('analysis', __name__)

# 字段元数据（中文名称和单位）
FIELD_METADATA = {
    # 碳化参数 - ✅ 修正为数据库实际字段名
    'carbon_max_temp': {'label': '碳化最高温度', 'unit': '℃'},
    'carbon_total_time': {'label': '碳化总时长', 'unit': 'min'},
    'carbon_yield_rate': {'label': '碳化收率', 'unit': '%'},
    
    # 石墨化参数 - ✅ 修正为数据库实际字段名
    'graphite_max_temp': {'label': '石墨化最高温度', 'unit': '℃'},
    'graphite_total_time': {'label': '石墨化总时长', 'unit': 'min'},
    'graphite_yield_rate': {'label': '石墨化收率', 'unit': '%'},
    
    # 成品参数 - ✅ 只保留数据库存在的字段
    'thermal_conductivity': {'label': '导热系数', 'unit': 'W/m·K'},
    'avg_density': {'label': '平均密度', 'unit': 'g/cm³'},
    'avg_thickness': {'label': '平均厚度', 'unit': 'μm'},
    'shrinkage_ratio': {'label': '收缩比', 'unit': '%'},
    'cohesion': {'label': '内聚力', 'unit': 'MPa'},
    'peel_strength': {'label': '剥离强度', 'unit': 'N/cm'},
    
    # PI膜参数
    'pi_film_thickness': {'label': 'PI膜厚度', 'unit': 'μm'}
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
        
        # 3. 构建基础 SQL（✅ 修复：改为 submitted, completed）
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
        
        # 4. 动态添加筛选条件 - ✅ 核心修复：检查 None 和空字符串
        filters = []
        params = {}
        
        # 日期筛选
        date_start = request.args.get('date_start')
        print(f"📊 [DEBUG] date_start 原始值: {repr(date_start)}")
        if date_start and date_start.strip():  # 确保不是 None 且不是空字符串
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
            # 过滤掉空项
            models = [m.strip() for m in pi_film_model.split(',') if m.strip()]
            print(f"📊 [DEBUG] 解析后的 models: {models}")
            if models:
                placeholders = ','.join([f':model_{i}' for i in range(len(models))])
                filters.append(f"pi_film_model IN ({placeholders})")
                for i, model in enumerate(models):
                    params[f'model_{i}'] = model
                print(f"✅ [DEBUG] 添加 pi_film_model 筛选: {models}")
        
        # 烧制地点筛选
        sintering_location = request.args.get('sintering_location')
        print(f"📊 [DEBUG] sintering_location 原始值: {repr(sintering_location)}")
        if sintering_location:
            locations = [l.strip() for l in sintering_location.split(',') if l.strip()]
            print(f"📊 [DEBUG] 解析后的 locations: {locations}")
            if locations:
                placeholders = ','.join([f':location_{i}' for i in range(len(locations))])
                filters.append(f"sintering_location IN ({placeholders})")
                for i, location in enumerate(locations):
                    params[f'location_{i}'] = location
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
            raise  # 重新抛出异常
        
        # 6. 后续数据清洗逻辑
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
        # ===== 完整的错误处理 =====
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
        # 检查X值是否有变化
        if np.all(x_values == x_values[0]):
            return jsonify({
                'error': 'No variance in X',
                'message': 'X轴数据无变化，无法计算回归方程',
                'x_value': float(x_values[0])
            }), 400
        
        # 检查Y值是否有变化
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
        'rolling': '压延参数'
    }
    
    # 字段分类
    field_categories = {
        'carbon_max_temp': 'carbonization',
        'carbon_total_time': 'carbonization',
        'carbon_yield_rate': 'carbonization',
        
        'graphite_max_temp': 'graphitization',
        'graphite_total_time': 'graphitization',
        'graphite_yield_rate': 'graphitization',
        
        'thermal_conductivity': 'product',
        'avg_density': 'product',
        'avg_thickness': 'product',
        'shrinkage_ratio': 'product',
        'cohesion': 'product',
        'peel_strength': 'product',
        
        'pi_film_thickness': 'pi_film'
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
