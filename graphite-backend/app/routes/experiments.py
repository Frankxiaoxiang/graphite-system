from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.models.experiment import (
    Experiment, ExperimentBasic, ExperimentPi, ExperimentLoose,
    ExperimentCarbon, ExperimentGraphite, ExperimentRolling, ExperimentProduct
)
from app.models.system_log import SystemLog
from app.utils.experiment_code import generate_experiment_code
from app.utils.permissions import require_permission
from datetime import datetime
import csv
import io

experiments_bp = Blueprint('experiments', __name__)

@experiments_bp.route('/', methods=['GET'])
@jwt_required()
def get_experiments():
    """获取实验列表"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        status = request.args.get('status')
        
        # 构建查询
        query = Experiment.query
        
        # 权限控制：普通用户只能看自己的实验
        if user.role == 'user':
            query = query.filter_by(created_by=current_user_id)
        
        # 状态筛选
        if status:
            query = query.filter_by(status=status)
        
        # 分页
        experiments = query.order_by(Experiment.created_at.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        result = []
        for exp in experiments.items:
            exp_data = exp.to_dict()
            exp_data['creator_name'] = exp.creator.real_name or exp.creator.username
            
            # 添加基础信息
            if exp.basic:
                exp_data['customer_name'] = exp.basic.customer_name
                exp_data['experiment_date'] = exp.basic.experiment_date.isoformat() if exp.basic.experiment_date else None
            
            result.append(exp_data)
        
        return jsonify({
            'experiments': result,
            'pagination': {
                'page': experiments.page,
                'pages': experiments.pages,
                'per_page': experiments.per_page,
                'total': experiments.total
            }
        }), 200       
    except Exception as e:
        return jsonify({'error': '获取实验列表失败'}), 500
@experiments_bp.route('/', methods=['POST'])
@jwt_required()
def create_experiment():
    """创建新实验"""
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        # 创建实验主记录
        experiment = Experiment(
            experiment_code='TEMP_CODE',  # 临时编码，后面会更新
            status='draft',
            created_by=current_user_id
        )
        db.session.add(experiment)
        db.session.flush()  # 获取实验ID
        
        # 保存实验基础参数
        if 'basic' in data:
            basic_data = data['basic']
            basic = ExperimentBasic(
                experiment_id=experiment.id,
                **basic_data
            )
            db.session.add(basic)
            
            # 生成实验编码
            if all(key in basic_data for key in ['pi_film_thickness', 'customer_type', 'customer_name', 
                                                 'pi_film_model', 'experiment_date', 'sintering_location',
                                                 'material_type_for_firing', 'rolling_method', 'experiment_group']):
                experiment_code = generate_experiment_code(basic_data)
                experiment.experiment_code = experiment_code
        
        # 保存其他模块数据
        modules = ['pi', 'loose', 'carbon', 'graphite', 'rolling', 'product']
        model_mapping = {
            'pi': ExperimentPi,
            'loose': ExperimentLoose,
            'carbon': ExperimentCarbon,
            'graphite': ExperimentGraphite,
            'rolling': ExperimentRolling,
            'product': ExperimentProduct
        }
        
        for module in modules:
            if module in data:
                model_class = model_mapping[module]
                module_data = data[module]
                module_data['experiment_id'] = experiment.id
                module_instance = model_class(**module_data)
                db.session.add(module_instance)
        
        db.session.commit()
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='create_experiment',
            target_type='experiment',
            target_id=experiment.id,
            description=f'创建实验 {experiment.experiment_code}',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': '实验创建成功',
            'experiment': experiment.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'创建实验失败: {str(e)}'}), 500

@experiments_bp.route('/<int:experiment_id>', methods=['GET'])
@jwt_required()
def get_experiment(experiment_id):
    """获取实验详情"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        experiment = Experiment.query.get(experiment_id)
        if not experiment:
            return jsonify({'error': '实验不存在'}), 404
        
        # 权限检查：普通用户只能查看自己的实验
        if user.role == 'user' and experiment.created_by != current_user_id:
            return jsonify({'error': '无权访问此实验'}), 403
        
        # 构建完整的实验数据
        experiment_data = experiment.to_dict()
        experiment_data['creator_name'] = experiment.creator.real_name or experiment.creator.username
        
        # 添加各模块数据
        if experiment.basic:
            experiment_data['basic'] = {
                'pi_film_thickness': float(experiment.basic.pi_film_thickness) if experiment.basic.pi_film_thickness else None,
                'customer_type': experiment.basic.customer_type,
                'customer_name': experiment.basic.customer_name,
                'pi_film_model': experiment.basic.pi_film_model,
                'experiment_date': experiment.basic.experiment_date.isoformat() if experiment.basic.experiment_date else None,
                'sintering_location': experiment.basic.sintering_location,
                'material_type_for_firing': experiment.basic.material_type_for_firing,
                'rolling_method': experiment.basic.rolling_method,
                'experiment_group': experiment.basic.experiment_group,
                'experiment_purpose': experiment.basic.experiment_purpose
            }
        
        if experiment.pi:
            experiment_data['pi'] = {
                'pi_manufacturer': experiment.pi.pi_manufacturer,
                'pi_thickness_detail': float(experiment.pi.pi_thickness_detail) if experiment.pi.pi_thickness_detail else None,
                'pi_model_detail': experiment.pi.pi_model_detail,
                'pi_width': float(experiment.pi.pi_width) if experiment.pi.pi_width else None,
                'batch_number': experiment.pi.batch_number,
                'pi_weight': float(experiment.pi.pi_weight) if experiment.pi.pi_weight else None
            }
        
        # 添加其他模块数据（碳化、石墨化、压延、成品）
        # 这里可以继续添加其他模块的数据转换
        
        return jsonify({'experiment': experiment_data}), 200
        
    except Exception as e:
        return jsonify({'error': '获取实验详情失败'}), 500

