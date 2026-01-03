<template>
  <div class="data-analysis-container">
    <el-card class="header-card" shadow="never">
      <template #header>
        <div class="card-header">
          <div class="header-left">
            <h2>
              <el-icon><TrendCharts /></el-icon>
              数据分析
            </h2>
            <p class="subtitle">实验数据回归分析与可视化</p>
          </div>

          <div class="header-right">
            <el-button
              type="primary"
              :icon="HomeFilled"
              @click="handleBackToHome"
            >
              返回主页
            </el-button>
          </div>
        </div>
      </template>
    </el-card>

    <div class="analysis-content">
      <div class="left-panel">
        <el-card class="selector-card" shadow="hover">
          <template #header>
            <div class="card-title">
              <el-icon><Filter /></el-icon>
              数据选择
            </div>
          </template>

          <VariableSelector
            v-model:xField="queryParams.x_field"
            v-model:yField="queryParams.y_field"
            v-model:dateStart="queryParams.date_start"
            v-model:dateEnd="queryParams.date_end"
            v-model:piFilmModels="piFilmModels"
            v-model:graphiteModels="graphiteModels"
            v-model:sinteringLocations="sinteringLocations"
            v-model:excludeZero="queryParams.exclude_zero"
            v-model:enableOutlierDetection="queryParams.enable_outlier_detection"
            @update:x-axis="handleXAxisUpdate"
            @update:y-axis="handleYAxisUpdate"
            @search="handleSearch"
          />
        </el-card>
      </div>

      <div class="right-panel">
        <el-card class="toolbar-card" shadow="never">
          <div class="toolbar-buttons">
            <el-button
              type="success"
              :icon="Collection"
              :disabled="!queryParams.x_field || !queryParams.y_field"
              @click="handleSaveConfig"
            >
              保存配置
            </el-button>

            <el-button
              type="info"
              :icon="Document"
              @click="toggleConfigList"
            >
              我的配置
            </el-button>

            <div class="toolbar-divider"></div>

            <el-text type="info" size="small">
              已选择:
              <el-tag v-if="queryParams.x_field" size="small" type="primary" style="margin-left: 8px;">
                X轴: {{ xAxisConfig.label || queryParams.x_field }}
              </el-tag>
              <el-tag v-if="queryParams.y_field" size="small" type="success" style="margin-left: 4px;">
                Y轴: {{ yAxisConfig.label || queryParams.y_field }}
              </el-tag>
            </el-text>
          </div>
        </el-card>

        <div class="results-area">
          <el-card v-if="analysisData" class="preview-card" shadow="hover">
            <template #header>
              <div class="card-title">
                <el-icon><Document /></el-icon>
                数据预览
                <el-tag v-if="analysisData.statistics" type="info" class="data-count">
                  {{ analysisData.statistics.valid_count }} / {{ analysisData.statistics.total_count }} 个有效点
                </el-tag>
              </div>
            </template>

            <DataPreview
              v-if="analysisData"
              :key="dataPreviewKey"
              :data="analysisData.data"
              :metadata="analysisData.metadata"
              :statistics="analysisData.statistics"
              :cleaning-report="analysisData.cleaning_report"
              @data-updated="handleDataUpdated"
              @start-analysis="handleStartAnalysis"
            />
          </el-card>

          <el-card v-if="regressionResult" class="result-card" shadow="hover">
            <template #header>
              <div class="card-title">
                <el-icon><DataAnalysis /></el-icon>
                回归分析结果
              </div>
            </template>

            <AnalysisResult
              :result="regressionResult"
              :metadata="analysisData?.metadata"
            />
          </el-card>

          <el-card v-if="regressionResult" class="chart-card" shadow="hover">
            <template #header>
              <div class="card-title">
                <el-icon><PieChart /></el-icon>
                回归图表
              </div>
            </template>

            <RegressionChart
              :data="validDataPoints"
              :regression="regressionResult"
              :metadata="analysisData?.metadata"
            />
          </el-card>

          <el-empty
            v-if="!analysisData && !loading"
            description="请在左侧选择变量并点击'查询数据'开始分析"
            :image-size="200"
          />
        </div>
      </div>
    </div>
  </div>

  <SaveConfigDialog
    v-model:visible="saveDialogVisible"
    :current-config="currentConfig"
    @success="handleSaveSuccess"
  />

  <el-drawer
    v-model="configListVisible"
    title="我的分析配置"
    size="600px"
    direction="rtl"
  >
    <ConfigList
      ref="configListRef"
      @run="handleRunConfig"
    />
  </el-drawer>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'  // ✅ 新增：导入 router
