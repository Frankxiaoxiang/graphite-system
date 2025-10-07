# graphite-backend/app/utils/experiment_code.py
# 实验编码生成和验证工具
# 主要用于：1) 格式验证  2) 备用生成（当前端未生成时）

from datetime import datetime

def generate_experiment_code(params):
    """
    生成实验编码（备用方案 - 当前端未生成时使用）
    
    编码规则：
    PI膜厚度 + 客户类型首字母 + 客户代码 + "-" + PI膜型号 + "-" + 
    实验日期后6位 + 烧制地点代码 + "-" + 送烧材料类型 + 压延方式 + 实验编组
    
    示例：55ISA-THS55-251005DG-RIR01
    
    参数说明：
    - pi_film_thickness: PI膜厚度（如：55）
    - customer_type: 客户类型（I/D/N）
    - customer_name: 客户名称（如：SA/三星，取前面的代码部分）
    - pi_film_model: PI膜型号（如：THS55）
    - experiment_date: 实验日期（YYYY-MM-DD 或 YYYYMMDD）
    - sintering_location: 烧制地点代码（如：DG）
    - material_type_for_firing: 送烧材料类型（R/P）
    - rolling_method: 压延方式（IF/IR/OF/OR）
    - experiment_group: 实验编组（如：1，会格式化为01）
    """
    
    try:
        # 1. PI膜厚度（整数部分）
        pi_thickness = str(int(float(params['pi_film_thickness'])))
        
        # 2. 客户类型首字母（I/D/N）
        customer_type = params['customer_type']
        
        # 3. 客户代码（从客户名称中提取，取"/"前的部分）
        customer_name = params['customer_name']
        if '/' in customer_name:
            customer_code = customer_name.split('/')[0]
        else:
            customer_code = customer_name[:2].upper()
        
        # 4. PI膜型号
        pi_model = params['pi_film_model']
        
        # 5. 实验日期后6位（YYMMDD）
        experiment_date = params['experiment_date']
        if isinstance(experiment_date, str):
            # 移除所有非数字字符
            date_str = ''.join(filter(str.isdigit, experiment_date))
            if len(date_str) == 8:  # YYYYMMDD
                date_code = date_str[2:]  # 取后6位：YYMMDD
            else:
                # 尝试解析日期
                try:
                    dt = datetime.strptime(experiment_date, '%Y-%m-%d')
                    date_code = dt.strftime('%y%m%d')
                except:
                    date_code = '000000'
        else:
            date_code = '000000'
        
        # 6. 烧制地点代码
        sintering_location = params['sintering_location']
        
        # 7. 送烧材料类型（R/P）
        material_type = params['material_type_for_firing']
        
        # 8. 压延方式（IF/IR/OF/OR）
        rolling_method = params['rolling_method']
        
        # 9. 实验编组（格式化为两位数）
        experiment_group = str(params['experiment_group']).zfill(2)
        
        # 组装实验编码
        experiment_code = (
            f"{pi_thickness}{customer_type}{customer_code}-"
            f"{pi_model}-"
            f"{date_code}{sintering_location}-"
            f"{material_type}{rolling_method}{experiment_group}"
        )
        
        return experiment_code
        
    except Exception as e:
        raise ValueError(f"生成实验编码失败: {str(e)}")


def validate_experiment_code_format(code):
    """
    验证实验编码格式是否正确
    
    返回：(is_valid: bool, error_message: str)
    
    示例：
    - 正确格式：55ISA-THS55-251005DG-RIR01
    - 错误格式：ISA-THS55-251005DG-RIR01（缺少厚度）
    """
    if not code or not isinstance(code, str):
        return False, "实验编码不能为空"
    
    # 去除首尾空格
    code = code.strip()
    
    # 检查连字符数量
    if code.count('-') != 3:
        return False, "实验编码格式错误：应包含3个连字符（-）"
    
    parts = code.split('-')
    
    # 验证第一部分：PI厚度+客户类型+客户代码
    if len(parts[0]) < 3:
        return False, "实验编码格式错误：第一部分过短（应包含PI厚度、客户类型和客户代码）"
    
    # 检查是否以数字开头（PI厚度）
    if not parts[0][0].isdigit():
        return False, "实验编码格式错误：应以PI膜厚度数字开头"
    
    # 验证第二部分：PI膜型号
    if len(parts[1]) < 1:
        return False, "实验编码格式错误：PI膜型号不能为空"
    
    # 验证第三部分：日期+地点（至少8位：6位日期+2位地点）
    if len(parts[2]) < 8:
        return False, "实验编码格式错误：日期和地点信息不完整（至少需要8个字符）"
    
    # 检查日期部分是否为数字
    date_part = parts[2][:6]
    if not date_part.isdigit():
        return False, "实验编码格式错误：日期部分应为6位数字（YYMMDD）"
    
    # 验证第四部分：材料类型+压延方式+编组（至少4位）
    if len(parts[3]) < 4:
        return False, "实验编码格式错误：材料类型、压延方式和编组信息不完整（至少需要4个字符）"
    
    # 检查材料类型（第1位应该是R或P）
    material_type = parts[3][0]
    if material_type not in ['R', 'P']:
        return False, f"实验编码格式错误：材料类型应为R或P，当前为{material_type}"
    
    # 检查压延方式（第2-3位）
    rolling_method = parts[3][1:3]
    valid_rolling_methods = ['IF', 'IR', 'OF', 'OR']
    if rolling_method not in valid_rolling_methods:
        return False, f"实验编码格式错误：压延方式应为{'/'.join(valid_rolling_methods)}之一，当前为{rolling_method}"
    
    # 检查编组（最后2位应该是数字）
    if len(parts[3]) >= 5:
        group = parts[3][3:5]
        if not group.isdigit():
            return False, f"实验编码格式错误：编组应为2位数字，当前为{group}"
    
    return True, ""


