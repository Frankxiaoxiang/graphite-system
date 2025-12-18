# app/routes/backup.py
# 异步版本 - 支持任务状态轮询
# ✅ 符合项目规范：Blueprint定义时不设置url_prefix

from flask import Blueprint, request, jsonify, send_file
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.utils.decorators import admin_required
from app.utils.backup_manager import BackupManager

# ✅ 符合项目规范：不在这里设置url_prefix
backup_bp = Blueprint('backup', __name__)


@backup_bp.route('', methods=['POST'])
@jwt_required()
@admin_required()
def create_backup():
    """
    创建数据库备份（异步）
    
    立即返回任务ID，前端通过轮询查询任务状态
    
    Returns:
        201: {success: true, task_id: str, filename: str, message: str}
        500: {success: false, message: str}
    """
    try:
        current_user_id = int(get_jwt_identity())
        
        result = BackupManager.create_backup_async(current_user_id)
        
        if result['success']:
            return jsonify(result), 201
        else:
            return jsonify(result), 500
            
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'备份失败: {str(e)}'
        }), 500


@backup_bp.route('/task/<task_id>', methods=['GET'])
@jwt_required()
@admin_required()
def get_task_status(task_id):
    """
    获取备份任务状态（用于前端轮询）
    
    Args:
        task_id: 任务ID
        
    Returns:
        200: {task_id, status, filename, file_size, error_message, ...}
        404: {error: '任务不存在'}
    """
    try:
        result = BackupManager.get_task_status(task_id)
        
        if 'error' in result:
            return jsonify(result), 404
        else:
            return jsonify(result), 200
            
    except Exception as e:
        return jsonify({
            'error': f'查询任务状态失败: {str(e)}'
        }), 500


@backup_bp.route('', methods=['GET'])
@jwt_required()
@admin_required()
def list_backups():
    """
    获取备份列表（包含任务状态）
    
    Returns:
        200: {backups: [], total: int}
        500: {error: str}
    """
    try:
        backups = BackupManager.list_backups()
        return jsonify({
            'backups': backups,
            'total': len(backups)
        }), 200
        
    except Exception as e:
        return jsonify({
            'error': f'获取备份列表失败: {str(e)}'
        }), 500


@backup_bp.route('/<filename>', methods=['GET'])
@jwt_required()
@admin_required()
def download_backup(filename):
    """
    下载备份文件
    
    Args:
        filename: 备份文件名
        
    Returns:
        200: 文件流
        400: 非法的文件路径
        404: 文件不存在
        500: 下载失败
    """
    try:
        # ✅ 安全验证：只允许 .sql 文件
        if not filename.endswith('.sql'):
            return jsonify({'error': '只支持下载 .sql 文件'}), 400
        
        filepath = BackupManager.BACKUP_DIR / filename
        
        # 验证文件存在
        if not filepath.exists():
            return jsonify({'error': '备份文件不存在'}), 404
        
        # ✅ 安全检查：防止目录遍历攻击
        if not str(filepath.resolve()).startswith(str(BackupManager.BACKUP_DIR.resolve())):
            return jsonify({'error': '非法的文件路径'}), 400
        
        # 发送文件
        return send_file(
            filepath,
            as_attachment=True,
            download_name=filename,
            mimetype='application/sql'
        )
        
    except Exception as e:
        return jsonify({'error': f'下载失败: {str(e)}'}), 500


@backup_bp.route('/<filename>', methods=['DELETE'])
@jwt_required()
@admin_required()
def delete_backup(filename):
    """
    删除备份文件
    
    Args:
        filename: 备份文件名
        
    Returns:
        200: {success: true, message: str}
        400: {success: false, message: str}
        500: {error: str}
    """
    try:
        current_user_id = int(get_jwt_identity())
        
        result = BackupManager.delete_backup(filename, current_user_id)
        
        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 400
            
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'删除失败: {str(e)}'
        }), 500


@backup_bp.route('/statistics', methods=['GET'])
@jwt_required()
@admin_required()
def get_statistics():
    """
    获取备份统计信息
    
    Returns:
        200: {total_backups, total_size, last_backup_time, database_size, running_tasks}
        500: {error: str}
    """
    try:
        stats = BackupManager.get_statistics()
        return jsonify(stats), 200
        
    except Exception as e:
        return jsonify({
            'error': f'获取统计信息失败: {str(e)}'
        }), 500