import { ElMessage } from 'element-plus'
import {
  TrendCharts, Filter, Document, DataAnalysis, PieChart, Collection,
  HomeFilled  // ✅ 新增：导入返回图标
} from '@element-plus/icons-vue'

// 组件导入
import VariableSelector from '@/components/analysis/VariableSelector.vue'
import DataPreview from '@/components/analysis/DataPreview.vue'
import AnalysisResult from '@/components/analysis/AnalysisResult.vue'
import RegressionChart from '@/components/analysis/RegressionChart.vue'
import SaveConfigDialog from '@/components/analysis/SaveConfigDialog.vue'
import ConfigList from '@/components/analysis/ConfigList.vue'

// API 与 类型
import { getAnalysisData, performLinearRegression } from '@/api/analysis'
import type { AnalysisConfig } from '@/api/analysisConfig'
import type {
  AnalysisQueryParams, AnalysisDataResponse, RegressionResult, DataPoint
} from '@/types/analysis'

// ✅ 新增：获取 router 实例
const router = useRouter()

// 1. 响应式状态声明
const queryParams = ref<AnalysisQueryParams>({
  x_field: '',
  y_field: '',
  exclude_zero: true,
  enable_outlier_detection: true,
  outlier_method: 'iqr'
})

const piFilmModels = ref<string[]>([])
const graphiteModels = ref<string[]>([])
const sinteringLocations = ref<string[]>([])
const loading = ref(false)
const analysisData = ref<AnalysisDataResponse | null>(null)
const regressionResult = ref<RegressionResult | null>(null)
const dataPreviewKey = ref(0)

// 2. 配置管理状态
const saveDialogVisible = ref(false)
const configListVisible = ref(false)
const currentConfig = ref<AnalysisConfig['config']>({
  x_axis: { field: '', label: '', unit: '' },
  y_axis: { field: '', label: '', unit: '' },
  filters: {},
  cleaning_options: {}
})

const xAxisConfig = ref({ field: '', label: '', unit: '' })
const yAxisConfig = ref({ field: '', label: '', unit: '' })
const configListRef = ref<InstanceType<typeof ConfigList>>()

// 3. 计算属性：过滤出有效点供图表渲染
const validDataPoints = computed(() => {
  if (!analysisData.value) return []
  return analysisData.value.data
    .filter(d => d.status === 'valid')
    .map(d => ({ x: d.x, y: d.y, experiment_code: d.experiment_code }))
})

// 4. 核心逻辑函数
const handleSearch = async () => {
  console.log('=== 🔍 handleSearch 调试信息 ===')
  console.log('X轴字段:', queryParams.value.x_field)
  console.log('Y轴字段:', queryParams.value.y_field)
  console.log('PI膜型号数组:', piFilmModels.value)
  console.log('石墨型号数组:', graphiteModels.value)
  console.log('烧结地点数组:', sinteringLocations.value)

  if (!queryParams.value.x_field || !queryParams.value.y_field) {
    ElMessage.warning('请选择X轴和Y轴字段')
    return
  }

  loading.value = true
  regressionResult.value = null

  try {
    const params: AnalysisQueryParams = {
      ...queryParams.value,
      pi_film_model: piFilmModels.value.length > 0 ? piFilmModels.value.join(',') : undefined,
      graphite_model: graphiteModels.value.length > 0 ? graphiteModels.value.join(',') : undefined,
      sintering_location: sinteringLocations.value.length > 0 ? sinteringLocations.value.join(',') : undefined
    }

    console.log('📤 最终请求参数:', params)
    console.log('===========================')

    const response = await getAnalysisData(params)
    analysisData.value = response
    dataPreviewKey.value++

    if (response.statistics.valid_count === 0) {
      ElMessage.warning('没有有效数据点，请调整筛选条件')
    } else {
      ElMessage.success(`成功加载 ${response.statistics.valid_count} 个有效数据点`)
    }
  } catch (error: any) {
    ElMessage.error(error.message || '数据加载失败')
    analysisData.value = null
  } finally {
    loading.value = false
  }
}

const handleDataUpdated = (updatedData: DataPoint[]) => {
  if (analysisData.value) {
    analysisData.value.data = updatedData
    const validCount = updatedData.filter(d => d.status === 'valid').length
    const excludedCount = updatedData.length - validCount
    analysisData.value.statistics.valid_count = validCount
    analysisData.value.statistics.excluded_count = excludedCount
  }
}

