// src/types/admin.ts
/**
 * 系统管理模块 - 类型定义
 */

/**
 * 用户角色类型
 */
export type UserRole = 'admin' | 'engineer' | 'user'

/**
 * 用户接口
 */
export interface User {
  id: number
  username: string
  real_name?: string | null
  email?: string | null
  role: UserRole
  is_active: boolean
  created_at?: string | null
  updated_at?: string | null
  last_login?: string | null
}

/**
 * 用户列表响应接口
 */
export interface UserListResponse {
  users: User[]
  total: number
  page: number
  page_size: number
  total_pages: number
}

/**
 * 用户查询参数接口
 */
export interface UserQueryParams {
  page?: number
  page_size?: number
  search?: string
  role?: UserRole | ''
  is_active?: boolean | ''
}

/**
 * 创建用户请求接口
 */
export interface CreateUserRequest {
  username: string
  password: string
  real_name?: string
  email?: string
  role?: UserRole
  is_active?: boolean
}

/**
 * 更新用户请求接口
 */
export interface UpdateUserRequest {
  real_name?: string
  email?: string
  role?: UserRole
  is_active?: boolean
}

/**
 * 重置密码请求接口
 */
export interface ResetPasswordRequest {
  new_password: string
}

/**
 * 切换用户状态请求接口
 */
export interface ToggleUserStatusRequest {
  is_active: boolean
}

/**
 * 用户统计信息接口
 */
export interface UserStatistics {
  total_users: number
  active_users: number
  inactive_users: number
  by_role: {
    admin: number
    engineer: number
    user: number
  }
}

/**
 * 角色配置接口
 */
export interface RoleConfig {
  value: UserRole
  label: string
  description: string
  color: string
}

/**
 * 角色标签映射
 */
export const ROLE_LABELS: Record<UserRole, string> = {
  admin: '管理员',
  engineer: '工程师',
  user: '普通用户'
}

/**
 * 角色描述映射
 */
export const ROLE_DESCRIPTIONS: Record<UserRole, string> = {
  admin: '拥有所有权限，可管理用户和系统设置',
  engineer: '可创建和管理实验数据',
  user: '只能查看实验数据'
}

/**
 * 角色颜色映射（用于 Element Plus Tag）
 */
export const ROLE_COLORS: Record<UserRole, string> = {
  admin: 'danger',
  engineer: 'warning',
  user: 'info'
}

/**
 * 角色配置列表
 */
export const ROLE_CONFIGS: RoleConfig[] = [
  {
    value: 'admin',
    label: '管理员',
    description: '拥有所有权限',
    color: 'danger'
  },
  {
    value: 'engineer',
    label: '工程师',
    description: '可创建和管理实验',
    color: 'warning'
  },
  {
    value: 'user',
    label: '普通用户',
    description: '只能查看数据',
    color: 'info'
  }
]

/**
 * 状态标签映射
 */
export const STATUS_LABELS: Record<string, string> = {
  true: '启用',
  false: '禁用'
}

/**
 * 状态颜色映射
 */
export const STATUS_COLORS: Record<string, string> = {
  true: 'success',
  false: 'info'
}
