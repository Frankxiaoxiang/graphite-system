def generate_experiment_code(basic_data):
    """
    生成实验编码
    格式: PI膜厚度 + 客户类型首字母 + 客户代码 + "-" + PI膜型号 + "-" + 日期后6位 + 烧制地点 + "-" + 材料类型 + 压延方式 + 编组
    """
    try:
        # 提取各个组成部分
        pi_thickness = str(int(float(basic_data['pi_film_thickness'])))
        customer_type = basic_data['customer_type']
        customer_code = basic_data['customer_name'].split('/')[0]  # 取/前的部分
        pi_model = basic_data['pi_film_model']
        
        # 处理日期（取后6位）
        experiment_date = basic_data['experiment_date']
        if isinstance(experiment_date, str):
            date_part = experiment_date.replace('-', '')[-6:]
        else:
            date_part = experiment_date.strftime('%y%m%d')
        
        sintering_location = basic_data['sintering_location']
        material_type = basic_data['material_type_for_firing']
        rolling_method = basic_data['rolling_method']
        experiment_group = str(basic_data['experiment_group']).zfill(2)  # 补零到2位
        
        # 生成编码
        experiment_code = f"{pi_thickness}{customer_type}{customer_code}-{pi_model}-{date_part}{sintering_location}-{material_type}{rolling_method}{experiment_group}"
        
        return experiment_code
        
    except Exception as e:
        raise ValueError(f"生成实验编码失败: {str(e)}")