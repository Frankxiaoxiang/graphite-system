from flask import Blueprint, request, jsonify, make_response
from flask_jwt_extended import get_jwt_identity, verify_jwt_in_request
from app import db
from app.models.user import User
from app.models.experiment import (
    Experiment, ExperimentBasic, ExperimentPi, ExperimentLoose,
    ExperimentCarbon, ExperimentGraphite, ExperimentRolling, ExperimentProduct
)
from app.models.system_log import SystemLog
from app.utils.experiment_code import generate_experiment_code, validate_experiment_code_format
from app.utils.permissions import require_permission
from datetime import datetime
import csv
import io
import traceback

experiments_bp = Blueprint('experiments', __name__)

# ==========================================
# 🆕 新增：草稿保存 API - 手动控制验证
# ==========================================
@experiments_bp.route('/draft', methods=['POST', 'OPTIONS'])
def save_draft():
    """
    保存草稿 - 只需验证基本参数
    前端已生成实验编码，后端负责验证和存储
    """
    # 🔧 第一步：处理 OPTIONS 预检请求（必须在最前面）
    if request.method == 'OPTIONS':
        response = make_response('', 200)
        response.headers['Access-Control-Allow-Origin'] = request.headers.get('Origin', 'http://localhost:5173')
        response.headers['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
        response.headers['Access-Control-Max-Age'] = '3600'
        return response
    
    # 🔧 第二步：手动验证 JWT（POST 请求）
    print("\n" + "="*60)
    print("📥 收到草稿保存请求")
    print("="*60)
    
    try:
        # 检查 Authorization 头
        auth_header = request.headers.get('Authorization')
        print(f"🔑 Authorization 头: {auth_header[:50] if auth_header else 'None'}...")
        
        if not auth_header:
            print("❌ 错误：缺少 Authorization 头")
            return jsonify({'error': '缺少认证令牌'}), 401
        
        if not auth_header.startswith('Bearer '):
            print("❌ 错误：Authorization 头格式错误")
            return jsonify({'error': '认证令牌格式错误'}), 401
        
        # 验证 JWT Token
        print("🔐 开始验证 JWT Token...")
        verify_jwt_in_request()
        
        # ✅ 修改：get_jwt_identity() 返回字符串，转换为整数
        current_user_id_str = get_jwt_identity()
        current_user_id = int(current_user_id_str)
        
        print(f"✅ JWT 验证成功！用户 ID: {current_user_id} (type: {type(current_user_id).__name__})")
        
    except Exception as e:
        print(f"❌ JWT 验证失败：{type(e).__name__}")
        print(f"   错误详情：{str(e)}")
        traceback.print_exc()
        return jsonify({'error': f'认证失败: {str(e)}'}), 401
    
    # 🔧 第三步：保存草稿逻辑
    try:
        data = request.get_json()
        print(f"\n📦 收到数据：")
        print(f"   - 实验编码: {data.get('experiment_code', 'N/A')}")
        print(f"   - 客户名称: {data.get('customer_name', 'N/A')}")
        
        # 1. 验证基本参数（必填字段）
        required_basic_fields = [
            'pi_film_thickness', 'customer_type', 'customer_name', 'pi_film_model',
            'experiment_date', 'sintering_location', 'material_type_for_firing',
            'rolling_method', 'experiment_group', 'experiment_purpose'
        ]
        
        missing_fields = [field for field in required_basic_fields if not data.get(field)]
        if missing_fields:
            print(f"❌ 缺少必填字段: {missing_fields}")
            return jsonify({
                'error': '缺少必填字段',
                'missing_fields': missing_fields
            }), 400
        
        print("✅ 基本参数验证通过")
        
        # 2. 获取前端生成的实验编码
        experiment_code = data.get('experiment_code', '').strip()
        
        if not experiment_code:
            print("⚠️  前端未生成编码，后端生成中...")
            experiment_code = generate_experiment_code(data)
        
        print(f"🔖 实验编码: {experiment_code}")
        
        # 3. 验证实验编码格式
        is_valid, error_msg = validate_experiment_code_format(experiment_code)
        if not is_valid:
            print(f"❌ 编码格式错误: {error_msg}")
            return jsonify({'error': f'实验编码格式错误: {error_msg}'}), 400
        
        # 4. 检查实验编码唯一性
        existing = Experiment.query.filter_by(experiment_code=experiment_code).first()
        if existing:
            print(f"❌ 编码已存在: {experiment_code}")
            return jsonify({'error': f'实验编码 {experiment_code} 已存在，请修改参数'}), 400
        
        # 5. 创建实验主记录
        experiment = Experiment(
            experiment_code=experiment_code,
            status='draft',
            created_by=current_user_id,
            notes=data.get('notes', '')
        )
        db.session.add(experiment)
        db.session.flush()
        
        print(f"✅ 实验主记录已创建 - ID: {experiment.id}")
        
        # 6. 保存实验基础参数
        basic = ExperimentBasic(
            experiment_id=experiment.id,
            pi_film_thickness=data['pi_film_thickness'],
            customer_type=data['customer_type'],
            customer_name=data['customer_name'],
            pi_film_model=data['pi_film_model'],
            experiment_date=_parse_date(data['experiment_date']),
            sintering_location=data['sintering_location'],
            material_type_for_firing=data['material_type_for_firing'],
            rolling_method=data['rolling_method'],
            experiment_group=data['experiment_group'],
            experiment_purpose=data['experiment_purpose']
        )
        db.session.add(basic)
        
        # 7. 保存其他模块数据（如果有）
        _save_optional_modules(experiment.id, data)
        
        db.session.commit()
        
        print(f"✅ 草稿保存成功！")
        print(f"   - 实验 ID: {experiment.id}")
        print(f"   - 实验编码: {experiment_code}")
        print("="*60 + "\n")
        
        # 8. 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='save_draft',
            target_type='experiment',
            target_id=experiment.id,
            description=f'保存草稿 {experiment_code}',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': '草稿保存成功',
            'id': experiment.id,
            'experiment_code': experiment_code
        }), 201
        
    except Exception as e:
        db.session.rollback()
        print(f"❌ 保存草稿失败：{type(e).__name__}")
        print(f"   错误详情：{str(e)}")
        traceback.print_exc()
        print("="*60 + "\n")
        return jsonify({'error': f'保存草稿失败: {str(e)}'}), 500


