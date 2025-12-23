<template>
  <div class="analysis-result">
    <!-- 回归方程 -->
    <div class="equation-card">
      <div class="equation-title">回归方程</div>
      <div class="equation-content">
        {{ result.equation }}
      </div>
    </div>

    <!-- 统计指标 -->
    <el-row :gutter="20" class="metrics-row">
      <!-- R² 值 -->
      <el-col :span="8">
        <div class="metric-card">
          <div class="metric-label">决定系数 (R²)</div>
          <div class="metric-value" :class="getRSquaredClass(result.r_squared)">
            {{ result.r_squared.toFixed(4) }}
          </div>
          <div class="metric-desc">
            {{ getRSquaredDesc(result.r_squared) }}
          </div>
        </div>
      </el-col>

      <!-- p值 -->
      <el-col :span="8">
        <div class="metric-card">
          <div class="metric-label">显著性 (p值)</div>
          <div class="metric-value" :class="getPValueClass(result.p_value)">
            {{ formatPValue(result.p_value) }}
          </div>
          <div class="metric-desc">
            {{ getPValueDesc(result.p_value) }}
          </div>
        </div>
      </el-col>

      <!-- 数据点数 -->
      <el-col :span="8">
        <div class="metric-card">
          <div class="metric-label">数据点数 (n)</div>
          <div class="metric-value">
            {{ result.n }}
          </div>
          <div class="metric-desc">
            样本量充足
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 回归系数 -->
    <el-row :gutter="20" class="metrics-row">
      <el-col :span="8">
        <div class="metric-card secondary">
          <div class="metric-label">斜率 (slope)</div>
          <div class="metric-value small">
            {{ result.slope.toFixed(4) }}
          </div>
        </div>
      </el-col>

      <el-col :span="8">
        <div class="metric-card secondary">
          <div class="metric-label">截距 (intercept)</div>
          <div class="metric-value small">
            {{ result.intercept.toFixed(4) }}
          </div>
        </div>
      </el-col>

      <el-col :span="8">
        <div class="metric-card secondary">
          <div class="metric-label">标准误差</div>
          <div class="metric-value small">
            {{ result.std_err.toFixed(4) }}
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 质量评估 -->
    <el-alert
      :title="getQualityAssessmentTitle()"
      :type="getQualityAssessmentType()"
      :closable="false"
      show-icon
      class="assessment-alert"
    >
      <div class="assessment-content">
        <p>{{ getQualityAssessmentText() }}</p>
        <p v-if="metadata" class="interpretation">
          <strong>结果解读:</strong> 
          {{ getInterpretation() }}
        </p>
      </div>
    </el-alert>

    <!-- 导出按钮 -->
    <div class="export-actions">
      <el-button @click="handleCopyEquation">
        <el-icon><CopyDocument /></el-icon>
        复制方程
      </el-button>
      <el-button @click="handleExportData">
        <el-icon><Download /></el-icon>
        导出数据
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ElMessage } from 'element-plus'
import { CopyDocument, Download } from '@element-plus/icons-vue'
import type { RegressionResult, FieldMetadata } from '@/types/analysis'

// Props
interface Props {
  result: RegressionResult
  metadata?: FieldMetadata
}

const props = defineProps<Props>()

// R²值评估
const getRSquaredClass = (r2: number): string => {
  if (r2 >= 0.9) return 'excellent'
  if (r2 >= 0.75) return 'good'
  if (r2 >= 0.5) return 'fair'
  return 'poor'
}

const getRSquaredDesc = (r2: number): string => {
  if (r2 >= 0.9) return '拟合优秀'
  if (r2 >= 0.75) return '拟合良好'
  if (r2 >= 0.5) return '拟合一般'
  return '拟合较差'
}

// p值评估
const getPValueClass = (p: number): string => {
  if (p < 0.001) return 'excellent'
  if (p < 0.05) return 'good'
  return 'poor'
}

const getPValueDesc = (p: number): string => {
  if (p < 0.001) return '高度显著'
  if (p < 0.05) return '显著'
  return '不显著'
}

// 格式化p值
const formatPValue = (p: number): string => {
  if (p < 0.0001) return '< 0.0001'
  return p.toFixed(4)
}

// 质量评估标题
const getQualityAssessmentTitle = (): string => {
  const quality = props.result.quality_assessment.fit_quality
  const titles: Record<string, string> = {
    excellent: '✅ 回归分析结果优秀',
    good: '✅ 回归分析结果良好',
    fair: '⚠️ 回归分析结果一般',
    poor: '❌ 回归分析结果较差'
  }
  return titles[quality] || '分析完成'
}

// 质量评估类型
const getQualityAssessmentType = () => {
  const quality = props.result.quality_assessment.fit_quality
  const types: Record<string, 'success' | 'warning' | 'error'> = {
    excellent: 'success',
    good: 'success',
    fair: 'warning',
    poor: 'error'
  }
  return types[quality] || 'info'
}

