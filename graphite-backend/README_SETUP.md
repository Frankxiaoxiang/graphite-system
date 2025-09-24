# 石墨实验数据管理系统 - 后端安装指南

## 环境要求

- Python 3.8+ 
- MySQL 9.4
- Windows 10/11 或 Linux/Mac

## 自动安装（推荐）

### Windows用户

1. **下载项目代码**
   ```cmd
   # 解压项目文件到指定目录
   cd graphite-backend
   ```

2. **运行自动安装脚本**
   ```cmd
   install.bat
   ```

3. **启动开发服务器**
   ```cmd
   start_dev.bat
   ```

### Linux/Mac用户

1. **下载项目代码**
   ```bash
   # 解压项目文件到指定目录
   cd graphite-backend
   ```

2. **设置脚本执行权限**
   ```bash
   chmod +x install.sh
   chmod +x start_dev.sh
   ```

3. **运行自动安装脚本**
   ```bash
   ./install.sh
   ```

4. **启动开发服务器**
   ```bash
   ./start_dev.sh
   ```

## 手动安装

如果自动安装脚本出现问题，可以手动执行：

### 1. 创建虚拟环境
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac  
python3 -m venv venv
source venv/bin/activate
```

### 2. 安装依赖
```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
```

### 3. 创建目录
```bash
mkdir uploads backups logs
```

### 4. 配置环境变量
```bash
# 复制并编辑 .env 文件
cp .env.example .env
# 编辑数据库连接等配置
```

### 5. 初始化数据库
```bash
# 确保MySQL服务运行，并执行了建表脚本
python app.py init-db
python app.py create-admin
```

### 6. 启动服务
```bash
python app.py
```

## 验证安装

1. **检查服务启动**
   - 浏览器访问：http://localhost:5000
   - 应该看到API服务响应

2. **测试登录**
   - 用户名：admin
   - 密码：admin123

3. **检查虚拟环境**
   ```bash
   # 命令行应显示 (venv) 前缀
   # 检查安装的包
   pip list
   ```

## 常见问题

### 1. Python命令不存在
- Windows: 安装Python时勾选"Add to PATH"
- Linux: `sudo apt install python3 python3-venv`
- Mac: `brew install python3`

### 2. 虚拟环境激活失败
- 确保在项目根目录执行命令
- Windows可能需要执行策略：`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### 3. MySQL连接失败
- 检查MySQL服务状态
- 确认数据库用户权限
- 验证.env文件中的连接字符串

### 4. 依赖包安装失败
- 升级pip：`python -m pip install --upgrade pip`
- 使用国内镜像：`pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple`

## 开发环境管理

### 激活虚拟环境
```bash
# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

### 退出虚拟环境
```bash
deactivate
```

### 查看已安装包
```bash
pip list
pip freeze > requirements.txt  # 更新依赖列表
```

## 下一步

1. 确认后端服务正常运行
2. 继续Vue前端开发
3. 前后端联调测试

---

**如有问题，请检查：**
1. Python版本是否正确
2. 虚拟环境是否激活
3. MySQL服务是否运行
4. 建表脚本是否执行