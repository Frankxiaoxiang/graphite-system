<template>
  <div class="variable-selector">
    <!-- X轴选择 -->
    <el-form :model="formData" label-position="top" label-width="80px">
      <el-form-item label="X轴变量">
        <el-select
          v-model="formData.xField"
          placeholder="选择X轴变量"
          filterable
          @change="handleXFieldChange"
        >
          <el-option-group
            v-for="group in groupedFields"
            :key="group.category"
            :label="group.label"
          >
            <el-option
              v-for="field in group.fields"
              :key="field.value"
              :label="`${field.label} (${field.unit})`"
              :value="field.value"
            />
          </el-option-group>
        </el-select>
      </el-form-item>

      <!-- Y轴选择 -->
      <el-form-item label="Y轴变量">
        <el-select
          v-model="formData.yField"
          placeholder="选择Y轴变量"
          filterable
          @change="handleYFieldChange"
        >
          <el-option-group
            v-for="group in groupedFields"
            :key="group.category"
            :label="group.label"
          >
            <el-option
              v-for="field in group.fields"
              :key="field.value"
              :label="`${field.label} (${field.unit})`"
              :value="field.value"
            />
          </el-option-group>
        </el-select>
      </el-form-item>

      <el-divider content-position="left">筛选条件</el-divider>

      <!-- 日期范围 -->
      <el-form-item label="实验日期">
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          format="YYYY-MM-DD"
          value-format="YYYY-MM-DD"
          @change="handleDateRangeChange"
        />
      </el-form-item>

      <!-- PI膜型号 -->
      <el-form-item label="PI膜型号">
        <el-select
          v-model="formData.piFilmModels"
          placeholder="选择PI膜型号（可多选）"
          multiple
          collapse-tags
          collapse-tags-tooltip
          @change="handlePiFilmModelsChange"
        >
          <el-option label="GH-100" value="GH-100" />
          <el-option label="TH-55" value="TH-55" />
          <el-option label="NA-38" value="NA-38" />
          <el-option label="PI-01" value="PI-01" />
        </el-select>
      </el-form-item>

      <!-- 烧制地点 -->
      <el-form-item label="烧制地点">
        <el-select
          v-model="formData.sinteringLocations"
          placeholder="选择烧制地点（可多选）"
          multiple
          collapse-tags
          @change="handleSinteringLocationsChange"
        >
          <el-option label="东莞" value="DG" />
          <el-option label="苏州" value="SZ" />
          <el-option label="深圳" value="ShenZ" />
        </el-select>
      </el-form-item>

      <el-divider content-position="left">数据清洗选项</el-divider>

      <!-- 数据清洗选项 -->
      <el-form-item>
        <div class="cleaning-options">
          <el-checkbox
            v-model="formData.excludeZero"
            @change="handleExcludeZeroChange"
          >
            排除0值数据
          </el-checkbox>
          <el-tooltip
            content="0值可能是未测量或无效数据，建议排除"
            placement="right"
          >
            <el-icon class="info-icon"><QuestionFilled /></el-icon>
          </el-tooltip>
        </div>
      </el-form-item>

      <el-form-item>
        <div class="cleaning-options">
          <el-checkbox
            v-model="formData.enableOutlierDetection"
            @change="handleOutlierDetectionChange"
          >
            启用异常值检测
          </el-checkbox>
          <el-tooltip
            content="使用IQR方法自动检测并排除异常值"
            placement="right"
          >
            <el-icon class="info-icon"><QuestionFilled /></el-icon>
          </el-tooltip>
        </div>
      </el-form-item>

      <!-- 查询按钮 -->
      <el-form-item>
        <el-button
          type="primary"
          :loading="loading"
          :disabled="!formData.xField || !formData.yField"
          @click="handleSearch"
          style="width: 100%"
        >
          <el-icon><Search /></el-icon>
          查询数据
        </el-button>
      </el-form-item>

      <!-- 清空筛选 -->
      <el-form-item>
        <el-button @click="handleReset" style="width: 100%">
          <el-icon><RefreshLeft /></el-icon>
          清空筛选
        </el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, RefreshLeft, QuestionFilled } from '@element-plus/icons-vue'
