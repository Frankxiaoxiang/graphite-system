// graphite-frontend/src/api/auth.ts
// 最终修正版：使用真实的后端登录 API

import request from '@/utils/request'
import type { LoginRequest, LoginResponse, User } from '@/types'

// ==========================================
// 真实后端 API（主要使用）
// ==========================================

/**
 * 用户登录 - 使用真实后端 API
 * @param credentials 登录凭据
 * @returns 登录响应（包含 token 和用户信息）
 */
export async function login(credentials: LoginRequest): Promise<LoginResponse> {
  console.log('🔐 调用真实登录API:', { username: credentials.username })

  try {
    // 调用真实的后端登录API
    // 注意：request 拦截器已经处理了 response.data，所以直接返回数据对象
    const response = await request.post('/auth/login', credentials) as LoginResponse

    console.log('✅ 登录成功:', {
      user: response.user.username,
      role: response.user.role,
      token: response.access_token.substring(0, 20) + '...'
    })

    return response
  } catch (error: any) {
    console.error('❌ 登录失败:', error.message || error)
    throw error
  }
}

/**
 * 刷新 Token
 * @param refresh_token 刷新令牌
 * @returns 新的访问令牌
 */
export async function refreshToken(refresh_token: string): Promise<{ access_token: string }> {
  console.log('🔄 刷新Token')

  try {
    const response = await request.post('/auth/refresh', { refresh_token }) as { access_token: string }
    console.log('✅ Token刷新成功')
    return response
  } catch (error) {
    console.error('❌ Token刷新失败:', error)
    throw error
  }
}

/**
 * 退出登录
 */
export async function logout(): Promise<void> {
  console.log('👋 退出登录')

  try {
    await request.post('/auth/logout')
    console.log('✅ 退出成功')
  } catch (error) {
    console.error('❌ 退出失败:', error)
    // 即使后端退出失败，前端也应该清除本地状态
  }
}

/**
 * 获取当前用户信息
 * @returns 当前用户信息
 */
export async function getCurrentUser(): Promise<User> {
  console.log('👤 获取当前用户信息')

  try {
    const response = await request.get('/auth/profile') as User
    console.log('✅ 获取用户信息成功:', response.username)
    return response
  } catch (error) {
    console.error('❌ 获取用户信息失败:', error)
    throw error
  }
}

/**
 * 验证 Token 是否有效
 * @param token 访问令牌
 * @returns 是否有效
 */
export async function verifyToken(token: string): Promise<boolean> {
  try {
    await request.get('/auth/verify', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
    return true
  } catch (error) {
    return false
  }
}


// ==========================================
// 模拟 API（仅用于前端开发测试）
// ⚠️ 警告：模拟Token无法通过后端验证！
// ==========================================

const MOCK_MODE = false // 设置为 true 使用模拟API，false 使用真实API

/**
 * 模拟登录 - 仅用于前端开发测试
 * ⚠️ 注意：这个 Token 无法通过后端验证！
 */
export async function mockLogin(credentials: LoginRequest): Promise<LoginResponse> {
  console.log('🔐 模拟登录API调用:', credentials.username)

  // 模拟延迟
  await new Promise(resolve => setTimeout(resolve, 500))

  // 模拟验证
  const validUsers: Record<string, string> = {
    'admin': 'admin123',
    'engineer': 'engineer123',
    'user': 'user123'
  }

  if (validUsers[credentials.username] !== credentials.password) {
    console.log('❌ 模拟登录失败：用户名或密码错误')
    throw new Error('用户名或密码错误')
  }

  // 生成模拟Token
  const mockToken = `mock_token_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`

  const response: LoginResponse = {
    access_token: mockToken,
    refresh_token: `mock_refresh_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    user: {
      id: credentials.username === 'admin' ? 1 : 2,
      username: credentials.username,
      role: credentials.username === 'admin' ? 'admin' : (credentials.username === 'engineer' ? 'engineer' : 'user'),
      real_name: credentials.username === 'admin' ? '系统管理员' : '普通用户',
      email: `${credentials.username}@example.com`,
      created_at: new Date().toISOString(),
      last_login: new Date().toISOString()
    }
  }

  console.log('✅ 模拟登录成功:', response.user.username)
  console.warn('⚠️ 警告：使用模拟Token，后端API调用会失败（401错误）')

  return response
}

/**
 * 模拟退出登录
 */
export async function mockLogout(): Promise<void> {
  await new Promise(resolve => setTimeout(resolve, 300))
  console.log('✅ 模拟退出成功')
}

/**
 * 模拟获取用户信息
 */
export async function mockGetCurrentUser(): Promise<User> {
  await new Promise(resolve => setTimeout(resolve, 300))
  console.warn('⚠️ 模拟API：无法获取真实用户信息')
  throw new Error('请使用真实登录')
}


// ==========================================
// 测试账号说明（仅用于开发参考）
// ==========================================

export const TEST_ACCOUNTS = {
  admin: {
    username: 'admin',
    password: 'admin123',
    role: 'admin',
    description: '系统管理员账号'
  },
  engineer: {
    username: 'engineer',
    password: 'engineer123',
    role: 'engineer',
    description: '工程师账号'
  },
  user: {
    username: 'user',
    password: 'user123',
    role: 'user',
    description: '普通用户账号'
  }
}

// 开发环境下打印测试账号
if (import.meta.env.DEV) {
  console.log('📋 开发环境 - 可用的测试账号:')
  console.table(TEST_ACCOUNTS)
  console.log(`🔧 当前模式: ${MOCK_MODE ? '模拟API模式 ⚠️' : '真实API模式 ✅'}`)

  if (!MOCK_MODE) {
    console.log('💡 提示：如果后端未启动，登录会失败。请确保后端服务正在运行（http://localhost:5000）')
  }
}


// ==========================================
// 默认导出（根据模式选择）
// ==========================================

// 如果需要在模拟和真实API之间切换，可以使用这个导出
export default {
  login: MOCK_MODE ? mockLogin : login,
  logout: MOCK_MODE ? mockLogout : logout,
  getCurrentUser: MOCK_MODE ? mockGetCurrentUser : getCurrentUser,
  refreshToken,
  verifyToken,
  TEST_ACCOUNTS
}
