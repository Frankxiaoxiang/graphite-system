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
# 🆕 新增：更新草稿 API
# ==========================================
@experiments_bp.route('/<int:experiment_id>/draft', methods=['PUT', 'OPTIONS'])
def update_draft(experiment_id):
    """
    更新草稿 - 只需验证基本参数
    """
    # 🔧 第一步：处理 OPTIONS 预检请求
    if request.method == 'OPTIONS':
        response = make_response('', 200)
        response.headers['Access-Control-Allow-Origin'] = request.headers.get('Origin', 'http://localhost:5173')
        response.headers['Access-Control-Allow-Methods'] = 'PUT, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
        response.headers['Access-Control-Max-Age'] = '3600'
        return response
    
    # 🔧 第二步：验证 JWT
    print("\n" + "="*60)
    print("📝 收到草稿更新请求")
    print("="*60)
    
    try:
        # 验证 JWT
        auth_header = request.headers.get('Authorization')
        print(f"🔑 Authorization 头: {auth_header[:50] if auth_header else 'None'}...")
        
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': '缺少认证令牌'}), 401
        
        verify_jwt_in_request()
        current_user_id = int(get_jwt_identity())
        print(f"✅ JWT 验证成功！用户 ID: {current_user_id}")
        
    except Exception as e:
        print(f"❌ JWT 验证失败：{str(e)}")
        return jsonify({'error': f'认证失败: {str(e)}'}), 401
    
    # 🔧 第三步：更新草稿逻辑
    try:
        data = request.get_json()
        print(f"\n📦 收到数据：")
        print(f"   - 实验 ID: {experiment_id}")
        print(f"   - 实验编码: {data.get('experiment_code', 'N/A')}")
        
        # 1. 查找实验
        experiment = Experiment.query.get(experiment_id)
        if not experiment:
            print(f"❌ 实验不存在: ID {experiment_id}")
            return jsonify({'error': '实验不存在'}), 404
        
        # 2. 权限检查
        if experiment.created_by != current_user_id:
            print(f"❌ 无权限更新此实验")
            return jsonify({'error': '无权限更新此实验'}), 403
        
        # 3. 检查实验状态（只能更新草稿）
        if experiment.status != 'draft':
            print(f"❌ 只能更新草稿状态的实验")
            return jsonify({'error': '只能更新草稿状态的实验'}), 400
        
        # 4. 验证基本参数（10个必填字段）
        required_basic_fields = [
            'pi_film_thickness', 'customer_type', 'customer_name', 'pi_film_model',
            'experiment_date', 'sintering_location', 'material_type_for_firing',
            'rolling_method', 'experiment_group', 'experiment_purpose'
        ]
        
        missing_fields = [f for f in required_basic_fields if not data.get(f)]
        if missing_fields:
            print(f"❌ 缺少必填字段: {', '.join(missing_fields)}")
            return jsonify({
                'error': '缺少必填字段',
                'missing_fields': missing_fields
            }), 400
        
        print("✅ 基本参数验证通过")
        
        # 5. 验证实验编码
        experiment_code = data.get('experiment_code')
        if not experiment_code:
            return jsonify({'error': '缺少实验编码'}), 400
        
        print(f"🔖 实验编码: {experiment_code}")
        
        # 验证编码格式
        is_valid, error_msg = validate_experiment_code_format(experiment_code)
        if not is_valid:
            print(f"❌ 编码格式错误: {error_msg}")
            return jsonify({'error': error_msg}), 400
        
        # 检查编码唯一性（排除当前实验）
        print("\n🔍 检查实验编码唯一性...")
        existing = Experiment.query.filter_by(experiment_code=experiment_code).filter(
            Experiment.id != experiment_id  # ✅ 排除当前正在更新的记录
        ).first()

        if existing:
            error_msg = f'实验编码 {experiment_code} 已被其他实验使用'
            print(f"❌ {error_msg}")
            return jsonify({'error': error_msg}), 400

        print(f"✅ 实验编码唯一")
        
        # 6. 更新实验主记录
        experiment.experiment_code = experiment_code
        experiment.updated_at = datetime.utcnow()
        
    
        # 7. 更新/保存各模块数据 - ✅ 先删除旧数据再保存新数据
        print("🔄 删除旧模块数据...")
        ExperimentBasic.query.filter_by(experiment_id=experiment.id).delete()
        ExperimentPi.query.filter_by(experiment_id=experiment.id).delete()
        ExperimentLoose.query.filter_by(experiment_id=experiment.id).delete()
        ExperimentCarbon.query.filter_by(experiment_id=experiment.id).delete()
        ExperimentGraphite.query.filter_by(experiment_id=experiment.id).delete()
        ExperimentRolling.query.filter_by(experiment_id=experiment.id).delete()
        ExperimentProduct.query.filter_by(experiment_id=experiment.id).delete()
        
        print("💾 保存新模块数据...")
        # 保存新的基础参数（必须）
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
        
        # 保存其他可选模块数据
        _save_optional_modules(experiment.id, data)
        
        # 8. 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='update_draft',
            target_type='experiment',
            target_id=experiment.id,
            description=f'更新草稿 {experiment_code}',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': '草稿更新成功',
            'id': experiment.id,
            'experiment_code': experiment_code
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"❌ 更新草稿失败：{type(e).__name__}")
        print(f"   错误详情：{str(e)}")
        traceback.print_exc()
        print("="*60 + "\n")
        return jsonify({'error': f'更新草稿失败: {str(e)}'}), 500

