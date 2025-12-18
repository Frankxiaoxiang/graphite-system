<template>
  <div class="database-backup-container">
    <div class="page-header">
      <div class="header-left">
        <el-button
          @click="handleGoBack"
          class="back-button"
        >
          <el-icon style="margin-right: 4px;"><ArrowLeft /></el-icon>
          返回主页
        </el-button>

        <el-divider direction="vertical" />

        <h2>数据库备份管理</h2>
      </div>
      <el-button
        type="primary"
        :icon="Download"
        :loading="isCreatingBackup"
        :disabled="hasRunningTask"
        @click="handleCreateBackup"
      >
        {{ isCreatingBackup ? '备份中...' : '立即备份' }}
      </el-button>
    </div>

    <el-row :gutter="20" class="statistics-cards">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-card">
            <div class="stat-icon backup-count">
              <el-icon :size="32"><Files /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-label">备份文件数</div>
              <div class="stat-value">{{ statistics.total_backups }}</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-card">
            <div class="stat-icon total-size">
              <el-icon :size="32"><FolderOpened /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-label">占用空间</div>
              <div class="stat-value">{{ formatFileSize(statistics.total_size) }}</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-card">
            <div class="stat-icon database-size">
              <el-icon :size="32"><DataAnalysis /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-label">数据库大小</div>
              <div class="stat-value">{{ formatFileSize(statistics.database_size) }}</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-card">
            <div class="stat-icon last-backup">
              <el-icon :size="32"><Clock /></el-icon>
            </div>
            <div class="stat-content">
              <div class="stat-label">最后备份</div>
              <div class="stat-value-small">{{ formatLastBackupTime }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card class="backup-list-card" shadow="never">
      <template #header>
        <div class="card-header">
          <span>备份文件列表</span>
          <el-button
            :icon="Refresh"
            :loading="isLoadingList"
            @click="loadBackupList"
          >
            刷新
          </el-button>
        </div>
      </template>

      <el-table
        v-loading="isLoadingList"
        :data="backupList"
        stripe
        style="width: 100%"
      >
        <el-table-column prop="filename" label="文件名" min-width="300">
          <template #default="{ row }">
            <div class="filename-cell">
              <el-icon class="file-icon"><Document /></el-icon>
              <span>{{ row.filename }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="状态" width="120" align="center">
          <template #default="{ row }">
            <el-tag
              :type="getStatusTagType(row.status)"
              :icon="getStatusIcon(row.status)"
              effect="plain"
            >
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="文件大小" width="130" align="right">
          <template #default="{ row }">
            {{ formatFileSize(row.file_size) }}
          </template>
        </el-table-column>

        <el-table-column label="创建时间" width="180" align="center">
          <template #default="{ row }">
            {{ formatDateTime(row.created_at) }}
          </template>
        </el-table-column>

        <el-table-column label="操作" width="180" align="center" fixed="right">
          <template #default="{ row }">
            <el-button
              type="primary"
              size="small"
              :icon="Download"
              :disabled="row.status !== 'success'"
              @click="handleDownload(row)"
            >
              下载
            </el-button>
            <el-button
              type="danger"
              size="small"
              :icon="Delete"
              @click="handleDelete(row)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div v-if="backupList.length === 0 && !isLoadingList" class="empty-state">
        <el-empty description="暂无备份文件">
          <el-button type="primary" @click="handleCreateBackup">创建第一个备份</el-button>
        </el-empty>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Download,
  Refresh,
  Delete,
  Document,
  Files,
  FolderOpened,
  DataAnalysis,
  Clock,
  Loading,
  CircleCheck,
  CircleClose,
  WarningFilled,
  ArrowLeft
} from '@element-plus/icons-vue'
import type { Component } from 'vue'
import {
  createBackup,
  getBackupList,
  getBackupStatistics,
  downloadBackup,
  deleteBackup,
  pollTaskStatus,
  formatFileSize,
  formatDateTime,
  triggerDownload,
  type BackupFile,
  type BackupStatistics,
  type BackupTaskStatus
} from '@/api/backup'

// ========== 响应式状态 ==========

const router = useRouter()

// 统计信息
const statistics = ref<BackupStatistics>({
  total_backups: 0,
  total_size: 0,
  last_backup_time: null,
  database_size: 0,
  running_tasks: 0
})

// 备份列表
const backupList = ref<BackupFile[]>([])

// 加载状态
const isLoadingList = ref(false)
const isCreatingBackup = ref(false)

// 自动刷新定时器
let refreshTimer: number | null = null

// ========== 计算属性 ==========

/**
 * 是否有正在运行的任务
 */
const hasRunningTask = computed(() => {
  return statistics.value.running_tasks > 0 || isCreatingBackup.value
})

/**
 * 格式化最后备份时间
 */
const formatLastBackupTime = computed(() => {
  if (!statistics.value.last_backup_time) {
    return '暂无备份'
  }
  return formatDateTime(statistics.value.last_backup_time)
})

// ========== 生命周期 ==========

onMounted(() => {
  loadData()
  startAutoRefresh()
})

onUnmounted(() => {
  stopAutoRefresh()
})

// ========== 页面导航 ==========

/**
 * 返回上一页
 */
function handleGoBack() {
  router.back()
}

// ========== 数据加载 ==========

/**
 * 加载所有数据
 */
async function loadData() {
  await Promise.all([
    loadStatistics(),
    loadBackupList()
  ])
}

/**
 * 加载统计信息
 */
async function loadStatistics() {
  try {
    const data = await getBackupStatistics()
    statistics.value = data
  } catch (error: any) {
    console.error('加载统计信息失败:', error)
    ElMessage.error('加载统计信息失败: ' + (error.message || '未知错误'))
  }
}

/**
 * 加载备份列表
 */
async function loadBackupList() {
  isLoadingList.value = true
  try {
    const data = await getBackupList()
    backupList.value = data.backups
  } catch (error: any) {
    console.error('加载备份列表失败:', error)
    ElMessage.error('加载备份列表失败: ' + (error.message || '未知错误'))
  } finally {
    isLoadingList.value = false
  }
}

// ========== 备份操作 ==========

/**
 * 创建备份
 */
async function handleCreateBackup() {
  isCreatingBackup.value = true

  try {
    // 创建备份任务
    const response = await createBackup()

    ElMessage.success({
      message: '备份任务已创建，正在后台执行...',
      duration: 2000
    })

    // 轮询任务状态
    await pollTaskStatus(
      response.task_id,
      (status) => {
        console.log('任务状态更新:', status.status)

        // 如果状态变为running，刷新统计信息（显示running_tasks）
        if (status.status === 'running') {
          loadStatistics()
        }
      },
      3000  // 每3秒轮询一次
    )

    // 任务完成，刷新数据
    await loadData()

    ElMessage.success({
      message: `备份完成！文件：${response.filename}`,
      duration: 3000
    })

  } catch (error: any) {
    console.error('备份失败:', error)

    // 检查是否是任务失败（有error_message）
    if (error.error_message) {
      ElMessage.error({
        message: `备份失败: ${error.error_message}`,
        duration: 5000
      })
    } else {
      ElMessage.error({
        message: '备份失败: ' + (error.message || '未知错误'),
        duration: 5000
      })
    }

    // 失败后也刷新数据
    await loadData()

  } finally {
    isCreatingBackup.value = false
  }
}

/**
 * 下载备份
 */
async function handleDownload(backup: BackupFile) {
  try {
    ElMessage.info('正在下载备份文件...')

    const blob = await downloadBackup(backup.filename)
    triggerDownload(blob, backup.filename)

    ElMessage.success('下载成功')
  } catch (error: any) {
    console.error('下载失败:', error)
    ElMessage.error('下载失败: ' + (error.message || '未知错误'))
  }
}

/**
 * 删除备份
 */
async function handleDelete(backup: BackupFile) {
  try {
    await ElMessageBox.confirm(
      `确定要删除备份文件 "${backup.filename}" 吗？`,
      '确认删除',
      {
        confirmButtonText: '删除',
        cancelButtonText: '取消',
        type: 'warning',
        confirmButtonClass: 'el-button--danger'
      }
    )

    await deleteBackup(backup.filename)

    ElMessage.success('删除成功')

    // 刷新数据
    await loadData()

  } catch (error: any) {
    if (error === 'cancel') {
      // 用户取消，不显示错误
      return
    }
    console.error('删除失败:', error)
    ElMessage.error('删除失败: ' + (error.message || '未知错误'))
  }
}

// ========== 自动刷新 ==========

/**
 * 启动自动刷新（每30秒）
 */
function startAutoRefresh() {
  refreshTimer = window.setInterval(() => {
    loadData()
  }, 30000)  // 30秒
}

/**
 * 停止自动刷新
 */
function stopAutoRefresh() {
  if (refreshTimer) {
    clearInterval(refreshTimer)
    refreshTimer = null
  }
}

// ========== 工具函数 ==========

/**
 * 获取状态标签类型
 */
function getStatusTagType(status: BackupTaskStatus): 'success' | 'warning' | 'danger' | 'info' {
  switch (status) {
    case 'success':
      return 'success'
    case 'running':
      return 'warning'
    case 'failed':
      return 'danger'
    case 'pending':
      return 'info'
    default:
      return 'info'
  }
}

/**
 * 获取状态图标
 */
function getStatusIcon(status: BackupTaskStatus): Component {
  switch (status) {
    case 'success':
      return CircleCheck
    case 'running':
      return Loading
    case 'failed':
      return CircleClose
    case 'pending':
      return WarningFilled
    default:
      return WarningFilled
  }
}

/**
 * 获取状态文本
 */
function getStatusText(status: BackupTaskStatus): string {
  switch (status) {
    case 'success':
      return '成功'
    case 'running':
      return '执行中'
    case 'failed':
      return '失败'
    case 'pending':
      return '等待中'
  }
  return '未知'
}
</script>

<style scoped lang="scss">
.database-backup-container {
  padding: 20px;

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;

    .header-left {
      display: flex;
      align-items: center;
      gap: 16px; // 稍微拉开间距

      .back-button {
        font-weight: normal;
        padding: 8px 15px;
        transition: all 0.3s;

        &:hover {
          background-color: #f5f7fa;
          border-color: #409eff;
          color: #409eff;
        }
      }
    }

    h2 {
      margin: 0;
      font-size: 24px;
      font-weight: 500;
      color: #303133;
    }
  }

  // 统计卡片
  .statistics-cards {
    margin-bottom: 20px;

    .stat-card {
      display: flex;
      align-items: center;
      padding: 10px 0;

      .stat-icon {
        width: 60px;
        height: 60px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-right: 15px;

        &.backup-count {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
        }

        &.total-size {
          background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
          color: white;
        }

        &.database-size {
          background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
          color: white;
        }

        &.last-backup {
          background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
          color: white;
        }
      }

      .stat-content {
        flex: 1;

        .stat-label {
          font-size: 14px;
          color: #909399;
          margin-bottom: 8px;
        }

        .stat-value {
          font-size: 24px;
          font-weight: 600;
          color: #303133;
        }

        .stat-value-small {
          font-size: 14px;
          font-weight: 500;
          color: #303133;
        }
      }
    }
  }

  // 备份列表卡片
  .backup-list-card {
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-weight: 500;
    }

    .filename-cell {
      display: flex;
      align-items: center;

      .file-icon {
        margin-right: 8px;
        color: #409eff;
      }
    }

    .empty-state {
      padding: 40px 0;
    }
  }
}
</style>