# ==========================================
# 🔄 修改：原有的创建实验 API → 正式提交 API - 手动控制验证
# ==========================================
@experiments_bp.route('/', methods=['POST', 'OPTIONS'])
def create_experiment():
    """
    正式提交实验 - 验证所有必填字段
    前端已生成实验编码，后端负责验证和存储
    
    注意：这个函数已被重构，现在需要所有40个必填字段
    """
    # 🔧 第一步：处理 OPTIONS 预检请求（必须在最前面）
    if request.method == 'OPTIONS':
        response = make_response('', 200)
        response.headers['Access-Control-Allow-Origin'] = request.headers.get('Origin', 'http://localhost:5173')
        response.headers['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
        response.headers['Access-Control-Max-Age'] = '3600'
        return response
    
    # 🔧 第二步：手动验证 JWT（POST 请求）
    print("\n" + "="*60)
    print("📥 收到实验提交请求")
    print("="*60)
    
    try:
        # 检查 Authorization 头
        auth_header = request.headers.get('Authorization')
        print(f"🔑 Authorization 头: {auth_header[:50] if auth_header else 'None'}...")
        
        if not auth_header:
            print("❌ 错误：缺少 Authorization 头")
            return jsonify({'error': '缺少认证令牌'}), 401
        
        if not auth_header.startswith('Bearer '):
            print("❌ 错误：Authorization 头格式错误")
            return jsonify({'error': '认证令牌格式错误'}), 401
        
        # 验证 JWT Token
        print("🔐 开始验证 JWT Token...")
        verify_jwt_in_request()
        
        # ✅ 修改：转换为整数
        current_user_id_str = get_jwt_identity()
        current_user_id = int(current_user_id_str)
        
        print(f"✅ JWT 验证成功！用户 ID: {current_user_id} (type: {type(current_user_id).__name__})")
        
    except Exception as e:
        print(f"❌ JWT 验证失败：{type(e).__name__}")
        print(f"   错误详情：{str(e)}")
        traceback.print_exc()
        return jsonify({'error': f'认证失败: {str(e)}'}), 401
    
    # 🔧 第三步：提交实验逻辑
    try:
        data = request.get_json()
        print(f"\n📦 收到数据：")
        print(f"   - 实验编码: {data.get('experiment_code', 'N/A')}")
        print(f"   - 客户名称: {data.get('customer_name', 'N/A')}")
        
        # 1. 验证所有必填字段（40个）
        validation_result = _validate_all_required_fields(data)
        if not validation_result['valid']:
            print(f"❌ 缺少必填字段: {validation_result['missing_fields']}")
            return jsonify({
                'error': '缺少必填字段',
                'missing_fields': validation_result['missing_fields']
            }), 400
        
        print("✅ 所有必填字段验证通过")
        
        # 2. 获取前端生成的实验编码
        experiment_code = data.get('experiment_code', '').strip()
        
        if not experiment_code:
            print("⚠️  前端未生成编码，后端生成中...")
            experiment_code = generate_experiment_code(data)
        
        print(f"🔖 实验编码: {experiment_code}")
        
        # 3. 验证实验编码格式
        is_valid, error_msg = validate_experiment_code_format(experiment_code)
        if not is_valid:
            print(f"❌ 编码格式错误: {error_msg}")
            return jsonify({'error': f'实验编码格式错误: {error_msg}'}), 400
        
        # 4. 检查实验编码唯一性
        existing = Experiment.query.filter_by(experiment_code=experiment_code).first()
        if existing:
            print(f"❌ 编码已存在: {experiment_code}")
            return jsonify({'error': f'实验编码 {experiment_code} 已存在，请修改参数'}), 400
        
        # 5. 创建实验主记录
        experiment = Experiment(
            experiment_code=experiment_code,
            status='submitted',
            created_by=current_user_id,
            submitted_at=datetime.utcnow(),
            notes=data.get('notes', '')
        )
        db.session.add(experiment)
        db.session.flush()
        
        print(f"✅ 实验主记录已创建 - ID: {experiment.id}")
        
        # 6. 保存所有模块数据
        _save_all_modules(experiment.id, data)
        
        db.session.commit()
        
        print(f"✅ 实验提交成功！")
        print(f"   - 实验 ID: {experiment.id}")
        print(f"   - 实验编码: {experiment_code}")
        print("="*60 + "\n")
        
        # 7. 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='submit_experiment',
            target_type='experiment',
            target_id=experiment.id,
            description=f'提交实验 {experiment_code}',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': '实验提交成功',
            'id': experiment.id,
            'experiment_code': experiment_code
        }), 201
        
    except Exception as e:
        db.session.rollback()
        print(f"❌ 提交实验失败：{type(e).__name__}")
        print(f"   错误详情：{str(e)}")
        traceback.print_exc()
        print("="*60 + "\n")
        return jsonify({'error': f'提交实验失败: {str(e)}'}), 500


