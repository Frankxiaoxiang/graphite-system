from flask import Flask, jsonify, request
from flask_cors import CORS
import pymysql
import bcrypt
import jwt
from datetime import datetime, timedelta

app = Flask(__name__)
app.config['SECRET_KEY'] = 'dev-secret-key'
CORS(app)

# 数据库连接配置
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '你的MySQL密码',  # 替换实际密码
    'database': 'graphite_db',
    'charset': 'utf8mb4'
}

@app.route('/')
def home():
    return jsonify({
        'message': '石墨实验数据管理系统后端运行正常',
        'version': '1.0',
        'status': 'success'
    })

@app.route('/api/auth/login', methods=['POST'])
def login():
    try:
        data = request.get_json()
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return jsonify({'error': '用户名和密码不能为空'}), 400
        
        # 连接数据库验证用户
        connection = pymysql.connect(**DB_CONFIG)
        cursor = connection.cursor()
        cursor.execute("SELECT id, username, password_hash, role FROM users WHERE username = %s", (username,))
        user = cursor.fetchone()
        cursor.close()
        connection.close()
        
        if not user:
            return jsonify({'error': '用户不存在'}), 401
        
        # 验证密码
        if bcrypt.checkpw(password.encode('utf-8'), user[2].encode('utf-8')):
            # 生成简单的token
            token = jwt.encode({
                'user_id': user[0],
                'username': user[1],
                'role': user[3],
                'exp': datetime.utcnow() + timedelta(hours=24)
            }, app.config['SECRET_KEY'], algorithm='HS256')
            
            return jsonify({
                'message': '登录成功',
                'token': token,
                'user': {
                    'id': user[0],
                    'username': user[1],
                    'role': user[3]
                }
            }), 200
        else:
            return jsonify({'error': '密码错误'}), 401
            
    except Exception as e:
        return jsonify({'error': f'登录失败: {str(e)}'}), 500

@app.route('/api/test/db')
def test_db():
    try:
        connection = pymysql.connect(**DB_CONFIG)
        cursor = connection.cursor()
        
        cursor.execute("SELECT COUNT(*) FROM users")
        user_count = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM dropdown_options")
        option_count = cursor.fetchone()[0]
        
        cursor.close()
        connection.close()
        
        return jsonify({
            'database': 'connected',
            'user_count': user_count,
            'dropdown_options': option_count,
            'status': 'success'
        })
    except Exception as e:
        return jsonify({
            'database': 'failed',
            'error': str(e)
        })

if __name__ == '__main__':
    print("启动石墨实验数据管理系统后端...")
    print("访问地址: http://localhost:5000")
    print("测试地址: http://localhost:5000/api/test/db")
    print("登录测试: POST http://localhost:5000/api/auth/login")
    print("登录账号: admin / admin123")
    app.run(debug=True, port=5000)