const handleStartAnalysis = async () => {
  if (validDataPoints.value.length < 3) {
    ElMessage.warning('至少需要3个有效数据点才能进行回归分析')
    return
  }

  loading.value = true
  try {
    const cleanData = validDataPoints.value
      .filter(p => {
        const xValid = p.x !== null && p.x !== undefined && !isNaN(Number(p.x))
        const yValid = p.y !== null && p.y !== undefined && !isNaN(Number(p.y))
        return xValid && yValid
      })
      .map(p => ({ x: Number(p.x), y: Number(p.y) }))

    if (cleanData.length < 2) {
      ElMessage.warning(`有效数据点不足：清洗后${cleanData.length}个，至少需要2个`)
      return
    }

    const result = await performLinearRegression({ data: cleanData })
    regressionResult.value = result

    const quality = result.quality_assessment.fit_quality
    const messages: Record<string, string> = {
      excellent: '回归分析完成！拟合效果优秀（R² ≥ 0.9）',
      good: '回归分析完成！拟合效果良好（R² ≥ 0.75）',
      fair: '回归分析完成！拟合效果一般（R² ≥ 0.5）',
      poor: '回归分析完成！拟合效果较差（R² < 0.5），建议检查数据'
    }

    ElMessage.success(messages[quality] || '回归分析完成')

    setTimeout(() => {
      document.querySelector('.result-card')?.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }, 100)
  } catch (error: any) {
    console.error('=== 📊 回归分析失败 ===')
    const responseData = error.response?.data
    const status = error.response?.status

    let errorMsg = '回归分析失败'

    if (status === 400 && responseData) {
      if (responseData.error === 'No variance in X') {
        const xValue = responseData.x_value
        const xLabel = analysisData.value?.metadata?.x_label || 'X轴'
        const xUnit = analysisData.value?.metadata?.x_unit || ''
        errorMsg = `无法进行回归分析：${xLabel}数据全部相同（当前值: ${xValue} ${xUnit}）。请在筛选条件中选择具有不同数值的样本。`
      } else if (responseData.error === 'Insufficient data') {
        errorMsg = '样本数据量太少（至少需要3个有效点），请放宽筛选条件以获取更多数据。'
      } else if (responseData.error === 'Missing required fields') {
        errorMsg = `请求参数缺失: ${responseData.missing_fields?.join(', ')}，请检查页面配置。`
      } else {
        errorMsg = responseData.message || responseData.error || errorMsg
      }
    } else if (status === 401) {
      errorMsg = '登录已失效，请重新登录'
    } else if (error.message === 'Network Error') {
      errorMsg = '网络连接失败，请检查后端服务是否正常'
    } else {
      errorMsg = error.message || '系统繁忙，请稍后再试'
    }

    ElMessage({
      message: errorMsg,
      type: 'error',
      duration: 5000,
      showClose: true
    })

    regressionResult.value = null
  } finally {
    loading.value = false
  }
}

// 5. 配置保存与加载处理
const handleXAxisUpdate = (config: { field: string; label: string; unit: string }) => {
  xAxisConfig.value = config
  queryParams.value.x_field = config.field
}

const handleYAxisUpdate = (config: { field: string; label: string; unit: string }) => {
  yAxisConfig.value = config
  queryParams.value.y_field = config.field
}

const handleSaveConfig = () => {
  if (!queryParams.value.x_field || !queryParams.value.y_field) {
    ElMessage.warning('请先选择X轴和Y轴字段')
    return
  }

  currentConfig.value = {
    x_axis: {
      field: xAxisConfig.value.field || queryParams.value.x_field,
      label: xAxisConfig.value.label || queryParams.value.x_field,
      unit: xAxisConfig.value.unit || ''
    },
    y_axis: {
      field: yAxisConfig.value.field || queryParams.value.y_field,
      label: yAxisConfig.value.label || queryParams.value.y_field,
      unit: yAxisConfig.value.unit || ''
    },
    filters: {
      ...(piFilmModels.value.length > 0 && { pi_film_models: piFilmModels.value }),
      ...(graphiteModels.value.length > 0 && { graphite_models: graphiteModels.value }),
      ...(sinteringLocations.value.length > 0 && { sintering_locations: sinteringLocations.value })
    },
    cleaning_options: {
      exclude_zero: queryParams.value.exclude_zero,
      enable_outlier_detection: queryParams.value.enable_outlier_detection,
      outlier_method: queryParams.value.outlier_method
    }
  }

  saveDialogVisible.value = true
}

