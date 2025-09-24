import request from '@/utils/request'
import type { DropdownOption } from '@/types'

export const getDropdownOptions = (fieldName: string, search?: string): Promise<{ options: DropdownOption[] }> => {
  return request.get('/dropdown/options', {
    params: { field_name: fieldName, search }
  })
}

export const addDropdownOption = (data: {
  field_name: string
  option_value: string
  option_label: string
}): Promise<any> => {
  return request.post('/dropdown/add', data)
}

export const getDropdownFields = (): Promise<any> => {
  return request.get('/dropdown/fields')
}