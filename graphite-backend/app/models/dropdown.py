from app import db
from datetime import datetime

class DropdownOption(db.Model):
    """下拉选择选项"""
    __tablename__ = 'dropdown_options'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    field_name = db.Column(db.String(100), nullable=False)
    option_value = db.Column(db.String(100), nullable=False)
    option_label = db.Column(db.String(200), nullable=False)
    sort_order = db.Column(db.Integer, default=0)
    is_active = db.Column(db.Boolean, default=True)
    is_system = db.Column(db.Boolean, default=False)
class DropdownOption(db.Model):
    """下拉选择选项"""
    __tablename__ = 'dropdown_options'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    field_name = db.Column(db.String(100), nullable=False)
    option_value = db.Column(db.String(100), nullable=False)
    option_label = db.Column(db.String(200), nullable=False)
    sort_order = db.Column(db.Integer, default=0)
    is_active = db.Column(db.Boolean, default=True)
    is_system = db.Column(db.Boolean, default=False)
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 关系
    creator = db.relationship('User', backref='dropdown_options')
    
    def to_dict(self):
        return {
            'id': self.id,
            'field_name': self.field_name,
            'option_value': self.option_value,
            'option_label': self.option_label,
            'sort_order': self.sort_order,
            'is_active': self.is_active,
            'is_system': self.is_system
        }

class DropdownField(db.Model):
    """下拉选择字段配置"""
    __tablename__ = 'dropdown_fields'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    field_name = db.Column(db.String(100), unique=True, nullable=False)
    field_label = db.Column(db.String(200), nullable=False)
    field_type = db.Column(db.Enum('fixed', 'expandable', 'searchable'), default='fixed')
    allow_user_add = db.Column(db.Boolean, default=False)
    allow_engineer_add = db.Column(db.Boolean, default=True)
    allow_admin_add = db.Column(db.Boolean, default=True)
    require_approval = db.Column(db.Boolean, default=False)
    max_options = db.Column(db.Integer)
    description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class DropdownApproval(db.Model):
    """下拉选择新增审批"""
    __tablename__ = 'dropdown_approvals'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    field_name = db.Column(db.String(100), nullable=False)
    option_value = db.Column(db.String(100), nullable=False)
    option_label = db.Column(db.String(200), nullable=False)
    requested_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    status = db.Column(db.Enum('pending', 'approved', 'rejected'), default='pending')
    approved_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    reason = db.Column(db.Text)
    requested_at = db.Column(db.DateTime, default=datetime.utcnow)
    processed_at = db.Column(db.DateTime)
    
    # 关系
    requester = db.relationship('User', foreign_keys=[requested_by], backref='dropdown_requests')
    approver = db.relationship('User', foreign_keys=[approved_by], backref='dropdown_approvals')