const handleRunConfig = async (config: AnalysisConfig) => {
  try {
    xAxisConfig.value = config.config.x_axis
    yAxisConfig.value = config.config.y_axis
    queryParams.value.x_field = config.config.x_axis.field
    queryParams.value.y_field = config.config.y_axis.field

    piFilmModels.value = config.config.filters?.pi_film_models || []
    graphiteModels.value = config.config.filters?.graphite_models || []
    sinteringLocations.value = config.config.filters?.sintering_locations || []

    if (config.config.cleaning_options) {
      queryParams.value.exclude_zero = config.config.cleaning_options.exclude_zero ?? true
      queryParams.value.enable_outlier_detection = config.config.cleaning_options.enable_outlier_detection ?? true
      queryParams.value.outlier_method = config.config.cleaning_options.outlier_method || 'iqr'
    }

    ElMessage.success(`配置"${config.name}"已加载`)
    await handleSearch()
    configListVisible.value = false
  } catch (error: any) {
    console.error('运行配置失败:', error)
    ElMessage.error('配置加载失败')
  }
}

const handleSaveSuccess = () => {
  ElMessage.success('配置保存成功')
  if (configListVisible.value && configListRef.value) {
    configListRef.value.refresh()
  }
}

const toggleConfigList = () => {
  configListVisible.value = !configListVisible.value
}

// ✅ 新增：返回主页函数
const handleBackToHome = () => {
  router.push('/')
}
</script>

<style scoped lang="scss">
.data-analysis-container {
  padding: 20px;
  background-color: #f5f7fa;
  min-height: 100vh;
}

// ✅ 修改：添加卡片头部样式
.header-card {
  margin-bottom: 20px;
  border-radius: 8px;

  // 卡片头部布局
  .card-header {
    display: flex;
    justify-content: space-between;  // 左右布局
    align-items: center;             // 垂直居中

    // 左侧：标题和副标题
    .header-left {
      h2 {
        margin: 0;
        display: flex;
        align-items: center;
        gap: 8px;
        color: #303133;
        font-size: 24px;
        font-weight: 600;
      }

      .subtitle {
        margin: 8px 0 0 0;
        color: #909399;
        font-size: 14px;
      }
    }

    // 右侧：返回按钮区域
    .header-right {
      display: flex;
      align-items: center;
    }
  }
}

.analysis-content {
  display: flex;
  gap: 20px;
  align-items: flex-start;

  // 1. 左侧面板：固定宽度 + 滚动跟随
  .left-panel {
    flex: 0 0 380px;
    width: 380px;
    position: sticky;
    top: 20px;
    z-index: 10;
  }

  // 2. 右侧面板：弹性拉伸
  .right-panel {
    flex: 1;
    min-width: 0; // 解决 ECharts 在 flex 容器下的宽度溢出问题
    display: flex;
    flex-direction: column;
    gap: 20px;
  }
}

// 3. 结果卡片样式
.selector-card, .toolbar-card, .preview-card, .result-card, .chart-card {
  border-radius: 8px;
}

// 4. 入场动画：让数据呈现更优雅
.preview-card, .result-card, .chart-card {
  animation: slideIn 0.4s ease-out forwards;
}

@keyframes slideIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

// 5. 工具栏美化
.toolbar-card {
  background: linear-gradient(135deg, #fdfbfb 0%, #ebedee 100%);
  .toolbar-divider { width: 1px; height: 24px; background: #dcdfe6; margin: 0 12px; }
}

// 6. 响应式：针对小屏幕自动切换为垂直堆叠
@media (max-width: 1200px) {
  .analysis-content {
    flex-direction: column;
    .left-panel { width: 100%; flex: none; position: static; }
  }

  // ✅ 小屏幕优化：标题区域垂直堆叠
  .header-card .card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;

    .header-right {
      width: 100%;
      justify-content: flex-end;
    }
  }
}

// ✅ 新增：超小屏幕优化
@media (max-width: 768px) {
  .data-analysis-container {
    padding: 12px;
  }

  .header-card .card-header {
    .header-left h2 {
      font-size: 20px;
    }

    .header-right {
      :deep(.el-button) {
        width: 100%;
      }
    }
  }
}
</style>
