// src/api/dropdown.ts
import request from '@/utils/request'

export interface DropdownOption {
  id?: number
  value: string | number
  label: string
  description?: string
  isActive?: boolean
  sortOrder?: number
  createdAt?: string
  updatedAt?: string
}

export interface DropdownFieldConfig {
  fieldName: string
  fieldLabel: string
  fieldType: 'fixed' | 'expandable' | 'searchable'
  canUserAdd: boolean
  canEngineerAdd: boolean
  canAdminAdd: boolean
  needsApproval: boolean
  maxOptions?: number
}

export interface AddOptionRequest {
  fieldName: string
  value: string | number
  label: string
  description?: string
  code?: string
  fullName?: string
  needsApproval?: boolean
}

export interface PendingApproval {
  id: number
  fieldName: string
  fieldLabel: string
  proposedValue: string
  proposedLabel: string
  description?: string
  requestedBy: string
  requestedAt: string
  status: 'pending' | 'approved' | 'rejected'
}

class DropdownApi {
  /**
   * 获取字段的所有选项
   */
  async getOptions(fieldName: string): Promise<DropdownOption[]> {
    try {
      const response = await request.get(`/dropdown/options/${fieldName}`)
      console.log(`getOptions(${fieldName}) response:`, response) // 调试日志
      return response || []  // 直接返回 response
    } catch (error) {
      console.error('获取下拉选项失败:', error)
      return this.getMockOptions(fieldName)
    }
  }

  /**
   * 搜索字段选项
   */
  async searchOptions(fieldName: string, keyword: string, limit: number = 20): Promise<DropdownOption[]> {
    try {
      const response = await request.get(`/dropdown/search/${fieldName}`, {
        params: { keyword, limit }
      })
      return response || []
    } catch (error) {
      console.error('搜索选项失败:', error)
      // 返回过滤后的模拟数据
      const mockOptions = this.getMockOptions(fieldName)
      return mockOptions.filter(option =>
        option.label.toLowerCase().includes(keyword.toLowerCase()) ||
        option.value.toString().toLowerCase().includes(keyword.toLowerCase())
      ).slice(0, limit)
    }
  }

  /**
   * 添加新选项
   */
  async addOption(fieldName: string, data: Partial<AddOptionRequest>): Promise<DropdownOption> {
    try {
      const requestData = { fieldName, ...data }
      const response = await request.post('/dropdown/options', requestData)
      return response.data
    } catch (error) {
      console.error('添加选项失败:', error)
      // 模拟成功添加
      return {
        id: Date.now(),
        value: data.value!,
        label: data.label!,
        description: data.description
      }
    }
  }

  /**
   * 更新选项
   */
  async updateOption(id: number, data: Partial<DropdownOption>): Promise<void> {
    await request.put(`/dropdown/options/${id}`, data)
  }

  /**
   * 删除选项
   */
  async deleteOption(id: number): Promise<void> {
    await request.delete(`/dropdown/options/${id}`)
  }

  /**
   * 获取字段配置
   */
  async getFieldConfig(fieldName: string): Promise<DropdownFieldConfig> {
    const response = await request.get(`/dropdown/config/${fieldName}`)
    return response.data
  }

  /**
   * 获取所有字段配置
   */
  async getAllFieldConfigs(): Promise<DropdownFieldConfig[]> {
    const response = await request.get('/dropdown/configs')
    return response.data
  }

  /**
   * 更新字段配置（仅管理员）
   */
  async updateFieldConfig(fieldName: string, config: Partial<DropdownFieldConfig>): Promise<void> {
    await request.put(`/dropdown/config/${fieldName}`, config)
  }

  /**
   * 获取待审批选项列表（仅管理员）
   */
  async getPendingApprovals(): Promise<PendingApproval[]> {
    const response = await request.get('/dropdown/approvals/pending')
    return response.data
  }

  /**
   * 审批选项（仅管理员）
   */
  async approveOption(id: number, comment?: string): Promise<void> {
    await request.post(`/dropdown/approvals/${id}/approve`, { comment })
  }

  /**
   * 拒绝选项（仅管理员）
   */
  async rejectOption(id: number, reason: string): Promise<void> {
    await request.post(`/dropdown/approvals/${id}/reject`, { reason })
  }