# ==========================================
# 🔄 修改：原有的创建实验 API → 正式提交 API - 手动控制验证
# ==========================================
# ==========================================
# 🔄 修改：原有的创建实验 API → 正式提交 API - 手动控制验证
# ==========================================
@experiments_bp.route('', methods=['POST', 'OPTIONS'])
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
        
        # 4. 检查实验编码是否已存在（可能是草稿）
        print("\n🔍 检查实验编码...")
        existing = Experiment.query.filter_by(experiment_code=experiment_code).first()
        is_updating_draft = False  # ✅ 标记是否是更新草稿

        if existing:
            # ✅ 如果已存在且是草稿，更新为submitted状态
            if existing.status == 'draft':
                print(f"📝 发现草稿记录，将更新为submitted状态")
                print(f"   - 草稿 ID: {existing.id}")
                print(f"   - 创建者: {existing.created_by}")
        
                # 验证权限：只能提交自己的草稿
                if existing.created_by != current_user_id:  # ✅ 修复：字段名
                    error_msg = '无权限提交此实验'
                    print(f"❌ {error_msg}")
                    return jsonify({'error': error_msg}), 403
        
                # 更新状态为submitted
                existing.status = 'submitted'
                existing.submitted_at = datetime.now()
                experiment = existing  # 使用已有的experiment对象
                experiment_id = existing.id
                is_updating_draft = True  # ✅ 标记为更新草稿
        
                print(f"✅ 草稿状态已更新为submitted")
        
            else:
                # 如果已存在且不是草稿，返回错误
                error_msg = f'实验编码 {experiment_code} 已存在（状态：{existing.status}）'
                print(f"❌ {error_msg}")
                return jsonify({'error': error_msg}), 400
        else:
            # 如果不存在，标记需要创建新记录
            print(f"✅ 实验编码不存在，将创建新记录")
        
        # 5. 创建或使用已有实验记录
        if not existing:  # ✅ 只有不存在时才创建新记录
            print("\n💾 创建实验记录...")
            experiment = Experiment(
                experiment_code=experiment_code,
                created_by=current_user_id,  # ✅ 修复：字段名
                status='submitted',
                submitted_at=datetime.now()
            )
            db.session.add(experiment)
            db.session.flush()
            experiment_id = experiment.id
            print(f"✅ 实验记录创建成功，ID: {experiment_id}")
        else:
            # 使用步骤4中已经设置的experiment对象
            experiment_id = experiment.id
            print(f"✅ 使用已有实验记录，ID: {experiment_id}")
        
        # 6. 如果是更新草稿，先删除旧的模块数据
        if is_updating_draft:
            print("\n🗑️ 删除旧草稿数据...")
            ExperimentBasic.query.filter_by(experiment_id=experiment_id).delete()
            ExperimentPi.query.filter_by(experiment_id=experiment_id).delete()
            ExperimentLoose.query.filter_by(experiment_id=experiment_id).delete()
            ExperimentCarbon.query.filter_by(experiment_id=experiment_id).delete()
            ExperimentGraphite.query.filter_by(experiment_id=experiment_id).delete()
            ExperimentRolling.query.filter_by(experiment_id=experiment_id).delete()
            ExperimentProduct.query.filter_by(experiment_id=experiment_id).delete()
            print("✅ 旧数据已删除")
        
        # 7. 保存所有模块数据
        print("\n💾 保存所有模块数据...")
        _save_all_modules(experiment_id, data)
        
        db.session.commit()
        
        print(f"\n✅ 实验提交成功！")
        print(f"   - 实验 ID: {experiment.id}")
        print(f"   - 实验编码: {experiment_code}")
        print("="*60 + "\n")
        
        # 8. 记录操作日志
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
        print(f"\n❌ 提交实验失败：{type(e).__name__}")
        print(f"   错误详情：{str(e)}")
        traceback.print_exc()
        print("="*60 + "\n")
        return jsonify({'error': f'提交实验失败: {str(e)}'}), 500

