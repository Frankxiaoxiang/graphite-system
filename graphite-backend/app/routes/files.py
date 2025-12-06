from flask import Blueprint, request, jsonify, send_file, current_app
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

def allowed_file(filename):
    """检查文件扩展名是否允许"""
    if '.' not in filename:
        return False
    ext = filename.rsplit('.', 1)[1].lower()
    return ext in current_app.config['ALLOWED_EXTENSIONS']

def get_file_path(experiment_id, field_name, filename):
    """
    生成文件存储路径 - 生产级实现
    返回: (绝对路径, 相对路径)
    """
    # 获取当前年月
    now = datetime.now()
    year = now.year
    month = now.month
    
    # ✅ 相对路径 - 存入数据库
    relative_path = os.path.join(
        str(year), 
        str(month).zfill(2),  # 月份补零
        str(experiment_id)
    )
    
    # ✅ 绝对路径 - 用于文件系统操作
    upload_root = current_app.config['UPLOAD_FOLDER']
    absolute_dir = os.path.join(upload_root, relative_path)
    
    # 确保目录存在
    os.makedirs(absolute_dir, exist_ok=True)
    
    # ✅ 修复：安全获取文件扩展名
    if '.' in filename:
        file_ext = filename.rsplit('.', 1)[1].lower()
    else:
        file_ext = 'bin'  # 无扩展名文件使用 .bin
    
    # 生成唯一文件名
    unique_filename = f"{field_name}_{uuid.uuid4().hex}.{file_ext}"
    
    # 完整路径
    absolute_path = os.path.join(absolute_dir, unique_filename)
    relative_full_path = os.path.join(relative_path, unique_filename)
    
    # ✅ 使用正斜杠，跨平台兼容
    relative_full_path = relative_full_path.replace(os.sep, '/')
    
    return absolute_path, relative_full_path

def compress_image(file_path, quality=70, max_size_mb=2):
    """压缩图片"""
    try:
        file_size_mb = os.path.getsize(file_path) / (1024 * 1024)
        
        if file_size_mb > max_size_mb:
            with Image.open(file_path) as img:
                # 转换RGBA到RGB
                if img.mode in ('RGBA', 'LA', 'P'):
                    background = Image.new('RGB', img.size, (255, 255, 255))
                    background.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
                    img = background
                
                # 保存压缩后的图片
                img.save(file_path, format='JPEG', quality=quality, optimize=True)
                
                print(f"✅ 图片已压缩: {file_size_mb:.2f}MB → {os.path.getsize(file_path)/(1024*1024):.2f}MB")
    except Exception as e:
        print(f"⚠️ 图片压缩失败: {str(e)}")
        pass  # 压缩失败不影响上传

@files_bp.route('/upload', methods=['POST', 'OPTIONS'])
@jwt_required(optional=True)  # 允许OPTIONS请求无需JWT
def upload_file():
    """文件上传 - 生产级实现"""
    
    # 处理OPTIONS预检请求
    if request.method == 'OPTIONS':
        return '', 200
    
    try:
        current_user_id = get_jwt_identity()
        if not current_user_id:
            return jsonify({'error': '未登录'}), 401
        
        current_user_id = int(current_user_id)
        
        print(f"\n{'='*60}")
        print(f"📁 文件上传请求")
        print(f"{'='*60}")
        print(f"用户ID: {current_user_id}")
        
        # 检查文件
        if 'file' not in request.files:
            print("❌ 错误: 请求中没有文件")
            return jsonify({'error': '没有文件'}), 400
        
        file = request.files['file']
        experiment_id_str = request.form.get('experiment_id')
        field_name = request.form.get('field_name')
        
        # ✅ 处理 experiment_id - 支持 'temp' 和 NULL
        if experiment_id_str and experiment_id_str != 'temp':
            try:
                experiment_id = int(experiment_id_str)
            except ValueError:
                experiment_id = None
        else:
            experiment_id = None  # 'temp' 或空，设为NULL
        
        print(f"实验ID (原始): {experiment_id_str}")
        print(f"实验ID (处理后): {experiment_id}")
        print(f"字段名: {field_name}")
        print(f"文件名: {file.filename}")
        
        # 只验证 field_name
        if not field_name:
            print("❌ 错误: 缺少field_name")
            return jsonify({'error': '字段名称不能为空'}), 400
        
        if file.filename == '':
            print("❌ 错误: 文件名为空")
            return jsonify({'error': '没有选择文件'}), 400
        
        # ✅ 保留原始文件名（包含中文）
        original_filename = file.filename
        
        if not allowed_file(original_filename):
            print(f"❌ 错误: 不支持的文件类型 {original_filename}")
            return jsonify({'error': '不支持的文件类型'}), 400
        
        # 检查文件大小
        file.seek(0, os.SEEK_END)
        file_size = file.tell()
        file.seek(0)
        
        max_size = current_app.config['MAX_CONTENT_LENGTH']
        if file_size > max_size:
            print(f"❌ 错误: 文件过大 {file_size} > {max_size}")
            return jsonify({'error': f'文件大小超过限制（{max_size/(1024*1024):.0f}MB）'}), 400
        
        # ✅ 文件路径使用 'temp' 或 实际ID
        storage_id = experiment_id if experiment_id else 'temp'
        absolute_path, relative_path = get_file_path(storage_id, field_name, original_filename)
        
        print(f"保存路径: {absolute_path}")
        print(f"相对路径: {relative_path}")
        
        file.save(absolute_path)
        
        # 如果是图片,进行压缩
        if original_filename.lower().endswith(('.png', '.jpg', '.jpeg')):
            compress_image(absolute_path)
        
        # 获取最终文件大小
        final_size = os.path.getsize(absolute_path)
        
        # 记录到数据库
        file_upload = FileUpload(
            experiment_id=experiment_id,  # ✅ 可以是 None
            field_name=field_name,
            original_filename=original_filename,
            saved_filename=os.path.basename(absolute_path),
            file_path=relative_path,  # ✅ 只存储相对路径
            file_size=final_size,
            file_type=original_filename.rsplit('.', 1)[1].lower() if '.' in original_filename else 'bin',
            mime_type=file.mimetype,
            uploaded_by=current_user_id
        )
        db.session.add(file_upload)
        db.session.commit()
        
        # ✅ 生成文件访问URL
        file_url = f"{current_app.config['FILE_URL_PREFIX']}/{relative_path}"
        
        print(f"✅ 文件上传成功")
        print(f"文件ID: {file_upload.id}")
        print(f"访问URL: {file_url}")
        print(f"{'='*60}\n")
        
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
            'file_url': file_url,      # ✅ 返回URL而非路径
            'file_size': final_size
        }), 201
        
    except Exception as e:
        print(f"❌ 文件上传失败: {str(e)}")
        import traceback
        traceback.print_exc()
        db.session.rollback()
        return jsonify({'error': f'文件上传失败: {str(e)}'}), 500

