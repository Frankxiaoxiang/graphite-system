// graphite-frontend/src/stores/auth.ts
// 修复版：增强 Token 保存和日志

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
      console.log('🔐 Auth Store: 开始登录流程')

      const response = await loginApi(credentials)
      console.log('✅ Auth Store: API返回成功', {
        user: response.user.username,
        tokenLength: response.access_token.length
      })

      // 更新状态
      token.value = response.access_token
      user.value = response.user

      // 保存到 localStorage
      console.log('💾 Auth Store: 保存Token到localStorage')
      localStorage.setItem('token', response.access_token)
      localStorage.setItem('user', JSON.stringify(response.user))

      // 验证保存
      const savedToken = localStorage.getItem('token')
      const savedUser = localStorage.getItem('user')
      console.log('✅ Auth Store: Token保存验证', {
        tokenSaved: !!savedToken,
        tokenMatches: savedToken === response.access_token,
        userSaved: !!savedUser,
        tokenPreview: savedToken?.substring(0, 30) + '...'
      })

      if (savedToken !== response.access_token) {
        console.error('❌ Auth Store: Token保存失败！')
        throw new Error('Token保存失败')
      }

      return response
    } catch (error) {
      console.error('❌ Auth Store: 登录失败', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  const logout = () => {
    console.log('👋 Auth Store: 退出登录')
    token.value = null
    user.value = null
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    console.log('✅ Auth Store: 清除完成')
  }

  const initAuth = () => {
    console.log('🔄 Auth Store: 初始化认证状态')
    const savedToken = localStorage.getItem('token')
    const savedUser = localStorage.getItem('user')

    if (savedToken && savedUser) {
      token.value = savedToken
      console.log('📝 Auth Store: 恢复Token', savedToken.substring(0, 30) + '...')

      try {
        const parsedUser = JSON.parse(savedUser)

        // 处理不同格式的用户数据
        if (parsedUser.roles && Array.isArray(parsedUser.roles)) {
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
          user.value = parsedUser
        }

        console.log('✅ Auth Store: 用户恢复成功', user.value.username)
      } catch (error) {
        console.error('❌ Auth Store: 解析用户数据失败', error)
        logout()
      }
    } else {
      console.log('ℹ️ Auth Store: 无保存的认证信息')
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