# ==========================================
# ✅ 保留：原有的其他 API（已修改）
# ==========================================
@experiments_bp.route('', methods=['GET'])
def get_experiments():
    """
    获取实验列表 - 适配前端 PaginatedResponse 格式
    
    查询参数：
        - page: 页码（默认1）
        - size: 每页数量（默认20）
        - status: 状态筛选（draft/submitted）
        - customer_name: 客户名称搜索
        - experiment_code: 实验编码搜索
        - date_from: 开始日期（YYYY-MM-DD）
        - date_to: 结束日期（YYYY-MM-DD）
    
    返回格式：
        {
            "data": [...],
            "total": 100,
            "page": 1,
            "size": 20,
            "pages": 5
        }
    """
    try:
               # ✅ 手动验证JWT
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': '缺少认证令牌'}), 401
        
        verify_jwt_in_request()
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        # 获取查询参数 - 适配前端参数名
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('size', 20, type=int)  # 前端使用 size
        status = request.args.get('status')
        customer_name = request.args.get('customer_name')
        experiment_code = request.args.get('experiment_code')
        date_from = request.args.get('date_from')
        date_to = request.args.get('date_to')
        
        print("\n" + "="*60)
        print("📥 收到实验列表查询请求")
        print(f"   - 用户ID: {current_user_id}, 角色: {user.role}")
        print(f"   - 页码: {page}, 每页: {per_page}")
        print(f"   - 筛选: status={status}, customer={customer_name}")
        print("="*60)
        
        # 构建查询 - JOIN ExperimentBasic 表获取完整信息
        query = db.session.query(
            Experiment,
            ExperimentBasic,
            User.username.label('creator_name')
        ).join(
            ExperimentBasic,
            Experiment.id == ExperimentBasic.experiment_id,
            isouter=True  # 左连接，允许没有基本参数的实验
        ).join(
            User,
            Experiment.created_by == User.id
        )
        
        # 权限控制：普通用户只能看自己的实验
        if user.role == 'user':
            query = query.filter(Experiment.created_by == current_user_id)
        
        # 应用筛选条件
        if status:
            query = query.filter(Experiment.status == status)
            print(f"   - 应用状态筛选: {status}")
        
        if customer_name:
            query = query.filter(ExperimentBasic.customer_name.like(f'%{customer_name}%'))
            print(f"   - 应用客户名称搜索: {customer_name}")
        
        if experiment_code:
            query = query.filter(Experiment.experiment_code.like(f'%{experiment_code}%'))
            print(f"   - 应用实验编码搜索: {experiment_code}")
        
        if date_from:
            query = query.filter(ExperimentBasic.experiment_date >= date_from)
            print(f"   - 应用开始日期: {date_from}")
        
        if date_to:
            query = query.filter(ExperimentBasic.experiment_date <= date_to)
            print(f"   - 应用结束日期: {date_to}")
        
        # 排序：最新的在前
        query = query.order_by(Experiment.created_at.desc())
        
        # 分页
        paginated = query.paginate(
            page=page,
            per_page=per_page,
            error_out=False
        )
        
        # 构建返回数据
        result_data = []
        for experiment, basic, creator_name in paginated.items:
            item = {
                'id': experiment.id,
                'experiment_code': experiment.experiment_code,
                'status': experiment.status,
                'created_by': experiment.created_by,
                'created_by_name': creator_name,
                'created_at': experiment.created_at.strftime('%Y-%m-%d %H:%M:%S') if experiment.created_at else None,
                'updated_at': experiment.updated_at.strftime('%Y-%m-%d %H:%M:%S') if experiment.updated_at else None,
                'submitted_at': experiment.submitted_at.strftime('%Y-%m-%d %H:%M:%S') if experiment.submitted_at else None,
                
                # 基本参数信息
                'pi_film_thickness': basic.pi_film_thickness if basic else None,
                'customer_name': basic.customer_name if basic else None,
                'pi_film_model': basic.pi_film_model if basic else None,
                'experiment_date': basic.experiment_date.strftime('%Y-%m-%d') if (basic and basic.experiment_date) else None
            }
            result_data.append(item)
        
        print(f"\n✅ 查询成功: 总{paginated.total}条, 当前页{len(result_data)}条")
        print("="*60 + "\n")
        
        # 返回数据 - 适配前端 PaginatedResponse 格式
        return jsonify({
            'data': result_data,         # 使用 data 字段
            'total': paginated.total,
            'page': paginated.page,
            'size': paginated.per_page,  # 使用 size 字段
            'pages': paginated.pages     # 使用 pages 字段
        }), 200
        
    except Exception as e:
        print(f"\n❌ 查询失败：{type(e).__name__}: {str(e)}")
        traceback.print_exc()
        print("="*60 + "\n")
        return jsonify({'error': f'获取实验列表失败: {str(e)}'}), 500