@experiments_bp.route('/<int:experiment_id>', methods=['PUT'])
@jwt_required()
def update_experiment(experiment_id):
    """更新实验数据"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        experiment = Experiment.query.get(experiment_id)
        if not experiment:
            return jsonify({'error': '实验不存在'}), 404
        
        # 权限检查
        if user.role == 'user' and experiment.created_by != current_user_id:
            return jsonify({'error': '无权修改此实验'}), 403
        
        data = request.get_json()
        
        # 更新实验状态
        if 'status' in data:
            experiment.status = data['status']
            if data['status'] == 'submitted':
                experiment.submitted_at = datetime.utcnow()
        
        # 更新各模块数据
        modules = ['basic', 'pi', 'loose', 'carbon', 'graphite', 'rolling', 'product']
        model_mapping = {
            'basic': ExperimentBasic,
            'pi': ExperimentPi,
            'loose': ExperimentLoose,
            'carbon': ExperimentCarbon,
            'graphite': ExperimentGraphite,
            'rolling': ExperimentRolling,
            'product': ExperimentProduct
        }
        
        for module in modules:
            if module in data:
                model_class = model_mapping[module]
                module_data = data[module]
                
                # 查找或创建模块实例
                module_instance = model_class.query.filter_by(experiment_id=experiment.id).first()
                if not module_instance:
                    module_instance = model_class(experiment_id=experiment.id)
                    db.session.add(module_instance)
                
                # 更新字段
                for key, value in module_data.items():
                    if hasattr(module_instance, key):
                        setattr(module_instance, key, value)
        
        experiment.updated_at = datetime.utcnow()
        db.session.commit()
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='update_experiment',
            target_type='experiment',
            target_id=experiment.id,
            description=f'更新实验 {experiment.experiment_code}',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': '实验更新成功',
            'experiment': experiment.to_dict()
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'更新实验失败: {str(e)}'}), 500

@experiments_bp.route('/<int:experiment_id>', methods=['DELETE'])
@jwt_required()
@require_permission('delete_all')
def delete_experiment(experiment_id):
    """删除实验"""
    try:
        current_user_id = get_jwt_identity()
        
        experiment = Experiment.query.get(experiment_id)
        if not experiment:
            return jsonify({'error': '实验不存在'}), 404
        
        experiment_code = experiment.experiment_code
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='delete_experiment',
            target_type='experiment',
            target_id=experiment.id,
            description=f'删除实验 {experiment_code}',
            ip_address=request.remote_addr
        )
        
        db.session.delete(experiment)
        db.session.commit()
        
        return jsonify({'message': '实验删除成功'}), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': '删除实验失败'}), 500

@experiments_bp.route('/export', methods=['POST'])
@jwt_required()
def export_experiments():
    """导出实验数据"""
    try:
        current_user_id = get_jwt_identity()
        user = User.query.get(current_user_id)
        
        data = request.get_json()
        experiment_ids = data.get('experiment_ids', [])
        
        if not experiment_ids:
            return jsonify({'error': '请选择要导出的实验'}), 400
        
        # 构建查询
        query = Experiment.query.filter(Experiment.id.in_(experiment_ids))
        
        # 权限控制：普通用户只能导出自己的实验
        if user.role == 'user':
            query = query.filter_by(created_by=current_user_id)
        
        experiments = query.all()
        
        # 生成CSV数据
        output = io.StringIO()
        writer = csv.writer(output)
        
        # 写入表头
        headers = [
            '实验编码', '客户名称', '实验日期', '状态', '创建人',
            'PI膜厚度', 'PI膜型号', '碳化最高温度', '石墨化最高温度',
            '成品厚度', '平均密度', '导热系数'
        ]
        writer.writerow(headers)
        
        # 写入数据
        for exp in experiments:
            row = [
                exp.experiment_code,
                exp.basic.customer_name if exp.basic else '',
                exp.basic.experiment_date.strftime('%Y-%m-%d') if exp.basic and exp.basic.experiment_date else '',
                exp.status,
                exp.creator.real_name or exp.creator.username,
                exp.basic.pi_film_thickness if exp.basic else '',
                exp.basic.pi_film_model if exp.basic else '',
                exp.carbon.carbon_max_temp if exp.carbon else '',
                exp.graphite.graphite_max_temp if exp.graphite else '',
                exp.product.avg_thickness if exp.product else '',
                exp.product.avg_density if exp.product else '',
                exp.product.thermal_conductivity if exp.product else ''
            ]
            writer.writerow(row)
        
        csv_content = output.getvalue()
        output.close()
        
        # 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='export_experiments',
            description=f'导出 {len(experiments)} 个实验数据',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'csv_content': csv_content,
            'filename': f'experiments_export_{datetime.now().strftime("%Y%m%d_%H%M%S")}.csv'
        }), 200
        
    except Exception as e:
        return jsonify({'error': '导出失败'}), 500