@files_bp.route('/<path:filepath>', methods=['GET'])
def serve_file(filepath):
    """
    提供文件访问 - 生产级实现
    示例: GET /files/2025/11/temp/carbon_loading_photo_abc123.jpg
    """
    try:
        print(f"\n{'='*60}")
        print(f"📂 文件访问请求: {filepath}")
        
        upload_root = current_app.config['UPLOAD_FOLDER']
        absolute_path = os.path.join(upload_root, filepath)
        
        # 安全检查：防止目录遍历攻击
        absolute_path = os.path.abspath(absolute_path)
        upload_root_abs = os.path.abspath(upload_root)
        
        if not absolute_path.startswith(upload_root_abs):
            print(f"❌ 安全检查失败: 路径不在上传目录内")
            print(f"{'='*60}\n")
            return jsonify({'error': '非法访问'}), 403
        
        if not os.path.exists(absolute_path):
            print(f"❌ 文件不存在: {absolute_path}")
            print(f"{'='*60}\n")
            return jsonify({'error': '文件不存在'}), 404
        
        print(f"✅ 返回文件")
        print(f"{'='*60}\n")
        
        return send_file(absolute_path)
        
    except Exception as e:
        print(f"❌ 文件访问失败: {str(e)}")
        import traceback
        traceback.print_exc()
        print(f"{'='*60}\n")
        return jsonify({'error': '文件访问失败'}), 500

@files_bp.route('/download/<int:file_id>', methods=['GET'])
@jwt_required()
def download_file(file_id):
    """文件下载"""
    try:
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        file_upload = FileUpload.query.get(file_id)
        if not file_upload:
            return jsonify({'error': '文件不存在'}), 404
        
        # 权限检查
        if user.role == 'user' and file_upload.uploaded_by != current_user_id:
            return jsonify({'error': '无权访问此文件'}), 403
        
        # 构建绝对路径
        upload_root = current_app.config['UPLOAD_FOLDER']
        absolute_path = os.path.join(upload_root, file_upload.file_path)
        
        if not os.path.exists(absolute_path):
            return jsonify({'error': '文件已丢失'}), 404
        
        # 记录日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='download_file',
            target_type='file',
            target_id=file_upload.id,
            description=f'下载文件: {file_upload.original_filename}',
            ip_address=request.remote_addr
        )
        
        return send_file(
            absolute_path,
            as_attachment=True,
            download_name=file_upload.original_filename
        )
        
    except Exception as e:
        print(f"❌ 文件下载失败: {str(e)}")
        return jsonify({'error': '文件下载失败'}), 500

@files_bp.route('/<int:file_id>', methods=['DELETE'])
@jwt_required()
def delete_file(file_id):
    """删除文件"""
    try:
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        file_upload = FileUpload.query.get(file_id)
        if not file_upload:
            return jsonify({'error': '文件不存在'}), 404
        
        # 权限检查
        if user.role == 'user' and file_upload.uploaded_by != current_user_id:
            return jsonify({'error': '无权删除此文件'}), 403
        
        # 删除物理文件
        upload_root = current_app.config['UPLOAD_FOLDER']
        absolute_path = os.path.join(upload_root, file_upload.file_path)
        
        if os.path.exists(absolute_path):
            os.remove(absolute_path)
        
        original_filename = file_upload.original_filename
        
        # 删除数据库记录
        db.session.delete(file_upload)
        db.session.commit()
        
        # 记录日志
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
        print(f"❌ 文件删除失败: {str(e)}")
        db.session.rollback()
        return jsonify({'error': '文件删除失败'}), 500

@files_bp.route('/experiment/<experiment_id>', methods=['GET'])
@jwt_required()
def get_experiment_files(experiment_id):
    """获取实验的所有文件"""
    try:
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        files = FileUpload.query.filter_by(
            experiment_id=experiment_id
        ).order_by(FileUpload.created_at.desc()).all()
        
        # 权限过滤
        if user.role == 'user':
            files = [f for f in files if f.uploaded_by == current_user_id]
        
        result = []
        file_url_prefix = current_app.config['FILE_URL_PREFIX']
        
        for file in files:
            file_data = file.to_dict()
            file_data['url'] = f"{file_url_prefix}/{file.file_path}"
            result.append(file_data)
        
        return jsonify({
            'files': result,
            'total': len(result)
        }), 200
        
    except Exception as e:
        print(f"❌ 获取文件列表失败: {str(e)}")
        return jsonify({'error': '获取文件列表失败'}), 500
