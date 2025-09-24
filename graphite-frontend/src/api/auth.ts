import request from '@/utils/request'
import type { LoginRequest, LoginResponse, User } from '@/types'

export const login = (data: LoginRequest): Promise<LoginResponse> => {
  return request.post('/auth/login', data)
}

export const logout = (): Promise<void> => {
  return request.post('/auth/logout')
}

export const getProfile = (): Promise<{ user: User }> => {
  return request.get('/auth/profile')
}

export const refreshToken = (): Promise<{ access_token: string }> => {
  return request.post('/auth/refresh')
}