def parse_experiment_code(code):
    """
    解析实验编码，返回各个组成部分
    
    示例输入：55ISA-THS55-251005DG-RIR01
    返回：{
        'pi_thickness': '55',
        'customer_type': 'I',
        'customer_code': 'SA',
        'pi_model': 'THS55',
        'date': '251005',
        'location': 'DG',
        'material_type': 'R',
        'rolling_method': 'IR',
        'group': '01'
    }
    """
    try:
        parts = code.split('-')
        if len(parts) != 4:
            return None
        
        # 第一部分：PI厚度+客户类型+客户代码
        part1 = parts[0]
        # 提取数字部分作为厚度
        pi_thickness = ''
        idx = 0
        while idx < len(part1) and part1[idx].isdigit():
            pi_thickness += part1[idx]
            idx += 1
        customer_type = part1[idx] if idx < len(part1) else ''
        customer_code = part1[idx+1:] if idx+1 < len(part1) else ''
        
        # 第二部分：PI膜型号
        pi_model = parts[1]
        
        # 第三部分：日期+地点
        part3 = parts[2]
        date = part3[:6] if len(part3) >= 6 else ''
        location = part3[6:] if len(part3) > 6 else ''
        
        # 第四部分：材料类型+压延方式+编组
        part4 = parts[3]
        material_type = part4[0] if len(part4) >= 1 else ''
        rolling_method = part4[1:3] if len(part4) >= 3 else ''
        group = part4[3:5] if len(part4) >= 5 else ''
        
        return {
            'pi_thickness': pi_thickness,
            'customer_type': customer_type,
            'customer_code': customer_code,
            'pi_model': pi_model,
            'date': date,
            'location': location,
            'material_type': material_type,
            'rolling_method': rolling_method,
            'group': group
        }
    except:
        return None


# 测试函数（仅用于开发调试）
if __name__ == '__main__':
    print("=" * 50)
    print("实验编码生成和验证工具测试")
    print("=" * 50)
    
    # 测试1：编码生成
    print("\n【测试1：生成实验编码】")
    test_params = {
        'pi_film_thickness': 55,
        'customer_type': 'I',
        'customer_name': 'SA/三星',
        'pi_film_model': 'THS55',
        'experiment_date': '2025-10-05',
        'sintering_location': 'DG',
        'material_type_for_firing': 'R',
        'rolling_method': 'IR',
        'experiment_group': 1
    }
    
    code = generate_experiment_code(test_params)
    print(f"生成的编码: {code}")
    print(f"预期编码: 55ISA-THS55-251005DG-RIR01")
    print(f"是否匹配: {'✓' if code == '55ISA-THS55-251005DG-RIR01' else '✗'}")
    
    # 测试2：编码验证（正确格式）
    print("\n【测试2：验证正确格式的编码】")
    valid_codes = [
        '55ISA-THS55-251005DG-RIR01',
        '50DMP-KPI50-251005XT-PIF02',
        '75IN-ABC123-251231WF-ROR99'
    ]
    
    for test_code in valid_codes:
        is_valid, msg = validate_experiment_code_format(test_code)
        status = '✓ 通过' if is_valid else f'✗ 失败: {msg}'
        print(f"{test_code}: {status}")
    
    # 测试3：编码验证（错误格式）
    print("\n【测试3：验证错误格式的编码】")
    invalid_codes = [
        ('ISA-THS55-251005DG-RIR01', '缺少PI厚度'),
        ('55ISA-THS55-251005-RIR01', '缺少地点代码'),
        ('55ISA-THS55-25100DG-RIR01', '日期不是6位'),
        ('55ISA-THS55-251005DG-XIR01', '材料类型错误'),
        ('55ISA-THS55-251005DG-RXX01', '压延方式错误'),
        ('55ISA-THS55-251005DG-RIRAB', '编组不是数字')
    ]
    
    for test_code, expected_error in invalid_codes:
        is_valid, msg = validate_experiment_code_format(test_code)
        status = f"✓ 正确拦截" if not is_valid else f"✗ 未拦截"
        print(f"{test_code}: {status}")
        if msg:
            print(f"  错误信息: {msg}")
    
    # 测试4：编码解析
    print("\n【测试4：解析实验编码】")
    test_code = '55ISA-THS55-251005DG-RIR01'
    parsed = parse_experiment_code(test_code)
    print(f"原始编码: {test_code}")
    print("解析结果:")
    for key, value in parsed.items():
        print(f"  {key}: {value}")
    
    print("\n" + "=" * 50)
    print("测试完成！")
    print("=" * 50)