@experiments_bp.route('/<int:experiment_id>', methods=['GET'])
def get_experiment(experiment_id):
    """获取实验详情"""
    try:
        # ✅ 手动验证JWT
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': '缺少认证令牌'}), 401
        
        verify_jwt_in_request()
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
        
# 3. 松卷参数
        if experiment.loose:
            experiment_data['loose'] = {
                'core_tube_type': experiment.loose.core_tube_type,
                'loose_gap_inner': float(experiment.loose.loose_gap_inner) if experiment.loose.loose_gap_inner else None,
                'loose_gap_middle': float(experiment.loose.loose_gap_middle) if experiment.loose.loose_gap_middle else None,
                'loose_gap_outer': float(experiment.loose.loose_gap_outer) if experiment.loose.loose_gap_outer else None
            }
        
        # 4. 碳化参数
        if experiment.carbon:
            experiment_data['carbon'] = {
                'carbon_furnace_number': experiment.carbon.carbon_furnace_number,
                'carbon_furnace_batch': experiment.carbon.carbon_furnace_batch,
                'boat_model': experiment.carbon.boat_model,
                'wrapping_method': experiment.carbon.wrapping_method,
                'vacuum_degree': float(experiment.carbon.vacuum_degree) if experiment.carbon.vacuum_degree else None,
                'power_consumption': float(experiment.carbon.power_consumption) if experiment.carbon.power_consumption else None,
                'start_time': experiment.carbon.start_time.isoformat() if experiment.carbon.start_time else None,
                'end_time': experiment.carbon.end_time.isoformat() if experiment.carbon.end_time else None,
                'carbon_max_temp': float(experiment.carbon.carbon_max_temp) if experiment.carbon.carbon_max_temp else None,
                'carbon_total_time': experiment.carbon.carbon_total_time,
                'carbon_film_thickness': float(experiment.carbon.carbon_film_thickness) if experiment.carbon.carbon_film_thickness else None,
                'carbon_after_weight': float(experiment.carbon.carbon_after_weight) if experiment.carbon.carbon_after_weight else None,
                'carbon_yield_rate': float(experiment.carbon.carbon_yield_rate) if experiment.carbon.carbon_yield_rate else None,
                'carbon_loading_photo': experiment.carbon.carbon_loading_photo,
                'carbon_sample_photo': experiment.carbon.carbon_sample_photo,
                'carbon_other_params': experiment.carbon.carbon_other_params
            }
        
        # 5. 石墨化参数
        if experiment.graphite:
            experiment_data['graphite'] = {
                'graphite_furnace_number': experiment.graphite.graphite_furnace_number,
                'graphite_furnace_batch': experiment.graphite.graphite_furnace_batch,
                'graphite_start_time': experiment.graphite.graphite_start_time.isoformat() if experiment.graphite.graphite_start_time else None,
                'graphite_end_time': experiment.graphite.graphite_end_time.isoformat() if experiment.graphite.graphite_end_time else None,
                'gas_pressure': float(experiment.graphite.gas_pressure) if experiment.graphite.gas_pressure else None,
                'graphite_power': float(experiment.graphite.graphite_power) if experiment.graphite.graphite_power else None,
                'foam_thickness': float(experiment.graphite.foam_thickness) if experiment.graphite.foam_thickness else None,
                'graphite_max_temp': float(experiment.graphite.graphite_max_temp) if experiment.graphite.graphite_max_temp else None,
                'graphite_width': float(experiment.graphite.graphite_width) if experiment.graphite.graphite_width else None,
                'shrinkage_ratio': float(experiment.graphite.shrinkage_ratio) if experiment.graphite.shrinkage_ratio else None,
                'graphite_total_time': experiment.graphite.graphite_total_time,
                'graphite_after_weight': float(experiment.graphite.graphite_after_weight) if experiment.graphite.graphite_after_weight else None,
                'graphite_yield_rate': float(experiment.graphite.graphite_yield_rate) if experiment.graphite.graphite_yield_rate else None,
                'graphite_min_thickness': float(experiment.graphite.graphite_min_thickness) if experiment.graphite.graphite_min_thickness else None,
                'graphite_loading_photo': experiment.graphite.graphite_loading_photo,
                'graphite_sample_photo': experiment.graphite.graphite_sample_photo,
                'graphite_other_params': experiment.graphite.graphite_other_params
            }
        
        # 6. 压延参数
        if experiment.rolling:
            experiment_data['rolling'] = {
                'rolling_machine': experiment.rolling.rolling_machine,
                'rolling_pressure': float(experiment.rolling.rolling_pressure) if experiment.rolling.rolling_pressure else None,
                'rolling_tension': float(experiment.rolling.rolling_tension) if experiment.rolling.rolling_tension else None,
                'rolling_speed': float(experiment.rolling.rolling_speed) if experiment.rolling.rolling_speed else None
            }
        
        # 7. 成品参数
        if experiment.product:
            experiment_data['product'] = {
                'product_code': experiment.product.product_code,
                'avg_thickness': float(experiment.product.avg_thickness) if experiment.product.avg_thickness else None,
                'specification': experiment.product.specification,
                'avg_density': float(experiment.product.avg_density) if experiment.product.avg_density else None,
                'thermal_diffusivity': float(experiment.product.thermal_diffusivity) if experiment.product.thermal_diffusivity else None,
                'thermal_conductivity': float(experiment.product.thermal_conductivity) if experiment.product.thermal_conductivity else None,
                'specific_heat': float(experiment.product.specific_heat) if experiment.product.specific_heat else None,
                'cohesion': float(experiment.product.cohesion) if experiment.product.cohesion else None,
                'peel_strength': float(experiment.product.peel_strength) if experiment.product.peel_strength else None,
                'roughness': experiment.product.roughness,
                'appearance_desc': experiment.product.appearance_desc,
                'appearance_defect_photo': experiment.product.appearance_defect_photo,
                'sample_photo': experiment.product.sample_photo,
                'experiment_summary': experiment.product.experiment_summary,
                'other_files': experiment.product.other_files,
                'remarks': experiment.product.remarks
            }
        
        return jsonify({'experiment': experiment_data}), 200
        
    except Exception as e:
        return jsonify({'error': '获取实验详情失败'}), 500


