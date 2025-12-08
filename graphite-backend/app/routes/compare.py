from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.experiment import (
    Experiment, ExperimentBasic, ExperimentPi, ExperimentLoose,
    ExperimentCarbon, ExperimentGraphite, ExperimentRolling, 
    ExperimentProduct
)
from app.models.user import User
from app import db
import traceback

compare_bp = Blueprint('compare', __name__)

# ==========================================
# 🔧 修复：添加SQLAlchemy对象序列化辅助函数
# ==========================================
def model_to_dict(instance):
    """
    将SQLAlchemy模型对象转换为字典
    
    Args:
        instance: SQLAlchemy模型实例
        
    Returns:
        dict: 包含所有列数据的字典
    """
    if instance is None:
        return {}
    
    result = {}
    # 遍历所有列
    for column in instance.__table__.columns:
        value = getattr(instance, column.name)
        # 处理日期时间类型
        if hasattr(value, 'isoformat'):
            result[column.name] = value.isoformat()
        else:
            result[column.name] = value
    
    return result


@compare_bp.route('/compare', methods=['POST'])
@jwt_required()
def compare_experiments():
    """
    实验数据对比API
    
    请求体：
    {
        "experiment_ids": [1, 2, 3, ...]  # 实验ID列表（2-10个）
    }
    
    返回：
    {
        "experiments": [
            {
                "id": 1,
                "code": "100ISA-TH5100-251008DG-RIF01",
                "basic": {...},
                "pi": {...},
                "carbon": {...},
                "graphite": {...},
                "product": {...}
            },
            ...
        ],
        "fields": [
            {
                "category": "基本参数",
                "name": "PI膜厚度",
                "key": "pi_film_thickness",
                "type": "number",
                "unit": "μm"
            },
            ...
        ]
    }
    """
    try:
        print("=" * 60)
        print("📊 收到实验对比请求")
        
        # 1. 验证JWT
        current_user_id = int(get_jwt_identity())
        user = User.query.get(current_user_id)
        print(f"   - 用户ID: {current_user_id}, 角色: {user.role}")
        
        # 2. 权限检查（只有工程师和管理员可以对比）
        if user.role not in ['admin', 'engineer']:
            print(f"❌ 权限不足: {user.role}")
            return jsonify({'error': '您没有权限访问此功能'}), 403
        
        # 3. 获取请求参数
        data = request.get_json()
        experiment_ids = data.get('experiment_ids', [])
        print(f"   - 请求对比的实验ID: {experiment_ids}")
        
        # 4. 验证实验数量（2-10个）
        if len(experiment_ids) < 2:
            print("❌ 实验数量不足")
            return jsonify({'error': '请至少选择2个实验进行对比'}), 400
        if len(experiment_ids) > 10:
            print("❌ 实验数量过多")
            return jsonify({'error': '最多只能同时对比10个实验'}), 400
        
        # 5. 查询实验数据
        experiments_data = []
        for exp_id in experiment_ids:
            experiment = Experiment.query.get(exp_id)
            if not experiment:
                print(f"❌ 实验ID {exp_id} 不存在")
                return jsonify({'error': f'实验ID {exp_id} 不存在'}), 404
            
            # 查询所有子表数据
            basic = ExperimentBasic.query.filter_by(experiment_id=exp_id).first()
            pi = ExperimentPi.query.filter_by(experiment_id=exp_id).first()
            loose = ExperimentLoose.query.filter_by(experiment_id=exp_id).first()
            carbon = ExperimentCarbon.query.filter_by(experiment_id=exp_id).first()
            graphite = ExperimentGraphite.query.filter_by(experiment_id=exp_id).first()
            rolling = ExperimentRolling.query.filter_by(experiment_id=exp_id).first()
            product = ExperimentProduct.query.filter_by(experiment_id=exp_id).first()
            
            # 🔧 修复：使用 model_to_dict() 替代 to_dict()
            exp_data = {
                'id': experiment.id,
                'code': experiment.experiment_code,
                'status': experiment.status,
                'created_at': experiment.created_at.isoformat() if experiment.created_at else None,
                'basic': model_to_dict(basic),
                'pi': model_to_dict(pi),
                'loose': model_to_dict(loose),
                'carbon': model_to_dict(carbon),
                'graphite': model_to_dict(graphite),
                'rolling': model_to_dict(rolling),
                'product': model_to_dict(product)
            }
            experiments_data.append(exp_data)
            print(f"   ✅ 加载实验 {experiment.experiment_code}")
        
        # 6. 定义字段元数据（所有要对比的字段）
        fields = _get_comparison_fields()
        
        print(f"✅ 对比成功: {len(experiments_data)}个实验, {len(fields)}个字段")
        print("=" * 60)
        
        return jsonify({
            'experiments': experiments_data,
            'fields': fields
        }), 200
        
    except Exception as e:
        print(f"❌ 对比实验数据失败: {str(e)}")
        traceback.print_exc()
        print("=" * 60)
        return jsonify({'error': '对比实验数据失败'}), 500


