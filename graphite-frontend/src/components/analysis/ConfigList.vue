<template>
  <div class="config-list">
    <div class="list-header">
      <h3>我的分析配置</h3>
      <el-button type="primary" size="small" @click="handleRefresh">
        <el-icon><Refresh /></el-icon>
        刷新
      </el-button>
    </div>

    <el-divider />

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-container">
      <el-skeleton :rows="3" animated />
    </div>

    <!-- 空状态 -->
    <el-empty
      v-else-if="!configs.length"
      description="还没有保存的分析配置"
      :image-size="120"
    >
      <template #image>
        <el-icon :size="80" color="#909399">
          <DocumentCopy />
        </el-icon>
      </template>
      <el-button type="primary" size="small">
        开始创建配置
      </el-button>
    </el-empty>

    <!-- 配置列表 -->
    <div v-else class="config-cards">
      <el-card
        v-for="config in configs"
        :key="config.id"
        class="config-card"
        shadow="hover"
      >
        <template #header>
          <div class="card-header">
            <div class="header-left">
              <el-icon class="config-icon"><DataAnalysis /></el-icon>
              <span class="config-name">{{ config.name }}</span>
            </div>
            <div class="header-right">
              <el-button
                type="primary"
                size="small"
                :icon="VideoPlay"
                @click="handleRun(config)"
              >
                运行
              </el-button>
              <el-dropdown @command="(cmd) => handleCommand(cmd, config)">
                <el-button :icon="More" circle size="small" />
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item command="edit" :icon="Edit">
                      编辑
                    </el-dropdown-item>
                    <el-dropdown-item command="delete" :icon="Delete">
                      删除
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </div>
        </template>

        <div class="card-body">
          <!-- 描述 -->
          <p v-if="config.description" class="description">
            {{ config.description }}
          </p>

          <!-- 配置详情 -->
          <div class="config-details">
            <div class="detail-row">
              <span class="label">X轴：</span>
              <span class="value">
                {{ config.config.x_axis.label }}
                <el-tag size="small" type="info">{{ config.config.x_axis.unit }}</el-tag>
              </span>
            </div>
            <div class="detail-row">
              <span class="label">Y轴：</span>
              <span class="value">
                {{ config.config.y_axis.label }}
                <el-tag size="small" type="info">{{ config.config.y_axis.unit }}</el-tag>
              </span>
            </div>
            
            <!-- 筛选条件 ✅ 优化：使用配置化方式显示 -->
            <div v-if="hasFilters(config)" class="detail-row">
              <span class="label">筛选：</span>
              <div class="filters">
                <template v-for="(filterConfig, key) in FILTER_CONFIG" :key="key">
                  <el-tag
                    v-if="config.config.filters?.[key]?.length"
                    size="small"
                    type="success"
                  >
                    {{ filterConfig.label }} {{ config.config.filters[key].length }} 个
                  </el-tag>
                </template>
              </div>
            </div>
          </div>

          <!-- 元数据 -->
          <div class="config-meta">
            <span class="meta-item">
              <el-icon><View /></el-icon>
              查看 {{ config.view_count }} 次
            </span>
            <span v-if="config.last_run_at" class="meta-item">
              <el-icon><Clock /></el-icon>
              最后运行：{{ formatRelativeTime(config.last_run_at) }}
            </span>
            <span class="meta-item">
              <el-icon><Calendar /></el-icon>
              创建于：{{ formatDate(config.created_at) }}
            </span>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 分页 -->
    <el-pagination
      v-if="total > perPage"
      v-model:current-page="currentPage"
      v-model:page-size="perPage"
      :total="total"
      :page-sizes="[10, 20, 50]"
      layout="total, sizes, prev, pager, next, jumper"
      class="pagination"
      @size-change="loadConfigs"
      @current-change="loadConfigs"
    />

    <!-- 编辑对话框 -->
    <el-dialog
      v-model="editDialogVisible"
      title="编辑配置"
      width="500px"
    >
      <el-form :model="editForm" label-width="100px">
        <el-form-item label="配置名称">
          <el-input v-model="editForm.name" placeholder="请输入配置名称" />
        </el-form-item>
        <el-form-item label="配置描述">
          <el-input
            v-model="editForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入配置描述（可选）"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSaveEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Refresh,
  DocumentCopy,
  DataAnalysis,
  VideoPlay,
  More,
  Edit,
  Delete,
  View,
  Clock,
  Calendar
} from '@element-plus/icons-vue'
import {
  getAnalysisConfigs,
  deleteAnalysisConfig,
  updateAnalysisConfig,
  type AnalysisConfig
} from '@/api/analysisConfig'

/**
 * 配置列表组件
 * 
 * 文件路径: graphite-frontend/src/components/analysis/ConfigList.vue
 * 
 * 修订日期: 2025-01-02
 * 修订内容:
 * - ✅ 使用配置化方式显示筛选器（提取FILTER_CONFIG常量）
 * - ✅ 支持石墨型号筛选器显示
 * - ✅ 支持烧结地点筛选器显示
 * - ✅ 优化代码可维护性
 */

interface Emits {
  (e: 'run', config: AnalysisConfig): void
}

const emit = defineEmits<Emits>()

// ========================================
// 筛选器配置 ✅ 提取为常量，提升可维护性
// ========================================
const FILTER_CONFIG: Record<string, { label: string; icon?: string }> = {
  pi_film_models: { label: 'PI膜型号', icon: 'film' },
  graphite_models: { label: '石墨型号', icon: 'box' },          // ✅ 新增
  sintering_locations: { label: '烧结地点', icon: 'location' }  // ✅ 新增
}

