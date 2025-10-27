// src/api/experiments.ts
import request from '@/utils/request'

export interface ExperimentData {
  // 实验设计参数
  pi_film_thickness?: number
  customer_type?: string
  customer_name?: string
  pi_film_model?: string
  experiment_date?: string
  sintering_location?: string
  material_type_for_firing?: string
  rolling_method?: string
  experiment_group?: number
  experiment_purpose?: string
  experiment_code?: string

  // PI膜参数
  pi_manufacturer?: string
  pi_thickness_detail?: number
  pi_model_detail?: string
  pi_width?: number
  batch_number?: string
  pi_weight?: number

  // 松卷参数
  core_tube_type?: string
  loose_gap_inner?: number
  loose_gap_middle?: number
  loose_gap_outer?: number

  // 碳化参数
  carbon_furnace_num?: string
  carbon_batch_num?: number
  boat_model?: string
  wrap_type?: string
  vacuum_degree?: number
  carbon_power?: number
  carbon_start_time?: string
  carbon_end_time?: string
  carbon_temp1?: number
  carbon_thickness1?: number
  carbon_temp2?: number
  carbon_thickness2?: number
  carbon_max_temp?: number
  carbon_film_thickness?: number
  carbon_total_time?: number
  carbon_weight?: number
  carbon_yield_rate?: number
  carbon_loading_photo?: any
  carbon_sample_photo?: any
  carbon_other_params?: any

  // 石墨化参数
  graphite_furnace_num?: string
  graphite_batch_num?: number
  graphite_start_time?: string
  graphite_end_time?: string
  pressure_value?: number
  graphite_power?: number
  graphite_temp1?: number
  graphite_thickness1?: number
  graphite_temp2?: number
  graphite_thickness2?: number
  graphite_temp3?: number
  graphite_thickness3?: number
  graphite_temp4?: number
  graphite_thickness4?: number
  graphite_temp5?: number
  graphite_thickness5?: number
  graphite_temp6?: number
  graphite_thickness6?: number
  graphite_max_temp?: number
  foam_thickness?: number
  graphite_width?: number
  shrinkage_ratio?: number
  graphite_total_time?: number
  graphite_weight?: number
  graphite_yield_rate?: number
  graphite_min_thickness?: number
  graphite_loading_photo?: any
  graphite_sample_photo?: any
  graphite_other_params?: any

  // 压延参数
  rolling_machine_num?: string
  rolling_pressure?: number
  rolling_tension?: number
  rolling_speed?: number

  // 成品参数
  product_code?: string
  product_avg_thickness?: number
  product_spec?: string
  product_avg_density?: number
  thermal_diffusivity?: number
  thermal_conductivity?: number
  specific_heat?: number
  cohesion?: number
  peel_strength?: number
  roughness?: string
  appearance_description?: string
  experiment_summary?: string
  remarks?: string
  defect_photo?: any
  sample_photo?: any
  other_files?: any

  // 系统字段
  status?: 'draft' | 'submitted' | 'reviewing' | 'approved'
  created_by?: number
  created_at?: string
  updated_at?: string
  submitted_at?: string
}

export interface ExperimentListItem {
  id: number
  experiment_code: string
  status: string
  pi_film_thickness: number
  customer_name: string
  pi_film_model: string
  experiment_date: string
  created_by_name: string
  created_at: string
  updated_at: string
  submitted_at?: string
}

export interface ExperimentSearchParams {
  page?: number
  size?: number
  status?: string
  customer_name?: string
  pi_film_model?: string
  experiment_code?: string
  date_from?: string
  date_to?: string
  created_by?: number
}

export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  size: number
  pages: number
}

class ExperimentApi {
  /**
   * 获取实验列表
   */
  async getExperiments(params: ExperimentSearchParams = {}): Promise<PaginatedResponse<ExperimentListItem>> {
    return await request.get('/experiments', { params })
  }

  /**
   * 获取实验详情
   */
  async getExperiment(id: number): Promise<ExperimentData> {
    return await request.get(`/experiments/${id}`)
  }

  /**
   * 保存草稿
   */
  async saveDraft(data: ExperimentData): Promise<{ id: number; experiment_code: string }> {
    return await request.post('/experiments/draft', data)
  }

  /**
   * 更新草稿
   */
  /**
   * 更新草稿 - ✅ 修复返回类型
   */
  async updateDraft(id: number, data: ExperimentData): Promise<{ id: number; experiment_code: string }> {
    return await request.put(`/experiments/${id}/draft`, data)
  }

  /**
   * 提交实验
   */
  async submitExperiment(data: ExperimentData): Promise<{ id: number; experiment_code: string }> {
    return await request.post('/experiments', data)
  }

  /**
   * 更新实验数据
   */
  async updateExperiment(id: number, data: ExperimentData): Promise<void> {
    await request.put(`/experiments/${id}`, data)
  }

  /**
   * 删除实验
   */
  async deleteExperiment(id: number): Promise<void> {
    await request.delete(`/experiments/${id}`)
  }

  /**
   * 获取草稿列表
   */
  async getDrafts(params: ExperimentSearchParams = {}): Promise<PaginatedResponse<ExperimentListItem>> {
    return await request.get('/experiments/drafts', { params })
  }

  /**
   * 生成实验编码
   */
  async generateExperimentCode(params: {
    pi_film_thickness: number
    customer_type: string
    customer_name: string
    pi_film_model: string
    experiment_date: string
    sintering_location: string
    material_type_for_firing: string
    rolling_method: string
    experiment_group: number
  }): Promise<{ experiment_code: string }> {
    return await request.post('/experiments/generate-code', params)
  }

  /**
   * 验证实验编码唯一性
   */
  async validateExperimentCode(code: string): Promise<{ isValid: boolean; message?: string }> {
    return await request.get(`/experiments/validate-code/${code}`)
  }

  /**
   * 导出实验数据
   */
  async exportExperiments(params: ExperimentSearchParams = {}): Promise<Blob> {
    return await request.get('/experiments/export', {
      params,
      responseType: 'blob'
    })
  }

  /**
   * 批量删除实验
   */
  async batchDeleteExperiments(ids: number[]): Promise<void> {
    await request.post('/experiments/batch-delete', { ids })
  }

  /**
   * 获取实验统计数据
   */
  async getExperimentStats(): Promise<{
    total: number
    drafts: number
    submitted: number
    approved: number
    thisMonth: number
    thisWeek: number
  }> {
    return await request.get('/experiments/stats')
  }

  /**
   * 复制实验
   */
  async copyExperiment(id: number): Promise<{ id: number; experiment_code: string }> {
    return await request.post(`/experiments/${id}/copy`)
  }

  /**
   * 审批实验
   */
  async approveExperiment(id: number, comment?: string): Promise<void> {
    await request.post(`/experiments/${id}/approve`, { comment })
  }

  /**
   * 拒绝实验
   */
  async rejectExperiment(id: number, reason: string): Promise<void> {
    await request.post(`/experiments/${id}/reject`, { reason })
  }
}

export const experimentApi = new ExperimentApi()
