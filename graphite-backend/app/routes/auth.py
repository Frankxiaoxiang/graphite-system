from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, create_refresh_token, jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.system_log import SystemLog
from datetime import datetime
import traceback

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    """用户登录"""
    print("\n" + "="*60)
    print("📥 收到登录请求")
    
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')
        
        print(f"👤 用户名: {username}")
        
        if not username or not password:
            print("❌ 用户名或密码为空")
            return jsonify({'error': '用户名和密码不能为空'}), 400
        
        # 查找用户
        print(f"🔍 查找用户 '{username}'...")
        user = User.query.filter_by(username=username).first()
        
        if not user:
            print(f"❌ 用户 '{username}' 不存在")
            return jsonify({'error': '用户名或密码错误'}), 401
        
        print(f"✅ 找到用户: ID={user.id}, username={user.username}, role={user.role}")
        
        # 验证密码
        print(f"🔑 验证密码...")
        if not user.check_password(password):
            print(f"❌ 密码错误")
            # 记录失败的登录尝试
            SystemLog.log_action(
                user_id=user.id,
                action='login_failed',
                description=f'用户 {username} 登录失败 - 密码错误',
                ip_address=request.remote_addr,
                user_agent=request.headers.get('User-Agent')
            )
            return jsonify({'error': '用户名或密码错误'}), 401
        
        print(f"✅ 密码验证通过")
        
        # 检查激活状态
        print(f"🔍 检查账户激活状态...")
        if not user.is_active:
            print(f"❌ 账户已被禁用")
            return jsonify({'error': '账户已被禁用'}), 401
        
        print(f"✅ 账户已激活")
        
        # 更新最后登录时间
        print(f"📝 更新最后登录时间...")
        user.last_login = datetime.utcnow()
        db.session.commit()
        print(f"✅ 最后登录时间已更新")
        
        # 生成Token
        print(f"🎫 生成JWT Token...")
        access_token = create_access_token(identity=str(user.id))
        refresh_token = create_refresh_token(identity=str(user.id))
        print(f"✅ Token生成成功")
        print(f"   Access Token (前20字符): {access_token[:20]}...")
        
        # 转换用户信息为字典
        print(f"📦 转换用户信息...")
        try:
            user_dict = user.to_dict()
            print(f"✅ 用户信息转换成功")
            print(f"   包含的字段: {list(user_dict.keys())}")
        except Exception as e:
            print(f"❌ 用户信息转换失败!")
            print(f"   错误类型: {type(e).__name__}")
            print(f"   错误信息: {str(e)}")
            print(f"   完整堆栈:")
            traceback.print_exc()
            raise
        
        # 记录成功登录
        print(f"📝 记录登录日志...")
        try:
            SystemLog.log_action(
                user_id=user.id,
                action='login_success',
                description=f'用户 {username} 登录成功',
                ip_address=request.remote_addr,
                user_agent=request.headers.get('User-Agent')
            )
            print(f"✅ 登录日志记录成功")
        except Exception as e:
            print(f"⚠️ 登录日志记录失败 (不影响登录): {str(e)}")
        
        print(f"🎉 登录流程完成！准备返回响应")
        print("="*60 + "\n")
        
        return jsonify({
            'access_token': access_token,
            'refresh_token': refresh_token,
            'user': user_dict
        }), 200
        
    except Exception as e:
        print(f"\n" + "!"*60)
        print(f"❌❌❌ 登录过程发生严重错误！")
        print(f"!"*60)
        print(f"错误类型: {type(e).__name__}")
        print(f"错误信息: {str(e)}")
        print(f"\n完整错误堆栈:")
        print("-"*60)
        traceback.print_exc()
        print("-"*60)
        print("!"*60 + "\n")
        return jsonify({'error': '登录失败，请稍后重试'}), 500

@auth_bp.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    """刷新访问令牌"""
    try:
        # ✅ 修改：get_jwt_identity()返回字符串，需要转换为整数
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        if not user or not user.is_active:
            return jsonify({'error': '用户不存在或已被禁用'}), 401
        
        # ✅ 修改：生成新token时转换为字符串
        access_token = create_access_token(identity=str(user.id))
        
        return jsonify({
            'access_token': access_token
        }), 200
        
    except Exception as e:
        print(f"❌ Token刷新失败: {str(e)}")
        traceback.print_exc()
        return jsonify({'error': '令牌刷新失败'}), 500

@auth_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    """获取用户信息"""
    try:
        # ✅ 修改：转换为整数
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        if not user:
            return jsonify({'error': '用户不存在'}), 404
        
        return jsonify({'user': user.to_dict()}), 200
        
    except Exception as e:
        print(f"❌ 获取用户信息失败: {str(e)}")
        traceback.print_exc()
        return jsonify({'error': '获取用户信息失败'}), 500

@auth_bp.route('/logout', methods=['POST'])
@jwt_required()
def logout():
    """用户登出"""
    try:
        # ✅ 修改：转换为整数
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        
        # 记录登出
        SystemLog.log_action(
            user_id=current_user_id,
            action='logout',
            description=f'用户 {user.username if user else "未知"} 登出',
            ip_address=request.remote_addr,
            user_agent=request.headers.get('User-Agent')
        )
        
        return jsonify({'message': '登出成功'}), 200
        
    except Exception as e:
        print(f"❌ 登出失败: {str(e)}")
        traceback.print_exc()
        return jsonify({'error': '登出失败'}), 500