/**
 * 数据分析模块 - TypeScript类型定义
 */

/**
 * 字段选项
 */
export interface FieldOption {
  value: string          // 字段名（数据库列名）
  label: string          // 中文显示名
  unit: string           // 单位
  category: string       // 分类标识
  category_label: string // 分类中文名
}

/**
 * 数据点
 */
export interface DataPoint {
  experiment_code: string  // 实验编号
  x: number                // X轴值
  y: number                // Y轴值
  status: 'valid' | 'excluded'  // 数据状态
  cleaning_note: string | null  // 清洗备注
}

/**
 * 字段元数据
 */
export interface FieldMetadata {
  x_field: string   // X轴字段名
  x_label: string   // X轴中文名
  x_unit: string    // X轴单位
  y_field: string   // Y轴字段名
  y_label: string   // Y轴中文名
  y_unit: string    // Y轴单位
}

/**
 * 数据统计信息
 */
export interface DataStatistics {
  total_count: number     // 总数据点数
  valid_count: number     // 有效数据点数
  excluded_count: number  // 被排除数据点数
  exclusion_reasons: {
    null_values: number   // NULL值数量
    zero_values: number   // 0值数量
    outliers: number      // 异常值数量
  }
}

/**
 * 清洗报告
 */
export interface CleaningReport {
  summary: {
    total_count: number
    valid_count: number
    excluded_count: number
    valid_percentage: number
    excluded_percentage: number
  }
  details: {
    null_values: number
    zero_values: number
    outliers: number
  }
  quality_assessment: 'excellent' | 'good' | 'fair' | 'poor' | 'insufficient'
}

/**
 * 分析数据响应
 */
export interface AnalysisDataResponse {
  data: DataPoint[]
  metadata: FieldMetadata
  statistics: DataStatistics
  cleaning_report: CleaningReport
}

/**
 * 查询参数
 */
export interface AnalysisQueryParams {
  x_field: string
  y_field: string
  date_start?: string
  date_end?: string
  pi_film_model?: string     // 逗号分隔的型号列表
  sintering_location?: string // 逗号分隔的地点列表
  exclude_zero?: boolean
  enable_outlier_detection?: boolean
  outlier_method?: 'iqr' | 'zscore'
}

/**
 * 回归分析结果
 */
export interface RegressionResult {
  equation: string         // 回归方程字符串
  slope: number           // 斜率
  intercept: number       // 截距
  r_squared: number       // R²值
  p_value: number         // p值
  std_err: number         // 标准误差
  n: number               // 数据点数量
  predictions: Array<{    // 预测点（用于绘制回归线）
    x: number
    y: number
  }>
  quality_assessment: {
    fit_quality: 'excellent' | 'good' | 'fair' | 'poor'
    significance: 'highly_significant' | 'moderately_significant' | 'not_significant'
  }
}

/**
 * 回归分析请求
 */
export interface RegressionRequest {
  data: Array<{
    x: number
    y: number
  }>
}

/**
 * 分析配置（用于保存/加载）
 */
export interface AnalysisConfig {
  id?: number
  name: string
  description?: string
  config: {
    x_axis: {
      field: string
      label: string
      unit: string
    }
    y_axis: {
      field: string
      label: string
      unit: string
    }
    filters: {
      date_start?: string
      date_end?: string
      pi_film_models?: string[]
      sintering_locations?: string[]
    }
    cleaning_options: {
      exclude_zero: boolean
      enable_outlier_detection: boolean
      outlier_method: 'iqr' | 'zscore'
    }
  }
  created_at?: string
  last_run_at?: string
  view_count?: number
}