# ==========================================
# ✅ 保留：原有的其他 API（已修改）
# ==========================================
@experiments_bp.route('/', methods=['GET'])
@require_permission('view_all')
def get_experiments():
    """获取实验列表"""
    try:
        # ✅ 修改：转换为整数
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        status = request.args.get('status')
        
        # 构建查询
        query = Experiment.query
        
        # 权限控制：普通用户只能看自己的实验
        if user.role == 'user':
            query = query.filter_by(created_by=current_user_id)
        
        # 状态筛选
        if status:
            query = query.filter_by(status=status)
        
        # 分页
        experiments = query.order_by(Experiment.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        result = []
        for exp in experiments.items:
            exp_data = exp.to_dict()
            exp_data['creator_name'] = exp.creator.real_name or exp.creator.username
            
            # 添加基础信息
            if exp.basic:
                exp_data['customer_name'] = exp.basic.customer_name
                exp_data['experiment_date'] = exp.basic.experiment_date.isoformat() if exp.basic.experiment_date else None
            
            result.append(exp_data)
        
        return jsonify({
            'experiments': result,
            'pagination': {
                'page': experiments.page,
                'pages': experiments.pages,
                'per_page': experiments.per_page,
                'total': experiments.total
            }
        }), 200       
    except Exception as e:
        return jsonify({'error': '获取实验列表失败'}), 500


@experiments_bp.route('/<int:experiment_id>', methods=['GET'])
@require_permission('view_all')
def get_experiment(experiment_id):
    """获取实验详情"""
    try:
        # ✅ 修改：转换为整数
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        experiment = Experiment.query.get(experiment_id)
        if not experiment:
            return jsonify({'error': '实验不存在'}), 404
        
        # 权限检查：普通用户只能查看自己的实验
        if user.role == 'user' and experiment.created_by != current_user_id:
            return jsonify({'error': '无权访问此实验'}), 403
        
        # 构建完整的实验数据
        experiment_data = experiment.to_dict()
        experiment_data['creator_name'] = experiment.creator.real_name or experiment.creator.username
        
        # 添加各模块数据
        if experiment.basic:
            experiment_data['basic'] = {
                'pi_film_thickness': float(experiment.basic.pi_film_thickness) if experiment.basic.pi_film_thickness else None,
                'customer_type': experiment.basic.customer_type,
                'customer_name': experiment.basic.customer_name,
                'pi_film_model': experiment.basic.pi_film_model,
                'experiment_date': experiment.basic.experiment_date.isoformat() if experiment.basic.experiment_date else None,
                'sintering_location': experiment.basic.sintering_location,
                'material_type_for_firing': experiment.basic.material_type_for_firing,
                'rolling_method': experiment.basic.rolling_method,
                'experiment_group': experiment.basic.experiment_group,
                'experiment_purpose': experiment.basic.experiment_purpose
            }
        
        if experiment.pi:
            experiment_data['pi'] = {
                'pi_manufacturer': experiment.pi.pi_manufacturer,
                'pi_thickness_detail': float(experiment.pi.pi_thickness_detail) if experiment.pi.pi_thickness_detail else None,
                'pi_model_detail': experiment.pi.pi_model_detail,
                'pi_width': float(experiment.pi.pi_width) if experiment.pi.pi_width else None,
                'batch_number': experiment.pi.batch_number,
                'pi_weight': float(experiment.pi.pi_weight) if experiment.pi.pi_weight else None
            }
        
        # 添加其他模块数据（碳化、石墨化、压延、成品）
        # 这里可以继续添加其他模块的数据转换
        
        return jsonify({'experiment': experiment_data}), 200
        
    except Exception as e:
        return jsonify({'error': '获取实验详情失败'}), 500


@experiments_bp.route('/<int:experiment_id>', methods=['PUT'])
@require_permission('edit_all')
def update_experiment(experiment_id):
    """更新实验数据"""
    try:
        # ✅ 修改：转换为整数
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        experiment = Experiment.query.get(experiment_id)
        if not experiment:
            return jsonify({'error': '实验不存在'}), 404
        
        # 权限检查
        if user.role == 'user' and experiment.created_by != current_user_id:
            return jsonify({'error': '无权修改此实验'}), 403
        
        data = request.get_json()
        
        # 更新实验状态
        if 'status' in data:
            experiment.status = data['status']
            if data['status'] == 'submitted':
                experiment.submitted_at = datetime.utcnow()
        
        # 更新各模块数据
        modules = ['basic', 'pi', 'loose', 'carbon', 'graphite', 'rolling', 'product']
        model_mapping = {
            'basic': ExperimentBasic,
            'pi': ExperimentPi,
            'loose': ExperimentLoose,
            'carbon': ExperimentCarbon,
            'graphite': ExperimentGraphite,
            'rolling': ExperimentRolling,
            'product': ExperimentProduct
        }
        
        for module in modules:
            if module in data:
                model_class = model_mapping[module]
                module_data = data[module]
                
                # 查找或创建模块实例
                module_instance = model_class.query.filter_by(experiment_id=experiment.id).first()
                if not module_instance:
                    module_instance = model_class(experiment_id=experiment.id)
                    db.session.add(module_instance)
                
                # 更新字段
                for key, value in module_data.items():
                    if hasattr(module_instance, key):
                        setattr(module_instance, key, value)
        
        experiment.updated_at = datetime.utcnow()
        db.session.commit()
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='update_experiment',
            target_type='experiment',
            target_id=experiment.id,
            description=f'更新实验 {experiment.experiment_code}',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': '实验更新成功',
            'experiment': experiment.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'更新实验失败: {str(e)}'}), 500


