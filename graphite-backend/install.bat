@echo off
echo ========================================
echo 石墨实验数据管理系统 - 后端安装脚本
echo ========================================
echo.

REM 检查Python是否安装
python --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到Python，请先安装Python 3.8+
    pause
    exit /b 1
)

echo 1. 创建Python虚拟环境...
python -m venv venv
if errorlevel 1 (
    echo 错误: 虚拟环境创建失败
    pause
    exit /b 1
)

echo 2. 激活虚拟环境...
call venv\Scripts\activate

echo 3. 升级pip...
python -m pip install --upgrade pip

echo 4. 安装依赖包...
pip install -r requirements.txt
if errorlevel 1 (
    echo 错误: 依赖包安装失败
    pause
    exit /b 1
)

echo 5. 创建必要目录...
if not exist "uploads" mkdir uploads
if not exist "backups" mkdir backups
if not exist "logs" mkdir logs

echo 6. 初始化数据库...
echo 请确保MySQL服务正在运行，并且已执行建表脚本
pause
python app.py init-db
python app.py create-admin

echo.
echo ========================================
echo 安装完成！
echo ========================================
echo.
echo 启动命令: start_dev.bat
echo 或手动执行: 
echo   1. call venv\Scripts\activate
echo   2. python app.py
echo.
echo 默认登录信息:
echo   用户名: admin
echo   密码: admin123
echo.
pause