// ========================================
// 状态管理
// ========================================
const loading = ref(false)
const configs = ref<AnalysisConfig[]>([])
const total = ref(0)
const currentPage = ref(1)
const perPage = ref(20)

const editDialogVisible = ref(false)
const editForm = reactive({
  id: 0,
  name: '',
  description: ''
})

// ========================================
// API 调用
// ========================================

/**
 * 加载配置列表
 */
async function loadConfigs() {
  try {
    loading.value = true
    const response = await getAnalysisConfigs(currentPage.value, perPage.value)
    
    configs.value = response.configs
    total.value = response.total
    
    console.log('✅ 配置列表加载成功:', {
      count: configs.value.length,
      total: total.value,
      page: currentPage.value
    })
  } catch (error: any) {
    console.error('❌ 加载配置列表失败:', error)
    ElMessage.error(error.response?.data?.message || '加载失败')
  } finally {
    loading.value = false
  }
}

/**
 * 刷新列表
 */
function handleRefresh() {
  currentPage.value = 1
  loadConfigs()
}

/**
 * 运行配置
 * ✅ 自动传递所有新字段（graphite_models, specific_heat等）
 */
function handleRun(config: AnalysisConfig) {
  console.log('▶️ 运行配置:', {
    name: config.name,
    x_axis: config.config.x_axis.field,
    y_axis: config.config.y_axis.field,
    filters: config.config.filters
  })
  
  emit('run', config)
  ElMessage.success(`正在运行配置：${config.name}`)
}

/**
 * 处理下拉菜单命令
 */
function handleCommand(command: string, config: AnalysisConfig) {
  if (command === 'edit') {
    handleEdit(config)
  } else if (command === 'delete') {
    handleDelete(config)
  }
}

/**
 * 编辑配置
 */
function handleEdit(config: AnalysisConfig) {
  editForm.id = config.id!
  editForm.name = config.name
  editForm.description = config.description || ''
  editDialogVisible.value = true
}

/**
 * 保存编辑
 */
async function handleSaveEdit() {
  try {
    await updateAnalysisConfig(editForm.id, {
      name: editForm.name,
      description: editForm.description
    })
    ElMessage.success('配置更新成功')
    editDialogVisible.value = false
    loadConfigs()
  } catch (error: any) {
    ElMessage.error(error.response?.data?.message || '更新失败')
  }
}

/**
 * 删除配置
 */
async function handleDelete(config: AnalysisConfig) {
  try {
    await ElMessageBox.confirm(
      `确定要删除配置"${config.name}"吗？此操作不可恢复。`,
      '确认删除',
      {
        type: 'warning',
        confirmButtonText: '删除',
        cancelButtonText: '取消'
      }
    )

    await deleteAnalysisConfig(config.id!)
    ElMessage.success('配置删除成功')
    loadConfigs()
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.response?.data?.message || '删除失败')
    }
  }
}

// ========================================
// 工具函数
// ========================================

/**
 * 是否有筛选条件
 * ✅ 支持所有筛选字段
 */
function hasFilters(config: AnalysisConfig): boolean {
  const filters = config.config.filters
  return !!(
    filters?.pi_film_models?.length ||
    filters?.graphite_models?.length ||       // ✅ 支持石墨型号
    filters?.sintering_locations?.length      // ✅ 支持烧结地点
  )
}

/**
 * 格式化日期
 */
function formatDate(dateString?: string): string {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

/**
 * 格式化相对时间
 */
function formatRelativeTime(dateString: string): string {
  const now = new Date()
  const date = new Date(dateString)
  const diff = now.getTime() - date.getTime()

  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(diff / 3600000)
  const days = Math.floor(diff / 86400000)

  if (minutes < 1) return '刚刚'
  if (minutes < 60) return `${minutes} 分钟前`
  if (hours < 24) return `${hours} 小时前`
  if (days < 7) return `${days} 天前`
  return formatDate(dateString)
}

// ========================================
// 生命周期
// ========================================
onMounted(() => {
  loadConfigs()
})

// 暴露刷新方法给父组件
defineExpose({
  refresh: loadConfigs
})
</script>

<style scoped lang="scss">
.config-list {
  .list-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;

    h3 {
      margin: 0;
      font-size: 18px;
      color: #303133;
    }
  }

  .loading-container {
    padding: 20px;
  }

  .config-cards {
    display: grid;
    gap: 16px;
    margin-bottom: 24px;
  }

  .config-card {
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;

      .header-left {
        display: flex;
        align-items: center;
        gap: 12px;

        .config-icon {
          font-size: 20px;
          color: #409eff;
        }

        .config-name {
          font-size: 16px;
          font-weight: 500;
          color: #303133;
        }
      }

      .header-right {
        display: flex;
        gap: 8px;
      }
    }

    .card-body {
      .description {
        color: #606266;
        font-size: 14px;
        line-height: 1.5;
        margin-bottom: 16px;
      }

      .config-details {
        .detail-row {
          display: flex;
          align-items: flex-start;
          margin-bottom: 12px;

          &:last-child {
            margin-bottom: 16px;
          }

          .label {
            min-width: 60px;
            color: #909399;
            font-size: 13px;
          }

          .value {
            flex: 1;
            color: #303133;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
          }

          .filters {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
          }
        }
      }

      .config-meta {
        display: flex;
        flex-wrap: wrap;
        gap: 16px;
        padding-top: 12px;
        border-top: 1px solid #ebeef5;
        color: #909399;
        font-size: 13px;

        .meta-item {
          display: flex;
          align-items: center;
          gap: 4px;

          .el-icon {
            font-size: 14px;
          }
        }
      }
    }
  }

  .pagination {
    display: flex;
    justify-content: center;
    margin-top: 24px;
  }
}
</style>