@experiments_bp.route('/<int:experiment_id>', methods=['DELETE'])
@require_permission('delete_all')
def delete_experiment(experiment_id):
    """删除实验"""
    try:
        # ✅ 修改：转换为整数
        current_user_id = int(get_jwt_identity())
        
        experiment = Experiment.query.get(experiment_id)
        if not experiment:
            return jsonify({'error': '实验不存在'}), 404
        
        experiment_code = experiment.experiment_code
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='delete_experiment',
            target_type='experiment',
            target_id=experiment.id,
            description=f'删除实验 {experiment_code}',
            ip_address=request.remote_addr
        )
        
        db.session.delete(experiment)
        db.session.commit()
        
        return jsonify({'message': '实验删除成功'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '删除实验失败'}), 500


@experiments_bp.route('/export', methods=['POST'])
@require_permission('export_all')
def export_experiments():
    """导出实验数据"""
    try:
        # ✅ 修改：转换为整数
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        data = request.get_json()
        experiment_ids = data.get('experiment_ids', [])
        
        if not experiment_ids:
            return jsonify({'error': '请选择要导出的实验'}), 400
        
        # 构建查询
        query = Experiment.query.filter(Experiment.id.in_(experiment_ids))
        
        # 权限控制：普通用户只能导出自己的实验
        if user.role == 'user':
            query = query.filter_by(created_by=current_user_id)
        
        experiments = query.all()
        
        # 生成CSV数据
        output = io.StringIO()
        writer = csv.writer(output)
        
        # 写入表头
        headers = [
            '实验编码', '客户名称', '实验日期', '状态', '创建人',
            'PI膜厚度', 'PI膜型号', '碳化最高温度', '石墨化最高温度',
            '成品厚度', '平均密度', '导热系数'
        ]
        writer.writerow(headers)
        
        # 写入数据
        for exp in experiments:
            row = [
                exp.experiment_code,
                exp.basic.customer_name if exp.basic else '',
                exp.basic.experiment_date.strftime('%Y-%m-%d') if exp.basic and exp.basic.experiment_date else '',
                exp.status,
                exp.creator.real_name or exp.creator.username,
                exp.basic.pi_film_thickness if exp.basic else '',
                exp.basic.pi_film_model if exp.basic else '',
                exp.carbon.carbon_max_temp if exp.carbon else '',
                exp.graphite.graphite_max_temp if exp.graphite else '',
                exp.product.avg_thickness if exp.product else '',
                exp.product.avg_density if exp.product else '',
                exp.product.thermal_conductivity if exp.product else ''
            ]
            writer.writerow(row)
        
        csv_content = output.getvalue()
        output.close()
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='export_experiments',
            description=f'导出 {len(experiments)} 个实验数据',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'csv_content': csv_content,
            'filename': f'experiments_export_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv'
        }), 200
        
    except Exception as e:
        return jsonify({'error': '导出失败'}), 500


