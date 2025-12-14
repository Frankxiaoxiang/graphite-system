# app/utils/decorators.py
"""
权限装饰器 - 用于保护需要管理员权限的路由
"""

from functools import wraps
from flask import jsonify
from flask_jwt_extended import get_jwt_identity
from app.models.user import User


def admin_required():
    """
    管理员权限装饰器
    使用方法:
        @app.route('/api/admin/users')
        @jwt_required()
        @admin_required()
        def admin_only_route():
            pass
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            try:
                # 1. 获取当前用户 ID（从 JWT）
                current_user_id = get_jwt_identity()
                
                # 2. ✅ 核心修改：用 ID 查询用户
                # 注意：确保将 ID 转换为 int，防止 JWT 解析出来是字符串
                if current_user_id is None:
                     return jsonify({'error': 'Invalid Token', 'message': '无法获取用户身份'}), 401

                user = User.query.get(int(current_user_id))
                
                # 3. 检查用户是否存在
                if not user:
                    return jsonify({
                        'error': 'User not found',
                        'message': '用户不存在'
                    }), 404
                
                # 4. 检查用户是否被禁用
                if not user.is_active:
                    return jsonify({
                        'error': 'Account disabled',
                        'message': '账号已被禁用'
                    }), 403
                
                # 5. 检查是否为管理员
                if user.role != 'admin':
                    return jsonify({
                        'error': 'Admin permission required',
                        'message': '需要管理员权限'
                    }), 403
                
                # 通过所有检查，执行原函数
                return f(*args, **kwargs)
                
            except Exception as e:
                # 打印错误到控制台，方便调试
                print(f"❌ 权限检查异常: {str(e)}")
                return jsonify({
                    'error': 'Permission check failed',
                    'message': str(e)
                }), 500
        
        return decorated_function
    return decorator


def role_required(allowed_roles):
    """
    角色权限装饰器（通用版本）
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            try:
                # 1. 获取当前用户 ID
                current_user_id = get_jwt_identity()
                
                # 2. ✅ 同步修改：用 ID 查询用户
                if current_user_id is None:
                     return jsonify({'error': 'Invalid Token', 'message': '无法获取用户身份'}), 401

                user = User.query.get(int(current_user_id))
                
                if not user:
                    return jsonify({
                        'error': 'User not found',
                        'message': '用户不存在'
                    }), 404
                
                if not user.is_active:
                    return jsonify({
                        'error': 'Account disabled',
                        'message': '账号已被禁用'
                    }), 403
                
                if user.role not in allowed_roles:
                    return jsonify({
                        'error': 'Insufficient permissions',
                        'message': f'需要以下角色之一: {", ".join(allowed_roles)}'
                    }), 403
                
                return f(*args, **kwargs)
                
            except Exception as e:
                print(f"❌ 权限检查异常: {str(e)}")
                return jsonify({
                    'error': 'Permission check failed',
                    'message': str(e)
                }), 500
        
        return decorated_function
    return decorator