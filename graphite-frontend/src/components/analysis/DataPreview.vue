<template>
  <div class="data-preview">
    <!-- 清洗报告卡片 -->
    <el-alert
      v-if="cleaningReport"
      :title="`数据质量: ${getQualityText(cleaningReport.quality_assessment)}`"
      :type="getQualityType(cleaningReport.quality_assessment)"
      :closable="false"
      show-icon
      class="cleaning-alert"
    >
      <div class="cleaning-summary">
        <div class="summary-item">
          <span class="label">总数据点:</span>
          <span class="value">{{ cleaningReport.summary.total_count }}</span>
        </div>
        <div class="summary-item">
          <span class="label">有效数据:</span>
          <span class="value success">
            {{ cleaningReport.summary.valid_count }}
            ({{ cleaningReport.summary.valid_percentage }}%)
          </span>
        </div>
        <div class="summary-item">
          <span class="label">已排除:</span>
          <span class="value danger">
            {{ cleaningReport.summary.excluded_count }}
            ({{ cleaningReport.summary.excluded_percentage }}%)
          </span>
        </div>
      </div>

      <div v-if="cleaningReport.summary.excluded_count > 0" class="cleaning-details">
        <el-divider content-position="left">排除原因</el-divider>
        <div class="detail-items">
          <span v-if="cleaningReport.details.null_values > 0">
            NULL值: {{ cleaningReport.details.null_values }}个
          </span>
          <span v-if="cleaningReport.details.zero_values > 0">
            0值: {{ cleaningReport.details.zero_values }}个
          </span>
          <span v-if="cleaningReport.details.outliers > 0">
            异常值: {{ cleaningReport.details.outliers }}个
          </span>
        </div>
        <el-button
          link
          type="primary"
          @click="showExcludedData = !showExcludedData"
        >
          {{ showExcludedData ? '隐藏' : '查看' }}被排除的数据
        </el-button>
      </div>
    </el-alert>

    <!-- 数据表格 -->
    <el-table
      :data="displayData"
      :row-class-name="getRowClassName"
      stripe
      border
      max-height="400"
      class="data-table"
    >
      <el-table-column
        prop="experiment_code"
        label="实验编号"
        width="200"
        fixed
      />
      <el-table-column
        prop="x"
        :label="`X轴: ${metadata?.x_label || ''}`"
        width="150"
        align="right"
      >
        <template #default="{ row }">
          {{ formatNumber(row.x) }} {{ metadata?.x_unit || '' }}
        </template>
      </el-table-column>
      <el-table-column
        prop="y"
        :label="`Y轴: ${metadata?.y_label || ''}`"
        width="150"
        align="right"
      >
        <template #default="{ row }">
          {{ formatNumber(row.y) }} {{ metadata?.y_unit || '' }}
        </template>
      </el-table-column>
      <el-table-column
        prop="status"
        label="状态"
        width="100"
        align="center"
      >
        <template #default="{ row }">
          <el-tag
            :type="row.status === 'valid' ? 'success' : 'info'"
            size="small"
          >
            {{ row.status === 'valid' ? '有效' : '已排除' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column
        prop="cleaning_note"
        label="备注"
        width="120"
      >
        <template #default="{ row }">
          <span v-if="row.cleaning_note" class="cleaning-note">
            {{ getCleaningNoteText(row.cleaning_note) }}
          </span>
        </template>
      </el-table-column>
      <el-table-column
        label="操作"
        width="120"
        fixed="right"
        align="center"
      >
        <template #default="{ row }">
          <el-button
            v-if="row.status === 'valid'"
            link
            type="danger"
            size="small"
            @click="handleExcludeData(row)"
          >
            排除
          </el-button>
          <el-button
            v-else
            link
            type="success"
            size="small"
            @click="handleRestoreData(row)"
          >
            恢复
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分析按钮 -->
    <div class="action-bar">
      <el-button
        type="primary"
        size="large"
        :disabled="validCount < 2"
        @click="handleStartAnalysis"
      >
        <el-icon><DataAnalysis /></el-icon>
        开始回归分析
        <span v-if="validCount >= 2">({{ validCount }}个数据点)</span>
      </el-button>
      <el-tooltip
        v-if="validCount < 2"
        content="至少需要2个有效数据点才能进行回归分析"
        placement="top"
      >
        <el-icon class="warning-icon"><WarningFilled /></el-icon>
      </el-tooltip>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { DataAnalysis, WarningFilled } from '@element-plus/icons-vue'
import type {
  DataPoint,
  FieldMetadata,
  DataStatistics,
  CleaningReport
} from '@/types/analysis'

// Props
interface Props {
  data: DataPoint[]
  metadata?: FieldMetadata
  statistics?: DataStatistics
  cleaningReport?: CleaningReport
}

const props = defineProps<Props>()

// Emits
const emit = defineEmits<{
  (e: 'dataUpdated', value: DataPoint[]): void
  (e: 'startAnalysis'): void
}>()

// 状态
const showExcludedData = ref(false)

// 本地数据副本（用于手动排除/恢复）
const localData = ref<DataPoint[]>([...props.data])

// 显示的数据（根据showExcludedData过滤）
const displayData = computed(() => {
  if (showExcludedData.value) {
    return localData.value
  }
  return localData.value.filter(d => d.status === 'valid')
})

// 有效数据点数量
const validCount = computed(() => {
  return localData.value.filter(d => d.status === 'valid').length
})

// 获取质量评估文本
const getQualityText = (quality: string): string => {
  const texts: Record<string, string> = {
    excellent: '优秀',
    good: '良好',
    fair: '一般',
    poor: '较差',
    insufficient: '数据不足'
  }
  return texts[quality] || quality
}

// 获取质量评估类型（用于Alert颜色）
const getQualityType = (quality: string) => {
  const types: Record<string, 'success' | 'warning' | 'error' | 'info'> = {
    excellent: 'success',
    good: 'success',
    fair: 'warning',
    poor: 'error',
    insufficient: 'error'
  }
  return types[quality] || 'info'
}

// 获取清洗备注文本
const getCleaningNoteText = (note: string): string => {
  const texts: Record<string, string> = {
    null_value: 'NULL值',
    zero_value: '0值',
    outlier_iqr: '异常值(IQR)',
    outlier_zscore: '异常值(Z-Score)',
    manual_exclusion: '手动排除'
  }
  return texts[note] || note
}

// 格式化数字
const formatNumber = (value: any): string => {
  if (value === null || value === undefined) return '-'
  const num = Number(value)
  if (isNaN(num)) return String(value)
  return num.toFixed(2)
}

// 表格行类名
const getRowClassName = ({ row }: { row: DataPoint }) => {
  return row.status === 'excluded' ? 'excluded-row' : ''
}

// 手动排除数据点
const handleExcludeData = (row: DataPoint) => {
  const index = localData.value.findIndex(d => d.experiment_code === row.experiment_code)
  if (index !== -1) {
    localData.value[index].status = 'excluded'
    localData.value[index].cleaning_note = 'manual_exclusion'
    emit('dataUpdated', localData.value)
  }
}

// 恢复数据点
const handleRestoreData = (row: DataPoint) => {
  const index = localData.value.findIndex(d => d.experiment_code === row.experiment_code)
  if (index !== -1) {
    localData.value[index].status = 'valid'
    localData.value[index].cleaning_note = null
    emit('dataUpdated', localData.value)
  }
}

// 开始分析
const handleStartAnalysis = () => {
  emit('startAnalysis')
}
</script>

<style scoped lang="scss">
.data-preview {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.cleaning-alert {
  .cleaning-summary {
    display: flex;
    gap: 30px;
    margin-top: 10px;

    .summary-item {
      display: flex;
      flex-direction: column;
      gap: 4px;

      .label {
        font-size: 12px;
        color: #909399;
      }

      .value {
        font-size: 16px;
        font-weight: 600;

        &.success {
          color: #67c23a;
        }

        &.danger {
          color: #f56c6c;
        }
      }
    }
  }

  .cleaning-details {
    margin-top: 15px;

    .detail-items {
      display: flex;
      gap: 20px;
      font-size: 14px;
      color: #606266;
      margin-bottom: 10px;
    }
  }
}

.data-table {
  :deep(.excluded-row) {
    background-color: #f5f7fa !important;
    opacity: 0.6;

    td {
      text-decoration: line-through;
      color: #909399;
    }
  }

  .cleaning-note {
    font-size: 12px;
    color: #e6a23c;
  }
}

.action-bar {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
  padding: 20px 0;

  .warning-icon {
    color: #e6a23c;
    font-size: 20px;
  }
}
</style>