# ==========================================
# 🆕 新增：辅助函数
# ==========================================
def _validate_all_required_fields(data):
    """验证所有必填字段（40个）"""
    required_fields = [
        # 实验设计参数 (10个)
        'pi_film_thickness', 'customer_type', 'customer_name', 'pi_film_model',
        'experiment_date', 'sintering_location', 'material_type_for_firing',
        'rolling_method', 'experiment_group', 'experiment_purpose',
        
        # PI膜参数 (4个)
        'pi_manufacturer', 'pi_thickness_detail', 'pi_model_detail', 'pi_weight',
        
        # 碳化参数 (7个)
        'carbon_furnace_num', 'carbon_batch_num', 'carbon_max_temp',
        'carbon_film_thickness', 'carbon_total_time', 'carbon_weight', 'carbon_yield_rate',
        
        # 石墨化参数 (9个)
        'graphite_furnace_num', 'pressure_value', 'graphite_max_temp',
        'foam_thickness', 'graphite_width', 'shrinkage_ratio',
        'graphite_total_time', 'graphite_weight', 'graphite_yield_rate',
        
        # 产品参数 (10个)
        'product_avg_thickness', 'product_spec', 'product_avg_density',
        'thermal_diffusivity', 'thermal_conductivity', 'specific_heat',
        'cohesion', 'peel_strength', 'roughness', 'appearance_description'
    ]
    
    missing_fields = []
    for field in required_fields:
        value = data.get(field)
        if value is None or value == '':
            missing_fields.append(field)
    
    return {
        'valid': len(missing_fields) == 0,
        'missing_fields': missing_fields
    }


