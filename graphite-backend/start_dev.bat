@echo off
echo 启动石墨实验数据管理系统...
echo.

REM 激活虚拟环境（如果使用）
REM call venv\Scripts\activate

REM 设置环境变量
set FLASK_ENV=development
set FLASK_DEBUG=1

REM 启动Flask应用
echo 正在启动后端服务...
python app.py

pause