@experiments_bp.route('/<int:experiment_id>', methods=['PUT'])
def update_experiment(experiment_id):
    """更新实验数据"""
    try:
        # ✅ 手动JWT验证
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': '缺少认证令牌'}), 401
        
        verify_jwt_in_request()
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        experiment = Experiment.query.get(experiment_id)
        if not experiment:
            return jsonify({'error': '实验不存在'}), 404
        
        # 权限检查
        if user.role == 'user' and experiment.created_by != current_user_id:
            return jsonify({'error': '无权修改此实验'}), 403
        
        data = request.get_json()
        
        print(f"\n✏️  更新实验: {experiment.experiment_code}")
        
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
        
        print(f"✅ 更新成功: {experiment.experiment_code}\n")
        
        return jsonify({
            'message': '实验更新成功',
            'experiment': experiment.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"❌ 更新失败: {str(e)}")
        traceback.print_exc()
        return jsonify({'error': f'更新实验失败: {str(e)}'}), 500


@experiments_bp.route('/<int:experiment_id>', methods=['DELETE'])
def delete_experiment(experiment_id):
    """删除实验"""
    try:
        # ✅ 手动JWT验证
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': '缺少认证令牌'}), 401
        
        verify_jwt_in_request()
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        experiment = Experiment.query.get(experiment_id)
        if not experiment:
            return jsonify({'error': '实验不存在'}), 404
        
        # ✅ 权限检查：只能删除自己的草稿
        if user.role == 'user' and experiment.created_by != current_user_id:
            return jsonify({'error': '无权删除此实验'}), 403
        
        if experiment.status != 'draft':
            return jsonify({'error': '只能删除草稿状态的实验'}), 400
        
        experiment_code = experiment.experiment_code
        
        print(f"\n🗑️  删除实验: {experiment_code}")
        
        # 删除关联数据（级联删除）
        ExperimentBasic.query.filter_by(experiment_id=experiment_id).delete()
        ExperimentPi.query.filter_by(experiment_id=experiment_id).delete()
        ExperimentLoose.query.filter_by(experiment_id=experiment_id).delete()
        ExperimentCarbon.query.filter_by(experiment_id=experiment_id).delete()
        ExperimentGraphite.query.filter_by(experiment_id=experiment_id).delete()
        ExperimentRolling.query.filter_by(experiment_id=experiment_id).delete()
        ExperimentProduct.query.filter_by(experiment_id=experiment_id).delete()
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='delete_experiment',
            target_type='experiment',
            target_id=experiment.id,
            description=f'删除实验 {experiment_code}',
            ip_address=request.remote_addr
        )
        
        # 删除主记录
        db.session.delete(experiment)
        db.session.commit()
        
        print(f"✅ 删除成功: {experiment_code}\n")
        
        return jsonify({'message': '实验删除成功'}), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"❌ 删除失败: {str(e)}")
        traceback.print_exc()
        return jsonify({'error': f'删除实验失败: {str(e)}'}), 500