def _save_optional_modules(experiment_id, data):
    """保存可选模块数据（草稿时使用）"""
    
    # PI膜参数
    if any(data.get(f'pi_{key}') for key in ['manufacturer', 'thickness_detail', 'model_detail', 'width', 'batch_number', 'weight']):
        pi = ExperimentPi(
            experiment_id=experiment_id,
            pi_manufacturer=data.get('pi_manufacturer'),
            pi_thickness_detail=data.get('pi_thickness_detail'),
            pi_model_detail=data.get('pi_model_detail'),
            pi_width=data.get('pi_width'),
            batch_number=data.get('batch_number'),
            pi_weight=data.get('pi_weight')
        )
        db.session.add(pi)
    
    # 松卷参数
    if any(data.get(key) for key in ['core_tube_type', 'loose_gap_inner', 'loose_gap_middle', 'loose_gap_outer']):
        loose = ExperimentLoose(
            experiment_id=experiment_id,
            core_tube_type=data.get('core_tube_type'),
            loose_gap_inner=data.get('loose_gap_inner'),
            loose_gap_middle=data.get('loose_gap_middle'),
            loose_gap_outer=data.get('loose_gap_outer')
        )
        db.session.add(loose)
    
    # 碳化参数
    if data.get('carbon_furnace_num'):
        carbon = ExperimentCarbon(
            experiment_id=experiment_id,
            carbon_furnace_number=data.get('carbon_furnace_num'),
            carbon_furnace_batch=data.get('carbon_batch_num'),
            boat_model=data.get('boat_model'),
            wrap_type=data.get('wrap_type'),
            vacuum_degree=data.get('vacuum_degree'),
            carbon_power=data.get('carbon_power'),
            carbon_start_time=_parse_datetime(data.get('carbon_start_time')),
            carbon_end_time=_parse_datetime(data.get('carbon_end_time')),
            carbon_temp1=data.get('carbon_temp1'),
            carbon_thickness1=data.get('carbon_thickness1'),
            carbon_temp2=data.get('carbon_temp2'),
            carbon_thickness2=data.get('carbon_thickness2'),
            carbon_max_temp=data.get('carbon_max_temp'),
            carbon_film_thickness=data.get('carbon_film_thickness'),
            carbon_total_time=data.get('carbon_total_time'),
            carbon_after_weight=data.get('carbon_weight'),
            carbon_yield_rate=data.get('carbon_yield_rate')
        )
        db.session.add(carbon)
    
    # 石墨化参数
    if data.get('graphite_furnace_num'):
        graphite = ExperimentGraphite(
            experiment_id=experiment_id,
            graphite_furnace_number=data.get('graphite_furnace_num'),
            graphite_furnace_batch=data.get('graphite_batch_num'),
            graphite_start_time=_parse_datetime(data.get('graphite_start_time')),
            graphite_end_time=_parse_datetime(data.get('graphite_end_time')),
            gas_pressure=data.get('pressure_value'),
            graphite_power=data.get('graphite_power'),
            graphite_max_temp=data.get('graphite_max_temp'),
            foam_thickness=data.get('foam_thickness'),
            graphite_width=data.get('graphite_width'),
            shrinkage_ratio=data.get('shrinkage_ratio'),
            graphite_total_time=data.get('graphite_total_time'),
            graphite_after_weight=data.get('graphite_weight'),
            graphite_yield_rate=data.get('graphite_yield_rate'),
            graphite_min_thickness=data.get('graphite_min_thickness')
        )
        db.session.add(graphite)
    
    # 压延参数
    if data.get('rolling_machine_num'):
        rolling = ExperimentRolling(
            experiment_id=experiment_id,
            rolling_machine=data.get('rolling_machine_num'),
            rolling_pressure=data.get('rolling_pressure'),
            rolling_tension=data.get('rolling_tension'),
            rolling_speed=data.get('rolling_speed')
        )
        db.session.add(rolling)
    
    # 产品参数
    if data.get('product_avg_thickness'):
        product = ExperimentProduct(
            experiment_id=experiment_id,
            product_code=data.get('product_code'),
            avg_thickness=data.get('product_avg_thickness'),
            specification=data.get('product_spec'),
            avg_density=data.get('product_avg_density'),
            thermal_diffusivity=data.get('thermal_diffusivity'),
            thermal_conductivity=data.get('thermal_conductivity'),
            specific_heat=data.get('specific_heat'),
            cohesion=data.get('cohesion'),
            peel_strength=data.get('peel_strength'),
            roughness=data.get('roughness'),
            appearance_desc=data.get('appearance_description'),
            experiment_summary=data.get('experiment_summary'),
            remarks=data.get('remarks')
        )
        db.session.add(product)


