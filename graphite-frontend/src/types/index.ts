export interface User {
  id: number
  username: string
  role: 'admin' | 'engineer' | 'user'
  real_name?: string
  email?: string
  created_at?: string
  last_login?: string
}

export interface LoginRequest {
  username: string
  password: string
}

export interface LoginResponse {
  access_token: string
  refresh_token: string
  user: User
}

export interface ApiResponse<T = any> {
  message?: string
  error?: string
  data?: T
}

export interface Experiment {
  id: number
  experiment_code: string
  status: 'draft' | 'submitted' | 'completed'
  created_by: number
  created_by_name: string
  created_at: string
  updated_at: string
  submitted_at?: string
  customer_name?: string
  experiment_date?: string
}

export interface ExperimentBasic {
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
}

export interface DropdownOption {
  value: string
  label: string
  sort_order?: number
}

export interface PaginationData {
  page: number
  pages: number
  per_page: number
  total: number
}