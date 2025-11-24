from app import db
from datetime import datetime

class Experiment(db.Model):
    """实验主表"""
    __tablename__ = 'experiments'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    experiment_code = db.Column(db.String(50), unique=True, nullable=False)
    status = db.Column(db.Enum('draft', 'submitted', 'completed'), default='draft')
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    submitted_at = db.Column(db.DateTime)
    version = db.Column(db.Integer, default=1)
    notes = db.Column(db.Text)
    
    # 关系
    basic = db.relationship('ExperimentBasic', backref='experiment', uselist=False, cascade='all, delete-orphan')
    pi = db.relationship('ExperimentPi', backref='experiment', uselist=False, cascade='all, delete-orphan')
    loose = db.relationship('ExperimentLoose', backref='experiment', uselist=False, cascade='all, delete-orphan')
    carbon = db.relationship('ExperimentCarbon', backref='experiment', uselist=False, cascade='all, delete-orphan')
    graphite = db.relationship('ExperimentGraphite', backref='experiment', uselist=False, cascade='all, delete-orphan')
    rolling = db.relationship('ExperimentRolling', backref='experiment', uselist=False, cascade='all, delete-orphan')
    product = db.relationship('ExperimentProduct', backref='experiment', uselist=False, cascade='all, delete-orphan')
    
    def to_dict(self):
        """转换为字典"""
        return {
            'id': self.id,
            'experiment_code': self.experiment_code,
            'status': self.status,
            'created_by': self.created_by,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
            'submitted_at': self.submitted_at.isoformat() if self.submitted_at else None,
            'version': self.version,
            'notes': self.notes
        }

