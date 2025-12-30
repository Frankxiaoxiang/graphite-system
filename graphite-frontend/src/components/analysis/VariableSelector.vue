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

      <!-- ✅ 修改：PI膜型号 - 动态加载 -->
      <el-form-item label="PI膜型号">
        <el-select
          v-model="formData.piFilmModels"
          placeholder="选择PI膜型号（可多选）"
          multiple
          collapse-tags
          collapse-tags-tooltip
          filterable
          :loading="piFilmModelLoading"
          @change="handlePiFilmModelsChange"
        >
          <el-option
            v-for="option in piFilmModelOptions"
            :key="option.value"
            :label="option.label"
            :value="option.value"
          />
        </el-select>
      </el-form-item>

      <!-- 石墨型号筛选 -->
      <el-form-item label="石墨型号">
        <el-select
          v-model="formData.graphiteModels"
          placeholder="选择石墨型号（可多选）"
          multiple
          collapse-tags
          collapse-tags-tooltip
          filterable
          @change="handleGraphiteModelsChange"
        >
          <el-option
            v-for="model in graphiteModelOptions"
            :key="model"
            :label="model"
            :value="model"
          />
        </el-select>
      </el-form-item>

      <!-- ✅ 修正：烧制地点选项 -->
      <el-form-item label="烧制地点">
        <el-select
          v-model="formData.sinteringLocations"
          placeholder="选择烧制地点（可多选）"
          multiple
          collapse-tags
          @change="handleSinteringLocationsChange"
        >
          <el-option label="DG：碳化（Dongguan） + 石墨化（Dongguan）" value="DG" />
          <el-option label="XT：碳化（湘潭/Xiangtan） + 石墨化（湘潭/Xiangtan）" value="XT" />
          <el-option label="DX：碳化（东莞/Dongguan） + 石墨化（湘潭/Xiangtan）" value="DX" />
          <el-option label="WF：外发" value="WF" />
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
import { dropdownApi } from '@/api/dropdown'  // ✅ 添加 dropdown API 导入
import type { FieldOption } from '@/types/analysis'

// Props
interface Props {
  xField?: string
  yField?: string
  dateStart?: string
  dateEnd?: string
  piFilmModels?: string[]
  graphiteModels?: string[]
  sinteringLocations?: string[]
  excludeZero?: boolean
  enableOutlierDetection?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  xField: '',
  yField: '',
  piFilmModels: () => [],
  graphiteModels: () => [],
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
  (e: 'update:graphiteModels', value: string[]): void
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
  graphiteModels: props.graphiteModels,
  sinteringLocations: props.sinteringLocations,
  excludeZero: props.excludeZero,
  enableOutlierDetection: props.enableOutlierDetection
})

const dateRange = ref<[string, string] | null>(null)
const loading = ref(false)

// 字段列表
const fields = ref<FieldOption[]>([])

// ✅ 新增：PI膜型号选项（动态加载）
const piFilmModelOptions = ref<Array<{ value: string; label: string }>>([])
const piFilmModelLoading = ref(false)

// 石墨型号选项（17个型号）
const graphiteModelOptions = ref([
  'SGF-010', 'SGF-012', 'SGF-015', 'SGF-017', 'SGF-020',
  'SGF-025', 'SGF-030', 'SGF-035', 'SGF-040', 'SGF-045',
  'SGF-050', 'SGF-060', 'SGF-070', 'SGF-080', 'SGF-100',
  'SGF-120', 'SGF-150'
])

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

// ✅ 新增：加载PI膜型号选项
async function loadPiFilmModelOptions() {
  try {
    piFilmModelLoading.value = true
    console.log('📥 开始加载PI膜型号选项...')

    const response = await dropdownApi.getOptions('pi_film_model')
    piFilmModelOptions.value = response.map(option => ({
      value: option.value,
      label: option.label
    }))

    console.log(`✅ PI膜型号加载成功: ${piFilmModelOptions.value.length} 个选项`)
  } catch (error) {
    console.error('❌ 加载PI膜型号失败:', error)
    ElMessage.error('加载PI膜型号列表失败')
  } finally {
    piFilmModelLoading.value = false
  }
}

// 加载字段选项和PI膜型号
onMounted(async () => {
  try {
    // 加载分析字段选项
    const response = await getFieldOptions()
    fields.value = response.fields

    // ✅ 加载PI膜型号选项
    await loadPiFilmModelOptions()
  } catch (error) {
    ElMessage.error('加载选项列表失败')
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

const handleGraphiteModelsChange = (value: string[]) => {
  emit('update:graphiteModels', value)
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
    graphiteModels: [],
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
  emit('update:graphiteModels', [])
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