import { getFieldOptions } from '@/api/analysis'
import type { FieldOption } from '@/types/analysis'

// Props
interface Props {
  xField?: string
  yField?: string
  dateStart?: string
  dateEnd?: string
  piFilmModels?: string[]
  sinteringLocations?: string[]
  excludeZero?: boolean
  enableOutlierDetection?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  xField: '',
  yField: '',
  piFilmModels: () => [],
  sinteringLocations: () => [],
  excludeZero: true,
  enableOutlierDetection: true
})

// Emits
const emit = defineEmits<{
  (e: 'update:xField', value: string): void
  (e: 'update:yField', value: string): void
  (e: 'update:dateStart', value: string | undefined): void
  (e: 'update:dateEnd', value: string | undefined): void
  (e: 'update:piFilmModels', value: string[]): void
  (e: 'update:sinteringLocations', value: string[]): void
  (e: 'update:excludeZero', value: boolean): void
  (e: 'update:enableOutlierDetection', value: boolean): void
  (e: 'search'): void
}>()

// 表单数据
const formData = ref({
  xField: props.xField,
  yField: props.yField,
  piFilmModels: props.piFilmModels,
  sinteringLocations: props.sinteringLocations,
  excludeZero: props.excludeZero,
  enableOutlierDetection: props.enableOutlierDetection
})

const dateRange = ref<[string, string] | null>(null)
const loading = ref(false)

// 字段列表
const fields = ref<FieldOption[]>([])

// 按分类分组的字段
const groupedFields = computed(() => {
  const groups: Record<string, { category: string; label: string; fields: FieldOption[] }> = {}
  
  fields.value.forEach(field => {
    if (!groups[field.category]) {
      groups[field.category] = {
        category: field.category,
        label: field.category_label,
        fields: []
      }
    }
    groups[field.category].fields.push(field)
  })
  
  return Object.values(groups)
})

// 加载字段选项
onMounted(async () => {
  try {
    const response = await getFieldOptions()
    fields.value = response.fields
  } catch (error) {
    ElMessage.error('加载字段列表失败')
  }
})

// 事件处理
const handleXFieldChange = (value: string) => {
  emit('update:xField', value)
}

const handleYFieldChange = (value: string) => {
  emit('update:yField', value)
}

const handleDateRangeChange = (value: [string, string] | null) => {
  if (value) {
    emit('update:dateStart', value[0])
    emit('update:dateEnd', value[1])
  } else {
    emit('update:dateStart', undefined)
    emit('update:dateEnd', undefined)
  }
}

const handlePiFilmModelsChange = (value: string[]) => {
  emit('update:piFilmModels', value)
}

const handleSinteringLocationsChange = (value: string[]) => {
  emit('update:sinteringLocations', value)
}

const handleExcludeZeroChange = (value: boolean) => {
  emit('update:excludeZero', value)
}

const handleOutlierDetectionChange = (value: boolean) => {
  emit('update:enableOutlierDetection', value)
}

const handleSearch = () => {
  emit('search')
}

const handleReset = () => {
  formData.value = {
    xField: '',
    yField: '',
    piFilmModels: [],
    sinteringLocations: [],
    excludeZero: true,
    enableOutlierDetection: true
  }
  dateRange.value = null
  
  emit('update:xField', '')
  emit('update:yField', '')
  emit('update:dateStart', undefined)
  emit('update:dateEnd', undefined)
  emit('update:piFilmModels', [])
  emit('update:sinteringLocations', [])
  emit('update:excludeZero', true)
  emit('update:enableOutlierDetection', true)
}
</script>

<style scoped lang="scss">
.variable-selector {
  padding: 10px 0;
}

.el-form {
  .el-form-item {
    margin-bottom: 20px;
  }
}

.cleaning-options {
  display: flex;
  align-items: center;
  gap: 8px;

  .info-icon {
    color: #909399;
    cursor: help;
    font-size: 16px;

    &:hover {
      color: #409eff;
    }
  }
}

:deep(.el-select) {
  width: 100%;
}

:deep(.el-date-editor) {
  width: 100%;
}
</style>