  /**
   * 获取模拟数据
   */
  private getMockOptions(fieldName: string): DropdownOption[] {
    const mockData: Record<string, DropdownOption[]> = {
      pi_film_thickness: [
        { value: 25, label: '25μm' },
        { value: 38, label: '38μm' },
        { value: 50, label: '50μm' },
        { value: 55, label: '55μm' },
        { value: 62, label: '62μm' },
        { value: 75, label: '75μm' },
        { value: 100, label: '100μm' },
        { value: 125, label: '125μm' },
        { value: 150, label: '150μm' }
      ],
      customer_name: [
        { value: 'RD/研发', label: 'RD/研发' },
        { value: 'MP/量产', label: 'MP/量产' },
        { value: 'SA/三星', label: 'SA/三星' },
        { value: 'HW/华为', label: 'HW/华为' },
        { value: 'BY/比亚迪', label: 'BY/比亚迪' },
        { value: 'GO/Google', label: 'GO/Google' },
        { value: 'AP/Apple', label: 'AP/Apple' },
        { value: 'XM/小米', label: 'XM/小米' },
        { value: 'OP/OPPO', label: 'OP/OPPO' },
        { value: 'VI/VIVO', label: 'VI/VIVO' }
      ],
      pi_film_model: [
        { value: 'GH-38', label: 'GH-38' },
        { value: 'GP-43', label: 'GP-43' },
        { value: 'THK-43', label: 'THK-43' },
        { value: 'NA-38', label: 'NA-38' },
        { value: 'GH-50', label: 'GH-50' },
        { value: 'THK-55', label: 'THK-55' },
        { value: 'THS-55', label: 'THS-55' },
        { value: 'GP-55', label: 'GP-55' },
        { value: 'GH-75', label: 'GH-75' },
        { value: 'GH-100', label: 'GH-100' },
        { value: 'GH-125', label: 'GH-125' },
        { value: 'GH-150', label: 'GH-150' }
      ],
      sintering_location: [
        { value: 'DG', label: 'DG/东莞' },
        { value: 'XT', label: 'XT/湘潭' },
        { value: 'DX', label: 'DX/东莞+湘潭' },
        { value: 'WF', label: 'WF/外发' }
      ],
      pi_manufacturer: [
        { value: '时代', label: '时代' },
        { value: '达迈', label: '达迈' },
        { value: '欣邦', label: '欣邦' },
        { value: '东丽', label: '东丽' },
        { value: 'SKC', label: 'SKC' }
      ]
    }

    return mockData[fieldName] || []
  }
}

export const dropdownApi = new DropdownApi()

// 预定义的字段配置
export const FIELD_CONFIGS: Record<string, Partial<DropdownFieldConfig>> = {
  pi_film_thickness: {
    fieldLabel: 'PI膜厚度',
    fieldType: 'searchable',
    canUserAdd: true,
    canEngineerAdd: true,
    canAdminAdd: true,
    needsApproval: false
  },
  customer_type: {
    fieldLabel: '客户类型',
    fieldType: 'fixed',
    canUserAdd: false,
    canEngineerAdd: false,
    canAdminAdd: true,
    needsApproval: false
  },
  customer_name: {
    fieldLabel: '客户名称',
    fieldType: 'expandable',
    canUserAdd: true,
    canEngineerAdd: true,
    canAdminAdd: true,
    needsApproval: false
  },
  pi_film_model: {
    fieldLabel: 'PI膜型号',
    fieldType: 'expandable',
    canUserAdd: false,
    canEngineerAdd: true,
    canAdminAdd: true,
    needsApproval: false
  },
  sintering_location: {
    fieldLabel: '烧制地点',
    fieldType: 'expandable',
    canUserAdd: false,
    canEngineerAdd: false,
    canAdminAdd: true,
    needsApproval: true
  },
  material_type_for_firing: {
    fieldLabel: '送烧材料类型',
    fieldType: 'fixed',
    canUserAdd: false,
    canEngineerAdd: false,
    canAdminAdd: true,
    needsApproval: false
  },
  rolling_method: {
    fieldLabel: '压延方式',
    fieldType: 'fixed',
    canUserAdd: false,
    canEngineerAdd: false,
    canAdminAdd: true,
    needsApproval: false
  },
  pi_manufacturer: {
    fieldLabel: 'PI膜厂商',
    fieldType: 'expandable',
    canUserAdd: false,
    canEngineerAdd: true,
    canAdminAdd: true,
    needsApproval: false
  }
}
