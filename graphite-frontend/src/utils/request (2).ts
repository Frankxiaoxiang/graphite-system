// src/utils/request.ts
import axios, { AxiosRequestConfig, AxiosResponse, AxiosError } from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import router from '@/router'

// 创建axios实例
const request = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000',
  timeout: 30000, // 30秒超时
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

// 请求拦截器
request.interceptors.request.use(
  (config: AxiosRequestConfig) => {
    const authStore = useAuthStore()
    
    // 添加认证token
    if (authStore.token && config.headers) {
      config.headers.Authorization = `Bearer ${authStore.token}`
    }
    
    // 添加时间戳防止缓存
    if (config.method === 'get') {
      config.params = {
        ...config.params,
        _t: Date.now()
      }
    }
    
    return config
  },
  (error: AxiosError) => {
    console.error('请求配置错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  (response: AxiosResponse) => {
    const { data, status } = response
    
    // 处理文件下载
    if (response.config.responseType === 'blob') {
      return response
    }
    
    // 检查业务状态码
    if (data.success === false) {
      ElMessage.error(data.message || '请求失败')
      return Promise.reject(new Error(data.message || '请求失败'))
    }
    
    return response
  },
  (error: AxiosError) => {
    console.error('请求失败:', error)
    
    if (!error.response) {
      ElMessage.error('网络连接失败，请检查网络')
      return Promise.reject(error)
    }
    
    const { status, data } = error.response
    const authStore = useAuthStore()
    
    switch (status) {
      case 400:
        ElMessage.error(data?.message || '请求参数错误')
        break
        
      case 401:
        ElMessage.error('登录已过期，请重新登录')
        authStore.logout()
        router.push('/login')
        break
        
      case 403:
        ElMessage.error('没有权限访问此资源')
        break
        
      case 404:
        ElMessage.error('请求的资源不存在')
        break
        
      case 422:
        // 表单验证错误
        if (data?.errors) {
          const errorMessages = Object.values(data.errors).flat()
          ElMessage.error(errorMessages.join(', '))
        } else {
          ElMessage.error(data?.message || '数据验证失败')
        }
        break
        
      case 429:
        ElMessage.error('请求过于频繁，请稍后再试')
        break
        
      case 500:
        ElMessage.error('服务器内部错误')
        break
        
      case 502:
      case 503:
      case 504:
        ElMessage.error('服务暂时不可用，请稍后再试')
        break
        
      default:
        ElMessage.error(data?.message || `请求失败 (${status})`)
        break
    }
    
    return Promise.reject(error)
  }
)

// 导出request实例
export default request

// 便捷方法
export const http = {
  get<T = any>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return request.get(url, config).then(res => res.data)
  },
  
  post<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    return request.post(url, data, config).then(res => res.data)
  },
  
  put<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    return request.put(url, data, config).then(res => res.data)
  },
  
  delete<T = any>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return request.delete(url, config).then(res => res.data)
  },
  
  patch<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    return request.patch(url, data, config).then(res => res.data)
  }
}

// 文件上传方法
export const uploadFile = (
  url: string, 
  file: File, 
  onProgress?: (percent: number) => void
) => {
  const formData = new FormData()
  formData.append('file', file)
  
  return request.post(url, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    },
    onUploadProgress: (progressEvent) => {
      if (onProgress && progressEvent.total) {
        const percent = Math.round(
          (progressEvent.loaded * 100) / progressEvent.total
        )
        onProgress(percent)
      }
    }
  })
}

// 文件下载方法
export const downloadFile = async (
  url: string, 
  filename?: string,
  config?: AxiosRequestConfig
) => {
  try {
    const response = await request.get(url, {
      ...config,
      responseType: 'blob'
    })
    
    const blob = new Blob([response.data])
    const link = document.createElement('a')
    link.href = window.URL.createObjectURL(blob)
    
    // 尝试从响应头获取文件名
    const contentDisposition = response.headers['content-disposition']
    if (contentDisposition && !filename) {
      const match = contentDisposition.match(/filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/)
      if (match && match[1]) {
        filename = match[1].replace(/['"]/g, '')
      }
    }
    
    link.download = filename || 'download'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(link.href)
    
    return response
  } catch (error) {
    console.error('文件下载失败:', error)
    throw error
  }
}

// 请求取消token管理
export class CancelTokenManager {
  private tokens: Map<string, AbortController> = new Map()
  
  create(key: string): AbortSignal {
    this.cancel(key) // 取消之前的请求
    const controller = new AbortController()
    this.tokens.set(key, controller)
    return controller.signal
  }
  
  cancel(key: string): void {
    const controller = this.tokens.get(key)
    if (controller) {
      controller.abort()
      this.tokens.delete(key)
    }
  }
  
  cancelAll(): void {
    this.tokens.forEach(controller => controller.abort())
    this.tokens.clear()
  }
}

// 导出取消token管理器实例
export const cancelTokenManager = new CancelTokenManager()

// 重试机制
export const requestWithRetry = async <T>(
  requestFn: () => Promise<T>,
  maxRetries: number = 3,
  delay: number = 1000
): Promise<T> => {
  let lastError: any
  
  for (let i = 0; i <= maxRetries; i++) {
    try {
      return await requestFn()
    } catch (error) {
      lastError = error
      
      // 如果是最后一次重试或者是客户端错误，直接抛出
      if (i === maxRetries || (error as AxiosError)?.response?.status < 500) {
        throw error
      }
      
      // 等待一段时间后重试
      await new Promise(resolve => setTimeout(resolve, delay * Math.pow(2, i)))
    }
  }
  
  throw lastError
}

// 并发请求控制
export class ConcurrencyController {
  private queue: Array<() => Promise<any>> = []
  private running: number = 0
  
  constructor(private maxConcurrency: number = 5) {}
  
  async add<T>(requestFn: () => Promise<T>): Promise<T> {
    return new Promise((resolve, reject) => {
      this.queue.push(async () => {
        try {
          this.running++
          const result = await requestFn()
          resolve(result)
        } catch (error) {
          reject(error)
        } finally {
          this.running--
          this.processQueue()
        }
      })
      
      this.processQueue()
    })
  }
  
  private processQueue(): void {
    if (this.running >= this.maxConcurrency || this.queue.length === 0) {
      return
    }
    
    const request = this.queue.shift()
    if (request) {
      request()
    }
  }
}

// 导出并发控制器实例
export const concurrencyController = new ConcurrencyController(5)