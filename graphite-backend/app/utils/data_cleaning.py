"""
数据清洗工具模块 - 用于分析功能的数据质量控制
实现三层过滤机制：SQL层 → Python层 → 报告生成
"""

import numpy as np
from typing import List, Dict, Any, Tuple


def clean_analysis_data(
    raw_data: List[Dict[str, Any]],
    exclude_zero: bool = True,
    enable_outlier_detection: bool = True,
    outlier_method: str = 'iqr',
    iqr_multiplier: float = 1.5
) -> Dict[str, Any]:
    """
    对分析数据进行清洗，返回带status字段的统一列表
    
    Args:
        raw_data: 原始数据列表，每项包含 experiment_code, x_value, y_value
        exclude_zero: 是否排除0值
        enable_outlier_detection: 是否启用异常值检测
        outlier_method: 异常值检测方法 ('iqr' 或 'zscore')
        iqr_multiplier: IQR方法的倍数（默认1.5）
    
    Returns:
        {
            'data': [...],  # 带status字段的数据列表
            'statistics': {...}  # 清洗统计信息
        }
    """
    
    # 初始化统计信息
    stats = {
        'total_count': len(raw_data),
        'valid_count': 0,
        'excluded_count': 0,
        'exclusion_reasons': {
            'null_values': 0,
            'zero_values': 0,
            'outliers': 0
        }
    }
    
    # 处理每条数据，添加status字段
    processed_data = []
    
    for item in raw_data:
        # 创建新数据项（保留原始数据）
        processed_item = {
            'experiment_code': item.get('experiment_code'),
            'x': float(item.get('x_value')) if item.get('x_value') is not None else None,  # ✅ 转换为 float
            'y': float(item.get('y_value')) if item.get('y_value') is not None else None,  # ✅ 转换为 float
            'status': 'valid',
            'cleaning_note': None
        }
        
        # Layer 1: NULL值检查（SQL层已过滤，这里做二次检查）
        if processed_item['x'] is None or processed_item['y'] is None:
            processed_item['status'] = 'excluded'
            processed_item['cleaning_note'] = 'null_value'
            stats['exclusion_reasons']['null_values'] += 1
            stats['excluded_count'] += 1
        
        # Layer 2: 0值检查
        elif exclude_zero and (processed_item['x'] == 0 or processed_item['y'] == 0):
            processed_item['status'] = 'excluded'
            processed_item['cleaning_note'] = 'zero_value'
            stats['exclusion_reasons']['zero_values'] += 1
            stats['excluded_count'] += 1
        
        else:
            # 暂时标记为有效，后续进行异常值检测
            stats['valid_count'] += 1
        
        processed_data.append(processed_item)
    
    # Layer 3: 异常值检测（仅对有效数据）
    if enable_outlier_detection and stats['valid_count'] >= 4:  # 至少需要4个点才能检测异常值
        outliers = _detect_outliers(processed_data, outlier_method, iqr_multiplier)
        
        for idx in outliers:
            processed_data[idx]['status'] = 'excluded'
            processed_data[idx]['cleaning_note'] = f'outlier_{outlier_method}'
            stats['valid_count'] -= 1
            stats['excluded_count'] += 1
            stats['exclusion_reasons']['outliers'] += 1
    
    return {
        'data': processed_data,
        'statistics': stats
    }


def _detect_outliers(
    data: List[Dict[str, Any]],
    method: str = 'iqr',
    iqr_multiplier: float = 1.5
) -> List[int]:
    """
    检测异常值，返回异常值的索引列表
    
    Args:
        data: 数据列表
        method: 检测方法 ('iqr' 或 'zscore')
        iqr_multiplier: IQR方法的倍数
    
    Returns:
        异常值的索引列表
    """
    # 只对status='valid'的数据进行检测
    valid_indices = [i for i, item in enumerate(data) if item['status'] == 'valid']
    
    if len(valid_indices) < 4:
        return []
    
    # 提取有效数据的X和Y值
    x_values = np.array([data[i]['x'] for i in valid_indices])
    y_values = np.array([data[i]['y'] for i in valid_indices])
    
    outlier_indices = []
    
    if method == 'iqr':
        # IQR方法（四分位距）
        x_outliers = _iqr_outliers(x_values, iqr_multiplier)
        y_outliers = _iqr_outliers(y_values, iqr_multiplier)
        
        # 合并X和Y的异常值索引
        combined_outliers = set(x_outliers) | set(y_outliers)
        outlier_indices = [valid_indices[i] for i in combined_outliers]
    
    elif method == 'zscore':
        # Z-Score方法
        x_outliers = _zscore_outliers(x_values, threshold=3)
        y_outliers = _zscore_outliers(y_values, threshold=3)
        
        combined_outliers = set(x_outliers) | set(y_outliers)
        outlier_indices = [valid_indices[i] for i in combined_outliers]
    
    return outlier_indices


def _iqr_outliers(values: np.ndarray, multiplier: float = 1.5) -> List[int]:
    """
    使用IQR方法检测异常值
    
    异常值定义：小于Q1 - multiplier*IQR 或 大于Q3 + multiplier*IQR
    """
    q1 = np.percentile(values, 25)
    q3 = np.percentile(values, 75)
    iqr = q3 - q1
    
    lower_bound = q1 - multiplier * iqr
    upper_bound = q3 + multiplier * iqr
    
    outliers = []
    for i, value in enumerate(values):
        if value < lower_bound or value > upper_bound:
            outliers.append(i)
    
    return outliers


def _zscore_outliers(values: np.ndarray, threshold: float = 3) -> List[int]:
    """
    使用Z-Score方法检测异常值
    
    异常值定义：|Z-Score| > threshold（默认3）
    """
    mean = np.mean(values)
    std = np.std(values)
    
    if std == 0:  # 避免除以0
        return []
    
    z_scores = np.abs((values - mean) / std)
    
    outliers = []
    for i, z in enumerate(z_scores):
        if z > threshold:
            outliers.append(i)
    
    return outliers


def generate_cleaning_report(statistics: Dict[str, Any]) -> Dict[str, Any]:
    """
    生成清洗报告，用于前端展示
    
    Args:
        statistics: 统计信息字典
    
    Returns:
        格式化的清洗报告
    """
    total = statistics['total_count']
    valid = statistics['valid_count']
    excluded = statistics['excluded_count']
    reasons = statistics['exclusion_reasons']
    
    # 计算百分比
    valid_percentage = (valid / total * 100) if total > 0 else 0
    excluded_percentage = (excluded / total * 100) if total > 0 else 0
    
    return {
        'summary': {
            'total_count': total,
            'valid_count': valid,
            'excluded_count': excluded,
            'valid_percentage': round(valid_percentage, 1),
            'excluded_percentage': round(excluded_percentage, 1)
        },
        'details': {
            'null_values': reasons['null_values'],
            'zero_values': reasons['zero_values'],
            'outliers': reasons['outliers']
        },
        'quality_assessment': _assess_data_quality(valid, total)
    }


def _assess_data_quality(valid_count: int, total_count: int) -> str:
    """
    评估数据质量
    
    Returns:
        'excellent' / 'good' / 'fair' / 'poor'
    """
    if total_count == 0:
        return 'insufficient'
    
    valid_ratio = valid_count / total_count
    
    if valid_ratio >= 0.9:
        return 'excellent'
    elif valid_ratio >= 0.75:
        return 'good'
    elif valid_ratio >= 0.5:
        return 'fair'
    else:
        return 'poor'
