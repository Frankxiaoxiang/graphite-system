/**
 * 数据分析模块 - API接口
 */

import request from '@/utils/request'
import type {
  FieldOption,
  AnalysisDataResponse,
  AnalysisQueryParams,
  RegressionResult,
  RegressionRequest,
  AnalysisConfig
} from '@/types/analysis'

/**
 * 获取可用字段列表
 */
export function getFieldOptions() {
  return request<{ fields: FieldOption[] }>({
    url: '/analysis/field-options',
    method: 'get'
  })
}

/**
 * 获取分析数据
 */
export function getAnalysisData(params: AnalysisQueryParams) {
  return request<AnalysisDataResponse>({
    url: '/analysis/data',
    method: 'get',
    params: {
      x_field: params.x_field,
      y_field: params.y_field,
      date_start: params.date_start,
      date_end: params.date_end,
      pi_film_model: params.pi_film_model,
      sintering_location: params.sintering_location,
      exclude_zero: params.exclude_zero !== false ? 'true' : 'false',
      enable_outlier_detection: params.enable_outlier_detection !== false ? 'true' : 'false',
      outlier_method: params.outlier_method || 'iqr'
    }
  })
}

/**
 * 执行线性回归分析
 */
export function performLinearRegression(data: RegressionRequest) {
  return request<RegressionResult>({
    url: '/analysis/linear-regression',
    method: 'post',
    data
  })
}

/**
 * 保存分析配置
 */
export function saveAnalysisConfig(config: AnalysisConfig) {
  return request<{ id: number }>({
    url: '/analysis/configs',
    method: 'post',
    data: config
  })
}

/**
 * 获取已保存的分析配置列表
 */
export function getSavedConfigs() {
  return request<{ configs: AnalysisConfig[] }>({
    url: '/analysis/configs',
    method: 'get'
  })
}

/**
 * 获取单个分析配置
 */
export function getConfigById(id: number) {
  return request<AnalysisConfig>({
    url: `/analysis/configs/${id}`,
    method: 'get'
  })
}

/**
 * 删除分析配置
 */
export function deleteConfig(id: number) {
  return request({
    url: `/analysis/configs/${id}`,
    method: 'delete'
  })
}