def _get_comparison_fields():
    """
    定义所有要对比的字段
    
    返回字段元数据列表，包含：
    - category: 分类（基本参数、PI膜参数等）
    - name: 中文名称
    - key: 字段key（用于取值，支持嵌套如 basic.pi_film_thickness）
    - type: 数据类型（number/string/date）
    - unit: 单位
    """
    return [
        # 基本参数（10个字段）
        {"category": "基本参数", "name": "实验编码", "key": "code", "type": "string", "unit": ""},
        {"category": "基本参数", "name": "PI膜厚度", "key": "basic.pi_film_thickness", "type": "number", "unit": "μm"},
        {"category": "基本参数", "name": "客户类型", "key": "basic.customer_type", "type": "string", "unit": ""},
        {"category": "基本参数", "name": "客户名称", "key": "basic.customer_name", "type": "string", "unit": ""},
        {"category": "基本参数", "name": "PI膜型号", "key": "basic.pi_film_model", "type": "string", "unit": ""},
        {"category": "基本参数", "name": "实验日期", "key": "basic.experiment_date", "type": "date", "unit": ""},
        {"category": "基本参数", "name": "烧制地点", "key": "basic.sintering_location", "type": "string", "unit": ""},
        {"category": "基本参数", "name": "送烧材料类型", "key": "basic.material_type_for_firing", "type": "string", "unit": ""},
        {"category": "基本参数", "name": "压延方式", "key": "basic.rolling_method", "type": "string", "unit": ""},
        {"category": "基本参数", "name": "实验编组", "key": "basic.experiment_group", "type": "number", "unit": ""},
        
        # PI膜参数（6个字段）
        {"category": "PI膜参数", "name": "PI膜厂商", "key": "pi.pi_manufacturer", "type": "string", "unit": ""},
        {"category": "PI膜参数", "name": "PI膜厚度", "key": "pi.pi_thickness_detail", "type": "number", "unit": "μm"},
        {"category": "PI膜参数", "name": "PI膜宽幅", "key": "pi.pi_width", "type": "number", "unit": "mm"},
        {"category": "PI膜参数", "name": "PI重量", "key": "pi.pi_weight", "type": "number", "unit": "kg"},
        {"category": "PI膜参数", "name": "PI膜批次", "key": "pi.pi_batch", "type": "string", "unit": ""},
        {"category": "PI膜参数", "name": "PI膜备注", "key": "pi.pi_remarks", "type": "string", "unit": ""},
        
        # 松卷参数（4个字段）
        {"category": "松卷参数", "name": "松卷张力", "key": "loose.loose_tension", "type": "number", "unit": "N"},
        {"category": "松卷参数", "name": "松卷速度", "key": "loose.loose_speed", "type": "number", "unit": "m/min"},
        {"category": "松卷参数", "name": "松卷温度", "key": "loose.loose_temperature", "type": "number", "unit": "℃"},
        {"category": "松卷参数", "name": "松卷备注", "key": "loose.loose_remarks", "type": "string", "unit": ""},
        
        # 碳化参数（关键字段）
        {"category": "碳化参数", "name": "碳化炉编号", "key": "carbon.carbon_furnace_number", "type": "string", "unit": ""},
        {"category": "碳化参数", "name": "碳化炉次", "key": "carbon.carbon_furnace_batch", "type": "string", "unit": ""},
        {"category": "碳化参数", "name": "碳化最高温度", "key": "carbon.carbon_max_temp", "type": "number", "unit": "℃"},
        {"category": "碳化参数", "name": "碳化总时长", "key": "carbon.carbon_total_time", "type": "number", "unit": "h"},
        {"category": "碳化参数", "name": "碳化后厚度", "key": "carbon.carbon_film_thickness", "type": "number", "unit": "μm"},
        {"category": "碳化参数", "name": "成碳率", "key": "carbon.carbon_yield_rate", "type": "number", "unit": "%"},
        
        # 石墨化参数（关键字段）
        {"category": "石墨化参数", "name": "石墨化炉编号", "key": "graphite.graphite_furnace_number", "type": "string", "unit": ""},
        {"category": "石墨化参数", "name": "石墨化炉次", "key": "graphite.graphite_furnace_batch", "type": "string", "unit": ""},
        {"category": "石墨化参数", "name": "石墨化最高温度", "key": "graphite.graphite_max_temp", "type": "number", "unit": "℃"},
        {"category": "石墨化参数", "name": "石墨化总时长", "key": "graphite.graphite_total_time", "type": "number", "unit": "h"},
        {"category": "石墨化参数", "name": "石墨化后厚度", "key": "graphite.graphite_thickness", "type": "number", "unit": "μm"},
        
        # 压延参数（4个字段）
        {"category": "压延参数", "name": "压延温度", "key": "rolling.rolling_temperature", "type": "number", "unit": "℃"},
        {"category": "压延参数", "name": "压延压力", "key": "rolling.rolling_pressure", "type": "number", "unit": "MPa"},
        {"category": "压延参数", "name": "压延速度", "key": "rolling.rolling_speed", "type": "number", "unit": "m/min"},
        {"category": "压延参数", "name": "压延备注", "key": "rolling.rolling_remarks", "type": "string", "unit": ""},
        
        # 成品参数（关键性能指标）
        {"category": "成品参数", "name": "成品编码", "key": "product.product_code", "type": "string", "unit": ""},
        {"category": "成品参数", "name": "成品厚度", "key": "product.product_thickness", "type": "number", "unit": "μm"},
        {"category": "成品参数", "name": "成品密度", "key": "product.density", "type": "number", "unit": "g/cm³"},
        {"category": "成品参数", "name": "导热系数", "key": "product.thermal_conductivity", "type": "number", "unit": "W/m·K"},
        {"category": "成品参数", "name": "抗拉强度", "key": "product.tensile_strength", "type": "number", "unit": "MPa"},
        {"category": "成品参数", "name": "弯曲强度", "key": "product.flexural_strength", "type": "number", "unit": "MPa"},
        {"category": "成品参数", "name": "拉伸模量", "key": "product.tensile_modulus", "type": "number", "unit": "GPa"},
        {"category": "成品参数", "name": "弯曲模量", "key": "product.flexural_modulus", "type": "number", "unit": "GPa"},
        {"category": "成品参数", "name": "热膨胀系数X", "key": "product.cte_x", "type": "number", "unit": "ppm/K"},
        {"category": "成品参数", "name": "热膨胀系数Y", "key": "product.cte_y", "type": "number", "unit": "ppm/K"},
    ]