# ========================================
# 修改后的 app.py 文件
# ========================================

import os
from flask import Flask
from app import create_app, db

# 创建Flask应用实例
app = create_app(os.getenv('FLASK_CONFIG') or 'development')

@app.cli.command()
def init_db():
    """初始化数据库（跳过，因为已通过SQL脚本创建）"""
    print("数据库表已通过SQL脚本创建，跳过初始化...")
    return

@app.cli.command()
def create_admin():
    """创建默认管理员用户"""
    from app.models.user import User
    
    with app.app_context():
        admin = User.query.filter_by(username='admin').first()
        if admin:
            print("管理员用户已存在")
            return
        
        admin = User(
            username='admin',
            role='admin',
            real_name='系统管理员',
            email='admin@example.com'
        )
        admin.set_password('admin123')
        
        db.session.add(admin)
        db.session.commit()
        print("管理员用户创建成功！用户名: admin, 密码: admin123")

@app.shell_context_processor
def make_shell_context():
    """Flask Shell上下文"""
    return {'db': db}

if __name__ == '__main__':
    # 开发模式启动
    app.run(debug=True, host='0.0.0.0', port=5000)