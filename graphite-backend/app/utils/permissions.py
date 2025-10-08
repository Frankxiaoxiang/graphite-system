from functools import wraps
from flask import jsonify
from flask_jwt_extended import get_jwt_identity
from app.models.user import User

def require_permission(permission):
    """权限装饰器"""
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            # ✅ 修改：转换为整数
            current_user_id = int(get_jwt_identity())
            user = User.query.get(current_user_id)
            
            if not user or not user.has_permission(permission):
                return jsonify({'error': '权限不足'}), 403
            
            return f(*args, **kwargs)
        return decorated_function
    return decorator

def check_experiment_permission(user, experiment, action='view'):
    """检查实验操作权限"""
    # 管理员和工程师可以访问所有实验
    if user.role in ['admin', 'engineer']:
        return True
    
    # 普通用户只能访问自己创建的实验
    if user.role == 'user' and experiment.created_by == user.id:
        return True
    
    return False