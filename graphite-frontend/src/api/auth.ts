import type { LoginRequest, LoginResponse, User } from '@/types'

// 模拟延迟函数
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms))

// 修复后的模拟登录API
export const login = async (credentials: LoginRequest): Promise<LoginResponse> => {
  console.log('🔐 模拟登录API调用:', credentials)
  
  // 模拟网络请求延迟
  await delay(800)
  
  // 基本验证
  if (!credentials.username || !credentials.password) {
    console.log('❌ 用户名或密码为空')
    throw new Error('用户名和密码不能为空')
  }
  
  // 模拟登录失败的情况（仅用于测试）
  if (credentials.password === 'wrong') {
    console.log('❌ 密码错误（测试用例）')
    throw new Error('用户名或密码错误')
  }
  
  // 模拟不同用户角色
  let userRole: 'admin' | 'engineer' | 'user' = 'user'
  
  if (credentials.username.toLowerCase().includes('admin')) {
    userRole = 'admin'
  } else if (credentials.username.toLowerCase().includes('engineer')) {
    userRole = 'engineer'
  }
  
  // 模拟登录成功响应
  const response: LoginResponse = {
    access_token: `token_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    refresh_token: `refresh_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
    user: {
      id: Math.floor(Math.random() * 1000) + 1,
      username: credentials.username,
      role: userRole,
      real_name: `测试用户_${credentials.username}`,
      email: `${credentials.username}@example.com`,
      created_at: new Date().toISOString(),
      last_login: new Date().toISOString()
    }
  }
  
  console.log('✅ 模拟登录成功:', response)
  return response
}

// 模拟登出API
export const logout = async (): Promise<void> => {
  await delay(500)
  console.log('✅ 模拟登出成功')
}

// 模拟获取当前用户信息API
export const getCurrentUser = async (): Promise<User> => {
  await delay(500)
  throw new Error('请重新登录') // 模拟token过期，需要重新登录
}

// 模拟刷新token API
export const refreshToken = async (): Promise<{ access_token: string; refresh_token: string }> => {
  await delay(500)
  return {
    access_token: `refreshed_token_${Date.now()}`,
    refresh_token: `refreshed_refresh_${Date.now()}`
  }
}

// 模拟验证token API
export const verifyToken = async (token: string): Promise<boolean> => {
  await delay(300)
  // 简单模拟：如果token包含'invalid'就返回false
  return !token.includes('invalid')
}

// 导出一些测试用的用户账号说明
export const TEST_ACCOUNTS = {
  admin: {
    username: 'admin',
    password: '任意密码（除了"wrong"）',
    role: 'admin',
    description: '系统管理员账号'
  },
  engineer: {
    username: 'engineer',
    password: '任意密码（除了"wrong"）', 
    role: 'engineer',
    description: '工程师账号'
  },
  user: {
    username: 'testuser',
    password: '任意密码（除了"wrong"）',
    role: 'user', 
    description: '普通用户账号'
  }
}

console.log('📋 可用的测试账号:', TEST_ACCOUNTS)