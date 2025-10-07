// graphite-frontend/src/utils/request.ts
// 修复版：请求拦截器直接从 localStorage 读取 Token

import axios, { type AxiosRequestConfig, type AxiosResponse } from 'axios'
import { ElMessage } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import router from '@/router'

// 创建axios实例
const request = axios.create({
  baseURL: 'http://localhost:5000/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// 请求拦截器
request.interceptors.request.use(
  (config) => {
    // 🔧 修复：直接从 localStorage 读取 Token
    // 这样可以确保获取到最新保存的 Token
    const token = localStorage.getItem('token')

    if (token) {
      config.headers.Authorization = `Bearer ${token}`
      console.log('🔑 请求携带Token:', token.substring(0, 20) + '...')
    } else {
      console.warn('⚠️ 请求未携带Token')
    }

    return config
  },
  (error) => {
    console.error('❌ 请求拦截器错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  (response: AxiosResponse) => {
    console.log('✅ 响应成功:', response.config.url, response.status)
    return response.data
  },
  (error) => {
    console.error('❌ 响应错误:', error.config?.url, error.response?.status)

    const authStore = useAuthStore()

    if (error.response) {
      const { status, data } = error.response

      switch (status) {
        case 401:
          console.error('❌ 401 错误 - Token无效或已过期')
          console.error('当前Token:', localStorage.getItem('token')?.substring(0, 30) + '...')
          ElMessage.error('登录已过期，请重新登录')
          authStore.logout()
          router.push('/login')
          break
        case 403:
          ElMessage.error('权限不足')
          break
        case 404:
          ElMessage.error('请求的资源不存在')
          break
        case 500:
          ElMessage.error('服务器内部错误')
          break
        default:
          ElMessage.error(data?.error || '请求失败')
      }
    } else if (error.request) {
      ElMessage.error('网络连接失败，请检查网络')
    } else {
      ElMessage.error('请求配置错误')
    }

    return Promise.reject(error)
  }
)

export default request
