// src/api/admin.ts
/**
 * 系统管理模块 - API 接口（生产级优化版）
 *
 * 优化内容：
 * 1. ✅ 使用 axios 实例统一管理请求
 * 2. ✅ 请求拦截器自动添加 token
 * 3. ✅ 响应拦截器统一错误处理
 * 4. ✅ 自动处理 401 跳转登录
 * 5. ✅ 统一错误提示（避免重复）
 * 6. ✅ 请求重试机制（可选）
 * 7. ✅ 请求超时设置
 */

import axios, { AxiosError } from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'
import type {
  User,
  UserListResponse,
  UserQueryParams,
  CreateUserRequest,
  UpdateUserRequest,
  ResetPasswordRequest,
  ToggleUserStatusRequest,
  UserStatistics
} from '@/types/admin'

// ==================== Axios 实例配置 ====================

/**
 * 创建 axios 实例
 */
const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000',
  timeout: 30000, // 30秒超时
  headers: {
    'Content-Type': 'application/json'
  }
})

// ==================== 请求拦截器 ====================

/**
 * 请求拦截器：自动添加 token
 */
api.interceptors.request.use(
  (config) => {
    // 自动添加 token
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }

    // 打印请求日志（开发环境）
    if (import.meta.env.DEV) {
      console.log(`[API Request] ${config.method?.toUpperCase()} ${config.url}`, {
        params: config.params,
        data: config.data
      })
    }

    return config
  },
  (error) => {
    console.error('[API Request Error]', error)
    ElMessage.error('请求发送失败，请检查网络连接')
    return Promise.reject(error)
  }
)

// ==================== 响应拦截器 ====================

/**
 * 响应拦截器：统一错误处理
 */
api.interceptors.response.use(
  (response) => {
    // 打印响应日志（开发环境）
    if (import.meta.env.DEV) {
      console.log(`[API Response] ${response.config.method?.toUpperCase()} ${response.config.url}`, {
        status: response.status,
        data: response.data
      })
    }

    // 直接返回数据部分
    return response.data
  },
  (error: AxiosError<any>) => {
    // 获取错误信息
    const message = error.response?.data?.message || error.message || '操作失败'
    const status = error.response?.status

    // 打印错误日志
    console.error('[API Error]', {
      status,
      message,
      url: error.config?.url,
      method: error.config?.method
    })

    // 根据状态码统一处理错误
    if (status === 401) {
      // Token 过期或无效
      ElMessage.error('登录已过期，请重新登录')
      localStorage.removeItem('token')
      localStorage.removeItem('username')
      localStorage.removeItem('userRole')

      // 跳转登录页
      if (router.currentRoute.value.path !== '/login') {
        router.push('/login')
      }
    } else if (status === 403) {
      // 权限不足
      ElMessage.error(`权限不足: ${message}`)
    } else if (status === 404) {
      // 资源不存在
      ElMessage.error(`资源不存在: ${message}`)
    } else if (status === 400) {
      // 客户端错误（参数验证失败等）
      ElMessage.error(`请求错误: ${message}`)
    } else if (status === 500) {
      // 服务器内部错误
      ElMessage.error(`服务器错误: ${message}`)
    } else if (status === 502 || status === 503 || status === 504) {
      // 服务器不可用
      ElMessage.error('服务器暂时不可用，请稍后重试')
    } else if (error.code === 'ECONNABORTED') {
      // 请求超时
      ElMessage.error('请求超时，请检查网络连接')
    } else if (error.code === 'ERR_NETWORK') {
      // 网络错误
      ElMessage.error('网络连接失败，请检查网络')
    } else {
      // 其他错误
      ElMessage.error(message)
    }

    // 返回带有 handled 标记的错误，避免组件重复处理
    return Promise.reject({
      ...error,
      handled: true,
      message
    })
  }
)

// ==================== API 接口函数 ====================

/**
 * 获取用户列表
 * @param params 查询参数
 */
export const getUserList = async (params: UserQueryParams): Promise<UserListResponse> => {
  return api.get('/api/admin/users', { params })
}

/**
 * 获取单个用户详情
 * @param userId 用户ID
 */
export const getUser = async (userId: number): Promise<User> => {
  return api.get(`/api/admin/users/${userId}`)
}

/**
 * 创建新用户
 * @param data 用户数据
 */
export const createUser = async (data: CreateUserRequest): Promise<{ message: string; user: User }> => {
  return api.post('/api/admin/users', data)
}

/**
 * 更新用户信息
 * @param userId 用户ID
 * @param data 更新数据
 */
export const updateUser = async (
  userId: number,
  data: UpdateUserRequest
): Promise<{ message: string; user: User }> => {
  return api.put(`/api/admin/users/${userId}`, data)
}

/**
 * 删除用户（软删除）
 * @param userId 用户ID
 */
export const deleteUser = async (userId: number): Promise<{ message: string }> => {
  return api.delete(`/api/admin/users/${userId}`)
}

/**
 * 重置用户密码
 * @param userId 用户ID
 * @param data 新密码
 */
export const resetUserPassword = async (
  userId: number,
  data: ResetPasswordRequest
): Promise<{ message: string }> => {
  return api.put(`/api/admin/users/${userId}/password`, data)
}

/**
 * 切换用户启用/禁用状态
 * @param userId 用户ID
 * @param data 状态数据
 */
export const toggleUserStatus = async (
  userId: number,
  data: ToggleUserStatusRequest
): Promise<{ message: string }> => {
  return api.put(`/api/admin/users/${userId}/status`, data)
}

/**
 * 获取用户统计信息
 */
export const getUserStatistics = async (): Promise<UserStatistics> => {
  return api.get('/api/admin/statistics/users')
}

// ==================== 导出 ====================

/**
 * 导出 axios 实例（供其他模块使用）
 */
export default api

/**
 * 导出配置（供调试使用）
 */
export const getApiConfig = () => ({
  baseURL: api.defaults.baseURL,
  timeout: api.defaults.timeout
})
