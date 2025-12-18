# app/utils/backup_manager.py
# 异步版本 - 已修复config导入问题

import subprocess
import os
import threading
import uuid
from datetime import datetime
from pathlib import Path
from typing import Dict, List
from flask import current_app

class BackupManager:
    """数据库备份管理器（异步版本）"""
    
    # 备份文件存储目录（相对于项目根目录）
    BACKUP_DIR = Path(__file__).parent.parent.parent / 'backups'
    
    @classmethod
    def create_backup_async(cls, user_id: int) -> Dict:
        """
        创建数据库备份（异步）
        
        立即返回任务ID，备份在后台线程执行
        适用场景：大文件备份（几十MB到3GB）
        
        Args:
            user_id: 操作用户ID
            
        Returns:
            {
                'success': True,
                'task_id': str,
                'filename': str,
                'message': str
            }
        """
        try:
            # 确保备份目录存在
            cls.BACKUP_DIR.mkdir(exist_ok=True)
            
            # 生成任务ID和文件名
            task_id = str(uuid.uuid4())
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            filename = f'graphite_backup_{timestamp}.sql'
            
            # 创建任务记录
            from app.models.backup_task import BackupTask
            task = BackupTask.create_task(
                task_id=task_id,
                filename=filename,
                created_by=user_id
            )
            
            # ✅ 关键修复：获取当前应用实例，传递给后台线程
            app = current_app._get_current_object()
            
            # 启动后台线程执行备份
            backup_thread = threading.Thread(
                target=cls._execute_backup,
                args=(app, task_id, filename, user_id),  # ✅ 传入app实例
                daemon=True  # 守护线程，进程结束时自动终止
            )
            backup_thread.start()
            
            return {
                'success': True,
                'task_id': task_id,
                'filename': filename,
                'message': '备份任务已创建，正在后台执行'
            }
            
        except Exception as e:
            return {
                'success': False,
                'message': f'创建备份任务失败: {str(e)}'
            }
    
    @classmethod
    def _execute_backup(cls, app, task_id: str, filename: str, user_id: int):
        """
        执行备份（后台线程）
        
        ✅ 关键修复：使用 app.app_context() 包裹所有数据库操作
        
        Args:
            app: Flask应用实例
            task_id: 任务ID
            filename: 备份文件名
            user_id: 操作用户ID
        """
        # ✅ 进入应用上下文
        with app.app_context():
            from app.models.backup_task import BackupTask
            from app.models.system_log import SystemLog
            
            filepath = cls.BACKUP_DIR / filename
            
            try:
                # 更新任务状态为 running
                BackupTask.update_status(task_id, 'running')
                
                # ✅ 修复：从Flask配置读取数据库信息（不再使用config模块）
                db_config = cls._parse_database_uri(app.config['SQLALCHEMY_DATABASE_URI'])
                
                # ✅ 创建环境变量副本，仅为子进程设置密码
                env = os.environ.copy()
                env['MYSQL_PWD'] = db_config['password']
                
                # ✅ 修复：Windows下使用完整路径（如果PATH中找不到）
                mysqldump_cmd = cls._find_mysqldump()
                
                cmd = [
                    mysqldump_cmd,
                    '-h', db_config['host'],
                    '-P', str(db_config['port']),
                    '-u', db_config['user'],
                    db_config['database'],
                    '--result-file', str(filepath),
                    '--single-transaction',  # 使用事务保证一致性
                    '--quick',               # 快速导出（不缓冲整个表）
                    '--lock-tables=false'    # 不锁表（因为晚上/周末备份）
                ]
                
                # ✅ 无timeout限制，支持大文件备份（可能需要10-15分钟）
                result = subprocess.run(
                    cmd,
                    env=env,
                    capture_output=True,
                    text=True
                    # 注意：不设置timeout参数，允许长时间运行
                )
                
                if result.returncode != 0:
                    error_msg = result.stderr if result.stderr else '未知错误'
                    raise Exception(f'mysqldump 执行失败: {error_msg}')
                
                # 验证文件是否创建成功
                if not filepath.exists():
                    raise Exception('备份文件未创建')
                
                # 获取文件大小
                file_size = filepath.stat().st_size
                
                # 更新任务状态为 success
                BackupTask.complete_task(task_id, file_size)
                
                # 记录日志
                SystemLog.log_action(
                    user_id=user_id,
                    action='create_backup',
                    description=f'创建数据库备份: {filename} ({cls._format_size(file_size)})',
                    ip_address='system'
                )
                
            except Exception as e:
                error_msg = str(e)
                
                # 更新任务状态为 failed
                BackupTask.fail_task(task_id, error_msg)
                
                # 记录错误日志
                SystemLog.log_action(
                    user_id=user_id,
                    action='backup_error',
                    description=f'备份失败 ({filename}): {error_msg}',
                    ip_address='system'
                )
    
    @classmethod
    def _parse_database_uri(cls, uri: str) -> Dict:
        """
        解析数据库URI
        
        Args:
            uri: 数据库连接字符串
            
        Returns:
            {'host': str, 'port': int, 'user': str, 'password': str, 'database': str}
        """
        # 格式: mysql+pymysql://user:password@host:port/database
        import re
        pattern = r'mysql\+pymysql://([^:]+):([^@]+)@([^:]+):?(\d+)?/(.+?)(?:\?|$)'
        match = re.match(pattern, uri)
        
        if not match:
            # 简化格式: mysql+pymysql://user:password@host/database
            pattern2 = r'mysql\+pymysql://([^:]+):([^@]+)@([^/]+)/(.+?)(?:\?|$)'
            match = re.match(pattern2, uri)
            if match:
                return {
                    'user': match.group(1),
                    'password': match.group(2),
                    'host': match.group(3),
                    'port': 3306,
                    'database': match.group(4)
                }
        else:
            return {
                'user': match.group(1),
                'password': match.group(2),
                'host': match.group(3),
                'port': int(match.group(4)) if match.group(4) else 3306,
                'database': match.group(5)
            }
        
        raise ValueError(f'无法解析数据库URI: {uri}')
    
    @classmethod
    def _find_mysqldump(cls) -> str:
        """
        查找mysqldump命令
        
        Returns:
            mysqldump命令的完整路径或命令名
        """
        import shutil
        
        # 1. 先尝试在PATH中查找
        mysqldump_path = shutil.which('mysqldump')
        if mysqldump_path:
            return mysqldump_path
        
        # 2. Windows常见安装位置
        if os.name == 'nt':  # Windows
            common_paths = [
                r'C:\Program Files\MySQL\MySQL Server 9.4\bin\mysqldump.exe',
                r'C:\Program Files\MySQL\MySQL Server 9.0\bin\mysqldump.exe',
                r'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe',
                r'C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqldump.exe',
                r'C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysqldump.exe',
            ]
            
            for path in common_paths:
                if os.path.exists(path):
                    return path
        
        # 3. 如果都找不到，返回命令名（会失败，但有明确错误信息）
        return 'mysqldump'
    
    @classmethod
    def get_task_status(cls, task_id: str) -> Dict:
        """
        获取备份任务状态（用于前端轮询）
        
        Args:
            task_id: 任务ID
            
        Returns:
            {
                'task_id': str,
                'status': str,  # pending/running/success/failed
                'filename': str,
                'file_size': int,
                'error_message': str,
                'created_at': str,
                'started_at': str,
                'completed_at': str
            }
        """
        from app.models.backup_task import BackupTask
        
        task = BackupTask.get_task(task_id)
        
        if not task:
            return {'error': '任务不存在'}
        
        return {
            'task_id': task.task_id,
            'status': task.status,
            'filename': task.filename,
            'file_size': task.file_size,
            'error_message': task.error_message,
            'created_at': task.created_at.isoformat() if task.created_at else None,
            'started_at': task.started_at.isoformat() if task.started_at else None,
            'completed_at': task.completed_at.isoformat() if task.completed_at else None
        }
    
    @classmethod
    def list_backups(cls) -> List[Dict]:
        """
        列出所有备份文件（包含任务状态）
        
        Returns:
            [
                {
                    'filename': str,
                    'file_size': int,
                    'created_at': str,
                    'status': str,  # pending/running/success/failed
                    'file_path': str
                },
                ...
            ]
        """
        from app.models.backup_task import BackupTask
        
        backups = []
        
        if not cls.BACKUP_DIR.exists():
            return backups
        
        # 获取所有任务记录（用于匹配状态）
        tasks_by_filename = BackupTask.get_tasks_by_filename()
        
        for file in cls.BACKUP_DIR.glob('*.sql'):
            try:
                stat = file.stat()
                
                # 从任务表获取状态
                task_info = tasks_by_filename.get(file.name)
                status = task_info['status'] if task_info else 'success'
                
                backups.append({
                    'filename': file.name,
                    'file_size': stat.st_size,
                    'created_at': datetime.fromtimestamp(stat.st_mtime).isoformat(),
                    'status': status,
                    'file_path': str(file)
                })
            except Exception as e:
                print(f"Warning: Failed to get info for {file.name}: {e}")
                continue
        
        # 按时间倒序排序
        backups.sort(key=lambda x: x['created_at'], reverse=True)
        
        return backups
    
    @classmethod
    def delete_backup(cls, filename: str, user_id: int) -> Dict:
        """
        删除备份文件
        
        Args:
            filename: 文件名
            user_id: 操作用户ID
            
        Returns:
            {'success': bool, 'message': str}
        """
        try:
            filepath = cls.BACKUP_DIR / filename
            
            # 验证文件存在
            if not filepath.exists():
                return {'success': False, 'message': '备份文件不存在'}
            
            # ✅ 安全检查：确保文件在备份目录内（防止目录遍历攻击）
            if not str(filepath.resolve()).startswith(str(cls.BACKUP_DIR.resolve())):
                return {'success': False, 'message': '非法的文件路径'}
            
            # ✅ 文件名验证：只允许 .sql 文件
            if not filename.endswith('.sql'):
                return {'success': False, 'message': '只支持删除 .sql 文件'}
            
            # 获取文件大小（用于日志）
            file_size = filepath.stat().st_size
            
            # 删除文件
            filepath.unlink()
            
            # 删除关联的任务记录
            from app.models.backup_task import BackupTask
            BackupTask.delete_by_filename(filename)
            
            # 记录日志
            from app.models.system_log import SystemLog
            SystemLog.log_action(
                user_id=user_id,
                action='delete_backup',
                description=f'删除备份文件: {filename} ({cls._format_size(file_size)})',
                ip_address='system'
            )
            
            return {'success': True, 'message': '备份已删除'}
            
        except Exception as e:
            error_msg = str(e)
            cls._log_error(user_id, f'删除备份失败: {error_msg}')
            return {'success': False, 'message': error_msg}
    
    @classmethod
    def get_statistics(cls) -> Dict:
        """
        获取备份统计信息
        
        Returns:
            {
                'total_backups': int,      # 备份文件数量
                'total_size': int,         # 总占用空间（字节）
                'last_backup_time': str,   # 最后备份时间
                'database_size': int,      # 数据库大小（字节）
                'running_tasks': int       # 正在运行的任务数
            }
        """
        from app.models.backup_task import BackupTask
        
        backups = cls.list_backups()
        
        # 计算总大小
        total_size = sum(b['file_size'] for b in backups)
        
        # 获取最后备份时间
        last_backup_time = backups[0]['created_at'] if backups else None
        
        # 查询数据库大小
        try:
            from app import db
            result = db.session.execute(
                "SELECT SUM(data_length + index_length) as size "
                "FROM information_schema.TABLES "
                "WHERE table_schema = DATABASE()"
            ).fetchone()
            
            database_size = result[0] if result and result[0] else 0
        except Exception as e:
            print(f"Warning: Failed to get database size: {e}")
            database_size = 0
        
        # 获取正在运行的任务数
        running_tasks = BackupTask.count_running_tasks()
        
        return {
            'total_backups': len(backups),
            'total_size': total_size,
            'last_backup_time': last_backup_time,
            'database_size': database_size,
            'running_tasks': running_tasks
        }
    
    @classmethod
    def _format_size(cls, bytes: int) -> str:
        """格式化文件大小"""
        if bytes == 0:
            return '0 B'
        k = 1024
        sizes = ['B', 'KB', 'MB', 'GB']
        i = 0
        size = bytes
        while size >= k and i < len(sizes) - 1:
            size /= k
            i += 1
        return f'{size:.2f} {sizes[i]}'
    
    @classmethod
    def _log_error(cls, user_id: int, error_msg: str):
        """记录错误日志"""
        try:
            from app.models.system_log import SystemLog
            SystemLog.log_action(
                user_id=user_id,
                action='backup_error',
                description=error_msg,
                ip_address='system'
            )
        except Exception as e:
            print(f"Warning: Failed to log error: {e}")
