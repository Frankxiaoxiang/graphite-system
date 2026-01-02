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
  data: Experiment[]      // ✅ 后端返回的字段名是 data
  total: number
  page: number
  pages: number
  size: number
}

// ===== 核心 API 函数 =====

/**
 * 获取用于对比的实验列表
 * 注意：后端返回的数据结构是 { data: [], total: ... }
 */
export async function getExperimentsForCompare(params: ExperimentQueryParams) {
  const response = await request.get<ExperimentListResponse>('/experiments', { params })

  // 转换响应结构，将 data 字段映射为 experiments 以适配前端组件
  return {
    experiments: response.data || [],
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

/**
 * 导出实验对比数据为 Excel
 * * @param data - 实验ID列表
 * @returns Blob对象（Excel文件流）
 */
export function exportComparison(data: { experiment_ids: number[] }) {
  return request({
    url: '/compare/export',
    method: 'post',
    data,
    // 🔧 关键：必须设置 responseType 为 'blob'，否则解析出的文件会损坏
    responseType: 'blob',
    // 设置超时时间（生成包含80+字段的Excel可能需要较长时间）
    timeout: 60000
  })
}

// ===== 辅助工具函数 =====

/**
 * 触发浏览器下载 Excel 文件
 * * @param blob - Excel 文件 Blob 对象
 * @param filename - 文件名（如果不传，则使用带时间戳的默认名）
 */
export function downloadExcelFile(blob: Blob, filename?: string) {
  if (!filename) {
    filename = `实验对比报告_${new Date().getTime()}.xlsx`
  }

  // 创建 URL 对象
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename

  // 触发点击下载
  document.body.appendChild(link)
  link.click()

  // 下载完成后清理内存
  document.body.removeChild(link)
  window.URL.revokeObjectURL(url)
}

// ===== 向后兼容的别名 =====

/**
 * @deprecated 使用 getExperimentsForCompare 代替
 */
export const getExperiments = getExperimentsForCompare
