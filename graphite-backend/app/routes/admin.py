# app/routes/admin.py
"""
系统管理 API 路由
包括: 用户管理、操作日志、数据备份等
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import or_, func
from datetime import datetime

from app.models.user import User
from app import db
from app.utils.decorators import admin_required

admin_bp = Blueprint('admin', __name__, url_prefix='/api/admin')


# ==================== 用户管理 API ====================

@admin_bp.route('/users', methods=['GET'])
@jwt_required()
@admin_required()
def get_users():
    """
    获取用户列表
    
    查询参数:
        - page: 页码（默认 1）
        - page_size: 每页数量（默认 10）
        - search: 搜索关键词（用户名、真实姓名、邮箱）
        - role: 角色筛选（admin/engineer/user）
        - is_active: 状态筛选（true/false）
    """
    try:
        # 获取查询参数
        page = request.args.get('page', 1, type=int)
        page_size = request.args.get('page_size', 10, type=int)
        search = request.args.get('search', '', type=str).strip()
        role = request.args.get('role', '', type=str).strip()
        is_active_str = request.args.get('is_active', '', type=str).strip()
        
        # 构建查询
        query = User.query
        
        # 搜索过滤
        if search:
            query = query.filter(
                or_(
                    User.username.like(f'%{search}%'),
                    User.real_name.like(f'%{search}%'),
                    User.email.like(f'%{search}%')
                )
            )
        
        # 角色过滤
        if role and role in ['admin', 'engineer', 'user']:
            query = query.filter(User.role == role)
        
        # 状态过滤
        if is_active_str:
            is_active = is_active_str.lower() == 'true'
            query = query.filter(User.is_active == is_active)
        
        # 按创建时间倒序排序
        query = query.order_by(User.created_at.desc())
        
        # 分页
        total = query.count()
        users = query.paginate(page=page, per_page=page_size, error_out=False).items
        
        # 序列化用户数据
        users_data = []
        for user in users:
            users_data.append({
                'id': user.id,
                'username': user.username,
                'real_name': user.real_name,
                'email': user.email,
                'role': user.role,
                'is_active': user.is_active,
                'created_at': user.created_at.isoformat() if user.created_at else None,
                'updated_at': user.updated_at.isoformat() if user.updated_at else None,
                'last_login': user.last_login.isoformat() if user.last_login else None
            })
        
        return jsonify({
            'users': users_data,
            'total': total,
            'page': page,
            'page_size': page_size,
            'total_pages': (total + page_size - 1) // page_size
        }), 200
        
    except Exception as e:
        return jsonify({
            'error': 'Failed to get users',
            'message': str(e)
        }), 500


@admin_bp.route('/users/<int:user_id>', methods=['GET'])
@jwt_required()
@admin_required()
def get_user(user_id):
    """
    获取单个用户详情
    """
    try:
        user = User.query.get(user_id)
        if not user:
            return jsonify({
                'error': 'User not found',
                'message': '用户不存在'
            }), 404
        
        user_data = {
            'id': user.id,
            'username': user.username,
            'real_name': user.real_name,
            'email': user.email,
            'role': user.role,
            'is_active': user.is_active,
            'created_at': user.created_at.isoformat() if user.created_at else None,
            'updated_at': user.updated_at.isoformat() if user.updated_at else None,
            'last_login': user.last_login.isoformat() if user.last_login else None
        }
        
        return jsonify(user_data), 200
        
    except Exception as e:
        return jsonify({
            'error': 'Failed to get user',
            'message': str(e)
        }), 500


@admin_bp.route('/users', methods=['POST'])
@jwt_required()
@admin_required()
def create_user():
    """
    创建新用户
    
    请求体:
        {
            "username": "string",      // 必填
            "password": "string",      // 必填
            "real_name": "string",     // 可选
            "email": "string",         // 可选
            "role": "user",            // 可选，默认 user
            "is_active": true          // 可选，默认 true
        }
    """
    try:
        data = request.get_json()
        
        # 验证必填字段
        if not data.get('username'):
            return jsonify({
                'error': 'Username is required',
                'message': '用户名不能为空'
            }), 400
        
        if not data.get('password'):
            return jsonify({
                'error': 'Password is required',
                'message': '密码不能为空'
            }), 400
        
        # 检查用户名是否已存在
        existing_user = User.query.filter_by(username=data['username']).first()
        if existing_user:
            return jsonify({
                'error': 'Username already exists',
                'message': '用户名已存在'
            }), 400
        
        # 验证角色
        role = data.get('role', 'user')
        if role not in ['admin', 'engineer', 'user']:
            return jsonify({
                'error': 'Invalid role',
                'message': '角色必须是 admin、engineer 或 user'
            }), 400
        
        # 创建新用户
        new_user = User(
            username=data['username'],
            real_name=data.get('real_name'),
            email=data.get('email'),
            role=role,
            is_active=data.get('is_active', True)
        )
        
        # ✅ 使用 set_password 方法设置密码（bcrypt哈希）
        new_user.set_password(data['password'])
        
        db.session.add(new_user)
        db.session.commit()
        
        return jsonify({
            'message': '用户创建成功',
            'user': {
                'id': new_user.id,
                'username': new_user.username,
                'real_name': new_user.real_name,
                'email': new_user.email,
                'role': new_user.role,
                'is_active': new_user.is_active
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': 'Failed to create user',
            'message': str(e)
        }), 500


@admin_bp.route('/users/<int:user_id>', methods=['PUT'])
@jwt_required()
@admin_required()
def update_user(user_id):
    """
    更新用户信息
    
    请求体:
        {
            "real_name": "string",     // 可选
            "email": "string",         // 可选
            "role": "user",            // 可选
            "is_active": true          // 可选
        }
    """
    try:
        user = User.query.get(user_id)
        if not user:
            return jsonify({
                'error': 'User not found',
                'message': '用户不存在'
            }), 404
        
        data = request.get_json()
        
        # 防止管理员禁用自己
        current_user_id = get_jwt_identity()
        current_user = User.query.get(int(current_user_id))
        if user.id == current_user.id and 'is_active' in data and not data['is_active']:
            return jsonify({
                'error': 'Cannot disable yourself',
                'message': '不能禁用自己的账号'
            }), 400
        
        # 更新字段
        if 'real_name' in data:
            user.real_name = data['real_name']
        
        if 'email' in data:
            user.email = data['email']
        
        if 'role' in data:
            if data['role'] not in ['admin', 'engineer', 'user']:
                return jsonify({
                    'error': 'Invalid role',
                    'message': '角色必须是 admin、engineer 或 user'
                }), 400
            user.role = data['role']
        
        if 'is_active' in data:
            user.is_active = data['is_active']
        
        db.session.commit()
        
        return jsonify({
            'message': '用户信息更新成功',
            'user': {
                'id': user.id,
                'username': user.username,
                'real_name': user.real_name,
                'email': user.email,
                'role': user.role,
                'is_active': user.is_active
            }
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': 'Failed to update user',
            'message': str(e)
        }), 500


@admin_bp.route('/users/<int:user_id>', methods=['DELETE'])
@jwt_required()
@admin_required()
def delete_user(user_id):
    """
    删除用户（软删除 - 设置 is_active = false）
    """
    try:
        user = User.query.get(user_id)
        if not user:
            return jsonify({
                'error': 'User not found',
                'message': '用户不存在'
            }), 404
        
        # 防止管理员删除自己
        current_user_id = get_jwt_identity()
        current_user = User.query.get(int(current_user_id))
        if user.id == current_user.id:
            return jsonify({
                'error': 'Cannot delete yourself',
                'message': '不能删除自己的账号'
            }), 400
        
        # 软删除（设置为不活跃状态）
        user.is_active = False
        db.session.commit()
        
        return jsonify({
            'message': '用户已被禁用'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': 'Failed to delete user',
            'message': str(e)
        }), 500


@admin_bp.route('/users/<int:user_id>/password', methods=['PUT'])
@jwt_required()
@admin_required()
def reset_password(user_id):
    """
    重置用户密码
    
    请求体:
        {
            "new_password": "string"  // 必填
        }
    """
    try:
        user = User.query.get(user_id)
        if not user:
            return jsonify({
                'error': 'User not found',
                'message': '用户不存在'
            }), 404
        
        data = request.get_json()
        new_password = data.get('new_password')
        
        if not new_password:
            return jsonify({
                'error': 'New password is required',
                'message': '新密码不能为空'
            }), 400
        
        if len(new_password) < 6:
            return jsonify({
                'error': 'Password too short',
                'message': '密码长度至少6个字符'
            }), 400
        
        # ✅ 使用 set_password 方法更新密码（bcrypt哈希）
        user.set_password(new_password)
        db.session.commit()
        
        return jsonify({
            'message': '密码重置成功'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': 'Failed to reset password',
            'message': str(e)
        }), 500


@admin_bp.route('/users/<int:user_id>/status', methods=['PUT'])
@jwt_required()
@admin_required()
def toggle_user_status(user_id):
    """
    切换用户启用/禁用状态
    
    请求体:
        {
            "is_active": true/false  // 必填
        }
    """
    try:
        user = User.query.get(user_id)
        if not user:
            return jsonify({
                'error': 'User not found',
                'message': '用户不存在'
            }), 404
        
        # 防止管理员禁用自己
        current_user_id = get_jwt_identity()
        current_user = User.query.get(int(current_user_id))
        if user.id == current_user.id:
            return jsonify({
                'error': 'Cannot disable yourself',
                'message': '不能禁用自己的账号'
            }), 400
        
        data = request.get_json()
        is_active = data.get('is_active')
        
        if is_active is None:
            return jsonify({
                'error': 'is_active is required',
                'message': '缺少 is_active 参数'
            }), 400
        
        user.is_active = is_active
        db.session.commit()
        
        status_text = '启用' if is_active else '禁用'
        return jsonify({
            'message': f'用户已{status_text}'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({
            'error': 'Failed to toggle user status',
            'message': str(e)
        }), 500


@admin_bp.route('/statistics/users', methods=['GET'])
@jwt_required()
@admin_required()
def get_user_statistics():
    """
    获取用户统计信息
    
    返回:
        {
            "total_users": 总用户数,
            "active_users": 活跃用户数,
            "by_role": {
                "admin": 管理员数量,
                "engineer": 工程师数量,
                "user": 普通用户数量
            }
        }
    """
    try:
        total_users = User.query.count()
        active_users = User.query.filter_by(is_active=True).count()
        
        # 按角色统计
        admin_count = User.query.filter_by(role='admin').count()
        engineer_count = User.query.filter_by(role='engineer').count()
        user_count = User.query.filter_by(role='user').count()
        
        return jsonify({
            'total_users': total_users,
            'active_users': active_users,
            'inactive_users': total_users - active_users,
            'by_role': {
                'admin': admin_count,
                'engineer': engineer_count,
                'user': user_count
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'error': 'Failed to get user statistics',
            'message': str(e)
        }), 500
