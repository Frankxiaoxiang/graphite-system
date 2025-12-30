from app import db
from datetime import datetime
from sqlalchemy.dialects.mysql import DECIMAL

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
    
    # 关系定义
    basic = db.relationship('ExperimentBasic', backref='experiment', uselist=False, cascade='all, delete-orphan')
    pi = db.relationship('ExperimentPi', backref='experiment', uselist=False, cascade='all, delete-orphan')
    loose = db.relationship('ExperimentLoose', backref='experiment', uselist=False, cascade='all, delete-orphan')
    carbon = db.relationship('ExperimentCarbon', backref='experiment', uselist=False, cascade='all, delete-orphan')
    graphite = db.relationship('ExperimentGraphite', backref='experiment', uselist=False, cascade='all, delete-orphan')
    rolling = db.relationship('ExperimentRolling', backref='experiment', uselist=False, cascade='all, delete-orphan')
    product = db.relationship('ExperimentProduct', backref='experiment', uselist=False, cascade='all, delete-orphan')
    
    def to_dict(self):
        """主表序列化，嵌套所有子表数据"""
        data = {
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
        # 嵌套各个部分的数据
        if self.basic: data['basic'] = self.basic.to_dict()
        if self.pi: data['pi'] = self.pi.to_dict()
        if self.loose: data['loose'] = self.loose.to_dict()
        if self.carbon: data['carbon'] = self.carbon.to_dict()
        if self.graphite: data['graphite'] = self.graphite.to_dict()
        if self.rolling: data['rolling'] = self.rolling.to_dict()
        if self.product: data['product'] = self.product.to_dict()
        return data

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
    
    # ✅ 新增：石墨型号 (必填)
    graphite_model = db.Column(db.String(50), nullable=False, default='SGF-010', comment='石墨型号')
    
    material_type_for_firing = db.Column(db.String(20))
    rolling_method = db.Column(db.String(20))
    experiment_group = db.Column(db.Integer)
    experiment_purpose = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'pi_film_thickness': float(self.pi_film_thickness) if self.pi_film_thickness else None,
            'customer_type': self.customer_type,
            'customer_name': self.customer_name,
            'pi_film_model': self.pi_film_model,
            'experiment_date': self.experiment_date.isoformat() if self.experiment_date else None,
            'sintering_location': self.sintering_location,
            'graphite_model': self.graphite_model,
            'material_type_for_firing': self.material_type_for_firing,
            'rolling_method': self.rolling_method,
            'experiment_group': self.experiment_group,
            'experiment_purpose': self.experiment_purpose
        }

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
    
    # ✅ 改名并必填
    pi_roll_batch_number = db.Column(db.String(100), nullable=False, comment='PI支料号/批次号')
    # ✅ 改为非必填
    pi_weight = db.Column(db.Numeric(10, 3), nullable=True)
    
    firing_rolls = db.Column(db.Integer, comment='烧制卷数')
    pi_notes = db.Column(db.Text, comment='PI膜补充说明')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'pi_manufacturer': self.pi_manufacturer,
            'pi_thickness_detail': float(self.pi_thickness_detail) if self.pi_thickness_detail else None,
            'pi_model_detail': self.pi_model_detail,
            'pi_width': float(self.pi_width) if self.pi_width else None,
            'pi_roll_batch_number': self.pi_roll_batch_number,
            'pi_weight': float(self.pi_weight) if self.pi_weight else None,
            'firing_rolls': self.firing_rolls,
            'pi_notes': self.pi_notes
        }

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

    def to_dict(self):
        return {
            'core_tube_type': self.core_tube_type,
            'loose_gap_inner': float(self.loose_gap_inner) if self.loose_gap_inner else None,
            'loose_gap_middle': float(self.loose_gap_middle) if self.loose_gap_middle else None,
            'loose_gap_outer': float(self.loose_gap_outer) if self.loose_gap_outer else None
        }

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
    carbon_notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'carbon_furnace_number': self.carbon_furnace_number,
            'carbon_furnace_batch': self.carbon_furnace_batch,
            'boat_model': self.boat_model,
            'wrapping_method': self.wrapping_method,
            'vacuum_degree': float(self.vacuum_degree) if self.vacuum_degree else None,
            'power_consumption': float(self.power_consumption) if self.power_consumption else None,
            'start_time': self.start_time.isoformat() if self.start_time else None,
            'end_time': self.end_time.isoformat() if self.end_time else None,
            'carbon_max_temp': float(self.carbon_max_temp) if self.carbon_max_temp else None,
            'carbon_total_time': self.carbon_total_time,
            'carbon_yield_rate': float(self.carbon_yield_rate) if self.carbon_yield_rate else None,
            'carbon_notes': self.carbon_notes
        }

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
    
    # 温度和厚度配对字段
    graphite_temp1 = db.Column(db.Numeric(8, 2)); graphite_thickness1 = db.Column(db.Numeric(8, 2))
    graphite_temp2 = db.Column(db.Numeric(8, 2)); graphite_thickness2 = db.Column(db.Numeric(8, 2))
    graphite_temp3 = db.Column(db.Numeric(8, 2)); graphite_thickness3 = db.Column(db.Numeric(8, 2))
    graphite_temp4 = db.Column(db.Numeric(8, 2)); graphite_thickness4 = db.Column(db.Numeric(8, 2))
    graphite_temp5 = db.Column(db.Numeric(8, 2)); graphite_thickness5 = db.Column(db.Numeric(8, 2))
    graphite_temp6 = db.Column(db.Numeric(8, 2)); graphite_thickness6 = db.Column(db.Numeric(8, 2))
    
    # ✅ 改名：卷内发泡厚度
    inner_foaming_thickness = db.Column(db.Numeric(8, 2), nullable=True, comment='卷内发泡厚度(μm)')
    # ✅ 新增：卷外发泡厚度 (必填)
    outer_foaming_thickness = db.Column(db.Numeric(8, 2), nullable=False, default=0.00, comment='卷外发泡厚度(μm)')
    
    graphite_max_temp = db.Column(db.Numeric(8, 2))
    graphite_width = db.Column(db.Numeric(10, 2))
    shrinkage_ratio = db.Column(db.Numeric(5, 4))
    graphite_total_time = db.Column(db.Integer)
    
    # ✅ 修改：改为非必填
    graphite_after_weight = db.Column(db.Numeric(10, 3), nullable=True)
    graphite_yield_rate = db.Column(db.Numeric(5, 2), nullable=True)
    
    graphite_loading_photo = db.Column(db.String(255))
    graphite_sample_photo = db.Column(db.String(255))
    graphite_min_thickness = db.Column(db.Numeric(8, 2))
    graphite_other_params = db.Column(db.String(255))
    graphite_notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'graphite_furnace_number': self.graphite_furnace_number,
            'graphite_furnace_batch': self.graphite_furnace_batch,
            'gas_pressure': float(self.gas_pressure) if self.gas_pressure else None,
            'inner_foaming_thickness': float(self.inner_foaming_thickness) if self.inner_foaming_thickness else None,
            'outer_foaming_thickness': float(self.outer_foaming_thickness) if self.outer_foaming_thickness else None,
            'graphite_max_temp': float(self.graphite_max_temp) if self.graphite_max_temp else None,
            'graphite_after_weight': float(self.graphite_after_weight) if self.graphite_after_weight else None,
            'graphite_yield_rate': float(self.graphite_yield_rate) if self.graphite_yield_rate else None,
            'graphite_notes': self.graphite_notes
        }

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
    rolling_notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'rolling_machine': self.rolling_machine,
            'rolling_pressure': float(self.rolling_pressure) if self.rolling_pressure else None,
            'rolling_speed': float(self.rolling_speed) if self.rolling_speed else None,
            'rolling_notes': self.rolling_notes
        }

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
    bond_strength = db.Column(db.Numeric(8, 2))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'product_code': self.product_code,
            'avg_thickness': float(self.avg_thickness) if self.avg_thickness else None,
            'avg_density': float(self.avg_density) if self.avg_density else None,
            'thermal_conductivity': float(self.thermal_conductivity) if self.thermal_conductivity else None,
            'cohesion': float(self.cohesion) if self.cohesion else None,
            'peel_strength': float(self.peel_strength) if self.peel_strength else None,
            'experiment_summary': self.experiment_summary
        }