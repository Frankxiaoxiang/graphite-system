<template>
  <el-dialog
    v-model="dialogVisible"
    title="保存分析配置"
    width="600px"
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <el-form
      ref="formRef"
      :model="formData"
      :rules="rules"
      label-width="100px"
      label-position="left"
    >
      <el-form-item label="配置名称" prop="name">
        <el-input
          v-model="formData.name"
          placeholder="请输入配置名称，如：石墨化温度 vs 比热"
          maxlength="100"
          show-word-limit
          clearable
        />
      </el-form-item>

      <el-form-item label="配置描述" prop="description">
        <el-input
          v-model="formData.description"
          type="textarea"
          :rows="3"
          placeholder="请输入配置描述（可选），如：研究石墨化温度对比热的影响"
          maxlength="500"
          show-word-limit
        />
      </el-form-item>

      <el-divider content-position="left">当前配置预览</el-divider>

      <div class="config-preview">
        <!-- X轴配置 -->
        <div class="preview-item">
          <span class="label">X轴：</span>
          <span class="value">
            {{ currentConfig.x_axis?.label || '未选择' }}
            <el-tag v-if="currentConfig.x_axis?.unit" size="small" type="info">
              {{ currentConfig.x_axis.unit }}
            </el-tag>
          </span>
        </div>

        <!-- Y轴配置 -->
        <div class="preview-item">
          <span class="label">Y轴：</span>
          <span class="value">
            {{ currentConfig.y_axis?.label || '未选择' }}
            <el-tag v-if="currentConfig.y_axis?.unit" size="small" type="info">
              {{ currentConfig.y_axis.unit }}
            </el-tag>
          </span>
        </div>

        <!-- 筛选条件 -->
        <div v-if="hasFilters" class="preview-item">
          <span class="label">筛选条件：</span>
          <div class="filters">
            <!-- 日期范围 -->
            <el-tag
              v-if="currentConfig.filters?.date_start"
              size="small"
              type="success"
              class="filter-tag"
            >
              日期：{{ currentConfig.filters.date_start }} 至 {{ currentConfig.filters.date_end }}
            </el-tag>
            
            <!-- PI膜型号 -->
            <el-tag
              v-if="currentConfig.filters?.pi_film_models?.length"
              size="small"
              type="success"
              class="filter-tag"
            >
              PI膜型号：{{ currentConfig.filters.pi_film_models.length }} 个
            </el-tag>
            
            <!-- 石墨型号 ✅ 新增支持 -->
            <el-tag
              v-if="currentConfig.filters?.graphite_models?.length"
              size="small"
              type="success"
              class="filter-tag"
            >
              石墨型号：{{ currentConfig.filters.graphite_models.length }} 个
            </el-tag>
            
            <!-- 烧结地点 ✅ 新增显示 -->
            <el-tag
              v-if="currentConfig.filters?.sintering_locations?.length"
              size="small"
              type="success"
              class="filter-tag"
            >
              烧结地点：{{ currentConfig.filters.sintering_locations.length }} 个
            </el-tag>
          </div>
        </div>

        <!-- 数据清洗选项 -->
        <div class="preview-item">
          <span class="label">数据清洗：</span>
          <div class="cleaning">
            <el-tag
              :type="currentConfig.cleaning_options?.exclude_zero ? 'warning' : 'info'"
              size="small"
              class="filter-tag"
            >
              {{ currentConfig.cleaning_options?.exclude_zero ? '排除' : '保留' }}0值
            </el-tag>
            <el-tag
              :type="currentConfig.cleaning_options?.enable_outlier_detection ? 'warning' : 'info'"
              size="small"
              class="filter-tag"
            >
              {{ currentConfig.cleaning_options?.enable_outlier_detection ? '启用' : '禁用' }}异常值检测
            </el-tag>
            <el-tag
              v-if="currentConfig.cleaning_options?.enable_outlier_detection"
              size="small"
              type="info"
              class="filter-tag"
            >
              方法：{{ getOutlierMethodLabel(currentConfig.cleaning_options?.outlier_method) }}
            </el-tag>
          </div>
        </div>
      </div>
    </el-form>

    <template #footer>
      <el-button @click="handleClose">取消</el-button>
      <el-button type="primary" :loading="loading" @click="handleSave">
        保存配置
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch } from 'vue'
import { ElMessage, FormInstance, FormRules } from 'element-plus'
import { saveAnalysisConfig, SaveConfigRequest } from '@/api/analysisConfig'
import type { AnalysisConfig } from '@/api/analysisConfig'

