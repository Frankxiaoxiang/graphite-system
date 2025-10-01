from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_marshmallow import Marshmallow
import os
from datetime import timedelta

# 初始化扩展
db = SQLAlchemy()
jwt = JWTManager()
ma = Marshmallow()

def create_app(config_name='development'):
    """Flask应用工厂函数"""
    app = Flask(__name__)
    
    # 配置
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY') or 'your-secret-key-change-in-production'
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL') or \
        'mysql+pymysql://root:your_password@localhost/graphite_db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
    app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
        'pool_size': 10,
        'pool_timeout': 20,
        'pool_recycle': -1,
        'pool_pre_ping': True
    }
    
    # JWT配置
    app.config['JWT_SECRET_KEY'] = os.environ.get('JWT_SECRET_KEY') or 'jwt-secret-string'
    app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=24)
    app.config['JWT_REFRESH_TOKEN_EXPIRES'] = timedelta(days=30)
    
    # 文件上传配置
    app.config['UPLOAD_FOLDER'] = os.path.join(os.getcwd(), 'uploads')
    app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024  # 10MB
    
    # 初始化扩展
    db.init_app(app)
    jwt.init_app(app)
    ma.init_app(app)
    
    # ========== 修改：完整的CORS配置 ==========
    CORS(app, 
         resources={
             r"/api/*": {
                 "origins": ["http://localhost:5173", "http://localhost:3000"],
                 "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
                 "allow_headers": ["Content-Type", "Authorization"],
                 "expose_headers": ["Content-Type", "Authorization"],
                 "supports_credentials": True,
                 "max_age": 3600
             }
         })
    # ==========================================
    
    # 注册蓝图
    from app.routes.auth import auth_bp
    from app.routes.experiments import experiments_bp
    from app.routes.dropdown import dropdown_bp
    from app.routes.files import files_bp
    from app.routes.admin import admin_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(experiments_bp, url_prefix='/api/experiments')
    app.register_blueprint(dropdown_bp, url_prefix='/api/dropdown')
    app.register_blueprint(files_bp, url_prefix='/api/files')
    app.register_blueprint(admin_bp, url_prefix='/api/admin')
    
    # 错误处理
    @app.errorhandler(404)
    def not_found(error):
        return {'error': 'Not found'}, 404
    
    @app.errorhandler(500)
    def internal_error(error):
        db.session.rollback()
        return {'error': 'Internal server error'}, 500
    
    # JWT错误处理
    @jwt.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        return {'error': 'Token has expired'}, 401
    
    @jwt.invalid_token_loader
    def invalid_token_callback(error):
        return {'error': 'Invalid token'}, 401
    
    @jwt.unauthorized_loader
    def missing_token_callback(error):
        return {'error': 'Authorization token is required'}, 401
    
    return app