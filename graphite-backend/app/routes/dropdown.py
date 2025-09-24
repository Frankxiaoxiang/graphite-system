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

@dropdown_bp.route('/options', methods=['GET'])
@jwt_required()
def get_dropdown_options():
    """获取下拉选择选项"""
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

@dropdown_bp.route('/add', methods=['POST'])
@jwt_required()
def add_dropdown_option():
    """添加新的下拉选择选项"""
    try:
        current_user_id = get_jwt_identity()
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
        
        # 检查权限
        can_add = False
        if user.role == 'admin' and field_config.allow_admin_add:
            can_add = True
        elif user.role == 'engineer' and field_config.allow_engineer_add:
            can_add = True
        elif user.role == 'user' and field_config.allow_user_add:
            can_add = True
        
        if not can_add:
            return jsonify({'error': '您没有权限添加此字段的选项'}), 403
        
        # 检查选项是否已存在
        existing = DropdownOption.query.filter_by(
            field_name=field_name,
            option_value=option_value
        ).first()
        
        if existing:
            return jsonify({'error': '选项已存在'}), 400
        
        # 检查最大选项数量限制
        if field_config.max_options:
            current_count = DropdownOption.query.filter_by(
                field_name=field_name,
                is_active=True
            ).count()
            
            if current_count >= field_config.max_options:
                return jsonify({'error': f'选项数量已达到最大限制 ({field_config.max_options})'}), 400
        
        # 如果需要审批且不是管理员
        if field_config.require_approval and user.role != 'admin':
            # 创建审批记录
            approval = DropdownApproval(
                field_name=field_name,
                option_value=option_value,
                option_label=option_label,
                requested_by=current_user_id,
                status='pending'
            )
            db.session.add(approval)
            db.session.commit()
            
            # 记录操作日志
            SystemLog.log_action(
                user_id=current_user_id,
                action='request_dropdown_option',
                description=f'申请添加选项: {field_name} - {option_label}',
                ip_address=request.remote_addr
            )
            
            return jsonify({
                'message': '选项已提交审批，等待管理员处理',
                'approval_id': approval.id
            }), 200
        
        else:
            # 直接添加选项
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
            SystemLog.log_action(
                user_id=current_user_id,
                action='add_dropdown_option',
                description=f'添加选项: {field_name} - {option_label}',
                ip_address=request.remote_addr
            )
            
            return jsonify({
                'message': '选项添加成功',
                'option': {
                    'value': option.option_value,
                    'label': option.option_label
                }
            }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '添加选项失败'}), 500

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

@dropdown_bp.route('/approvals', methods=['GET'])
@jwt_required()
@require_permission('approve_dropdown')
def get_dropdown_approvals():
    """获取待审批的下拉选择选项"""
    try:
        status = request.args.get('status', 'pending')
        
        approvals = DropdownApproval.query.filter_by(status=status).order_by(
            DropdownApproval.requested_at.desc()
        ).all()
        
        result = []
        for approval in approvals:
            approval_data = {
                'id': approval.id,
                'field_name': approval.field_name,
                'option_value': approval.option_value,
                'option_label': approval.option_label,
                'status': approval.status,
                'requested_by': approval.requester.username if approval.requester else None,
                'requested_by_name': approval.requester.real_name if approval.requester else None,
                'requested_at': approval.requested_at.isoformat() if approval.requested_at else None,
                'reason': approval.reason,
                'approved_by': approval.approver.username if approval.approver else None,
                'processed_at': approval.processed_at.isoformat() if approval.processed_at else None
            }
            result.append(approval_data)
        
        return jsonify({'approvals': result}), 200
        
    except Exception as e:
        return jsonify({'error': '获取审批列表失败'}), 500

@dropdown_bp.route('/approve/<int:approval_id>', methods=['POST'])
@jwt_required()
@require_permission('approve_dropdown')
def approve_dropdown_option(approval_id):
    """审批下拉选择选项"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        action = data.get('action')  # 'approve' 或 'reject'
        reason = data.get('reason', '')
        
        if action not in ['approve', 'reject']:
            return jsonify({'error': '无效的操作'}), 400
        
        approval = DropdownApproval.query.get(approval_id)
        if not approval:
            return jsonify({'error': '审批记录不存在'}), 404
        
        if approval.status != 'pending':
            return jsonify({'error': '此记录已被处理'}), 400
        
        # 更新审批状态
        approval.status = 'approved' if action == 'approve' else 'rejected'
        approval.approved_by = current_user_id
        approval.reason = reason
        approval.processed_at = db.func.now()
        
        # 如果审批通过，创建选项
        if action == 'approve':
            # 获取下一个排序号
            max_sort = db.session.query(db.func.max(DropdownOption.sort_order)).filter_by(
                field_name=approval.field_name
            ).scalar() or 0
            
            option = DropdownOption(
                field_name=approval.field_name,
                option_value=approval.option_value,
                option_label=approval.option_label,
                sort_order=max_sort + 1,
                created_by=current_user_id
            )
            db.session.add(option)
        
        db.session.commit()
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action=f'{action}_dropdown_option',
            description=f'{action} 选项: {approval.field_name} - {approval.option_label}',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': f'选项已{action}',
            'approval': {
                'id': approval.id,
                'status': approval.status,
                'reason': approval.reason
            }
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '审批操作失败'}), 500