/**
 * 保存配置对话框组件
 * 
 * 文件路径: graphite-frontend/src/components/analysis/SaveConfigDialog.vue
 * 
 * 修订日期: 2025-01-02
 * 修订内容: 
 * - ✅ 添加石墨型号筛选项显示
 * - ✅ 添加烧结地点筛选项显示
 * - ✅ 支持新增Y轴字段（specific_heat, bond_strength等）
 * - ✅ 优化异常值检测方法显示
 */

interface Props {
  visible: boolean
  currentConfig: AnalysisConfig['config']
}

interface Emits {
  (e: 'update:visible', value: boolean): void
  (e: 'success'): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const dialogVisible = ref(false)
const loading = ref(false)
const formRef = ref<FormInstance>()

const formData = reactive({
  name: '',
  description: ''
})

const rules: FormRules = {
  name: [
    { required: true, message: '请输入配置名称', trigger: 'blur' },
    { min: 2, max: 100, message: '配置名称长度在 2 到 100 个字符', trigger: 'blur' }
  ]
}

/**
 * 是否有筛选条件
 */
const hasFilters = computed(() => {
  const filters = props.currentConfig.filters
  return (
    filters?.date_start ||
    filters?.pi_film_models?.length ||
    filters?.graphite_models?.length ||      // ✅ 支持石墨型号
    filters?.sintering_locations?.length     // ✅ 支持烧结地点
  )
})

/**
 * 获取异常值检测方法的中文标签
 */
function getOutlierMethodLabel(method?: string): string {
  const labels: Record<string, string> = {
    'iqr': 'IQR四分位法',
    'zscore': 'Z-Score标准分',
    'isolation_forest': '孤立森林'
  }
  return labels[method || 'iqr'] || method || 'IQR四分位法'
}

// 监听 visible 变化
watch(
  () => props.visible,
  (val) => {
    dialogVisible.value = val
  }
)

// 监听 dialogVisible 变化
watch(dialogVisible, (val) => {
  emit('update:visible', val)
})

/**
 * 关闭对话框
 */
function handleClose() {
  formRef.value?.resetFields()
  dialogVisible.value = false
}

/**
 * 保存配置
 */
async function handleSave() {
  if (!formRef.value) return

  try {
    // 表单验证
    await formRef.value.validate()

    // 验证配置数据
    if (!props.currentConfig.x_axis?.field || !props.currentConfig.y_axis?.field) {
      ElMessage.warning('请先选择 X轴 和 Y轴 变量')
      return
    }

    loading.value = true

    // 构建请求数据（✅ 自动包含所有新字段）
    const requestData: SaveConfigRequest = {
      name: formData.name,
      description: formData.description,
      config: props.currentConfig  // 包含 graphite_models, specific_heat 等新字段
    }

    console.log('💾 保存配置:', requestData)

    // 调用 API
    await saveAnalysisConfig(requestData)

    ElMessage.success('配置保存成功')
    
    // 触发成功事件
    emit('success')
    
    // 关闭对话框
    handleClose()
  } catch (error: any) {
    console.error('❌ 保存配置失败:', error)
    ElMessage.error(error.response?.data?.message || '保存配置失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped lang="scss">
.config-preview {
  padding: 16px;
  background: #f5f7fa;
  border-radius: 4px;
  margin-bottom: 16px;

  .preview-item {
    display: flex;
    align-items: flex-start;
    margin-bottom: 12px;

    &:last-child {
      margin-bottom: 0;
    }

    .label {
      min-width: 100px;
      color: #606266;
      font-weight: 500;
    }

    .value {
      flex: 1;
      color: #303133;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .filters,
    .cleaning {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
    }

    .filter-tag {
      margin: 0;
    }
  }
}

:deep(.el-dialog__body) {
  padding-top: 16px;
}

:deep(.el-divider--horizontal) {
  margin: 16px 0;
}
</style>
