# ========================================
# 文件名: app/routes/dropdown.py
# 下拉选择数据管理路由
# ========================================

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.dropdown import DropdownOption, DropdownField, DropdownApproval
from app.models.system_log import SystemLog
from app.utils.permissions import require_permission

dropdown_bp = Blueprint('dropdown', __name__)

# ========== 新增：支持路径参数的路由（兼容前端） ==========
@dropdown_bp.route('/options/<string:field_name>', methods=['GET', 'OPTIONS'])
def get_dropdown_options_by_path(field_name):
    """获取下拉选择选项 (通过路径参数)"""
    # OPTIONS请求直接返回200（用于CORS预检）
    if request.method == 'OPTIONS':
        return '', 200
    
    try:
        search = request.args.get('search', '')
        
        # 构建查询
        query = DropdownOption.query.filter_by(
            field_name=field_name, 
            is_active=True
        )
        
        # 搜索功能
        if search and len(search) >= 2:
            query = query.filter(
                db.or_(
                    DropdownOption.option_value.contains(search),
                    DropdownOption.option_label.contains(search)
                )
            )
        
        options = query.order_by(DropdownOption.sort_order).limit(20).all()
        
        result = [{
            'value': option.option_value,
            'label': option.option_label,
            'sort_order': option.sort_order
        } for option in options]
        
        return jsonify(result), 200
        
    except Exception as e:
        print(f"获取选项失败: {str(e)}")
        return jsonify({'error': '获取选项失败', 'message': str(e)}), 500
# ==========================================================

@dropdown_bp.route('/options', methods=['GET'])
@jwt_required()
def get_dropdown_options():
    """获取下拉选择选项 (通过查询参数，保留旧接口)"""
    try:
        field_name = request.args.get('field_name')
        search = request.args.get('search', '')
        
        if not field_name:
            return jsonify({'error': '字段名称不能为空'}), 400
        
        # 构建查询
        query = DropdownOption.query.filter_by(
            field_name=field_name, 
            is_active=True
        )
        
        # 搜索功能
        if search and len(search) >= 2:
            query = query.filter(
                db.or_(
                    DropdownOption.option_value.contains(search),
                    DropdownOption.option_label.contains(search)
                )
            )
        
        options = query.order_by(DropdownOption.sort_order).limit(20).all()
        
        result = [{
            'value': option.option_value,
            'label': option.option_label,
            'sort_order': option.sort_order
        } for option in options]
        
        return jsonify({'options': result}), 200
        
    except Exception as e:
        return jsonify({'error': '获取选项失败'}), 500

@dropdown_bp.route('/add', methods=['POST', 'OPTIONS'])
def add_dropdown_option():
    """添加新的下拉选择选项"""
    # OPTIONS请求直接返回200（用于CORS预检）
    if request.method == 'OPTIONS':
        return '', 200
        
    try:
        # 注意：这里暂时不使用@jwt_required装饰器，让OPTIONS请求通过
        # 在实际请求中，我们手动检查token
        from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
        
        try:
            verify_jwt_in_request()
            current_user_id = get_jwt_identity()
        except:
            return jsonify({'error': '未授权'}), 401
        
        user = User.query.get(current_user_id)
        
        data = request.get_json()
        field_name = data.get('field_name')
        option_value = data.get('option_value')
        option_label = data.get('option_label')
        
        if not all([field_name, option_value, option_label]):
            return jsonify({'error': '字段名称、选项值和显示文本不能为空'}), 400
        
        # 检查字段配置
        field_config = DropdownField.query.filter_by(field_name=field_name).first()
        if not field_config:
            return jsonify({'error': '字段不存在或不支持扩展'}), 400
        
        if field_config.field_type == 'fixed':
            return jsonify({'error': '此字段不允许添加新选项'}), 400
        
        # 简化版：所有用户都可以添加searchable字段
        # 检查权限（保留原有逻辑，但实际上所有用户都有权限）
        can_add = field_config.field_type == 'searchable'
        
        if not can_add:
            return jsonify({'error': '您没有权限添加此字段的选项'}), 403
        
        # 检查选项是否已存在
        existing = DropdownOption.query.filter_by(
            field_name=field_name,
            option_value=option_value
        ).first()
        
        if existing:
            return jsonify({'error': '选项已存在'}), 400
        
        # 直接添加选项（无需审批）
        # 获取下一个排序号
        max_sort = db.session.query(db.func.max(DropdownOption.sort_order)).filter_by(
            field_name=field_name
        ).scalar() or 0
        
        option = DropdownOption(
            field_name=field_name,
            option_value=option_value,
            option_label=option_label,
            sort_order=max_sort + 1,
            created_by=current_user_id
        )
        db.session.add(option)
        db.session.commit()
        
        # 记录操作日志
        try:
            SystemLog.log_action(
                user_id=current_user_id,
                action='add_dropdown_option',
                description=f'添加选项: {field_name} - {option_label}',
                ip_address=request.remote_addr
            )
        except:
            pass  # 日志失败不影响主流程
        
        return jsonify({
            'message': '选项添加成功',
            'option': {
                'value': option.option_value,
                'label': option.option_label
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        print(f"添加选项失败: {str(e)}")
        return jsonify({'error': '添加选项失败', 'message': str(e)}), 500

@dropdown_bp.route('/fields', methods=['GET'])
@jwt_required()
def get_dropdown_fields():
    """获取下拉字段配置"""
    try:
        fields = DropdownField.query.all()
        
        result = []
        for field in fields:
            field_data = {
                'field_name': field.field_name,
                'field_label': field.field_label,
                'field_type': field.field_type,
                'allow_user_add': field.allow_user_add,
                'allow_engineer_add': field.allow_engineer_add,
                'allow_admin_add': field.allow_admin_add,
                'require_approval': field.require_approval,
                'max_options': field.max_options,
                'description': field.description
            }
            result.append(field_data)
        
        return jsonify({'fields': result}), 200
        
    except Exception as e:
        return jsonify({'error': '获取字段配置失败'}), 500

# 其余路由保持不变...