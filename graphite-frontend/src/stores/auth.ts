import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User, LoginRequest } from '@/types'
import { login as loginApi } from '@/api/auth'

export const useAuthStore = defineStore('auth', () => {
  // 状态
  const token = ref<string | null>(localStorage.getItem('token'))
  const user = ref<User | null>(null)
  const loading = ref(false)

  // 计算属性
  const isAuthenticated = computed(() => !!token.value && !!user.value)
  const isAdmin = computed(() => user.value?.role === 'admin')
  const isEngineer = computed(() => ['admin', 'engineer'].includes(user.value?.role || ''))

  // 方法
  const login = async (credentials: LoginRequest) => {
    try {
      loading.value = true
      const response = await loginApi(credentials)
      
      token.value = response.access_token
      user.value = response.user
      
      localStorage.setItem('token', response.access_token)
      localStorage.setItem('user', JSON.stringify(response.user))
      
      return response
    } finally {
      loading.value = false
    }
  }

  const logout = () => {
    token.value = null
    user.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  const initAuth = () => {
    const savedToken = localStorage.getItem('token')
    const savedUser = localStorage.getItem('user')
    
    if (savedToken && savedUser) {
      token.value = savedToken
      try {
        const parsedUser = JSON.parse(savedUser)
        
        // 处理不同格式的用户数据 - 保留这个逻辑，它很有用
        if (parsedUser.roles && Array.isArray(parsedUser.roles)) {
          // 如果有roles数组，转换为单个role字符串
          const roleMapping: { [key: string]: 'admin' | 'engineer' | 'user' } = {
            'Admin': 'admin',
            'Engineer': 'engineer', 
            'User': 'user',
            'admin': 'admin',
            'engineer': 'engineer',
            'user': 'user'
          }
          
          const firstRole = parsedUser.roles[0]
          const mappedRole = roleMapping[firstRole] || 'user'
          
          user.value = {
            id: parsedUser.id,
            username: parsedUser.username,
            role: mappedRole,
            real_name: parsedUser.real_name,
            email: parsedUser.email,
            created_at: parsedUser.created_at,
            last_login: parsedUser.last_login
          }
        } else {
          // 如果已经是正确格式
          user.value = parsedUser
        }
        
      } catch (error) {
        console.error('解析用户数据失败:', error)
        logout()
      }
    }
  }

  // 检查权限
  const hasPermission = (permission: string): boolean => {
    if (!user.value) return false
    
    const permissions = {
      admin: ['view_all', 'edit_all', 'delete_all', 'manage_users', 'system_admin'],
      engineer: ['view_all', 'edit_all', 'approve_dropdown'],
      user: ['view_own', 'edit_own', 'create_experiment']
    }
    
    return permissions[user.value.role]?.includes(permission) || false
  }

  return {
    token,
    user,
    loading,
    isAuthenticated,
    isAdmin,
    isEngineer,
    login,
    logout,
    initAuth,
    hasPermission
  }
})