def _save_all_modules(experiment_id, data):
    """保存所有模块数据（正式提交时使用）"""
    
    # 1. 实验基础参数
    basic = ExperimentBasic(
        experiment_id=experiment_id,
        pi_film_thickness=data['pi_film_thickness'],
        customer_type=data['customer_type'],
        customer_name=data['customer_name'],
        pi_film_model=data['pi_film_model'],
        experiment_date=_parse_date(data['experiment_date']),
        sintering_location=data['sintering_location'],
        material_type_for_firing=data['material_type_for_firing'],
        rolling_method=data['rolling_method'],
        experiment_group=data['experiment_group'],
        experiment_purpose=data['experiment_purpose']
    )
    db.session.add(basic)
    
    # 2. PI膜参数
    pi = ExperimentPi(
        experiment_id=experiment_id,
        pi_manufacturer=data['pi_manufacturer'],
        pi_thickness_detail=data['pi_thickness_detail'],
        pi_model_detail=data['pi_model_detail'],
        pi_width=data.get('pi_width'),
        batch_number=data.get('batch_number'),
        pi_weight=data['pi_weight']
    )
    db.session.add(pi)
    
    # 3. 松卷参数
    loose = ExperimentLoose(
        experiment_id=experiment_id,
        core_tube_type=data.get('core_tube_type'),
        loose_gap_inner=data.get('loose_gap_inner'),
        loose_gap_middle=data.get('loose_gap_middle'),
        loose_gap_outer=data.get('loose_gap_outer')
    )
    db.session.add(loose)
    
    # 4. 碳化参数
    carbon = ExperimentCarbon(
        experiment_id=experiment_id,
        carbon_furnace_number=data['carbon_furnace_num'],
        carbon_furnace_batch=data['carbon_batch_num'],
        boat_model=data.get('boat_model'),
        wrap_type=data.get('wrap_type'),
        vacuum_degree=data.get('vacuum_degree'),
        carbon_power=data.get('carbon_power'),
        carbon_start_time=_parse_datetime(data.get('carbon_start_time')),
        carbon_end_time=_parse_datetime(data.get('carbon_end_time')),
        carbon_temp1=data.get('carbon_temp1'),
        carbon_thickness1=data.get('carbon_thickness1'),
        carbon_temp2=data.get('carbon_temp2'),
        carbon_thickness2=data.get('carbon_thickness2'),
        carbon_max_temp=data['carbon_max_temp'],
        carbon_film_thickness=data['carbon_film_thickness'],
        carbon_total_time=data['carbon_total_time'],
        carbon_after_weight=data['carbon_weight'],
        carbon_yield_rate=data['carbon_yield_rate']
    )
    db.session.add(carbon)
    
    # 5. 石墨化参数
    graphite = ExperimentGraphite(
        experiment_id=experiment_id,
        graphite_furnace_number=data['graphite_furnace_num'],
        graphite_furnace_batch=data.get('graphite_batch_num'),
        graphite_start_time=_parse_datetime(data.get('graphite_start_time')),
        graphite_end_time=_parse_datetime(data.get('graphite_end_time')),
        gas_pressure=data['pressure_value'],
        graphite_power=data.get('graphite_power'),
        graphite_temp1=data.get('graphite_temp1'),
        graphite_thickness1=data.get('graphite_thickness1'),
        graphite_temp2=data.get('graphite_temp2'),
        graphite_thickness2=data.get('graphite_thickness2'),
        graphite_temp3=data.get('graphite_temp3'),
        graphite_thickness3=data.get('graphite_thickness3'),
        graphite_temp4=data.get('graphite_temp4'),
        graphite_thickness4=data.get('graphite_thickness4'),
        graphite_temp5=data.get('graphite_temp5'),
        graphite_thickness5=data.get('graphite_thickness5'),
        graphite_temp6=data.get('graphite_temp6'),
        graphite_thickness6=data.get('graphite_thickness6'),
        graphite_max_temp=data['graphite_max_temp'],
        foam_thickness=data['foam_thickness'],
        graphite_width=data['graphite_width'],
        shrinkage_ratio=data['shrinkage_ratio'],
        graphite_total_time=data['graphite_total_time'],
        graphite_after_weight=data['graphite_weight'],
        graphite_yield_rate=data['graphite_yield_rate'],
        graphite_min_thickness=data.get('graphite_min_thickness')
    )
    db.session.add(graphite)
    
    # 6. 压延参数
    rolling = ExperimentRolling(
        experiment_id=experiment_id,
        rolling_machine=data.get('rolling_machine_num'),
        rolling_pressure=data.get('rolling_pressure'),
        rolling_tension=data.get('rolling_tension'),
        rolling_speed=data.get('rolling_speed')
    )
    db.session.add(rolling)
    
    # 7. 产品参数
    product = ExperimentProduct(
        experiment_id=experiment_id,
        product_code=data.get('product_code'),
        avg_thickness=data['product_avg_thickness'],
        specification=data['product_spec'],
        avg_density=data['product_avg_density'],
        thermal_diffusivity=data['thermal_diffusivity'],
        thermal_conductivity=data['thermal_conductivity'],
        specific_heat=data['specific_heat'],
        cohesion=data['cohesion'],
        peel_strength=data['peel_strength'],
        roughness=data['roughness'],
        appearance_desc=data['appearance_description'],
        experiment_summary=data.get('experiment_summary'),
        remarks=data.get('remarks')
    )
    db.session.add(product)


def _parse_date(date_str):
    """解析日期字符串"""
    if not date_str:
        return None
    try:
        if isinstance(date_str, str):
            return datetime.strptime(date_str, '%Y-%m-%d').date()
        return date_str
    except:
        return None


def _parse_datetime(datetime_str):
    """解析日期时间字符串"""
    if not datetime_str:
        return None
    try:
        return datetime.fromisoformat(datetime_str.replace('Z', '+00:00'))
    except:
        return None