// 质量评估文本
const getQualityAssessmentText = (): string => {
  const { fit_quality, significance } = props.result.quality_assessment
  const { r_squared, p_value } = props.result
  
  let text = ''
  
  // 拟合质量
  if (fit_quality === 'excellent') {
    text = `模型拟合度非常高（R² = ${(r_squared * 100).toFixed(1)}%），`
  } else if (fit_quality === 'good') {
    text = `模型拟合度良好（R² = ${(r_squared * 100).toFixed(1)}%），`
  } else if (fit_quality === 'fair') {
    text = `模型拟合度一般（R² = ${(r_squared * 100).toFixed(1)}%），`
  } else {
    text = `模型拟合度较差（R² = ${(r_squared * 100).toFixed(1)}%），`
  }
  
  // 显著性
  if (significance === 'highly_significant') {
    text += `回归关系高度显著（p < 0.001）。`
  } else if (significance === 'moderately_significant') {
    text += `回归关系显著（p < 0.05）。`
  } else {
    text += `回归关系不显著（p ≥ 0.05），结果可能不可靠。`
  }
  
  return text
}

// 结果解读
const getInterpretation = (): string => {
  if (!props.metadata) return ''
  
  const { x_label, y_label } = props.metadata
  const { slope, r_squared } = props.result
  
  let interpretation = ''
  
  if (slope > 0) {
    interpretation = `${x_label}每增加1个单位，${y_label}平均增加${Math.abs(slope).toFixed(2)}个单位。`
  } else {
    interpretation = `${x_label}每增加1个单位，${y_label}平均减少${Math.abs(slope).toFixed(2)}个单位。`
  }
  
  const variance = (r_squared * 100).toFixed(1)
  interpretation += ` 模型可以解释${variance}%的${y_label}变化。`
  
  return interpretation
}

// 复制方程
const handleCopyEquation = async () => {
  try {
    await navigator.clipboard.writeText(props.result.equation)
    ElMessage.success('方程已复制到剪贴板')
  } catch (error) {
    ElMessage.error('复制失败')
  }
}

// 导出数据
const handleExportData = () => {
  // 构建导出内容
  const content = [
    '=== 回归分析结果 ===',
    '',
    `回归方程: ${props.result.equation}`,
    `决定系数 (R²): ${props.result.r_squared.toFixed(4)}`,
    `p值: ${formatPValue(props.result.p_value)}`,
    `斜率: ${props.result.slope.toFixed(4)}`,
    `截距: ${props.result.intercept.toFixed(4)}`,
    `标准误差: ${props.result.std_err.toFixed(4)}`,
    `数据点数: ${props.result.n}`,
    '',
    `拟合质量: ${getRSquaredDesc(props.result.r_squared)}`,
    `显著性: ${getPValueDesc(props.result.p_value)}`,
    '',
    '=== 预测值 ===',
    'X,Y',
    ...props.result.predictions.map(p => `${p.x.toFixed(2)},${p.y.toFixed(2)}`)
  ].join('\n')
  
  // 创建下载
  const blob = new Blob([content], { type: 'text/plain;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `regression_result_${Date.now()}.txt`
  link.click()
  URL.revokeObjectURL(url)
  
  ElMessage.success('分析结果已导出')
}
</script>

<style scoped lang="scss">
.analysis-result {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.equation-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30px;
  border-radius: 12px;
  color: white;
  text-align: center;

  .equation-title {
    font-size: 14px;
    opacity: 0.9;
    margin-bottom: 10px;
  }

  .equation-content {
    font-size: 28px;
    font-weight: 600;
    font-family: 'Courier New', monospace;
  }
}

.metrics-row {
  margin-bottom: 0;
}

.metric-card {
  background: white;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  padding: 20px;
  text-align: center;
  transition: all 0.3s;

  &:hover {
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  }

  &.secondary {
    background: #f5f7fa;
    border: none;
  }

  .metric-label {
    font-size: 14px;
    color: #909399;
    margin-bottom: 10px;
  }

  .metric-value {
    font-size: 32px;
    font-weight: 600;
    color: #303133;
    margin-bottom: 8px;

    &.small {
      font-size: 24px;
    }

    &.excellent {
      color: #67c23a;
    }

    &.good {
      color: #409eff;
    }

    &.fair {
      color: #e6a23c;
    }

    &.poor {
      color: #f56c6c;
    }
  }

  .metric-desc {
    font-size: 12px;
    color: #909399;
  }
}

.assessment-alert {
  .assessment-content {
    font-size: 14px;
    line-height: 1.8;

    p {
      margin: 0 0 10px 0;

      &:last-child {
        margin-bottom: 0;
      }
    }

    .interpretation {
      color: #606266;
      padding-left: 10px;
      border-left: 3px solid #409eff;
    }
  }
}

.export-actions {
  display: flex;
  justify-content: center;
  gap: 15px;
  padding-top: 10px;
}
</style>
