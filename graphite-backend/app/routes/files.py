from flask import Blueprint, request, jsonify, send_file
from flask_jwt_extended import jwt_required, get_jwt_identity
from werkzeug.utils import secure_filename
from PIL import Image
import os
import uuid
from datetime import datetime
from app import db
from app.models.user import User
from app.models.file_upload import FileUpload
from app.models.system_log import SystemLog

files_bp = Blueprint('files', __name__)

# 允许的文件扩展名
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'pdf'}

def allowed_file(filename):
    """检查文件扩展名是否允许"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_file_path(experiment_id, field_name, filename):
    """生成文件存储路径"""
    year = datetime.now().year
    month = datetime.now().month
    upload_dir = os.path.join('uploads', str(year), str(month), str(experiment_id))
    
    # 确保目录存在
    os.makedirs(upload_dir, exist_ok=True)
    
    # 生成唯一文件名
    file_ext = filename.rsplit('.', 1)[1].lower()
    unique_filename = f"{field_name}_{uuid.uuid4().hex}.{file_ext}"
    
    return os.path.join(upload_dir, unique_filename)

def compress_image(file_path, quality=70):
    """压缩图片"""
    try:
        # 检查文件大小
        if os.path.getsize(file_path) > 2 * 1024 * 1024:  # 大于2MB
            with Image.open(file_path) as img:
                # 保持原始格式
                if img.format in ['JPEG', 'PNG']:
                    img.save(file_path, format=img.format, quality=quality, optimize=True)
    except Exception:
        pass  # 如果压缩失败，保留原文件

@files_bp.route('/upload', methods=['POST'])
@jwt_required()
def upload_file():
    """文件上传"""
    try:
        current_user_id = get_jwt_identity()
        
        # 检查请求中是否有文件
        if 'file' not in request.files:
            return jsonify({'error': '没有文件'}), 400
        
        file = request.files['file']
        experiment_id = request.form.get('experiment_id')
        field_name = request.form.get('field_name')
        
        if not experiment_id or not field_name:
            return jsonify({'error': '实验ID和字段名称不能为空'}), 400
        
        if file.filename == '':
            return jsonify({'error': '没有选择文件'}), 400
        
        if not allowed_file(file.filename):
            return jsonify({'error': '不支持的文件类型'}), 400
        
        # 检查文件大小
        file.seek(0, os.SEEK_END)
        file_size = file.tell()
        file.seek(0)
        
        if file_size > 10 * 1024 * 1024:  # 10MB
            return jsonify({'error': '文件大小超过限制（10MB）'}), 400
        
        # 保存文件
        original_filename = secure_filename(file.filename)
        file_path = get_file_path(experiment_id, field_name, original_filename)
        file.save(file_path)
        
        # 如果是图片，进行压缩
        if original_filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            compress_image(file_path)
        
        # 记录到数据库
        file_upload = FileUpload(
            experiment_id=experiment_id,
            field_name=field_name,
            original_filename=original_filename,
            saved_filename=os.path.basename(file_path),
            file_path=file_path,
            file_size=os.path.getsize(file_path),
            file_type=original_filename.rsplit('.', 1)[1].lower(),
            mime_type=file.mimetype,
            uploaded_by=current_user_id
        )
        db.session.add(file_upload)
        db.session.commit()
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='upload_file',
            target_type='file',
            target_id=file_upload.id,
            description=f'上传文件: {original_filename}',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': '文件上传成功',
            'file_id': file_upload.id,
            'filename': original_filename,
            'file_path': file_path,
            'file_size': file_upload.file_size
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'文件上传失败: {str(e)}'}), 500

@files_bp.route('/download/<int:file_id>', methods=['GET'])
@jwt_required()
def download_file(file_id):
    """文件下载"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        file_upload = FileUpload.query.get(file_id)
        if not file_upload:
            return jsonify({'error': '文件不存在'}), 404
        
        # 权限检查：普通用户只能下载自己上传的文件
        if user.role == 'user' and file_upload.uploaded_by != current_user_id:
            return jsonify({'error': '无权访问此文件'}), 403
        
        if not os.path.exists(file_upload.file_path):
            return jsonify({'error': '文件已丢失'}), 404
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='download_file',
            target_type='file',
            target_id=file_upload.id,
            description=f'下载文件: {file_upload.original_filename}',
            ip_address=request.remote_addr
        )
        
        return send_file(
            file_upload.file_path,
            as_attachment=True,
            download_name=file_upload.original_filename
        )
        
    except Exception as e:
        return jsonify({'error': '文件下载失败'}), 500

@files_bp.route('/<int:file_id>', methods=['DELETE'])
@jwt_required()
def delete_file(file_id):
    """删除文件"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        file_upload = FileUpload.query.get(file_id)
        if not file_upload:
            return jsonify({'error': '文件不存在'}), 404
        
        # 权限检查：普通用户只能删除自己上传的文件
        if user.role == 'user' and file_upload.uploaded_by != current_user_id:
            return jsonify({'error': '无权删除此文件'}), 403
        
        # 删除物理文件
        if os.path.exists(file_upload.file_path):
            os.remove(file_upload.file_path)
        
        original_filename = file_upload.original_filename
        
        # 删除数据库记录
        db.session.delete(file_upload)
        db.session.commit()
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='delete_file',
            target_type='file',
            target_id=file_id,
            description=f'删除文件: {original_filename}',
            ip_address=request.remote_addr
        )
        
        return jsonify({'message': '文件删除成功'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '文件删除失败'}), 500

@files_bp.route('/experiment/<int:experiment_id>', methods=['GET'])
@jwt_required()
def get_experiment_files(experiment_id):
    """获取实验的所有文件"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        files = FileUpload.query.filter_by(experiment_id=experiment_id).all()
        
        result = []
        for file_upload in files:
            # 权限检查：普通用户只能查看自己上传的文件
            if user.role == 'user' and file_upload.uploaded_by != current_user_id:
                continue
            
            file_data = {
                'id': file_upload.id,
                'field_name': file_upload.field_name,
                'original_filename': file_upload.original_filename,
                'file_size': file_upload.file_size,
                'file_type': file_upload.file_type,
                'uploaded_by': file_upload.uploader.username if file_upload.uploader else None,
                'created_at': file_upload.created_at.isoformat() if file_upload.created_at else None
            }
            result.append(file_data)
        
        return jsonify({'files': result}), 200
        
    except Exception as e:
        return jsonify({'error': '获取文件列表失败'}), 500