class ExperimentBasic(db.Model):
    """实验设计参数表"""
    __tablename__ = 'experiment_basic'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    experiment_id = db.Column(db.Integer, db.ForeignKey('experiments.id'), nullable=False, unique=True)
    pi_film_thickness = db.Column(db.Numeric(8, 2))
    customer_type = db.Column(db.String(20))
    customer_name = db.Column(db.String(100))
    pi_film_model = db.Column(db.String(100))
    experiment_date = db.Column(db.Date)
    sintering_location = db.Column(db.String(50))
    material_type_for_firing = db.Column(db.String(20))
    rolling_method = db.Column(db.String(20))
    experiment_group = db.Column(db.Integer)
    experiment_purpose = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class ExperimentPi(db.Model):
    """PI膜参数表"""
    __tablename__ = 'experiment_pi'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    experiment_id = db.Column(db.Integer, db.ForeignKey('experiments.id'), nullable=False, unique=True)
    pi_manufacturer = db.Column(db.String(100))
    pi_thickness_detail = db.Column(db.Numeric(8, 2))
    pi_model_detail = db.Column(db.String(100))
    pi_width = db.Column(db.Numeric(10, 2))
    batch_number = db.Column(db.String(100))
    pi_weight = db.Column(db.Numeric(10, 3))
    firing_rolls = db.Column(db.Integer, comment='烧制卷数')
    pi_notes = db.Column(db.Text, comment='PI膜补充说明')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class ExperimentLoose(db.Model):
    """松卷参数表"""
    __tablename__ = 'experiment_loose'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    experiment_id = db.Column(db.Integer, db.ForeignKey('experiments.id'), nullable=False, unique=True)
    core_tube_type = db.Column(db.String(100))
    loose_gap_inner = db.Column(db.Numeric(8, 2))
    loose_gap_middle = db.Column(db.Numeric(8, 2))
    loose_gap_outer = db.Column(db.Numeric(8, 2))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class ExperimentCarbon(db.Model):
    """碳化参数表"""
    __tablename__ = 'experiment_carbon'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    experiment_id = db.Column(db.Integer, db.ForeignKey('experiments.id'), nullable=False, unique=True)
    carbon_furnace_number = db.Column(db.String(50))
    carbon_furnace_batch = db.Column(db.Integer)
    boat_model = db.Column(db.String(100))
    wrapping_method = db.Column(db.String(100))
    vacuum_degree = db.Column(db.Numeric(10, 4))
    power_consumption = db.Column(db.Numeric(10, 2))
    start_time = db.Column(db.DateTime)
    end_time = db.Column(db.DateTime)
        # ✅ 新增：碳化温度/厚度字段
    carbon_temp1 = db.Column(db.Integer)
    carbon_thickness1 = db.Column(db.Numeric(10, 2))
    carbon_temp2 = db.Column(db.Integer)
    carbon_thickness2 = db.Column(db.Numeric(10, 2))
    carbon_max_temp = db.Column(db.Numeric(8, 2))
    carbon_total_time = db.Column(db.Integer)
    carbon_film_thickness = db.Column(db.Numeric(8, 2))
    carbon_after_weight = db.Column(db.Numeric(10, 3))
    carbon_yield_rate = db.Column(db.Numeric(5, 2))
    carbon_loading_photo = db.Column(db.String(255))
    carbon_sample_photo = db.Column(db.String(255))
    carbon_other_params = db.Column(db.String(255))
    carbon_notes = db.Column(db.Text, comment='碳化补充说明')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class ExperimentGraphite(db.Model):
    """石墨化参数表"""
    __tablename__ = 'experiment_graphite'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    experiment_id = db.Column(db.Integer, db.ForeignKey('experiments.id'), nullable=False, unique=True)
    graphite_furnace_number = db.Column(db.String(50))
    graphite_furnace_batch = db.Column(db.Integer)
    graphite_start_time = db.Column(db.DateTime)
    graphite_end_time = db.Column(db.DateTime)
    gas_pressure = db.Column(db.Numeric(10, 4))
    graphite_power = db.Column(db.Numeric(10, 2))
        # ✅ 新增：温度和厚度配对字段
    graphite_temp1 = db.Column(db.Numeric(8, 2))
    graphite_thickness1 = db.Column(db.Numeric(8, 2))
    graphite_temp2 = db.Column(db.Numeric(8, 2))
    graphite_thickness2 = db.Column(db.Numeric(8, 2))
    graphite_temp3 = db.Column(db.Numeric(8, 2))
    graphite_thickness3 = db.Column(db.Numeric(8, 2))
    graphite_temp4 = db.Column(db.Numeric(8, 2))
    graphite_thickness4 = db.Column(db.Numeric(8, 2))
    graphite_temp5 = db.Column(db.Numeric(8, 2))
    graphite_thickness5 = db.Column(db.Numeric(8, 2))
    graphite_temp6 = db.Column(db.Numeric(8, 2))
    graphite_thickness6 = db.Column(db.Numeric(8, 2))
    foam_thickness = db.Column(db.Numeric(8, 2))
    graphite_max_temp = db.Column(db.Numeric(8, 2))
    graphite_width = db.Column(db.Numeric(10, 2))
    shrinkage_ratio = db.Column(db.Numeric(5, 4))
    graphite_total_time = db.Column(db.Integer)
    graphite_after_weight = db.Column(db.Numeric(10, 3))
    graphite_yield_rate = db.Column(db.Numeric(5, 2))
    graphite_loading_photo = db.Column(db.String(255))
    graphite_sample_photo = db.Column(db.String(255))
    graphite_min_thickness = db.Column(db.Numeric(8, 2))
    graphite_other_params = db.Column(db.String(255))
    graphite_notes = db.Column(db.Text, comment='石墨化补充说明')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class ExperimentRolling(db.Model):
    """压延参数表"""
    __tablename__ = 'experiment_rolling'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    experiment_id = db.Column(db.Integer, db.ForeignKey('experiments.id'), nullable=False, unique=True)
    rolling_machine = db.Column(db.String(100))
    rolling_pressure = db.Column(db.Numeric(8, 2))
    rolling_tension = db.Column(db.Numeric(8, 2))
    rolling_speed = db.Column(db.Numeric(8, 3))
    rolling_notes = db.Column(db.Text, comment='压延补充说明')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class ExperimentProduct(db.Model):
    """成品参数表"""
    __tablename__ = 'experiment_product'
    __table_args__ = {'extend_existing': True}
    
    id = db.Column(db.Integer, primary_key=True)
    experiment_id = db.Column(db.Integer, db.ForeignKey('experiments.id'), nullable=False, unique=True)
    product_code = db.Column(db.String(100))
    avg_thickness = db.Column(db.Numeric(8, 2))
    specification = db.Column(db.String(100))
    avg_density = db.Column(db.Numeric(6, 3))
    thermal_diffusivity = db.Column(db.Numeric(10, 6))
    thermal_conductivity = db.Column(db.Numeric(8, 3))
    specific_heat = db.Column(db.Numeric(8, 4))
    cohesion = db.Column(db.Numeric(8, 2))
    peel_strength = db.Column(db.Numeric(8, 2))
    roughness = db.Column(db.String(50))
    appearance_desc = db.Column(db.Text)
    appearance_defect_photo = db.Column(db.String(255))
    sample_photo = db.Column(db.String(255))
    experiment_summary = db.Column(db.Text)
    other_files = db.Column(db.String(255))
    remarks = db.Column(db.Text)
    bond_strength = db.Column(db.Numeric(8, 2), comment='结合力')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)