#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
快速修复engineer账号
用途：创建或重置engineer用户账号
"""

import sys
import os

# 添加项目路径
sys.path.insert(0, os.path.abspath('.'))

def fix_engineer_account():
    """修复engineer账号"""
    
    try:
        from app import create_app, db
        from app.models.user import User
        from werkzeug.security import generate_password_hash
        
        app = create_app()
        
        with app.app_context():
            print("\n" + "="*60)
            print("🔧 修复 engineer 账号")
            print("="*60 + "\n")
            
            # 1. 检查engineer用户是否存在
            engineer = User.query.filter_by(username='engineer').first()
            
            if engineer:
                print("📋 发现已存在的 engineer 用户：")
                print(f"   - ID: {engineer.id}")
                print(f"   - 用户名: {engineer.username}")
                print(f"   - 角色: {engineer.role}")
                print(f"   - 邮箱: {engineer.email}\n")
                
                # 询问是否重置密码
                choice = input("是否重置密码为 'engineer123'? (y/n): ").lower()
                
                if choice == 'y':
                    # 重置密码
                    engineer.password_hash = generate_password_hash('engineer123')
                    engineer.role = 'engineer'  # 确保角色正确
                    
                    # 如果有 is_active 字段，激活用户
                    if hasattr(engineer, 'is_active'):
                        engineer.is_active = True
                    
                    db.session.commit()
                    
                    print("\n✅ engineer 账号已修复！")
                    print("   - 用户名: engineer")
                    print("   - 密码: engineer123")
                    print("   - 角色: engineer")
                    
                    # 验证密码
                    if engineer.check_password('engineer123'):
                        print("\n✅ 密码验证成功！可以正常登录了\n")
                    else:
                        print("\n⚠️  警告：密码验证失败，可能仍有问题\n")
                else:
                    print("\n❌ 已取消操作\n")
            
            else:
                print("❌ 数据库中没有 engineer 用户")
                print("📝 开始创建新用户...\n")
                
                # 创建新用户
                new_engineer = User(
                    username='engineer',
                    password_hash=generate_password_hash('engineer123'),
                    role='engineer',
                    real_name='工程师',
                    email='engineer@example.com'
                )
                
                # 如果有 is_active 字段，设置为激活
                if hasattr(new_engineer, 'is_active'):
                    new_engineer.is_active = True
                
                db.session.add(new_engineer)
                db.session.commit()
                
                print("✅ engineer 账号创建成功！")
                print("   - 用户名: engineer")
                print("   - 密码: engineer123")
                print("   - 角色: engineer")
                print("   - 邮箱: engineer@example.com\n")
                
                # 验证
                if new_engineer.check_password('engineer123'):
                    print("✅ 密码验证成功！可以正常登录了\n")
            
            # 2. 同时检查其他测试账号
            print("="*60)
            print("\n📋 检查其他测试账号：\n")
            
            # 检查admin
            admin = User.query.filter_by(username='admin').first()
            if admin:
                print(f"✅ admin 账号存在 (角色: {admin.role})")
            else:
                print("⚠️  admin 账号不存在")
            
            # 检查user
            user = User.query.filter_by(username='user').first()
            if user:
                print(f"✅ user 账号存在 (角色: {user.role})")
            else:
                print("⚠️  user 账号不存在")
            
            # 创建缺失的测试账号
            missing_accounts = []
            
            if not admin:
                missing_accounts.append(('admin', 'admin123', 'admin', '系统管理员', 'admin@example.com'))
            
            if not user:
                missing_accounts.append(('user', 'user123', 'user', '普通用户', 'user@example.com'))
            
            if missing_accounts:
                print(f"\n❓ 是否创建缺失的账号? (y/n): ", end='')
                choice = input().lower()
                
                if choice == 'y':
                    for username, password, role, real_name, email in missing_accounts:
                        new_user = User(
                            username=username,
                            password_hash=generate_password_hash(password),
                            role=role,
                            real_name=real_name,
                            email=email
                        )
                        
                        if hasattr(new_user, 'is_active'):
                            new_user.is_active = True
                        
                        db.session.add(new_user)
                        print(f"   ✅ 创建 {username} 账号")
                    
                    db.session.commit()
                    print("\n✅ 所有账号创建完成！\n")
            
            print("="*60)
            print("\n📝 当前可用的测试账号：\n")
            
            all_users = User.query.all()
            for u in all_users:
                print(f"   - {u.username:12} (角色: {u.role:10}, 密码: {u.username}123)")
            
            print("\n" + "="*60)
            print("\n✅ 修复完成！请尝试重新登录\n")
            
    except ImportError as e:
        print(f"\n❌ 错误：无法导入模块")
        print(f"   详情：{str(e)}")
        print(f"\n💡 解决方案：")
        print(f"   1. 确保在 graphite-backend 目录运行此脚本")
        print(f"   2. 确保虚拟环境已激活")
        print(f"   3. 确保已安装所有依赖\n")
        
    except Exception as e:
        print(f"\n❌ 错误：{str(e)}")
        import traceback
        traceback.print_exc()
        print()


if __name__ == '__main__':
    print("\n🔧 Engineer账号快速修复工具")
    print("="*60)
    
    # 检查是否在正确的目录
    if not os.path.exists('app'):
        print("\n❌ 错误：当前目录不是 graphite-backend 项目根目录")
        print("💡 请在 graphite-backend 目录下运行此脚本：")
        print("   cd graphite-backend")
        print("   python fix_engineer.py\n")
        sys.exit(1)
    
    fix_engineer_account()
