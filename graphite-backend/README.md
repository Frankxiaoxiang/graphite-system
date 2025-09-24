# 石墨实验数据管理系统 - Flask后端

## 项目概述

本项目是石墨实验数据管理系统的Flask后端部分，提供完整的REST API服务，支持：

- 用户认证和权限管理
- 实验数据管理（90个字段，7个模块）
- 文件上传和管理
- 下拉选择数据动态扩展
- 数据导出和备份
- 系统日志和审计

## 技术栈

- **框架**: Flask 2.3.3
- **数据库**: MySQL 9.4
- **ORM**: SQLAlchemy
- **认证**: JWT (Flask-JWT-Extended)
- **文件处理**: Pillow (图片压缩)
- **API**: RESTful设计

## 快速开始

### 1. 环境准备

确保已安装：
- Python 3.8+
- MySQL 9.4
- pip包管理器

### 2. 安装依赖

```bash
# 克隆项目
git clone <项目地址>
cd graphite-backend

# 安装依赖
pip install -r requirements.txt
```

### 3. 配置数据库

```bash
# 登录MySQL
mysql -u root -p

# 创建数据库
CREATE DATABASE graphite_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 执行建表脚本（使用之前提供的SQL脚本）
source database_schema.sql
source insert_dropdown_data.sql
```

### 4. 环境配置

复制 `.env.example` 为 `.env` 并修改配置：

```bash
# 数据库配置
DATABASE_URL=mysql+pymysql://root:your_password@localhost/graphite_db

# 密钥配置（生产环境必须修改）
SECRET_KEY=your-super-secret-key
JWT_SECRET_KEY=your-jwt-secret-key
```

### 5. 初始化和启动

```bash
# 方式一：使用安装脚本（推荐）
python setup.py

# 方式二：手动初始化
python app.py init-db
python app.py create-admin

# 启动服务
python app.py
```

### 6. 验证安装

访问 `http://localhost:5000` 确认服务启动成功。

默认登录信息：
- 用户名: `admin`
- 密码: `admin123`

## 项目结构

```
graphite-backend/
├── app/                    # 应用代码
│   ├── __init__.py        # Flask应用工厂
│   ├── models/            # 数据模型
│   │   ├── user.py       # 用户模型
│   │   ├── experiment.py # 实验数据模型
│   │   ├── dropdown.py   # 下拉选择模型
│   │   └── ...
│   ├── routes/            # API路由
│   │   ├── auth.py       # 认证路由
│   │   ├── experiments.py # 实验数据路由
│   │   ├── dropdown.py   # 下拉选择路由
│   │   └── ...
│   ├── utils/             # 工具函数
│   │   ├── permissions.py # 权限控制
│   │   └── experiment_code.py # 编码生成
│   └── config.py          # 配置文件
├── uploads/               # 文件上传目录
├── backups/               # 数据库备份目录
├── requirements.txt       # Python依赖
├── app.py                 # 应用启动文件
├── setup.py              # 安装脚本
└── .env                  # 环境变量配置
```

## API文档

### 认证相关

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/auth/login` | 用户登录 |
| POST | `/api/auth/refresh` | 刷新Token |
| GET | `/api/auth/profile` | 获取用户信息 |
| POST | `/api/auth/logout` | 用户登出 |

### 实验数据

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/experiments` | 获取实验列表 |
| POST | `/api/experiments` | 创建实验 |
| GET | `/api/experiments/{id}` | 获取实验详情 |
| PUT | `/api/experiments/{id}` | 更新实验 |
| DELETE | `/api/experiments/{id}` | 删除实验 |
| POST | `/api/experiments/export` | 导出实验数据 |

### 下拉选择

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/dropdown/options` | 获取选项列表 |
| POST | `/api/dropdown/add` | 添加新选项 |
| GET | `/api/dropdown/approvals` | 获取待审批选项 |
| POST | `/api/dropdown/approve/{id}` | 审批选项 |

### 文件管理

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/files/upload` | 文件上传 |
| GET | `/api/files/download/{id}` | 文件下载 |
| DELETE | `/api/files/{id}` | 删除文件 |
| GET | `/api/files/experiment/{id}` | 获取实验文件 |

### 系统管理

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/admin/users` | 用户列表 |
| POST | `/api/admin/users` | 创建用户 |
| PUT | `/api/admin/users/{id}` | 更新用户 |
| DELETE | `/api/admin/users/{id}` | 删除用户 |
| POST | `/api/admin/backup` | 数据库备份 |
| GET | `/api/admin/logs` | 系统日志 |

## 权限说明

### 用户角色

- **管理员 (admin)**: 所有权限
- **工程师 (engineer)**: 数据管理和审批权限
- **用户 (user)**: 基础数据录入权限

### 权限控制

- 普通用户只能访问自己创建的实验
- 工程师可以查看和编辑所有实验
- 管理员拥有完整的系统管理权限

## 开发说明

### 添加新的API路由

1. 在 `app/routes/` 创建新的路由文件
2. 在 `app/__init__.py` 中注册蓝图
3. 添加相应的权限装饰器

### 数据库迁移

```bash
# 如果修改了模型，需要手动更新数据库
# 建议在开发环境中测试后，编写迁移脚本
```

### 测试

```bash
# 运行测试（如果有测试文件）
python -m pytest tests/
```

## 部署说明

### 生产环境配置

1. 修改 `.env` 文件中的密钥
2. 设置 `FLASK_ENV=production`
3. 配置反向代理（Nginx）
4. 使用 WSGI 服务器（如 Gunicorn）

### 使用 Gunicorn 部署

```bash
# 安装Gunicorn
pip install gunicorn

# 启动服务
gunicorn -w 4 -b 0.0.0.0:5000 wsgi:application
```

## 安全注意事项

1. **生产环境必须修改默认密钥**
2. **定期备份数据库**
3. **启用HTTPS**
4. **限制文件上传大小和类型**
5. **监控系统日志**

## 故障排除

### 常见问题

1. **数据库连接失败**
   - 检查MySQL服务是否启动
   - 确认数据库用户权限
   - 验证连接字符串

2. **文件上传失败**
   - 检查uploads目录权限
   - 确认文件大小限制
   - 验证文件类型

3. **Token认证失败**
   - 检查JWT密钥配置
   - 确认Token有效期
   - 验证请求头格式

### 日志查看

```bash
# 查看应用日志
tail -f logs/app.log

# 查看错误日志
tail -f logs/error.log
```

## 技术支持

如有问题，请：
1. 查看系统日志
2. 检查数据库连接
3. 验证配置文件
4. 提交Issue

---

**版本**: v1.0  
**最后更新**: 2025年  
**维护者**: 肖翔