@experiments_bp.route('/export', methods=['POST'])
def export_experiments():
    """导出实验数据"""
    try:
        # ✅ 手动JWT验证
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': '缺少认证令牌'}), 401
        
        verify_jwt_in_request()
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        data = request.get_json()
        experiment_ids = data.get('experiment_ids', [])
        
        if not experiment_ids:
            return jsonify({'error': '请选择要导出的实验'}), 400
        
        print(f"\n📤 导出实验: {len(experiment_ids)}条")
        
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
        
        print(f"✅ 导出成功: {len(experiments)}条\n")
        
        return jsonify({
            'csv_content': csv_content,
            'filename': f'experiments_export_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv'
        }), 200
        
    except Exception as e:
        print(f"❌ 导出失败: {str(e)}")
        traceback.print_exc()
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
            wrapping_method=data.get('wrap_type'),
            vacuum_degree=data.get('vacuum_degree'),
            power_consumption=data.get('carbon_power'),
            start_time=_parse_datetime(data.get('carbon_start_time')),
            end_time=_parse_datetime(data.get('carbon_end_time')),
            
            # ✅ 新增：碳化温度/厚度字段
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
            
            # ✅ 新增：石墨化温度/厚度字段
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
            
            foam_thickness=data.get('foam_thickness'),
            graphite_max_temp=data.get('graphite_max_temp'),
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
    # 4. 碳化参数
    carbon = ExperimentCarbon(
        experiment_id=experiment_id,
        carbon_furnace_number=data['carbon_furnace_num'],
        carbon_furnace_batch=data['carbon_batch_num'],
        boat_model=data.get('boat_model'),
        wrapping_method=data.get('wrap_type'),
        vacuum_degree=data.get('vacuum_degree'),
        power_consumption=data.get('carbon_power'),
        start_time=_parse_datetime(data.get('carbon_start_time')),
        end_time=_parse_datetime(data.get('carbon_end_time')),
    
    # ✅ 新增：碳化温度/厚度字段
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


# ==========================================
# 辅助函数
# ==========================================
def _parse_date(date_str):
    """解析日期字符串为 date 对象"""
    if not date_str:
        return None
    if isinstance(date_str, str):
        try:
            return datetime.strptime(date_str, '%Y-%m-%d').date()
        except:
            return None
    return date_str

def _parse_datetime(datetime_str):
    """解析日期时间字符串为 datetime 对象"""
    if not datetime_str:
        return None
    if isinstance(datetime_str, str):
        try:
            # 尝试 ISO 格式 (2025-10-09T14:30:00)
            return datetime.strptime(datetime_str, '%Y-%m-%dT%H:%M:%S')
        except:
            try:
                # 尝试标准格式 (2025-10-09 14:30:00)
                return datetime.strptime(datetime_str, '%Y-%m-%d %H:%M:%S')
            except:
                return None
    return datetime_str