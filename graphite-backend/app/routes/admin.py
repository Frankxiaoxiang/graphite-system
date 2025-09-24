from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.system_log import SystemLog
from app.utils.permissions import require_permission
from datetime import datetime
import subprocess
import os

admin_bp = Blueprint('admin', __name__)

@admin_bp.route('/users', methods=['GET'])
@jwt_required()
@require_permission('manage_users')
def get_users():
    """获取用户列表"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        users = User.query.order_by(User.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        result = []
        for user in users.items:
            user_data = user.to_dict()
            # 添加统计信息
            user_data['experiment_count'] = user.experiments.count()
            result.append(user_data)
        
        return jsonify({
            'users': result,
            'pagination': {
                'page': users.page,
                'pages': users.pages,
                'per_page': users.per_page,
                'total': users.total
            }
        }), 200
        
    except Exception as e:
        return jsonify({'error': '获取用户列表失败'}), 500

@admin_bp.route('/users', methods=['POST'])
@jwt_required()
@require_permission('manage_users')
def create_user():
    """创建新用户"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        username = data.get('username')
        password = data.get('password')
        role = data.get('role', 'user')
        real_name = data.get('real_name')
        email = data.get('email')
        
        if not username or not password:
            return jsonify({'error': '用户名和密码不能为空'}), 400
        
        if role not in ['admin', 'engineer', 'user']:
            return jsonify({'error': '无效的用户角色'}), 400
        
        # 检查用户名是否已存在
        existing_user = User.query.filter_by(username=username).first()
        if existing_user:
            return jsonify({'error': '用户名已存在'}), 400
        
        # 创建用户
        user = User(
            username=username,
            role=role,
            real_name=real_name,
            email=email
        )
        user.set_password(password)
        
        db.session.add(user)
        db.session.commit()
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='create_user',
            target_type='user',
            target_id=user.id,
            description=f'创建用户: {username} ({role})',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': '用户创建成功',
            'user': user.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '创建用户失败'}), 500

@admin_bp.route('/users/<int:user_id>', methods=['PUT'])
@jwt_required()
@require_permission('manage_users')
def update_user(user_id):
    """更新用户信息"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': '用户不存在'}), 404
        
        # 更新字段
        if 'username' in data:
            # 检查用户名是否已被其他用户使用
            existing_user = User.query.filter(
                User.username == data['username'],
                User.id != user_id
            ).first()
            if existing_user:
                return jsonify({'error': '用户名已存在'}), 400
            user.username = data['username']
        
        if 'role' in data:
            if data['role'] not in ['admin', 'engineer', 'user']:
                return jsonify({'error': '无效的用户角色'}), 400
            user.role = data['role']
        
        if 'real_name' in data:
            user.real_name = data['real_name']
        
        if 'email' in data:
            user.email = data['email']
        
        if 'is_active' in data:
            user.is_active = data['is_active']
        
        if 'password' in data and data['password']:
            user.set_password(data['password'])
        
        user.updated_at = datetime.utcnow()
        db.session.commit()
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='update_user',
            target_type='user',
            target_id=user.id,
            description=f'更新用户: {user.username}',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': '用户更新成功',
            'user': user.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '更新用户失败'}), 500

@admin_bp.route('/users/<int:user_id>', methods=['DELETE'])
@jwt_required()
@require_permission('manage_users')
def delete_user(user_id):
    """删除用户"""
    try:
        current_user_id = get_jwt_identity()
        
        if user_id == current_user_id:
            return jsonify({'error': '不能删除自己的账户'}), 400
        
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': '用户不存在'}), 404
        
        username = user.username
        
        # 检查用户是否有关联数据
        if user.experiments.count() > 0:
            return jsonify({'error': '用户有关联的实验数据，无法删除'}), 400
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='delete_user',
            target_type='user',
            target_id=user.id,
            description=f'删除用户: {username}',
            ip_address=request.remote_addr
        )
        
        db.session.delete(user)
        db.session.commit()
        
        return jsonify({'message': '用户删除成功'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '删除用户失败'}), 500

@admin_bp.route('/backup', methods=['POST'])
@jwt_required()
@require_permission('system_admin')
def backup_database():
    """数据库备份"""
    try:
        current_user_id = get_jwt_identity()
        
        # 生成备份文件名
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_filename = f'graphite_db_backup_{timestamp}.sql'
        backup_path = os.path.join('backups', backup_filename)
        
        # 确保备份目录存在
        os.makedirs('backups', exist_ok=True)
        
        # 执行备份命令
        cmd = [
            'mysqldump',
            '-u', 'root',
            '-p',  # 这里需要根据实际情况配置密码
            'graphite_db'
        ]
        
        with open(backup_path, 'w') as backup_file:
            result = subprocess.run(cmd, stdout=backup_file, stderr=subprocess.PIPE, text=True)
        
        if result.returncode != 0:
            return jsonify({'error': f'备份失败: {result.stderr}'}), 500
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='backup_database',
            description=f'数据库备份: {backup_filename}',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': '数据库备份成功',
            'backup_file': backup_filename,
            'backup_path': backup_path
        }), 200
        
    except Exception as e:
        return jsonify({'error': f'备份失败: {str(e)}'}), 500

@admin_bp.route('/logs', methods=['GET'])
@jwt_required()
@require_permission('system_admin')
def get_system_logs():
    """获取系统日志"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 50, type=int)
        action = request.args.get('action')
        user_id = request.args.get('user_id', type=int)
        
        query = SystemLog.query
        
        if action:
            query = query.filter_by(action=action)
        
        if user_id:
            query = query.filter_by(user_id=user_id)
        
        logs = query.order_by(SystemLog.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        result = [log.to_dict() for log in logs.items]
        
        return jsonify({
            'logs': result,
            'pagination': {
                'page': logs.page,
                'pages': logs.pages,
                'per_page': logs.per_page,
                'total': logs.total
            }
        }), 200
        
    except Exception as e:
        return jsonify({'error': '获取系统日志失败'}), 500