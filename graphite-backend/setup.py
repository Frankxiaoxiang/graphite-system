import os
import subprocess
import sys

def install_requirements():
    """安装依赖包"""
    print("正在安装Python依赖包...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
    print("依赖包安装完成！")

def create_directories():
    """创建必要的目录"""
    directories = ['uploads', 'backups', 'logs']
    for directory in directories:
        if not os.path.exists(directory):
            os.makedirs(directory)
            print(f"创建目录: {directory}")

def setup_database():
    """设置数据库"""
    print("正在初始化数据库...")
    from app import create_app, db
    from app.models import *
    
    app = create_app('development')
    with app.app_context():
        db.create_all()
        print("数据库表创建完成！")
        
def setup_database():
    """设置数据库"""
    print("正在初始化数据库...")
    from app import create_app, db
    from app.models import *
    
    app = create_app('development')
    with app.app_context():
        db.create_all()
        print("数据库表创建完成！")
        
        # 创建默认管理员用户
        from app.models.user import User
        admin = User.query.filter_by(username='admin').first()
        if not admin:
            admin = User(
                username='admin',
                role='admin',
                real_name='系统管理员',
                email='admin@example.com'
            )
            admin.set_password('admin123')
            db.session.add(admin)
            db.session.commit()
            print("默认管理员用户创建完成！用户名: admin, 密码: admin123")

def main():
    """主安装流程"""
    print("=== 石墨实验数据管理系统安装程序 ===")
    print()
    
    try:
        # 1. 安装依赖
        install_requirements()
        print()
        
        # 2. 创建目录
        print("正在创建必要的目录...")
        create_directories()
        print()
        
        # 3. 设置数据库
        setup_database()
        print()
        
        print("=== 安装完成！===")
        print()
        print("后端服务启动命令:")
        print("python app.py")
        print()
        print("默认登录信息:")
        print("用户名: admin")
        print("密码: admin123")
        print()
        print("API访问地址: http://localhost:5000")
        
    except Exception as e:
        print(f"安装过程中发生错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()