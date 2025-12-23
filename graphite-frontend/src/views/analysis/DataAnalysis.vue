<template>
  <div class="data-analysis-container">
    <el-card class="header-card" shadow="never">
      <template #header>
        <div class="card-header">
          <h2>
            <el-icon><TrendCharts /></el-icon>
            数据分析
          </h2>
          <p class="subtitle">实验数据回归分析与可视化</p>
        </div>
      </template>
    </el-card>

    <div class="analysis-content">
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
          v-model:sinteringLocations="sinteringLocations"
          v-model:excludeZero="queryParams.exclude_zero"
          v-model:enableOutlierDetection="queryParams.enable_outlier_detection"
          @search="handleSearch"
        />
      </el-card>

      <div class="results-area">
        <el-card v-if="analysisData" class="preview-card" shadow="hover">
          <template #header>
            <div class="card-title">
              <el-icon><Document /></el-icon>
              数据预览
              <el-tag v-if="analysisData.statistics" type="info" class="data-count">
                {{ analysisData.statistics.valid_count }} / {{ analysisData.statistics.total_count }} 个有效数据点
              </el-tag>
            </div>
          </template>

          <DataPreview
            v-if="analysisData"
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
          description="请选择X轴和Y轴变量，然后点击 '查询数据' 开始分析"
          :image-size="200"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import {
  TrendCharts,
  Filter,
  Document,
  DataAnalysis,
  PieChart
} from '@element-plus/icons-vue'

import VariableSelector from '@/components/analysis/VariableSelector.vue'
import DataPreview from '@/components/analysis/DataPreview.vue'
import AnalysisResult from '@/components/analysis/AnalysisResult.vue'
import RegressionChart from '@/components/analysis/RegressionChart.vue'

import { getAnalysisData, performLinearRegression } from '@/api/analysis'
import type {
  AnalysisQueryParams,
  AnalysisDataResponse,
  RegressionResult,
  DataPoint
} from '@/types/analysis'

// 查询参数
const queryParams = ref<AnalysisQueryParams>({
  x_field: '',
  y_field: '',
  exclude_zero: true,
  enable_outlier_detection: true,
  outlier_method: 'iqr'
})

// PI膜型号列表（用于逗号分隔的字符串转换）
const piFilmModels = ref<string[]>([])
const sinteringLocations = ref<string[]>([])

// 数据状态
const loading = ref(false)
const analysisData = ref<AnalysisDataResponse | null>(null)
const regressionResult = ref<RegressionResult | null>(null)

// 计算有效数据点（用于回归分析）
const validDataPoints = computed(() => {
  if (!analysisData.value) return []
  return analysisData.value.data
    .filter(d => d.status === 'valid')
    .map(d => ({ x: d.x, y: d.y, experiment_code: d.experiment_code }))
})

/**
 * 处理数据查询
 */
const handleSearch = async () => {
  if (!queryParams.value.x_field || !queryParams.value.y_field) {
    ElMessage.warning('请选择X轴和Y轴字段')
    return
  }

  loading.value = true
  regressionResult.value = null // 清空之前的分析结果

  try {
    // 构建查询参数
    const params: AnalysisQueryParams = {
      ...queryParams.value,
      pi_film_model: piFilmModels.value.length > 0
        ? piFilmModels.value.join(',')
        : undefined,
      sintering_location: sinteringLocations.value.length > 0
        ? sinteringLocations.value.join(',')
        : undefined
    }

    // 获取数据
    const response = await getAnalysisData(params)
    analysisData.value = response

    // 检查有效数据点数量
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

/**
 * 处理数据更新（手动排除/恢复数据点）
 */
const handleDataUpdated = (updatedData: DataPoint[]) => {
  if (analysisData.value) {
    analysisData.value.data = updatedData

    // 重新计算统计信息
    const validCount = updatedData.filter(d => d.status === 'valid').length
    const excludedCount = updatedData.length - validCount

    analysisData.value.statistics.valid_count = validCount
    analysisData.value.statistics.excluded_count = excludedCount
  }
}

/**
 * 执行回归分析
 */
const handleStartAnalysis = async () => {
  if (validDataPoints.value.length < 2) {
    ElMessage.warning('至少需要2个有效数据点才能进行回归分析')
    return
  }

  loading.value = true

  try {
    // 准备数据
    const requestData = {
      data: validDataPoints.value.map(p => ({ x: p.x, y: p.y }))
    }

    // 执行回归分析
    const result = await performLinearRegression(requestData)
    regressionResult.value = result

    // 根据拟合质量显示提示
    const quality = result.quality_assessment.fit_quality
    const messages: Record<string, string> = {
      excellent: '回归分析完成！拟合效果优秀（R² ≥ 0.9）',
      good: '回归分析完成！拟合效果良好（R² ≥ 0.75）',
      fair: '回归分析完成！拟合效果一般（R² ≥ 0.5）',
      poor: '回归分析完成！拟合效果较差（R² < 0.5），建议检查数据'
    }

    ElMessage.success(messages[quality] || '回归分析完成')

    // 滚动到结果区域
    setTimeout(() => {
      document.querySelector('.result-card')?.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      })
    }, 100)
  } catch (error: any) {
    ElMessage.error(error.message || '回归分析失败')
    regressionResult.value = null
  } finally {
    loading.value = false
  }
}
</script>

<style scoped lang="scss">
.data-analysis-container {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: calc(100vh - 60px);
}

.header-card {
  margin-bottom: 20px;

  .card-header {
    h2 {
      margin: 0;
      font-size: 24px;
      color: #303133;
      display: flex;
      align-items: center;
      gap: 10px;

      .el-icon {
        font-size: 28px;
        color: #409eff;
      }
    }

    .subtitle {
      margin: 8px 0 0 0;
      font-size: 14px;
      color: #909399;
    }
  }
}

.analysis-content {
  display: grid;
  grid-template-columns: 350px 1fr;
  gap: 20px;
  align-items: start;
}

.selector-card {
  position: sticky;
  top: 20px;
}

.results-area {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  font-size: 16px;

  .el-icon {
    font-size: 18px;
    color: #409eff;
  }

  .data-count {
    margin-left: auto;
  }
}

.preview-card,
.result-card,
.chart-card {
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

// 响应式布局
@media (max-width: 1200px) {
  .analysis-content {
    grid-template-columns: 1fr;
  }

  .selector-card {
    position: static;
  }
}
</style>
