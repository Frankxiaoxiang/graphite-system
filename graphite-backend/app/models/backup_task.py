# app/models/backup_task.py

from datetime import datetime
from app import db

class BackupTask(db.Model):
    """备份任务模型"""
    
    __tablename__ = 'backup_tasks'
    
    id = db.Column(db.Integer, primary_key=True)
    task_id = db.Column(db.String(50), unique=True, nullable=False)
    filename = db.Column(db.String(255), nullable=False)
    status = db.Column(db.Enum('pending', 'running', 'success', 'failed'), default='pending')
    file_size = db.Column(db.BigInteger, default=0)
    error_message = db.Column(db.Text)
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    started_at = db.Column(db.DateTime)
    completed_at = db.Column(db.DateTime)
    
    def to_dict(self):
        """转换为字典"""
        return {
            'id': self.id,
            'task_id': self.task_id,
            'filename': self.filename,
            'status': self.status,
            'file_size': self.file_size,
            'error_message': self.error_message,
            'created_by': self.created_by,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'started_at': self.started_at.isoformat() if self.started_at else None,
            'completed_at': self.completed_at.isoformat() if self.completed_at else None
        }
    
    @staticmethod
    def create_task(task_id, filename, created_by):
        """创建新任务"""
        task = BackupTask(
            task_id=task_id,
            filename=filename,
            status='pending',
            created_by=created_by
        )
        db.session.add(task)
        db.session.commit()
        return task
    
    @staticmethod
    def get_task(task_id):
        """根据task_id获取任务"""
        return BackupTask.query.filter_by(task_id=task_id).first()
    
    @staticmethod
    def update_status(task_id, status):
        """更新任务状态"""
        task = BackupTask.get_task(task_id)
        if task:
            task.status = status
            if status == 'running':
                task.started_at = datetime.utcnow()
            db.session.commit()
        return task
    
    @staticmethod
    def complete_task(task_id, file_size):
        """任务完成"""
        task = BackupTask.get_task(task_id)
        if task:
            task.status = 'success'
            task.file_size = file_size
            task.completed_at = datetime.utcnow()
            db.session.commit()
        return task
    
    @staticmethod
    def fail_task(task_id, error_message):
        """任务失败"""
        task = BackupTask.get_task(task_id)
        if task:
            task.status = 'failed'
            task.error_message = error_message
            task.completed_at = datetime.utcnow()
            db.session.commit()
        return task
    
    @staticmethod
    def get_tasks_by_filename():
        """获取所有任务，按filename索引"""
        tasks = BackupTask.query.all()
        return {task.filename: {'status': task.status, 'task_id': task.task_id} for task in tasks}
    
    @staticmethod
    def count_running_tasks():
        """统计正在运行的任务数"""
        return BackupTask.query.filter_by(status='running').count()
    
    @staticmethod
    def delete_by_filename(filename):
        """根据文件名删除任务记录"""
        BackupTask.query.filter_by(filename=filename).delete()
        db.session.commit()
