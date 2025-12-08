import request from '@/utils/request'

// ===== 类型定义 =====

/**
 * 实验基本信息
 */
export interface Experiment {
  id: number
  experiment_code: string
  customer_name: string
  pi_film_thickness: number
  experiment_date: string
  status: string
  created_at: string
  updated_at: string
}

/**
 * 对比字段定义
 */
export interface ComparisonField {
  key: string
  name: string
  category: string
  type: 'string' | 'number' | 'date'
  unit?: string
}

/**
 * 对比数据响应
 */
export interface ComparisonData {
  experiments: any[]
  fields: ComparisonField[]
}

/**
 * 实验列表查询参数
 */
export interface ExperimentQueryParams {
  page?: number
  page_size?: number
  status?: string
  search?: string
}

/**
 * 实验列表响应（匹配后端实际结构）
 */
export interface ExperimentListResponse {
  data: Experiment[]      // ✅ 后端返回的字段名是 data，不是 experiments
  total: number
  page: number
  pages: number
  size: number
}

// ===== API 函数 =====

/**
 * 获取用于对比的实验列表
 * 注意：后端返回的数据结构是 { data: [], total: ... }
 */
export async function getExperimentsForCompare(params: ExperimentQueryParams) {
  const response = await request.get<ExperimentListResponse>('/experiments', { params })
  
  // 转换响应结构，将 data 字段映射为 experiments
  return {
    experiments: response.data || [],  // ✅ 使用 data 字段
    total: response.total || 0
  }
}

/**
 * 对比多个实验的数据
 */
export async function compareExperiments(data: {
  experiment_ids: number[]
}): Promise<ComparisonData> {
  return request.post<ComparisonData>('/compare/compare', data)
}

// ===== 向后兼容的别名 =====

/**
 * @deprecated 使用 getExperimentsForCompare 代替
 */
export const getExperiments = getExperimentsForCompare
