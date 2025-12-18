// src/api/backup.ts
// 数据库备份管理 API

import request from '@/utils/request'

// ========== 类型定义 ==========

/**
 * 备份任务状态
 */
export type BackupTaskStatus = 'pending' | 'running' | 'success' | 'failed'

/**
 * 创建备份响应
 */
export interface CreateBackupResponse {
  success: boolean
  task_id: string
  filename: string
  message: string
}

/**
 * 任务状态响应
 */
export interface TaskStatusResponse {
  task_id: string
  status: BackupTaskStatus
  filename: string
  file_size: number | null
  error_message: string | null
  created_at: string
  started_at: string | null
  completed_at: string | null
}

/**
 * 备份文件信息
 */
export interface BackupFile {
  filename: string
  file_size: number
  created_at: string
  status: BackupTaskStatus
  file_path: string
}

/**
 * 备份列表响应
 */
export interface BackupListResponse {
  backups: BackupFile[]
  total: number
}

/**
 * 备份统计信息
 */
export interface BackupStatistics {
  total_backups: number      // 备份文件数量
  total_size: number          // 总占用空间（字节）
  last_backup_time: string | null  // 最后备份时间
  database_size: number       // 数据库大小（字节）
  running_tasks: number       // 正在运行的任务数
}

// ========== API 函数 ==========

/**
 * 创建数据库备份（异步）
 *
 * @returns 任务ID和文件名
 */
export function createBackup() {
  return request<CreateBackupResponse>({
    url: '/admin/backup',
    method: 'post'
  })
}

/**
 * 查询备份任务状态
 *
 * @param taskId 任务ID
 * @returns 任务状态详情
 */
export function getTaskStatus(taskId: string) {
  return request<TaskStatusResponse>({
    url: `/admin/backup/task/${taskId}`,
    method: 'get'
  })
}

/**
 * 获取备份列表
 *
 * @returns 备份文件列表
 */
export function getBackupList() {
  return request<BackupListResponse>({
    url: '/admin/backup',
    method: 'get'
  })
}

/**
 * 下载备份文件
 *
 * @param filename 文件名
 * @returns Blob下载流
 */
export function downloadBackup(filename: string) {
  return request({
    url: `/admin/backup/${filename}`,
    method: 'get',
    responseType: 'blob'
  })
}

/**
 * 删除备份文件
 *
 * @param filename 文件名
 * @returns 删除结果
 */
export function deleteBackup(filename: string) {
  return request<{ success: boolean; message: string }>({
    url: `/admin/backup/${filename}`,
    method: 'delete'
  })
}

/**
 * 获取备份统计信息
 *
 * @returns 统计数据
 */
export function getBackupStatistics() {
  return request<BackupStatistics>({
    url: '/admin/backup/statistics',
    method: 'get'
  })
}

// ========== 工具函数 ==========

/**
 * 轮询任务状态直到完成
 *
 * @param taskId 任务ID
 * @param onUpdate 状态更新回调
 * @param interval 轮询间隔（毫秒），默认3000
 * @returns Promise，在任务完成或失败时resolve
 */
export function pollTaskStatus(
  taskId: string,
  onUpdate: (status: TaskStatusResponse) => void,
  interval: number = 3000
): Promise<TaskStatusResponse> {
  return new Promise((resolve, reject) => {
    const poll = async () => {
      try {
        const status = await getTaskStatus(taskId)

        // 调用更新回调
        onUpdate(status)

        // 检查任务是否完成
        if (status.status === 'success' || status.status === 'failed') {
          resolve(status)
        } else {
          // 继续轮询
          setTimeout(poll, interval)
        }
      } catch (error) {
        reject(error)
      }
    }

    // 开始轮询
    poll()
  })
}

/**
 * 格式化文件大小
 *
 * @param bytes 字节数
 * @returns 格式化的大小字符串（如 "1.23 MB"）
 */
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 B'

  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))

  return `${(bytes / Math.pow(k, i)).toFixed(2)} ${sizes[i]}`
}

/**
 * 格式化日期时间
 *
 * @param dateString ISO日期字符串
 * @returns 格式化的日期时间（如 "2024-12-16 21:52:43"）
 */
export function formatDateTime(dateString: string | null): string {
  if (!dateString) return '-'

  const date = new Date(dateString)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const seconds = String(date.getSeconds()).padStart(2, '0')

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
}

/**
 * 触发浏览器下载
 *
 * @param blob Blob对象
 * @param filename 文件名
 */
export function triggerDownload(blob: Blob, filename: string) {
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  window.URL.revokeObjectURL(url)
}
