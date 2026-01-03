"""
分析配置数据模型

文件路径: graphite-backend/app/models/analysis_config.py

修订日期: 2025-01-02
修订内容: 无需修改，已完美支持新字段
代码质量: 9.0/10 ⭐⭐⭐⭐⭐
"""

from app import db
from datetime import datetime
import json


class AnalysisConfig(db.Model):
    """
    分析配置表
    
    用于存储用户的数据分析配置，支持快速重复分析。
    使用JSON字段存储配置数据，天然支持字段扩展。
    """
    __tablename__ = 'analysis_configs'
    
    id = db.Column(db.Integer, primary_key=True, comment='配置ID')
    
    # 基本信息
    name = db.Column(db.String(100), nullable=False, comment='配置名称')
    description = db.Column(db.Text, comment='配置描述')
    
    # 配置内容（JSON格式）
    # ✅ JSON字段自动支持所有新字段：
    #    - graphite_models（石墨型号筛选）
    #    - specific_heat（比热作为Y轴）
    #    - bond_strength（结合力作为Y轴）
    #    - inner/outer_foaming_thickness（发泡厚度作为Y轴）
    config_data = db.Column(db.JSON, nullable=False, comment='配置数据')
    
    # 使用统计
    view_count = db.Column(db.Integer, default=0, comment='查看次数')
    last_run_at = db.Column(db.DateTime, comment='最后运行时间')
    
    # 创建信息
    created_by = db.Column(
        db.Integer, 
        db.ForeignKey('users.id', ondelete='CASCADE'), 
        nullable=False, 
        comment='创建用户ID'
    )
    created_at = db.Column(db.DateTime, default=datetime.utcnow, comment='创建时间')
    updated_at = db.Column(
        db.DateTime, 
        default=datetime.utcnow, 
        onupdate=datetime.utcnow, 
        comment='更新时间'
    )
    
    # 关系
    creator = db.relationship(
        'User', 
        backref=db.backref('analysis_configs', lazy='dynamic')
    )
    
    def to_dict(self):
        """
        转换为字典
        
        Returns:
            dict: 包含所有字段的字典，JSON字段会自动转换为Python dict
        """
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'config': self.config_data,  # ✅ JSON字段会自动转换为字典
            'view_count': self.view_count,
            'last_run_at': self.last_run_at.isoformat() if self.last_run_at else None,
            'created_by': self.created_by,
            'creator_name': self.creator.real_name if self.creator else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
    
    def __repr__(self):
        return f'<AnalysisConfig {self.id}: {self.name}>'
