<template>
  <div class="compare-container">
    <!-- 页面头部 - 添加返回按钮 -->
    <div class="page-header">
      <div class="header-left">
        <el-button 
          type="default" 
          :icon="ArrowLeft" 
          @click="handleBackToHome"
          class="back-button"
        >
          返回主页
        </el-button>
        <h2>实验数据对比</h2>
      </div>
      <div class="header-right">
        <el-button 
          type="success" 
          :icon="Download" 
          @click="handleExport"
          :disabled="!comparisonData"
        >
          导出报告
        </el-button>
      </div>
    </div>

    <!-- 选择实验卡片 -->
    <el-card class="selection-card">
      <template #header>
        <div class="card-header">
          <span>选择要对比的实验（2-10个）</span>
          <el-button 
            type="primary" 
            size="small" 
            @click="addExperiment"
            :disabled="selectedExperiments.length >= 10"
          >
            + 添加实验
          </el-button>
        </div>
      </template>

      <div class="experiment-selectors">
        <div 
          v-for="(expId, index) in selectedExperiments" 
          :key="index"
          class="selector-item"
        >
          <span class="selector-label">实验 {{ index + 1 }}:</span>
          <el-select
            v-model="selectedExperiments[index]"
            placeholder="请选择实验"
            filterable
            remote
            :remote-method="searchExperiments"
            :loading="searching"
            @change="handleExperimentChange"
            @focus="handleSelectFocus"
            class="experiment-select"
          >
            <el-option
              v-for="exp in experimentOptions"
              :key="exp.id"
              :label="`${exp.experiment_code} - ${exp.customer_name || '无客户'}`"
              :value="exp.id"
            />
          </el-select>
          <el-button 
            v-if="selectedExperiments.length > 2"
            type="danger" 
            :icon="Delete" 
            circle 
            @click="removeExperiment(index)"
          />
        </div>
      </div>

      <div class="action-buttons">
        <el-button 
          type="primary" 
          :icon="Check" 
          @click="handleCompare"
          :loading="comparing"
          :disabled="validSelectedCount < 2"
        >
          开始对比 ({{ validSelectedCount }}个)
        </el-button>
        <el-button 
          :icon="RefreshLeft" 
          @click="handleReset"
        >
          重置
        </el-button>
      </div>
    </el-card>

    <!-- 对比结果表格 -->
    <el-card v-if="comparisonData" class="comparison-card">
      <template #header>
        <div class="card-header">
          <span>对比结果</span>
          <el-radio-group v-model="viewMode" size="small">
            <el-radio-button label="table">表格视图</el-radio-button>
            <el-radio-button label="chart">图表视图</el-radio-button>
          </el-radio-group>
        </div>
      </template>

      <!-- 表格视图 -->
      <el-table
        v-if="viewMode === 'table'"
        :data="comparisonTableData"
        border
        stripe
        :row-class-name="getRowClassName"
        style="width: 100%"
        max-height="600"
      >
        <!-- 字段名称列 -->
        <el-table-column 
          prop="fieldName" 
          label="参数名称" 
          width="180" 
          fixed
        />

        <!-- 动态生成实验列 -->
        <el-table-column
          v-for="(exp, index) in comparisonData.experiments"
          :key="exp.id"
          :label="`实验 ${index + 1}`"
          min-width="150"
        >
          <template #header>
            <div class="experiment-header">
              <div class="exp-code">{{ exp.code }}</div>
              <div class="exp-date">{{ formatDate(exp.created_at) }}</div>
            </div>
          </template>
          <template #default="{ row }">
            <div 
              class="cell-content"
              :class="row[`highlight${index}`]"
            >
              {{ row[`value${index}`] }}
              <span v-if="row.unit" class="unit">{{ row.unit }}</span>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <!-- 图表视图 -->
      <div v-else class="chart-view">
        <el-empty description="图表视图开发中..." />
      </div>
    </el-card>

    <!-- 空状态提示 -->
    <el-empty 
      v-if="!comparisonData"
      description="请选择至少2个实验进行对比"
      :image-size="200"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  ArrowLeft, Download, Delete, Check, RefreshLeft 
} from '@element-plus/icons-vue'
import { getExperimentsForCompare, compareExperiments } from '@/api/compare'
import type { Experiment, ComparisonResult } from '@/types/experiment'

const router = useRouter()

// 状态变量
const selectedExperiments = ref<(number | null)[]>([null, null])
const experimentOptions = ref<Experiment[]>([])
const searching = ref(false)
const comparing = ref(false)
const comparisonData = ref<ComparisonResult | null>(null)
const viewMode = ref('table')

// 计算有效选择数量
const validSelectedCount = computed(() => {
  return selectedExperiments.value.filter(id => id !== null).length
})

// 🆕 返回主页
function handleBackToHome() {
  router.push('/')
}

// 组件挂载时加载初始数据
onMounted(() => {
  console.log('🚀 ExperimentCompare 组件挂载，开始加载数据...')
  loadInitialExperiments()
})

// 🆕 下拉框获得焦点时加载数据
function handleSelectFocus() {
  if (experimentOptions.value.length === 0 && !searching.value) {
    loadInitialExperiments()
  }
}

// 🆕 加载初始实验列表
async function loadInitialExperiments() {
  searching.value = true
  try {
    const response = await getExperimentsForCompare({
      page: 1,
      page_size: 20,
      status: 'submitted'
    })
    
    experimentOptions.value = response.experiments || []
    console.log(`✅ 加载实验列表成功: ${experimentOptions.value.length} 条`)
  } catch (error: any) {
    console.error('❌ 加载实验列表失败:', error)
    ElMessage.error(error.message || '加载实验列表失败')
  } finally {
    searching.value = false
  }
}

// 搜索实验
async function searchExperiments(query: string) {
  if (query.length < 2) return
  
  searching.value = true
  try {
    const response = await getExperimentsForCompare({
      search: query,
      page: 1,
      page_size: 20,
      status: 'submitted'
    })
    experimentOptions.value = response.experiments || []
  } catch (error: any) {
    ElMessage.error(error.message || '搜索实验失败')
  } finally {
    searching.value = false
  }
}

// 添加实验
function addExperiment() {
  if (selectedExperiments.value.length < 10) {
    selectedExperiments.value.push(null)
  }
}

// 移除实验
function removeExperiment(index: number) {
  selectedExperiments.value.splice(index, 1)
}

// 实验选择变化
function handleExperimentChange() {
  // 清空之前的对比结果
  comparisonData.value = null
}

// 开始对比
async function handleCompare() {
  // 过滤掉null值
  const validIds = selectedExperiments.value.filter(id => id !== null) as number[]
  
  if (validIds.length < 2) {
    ElMessage.warning('请至少选择2个实验进行对比')
    return
  }
  
  comparing.value = true
  try {
    const response = await compareExperiments({ experiment_ids: validIds })
    comparisonData.value = response
    ElMessage.success('对比成功')
  } catch (error: any) {
    console.error('对比失败:', error)
    ElMessage.error(error.message || '对比失败')
  } finally {
    comparing.value = false
  }
}

// 重置
function handleReset() {
  selectedExperiments.value = [null, null]
  comparisonData.value = null
  experimentOptions.value = []
}

// 导出报告
async function handleExport() {
  if (!comparisonData.value) {
    ElMessage.warning('请先进行对比')
    return
  }
  
  // TODO: 实现导出功能
  ElMessage.info('导出功能开发中...')
}

// 格式化日期
function formatDate(date: string) {
  if (!date) return ''
  return new Date(date).toLocaleDateString('zh-CN')
}

// 计算对比表格数据
const comparisonTableData = computed(() => {
  if (!comparisonData.value) return []
  
  const { experiments, fields } = comparisonData.value
  const rows: any[] = []
  
  fields.forEach((field: any) => {
    const row: any = {
      category: field.category,
      fieldName: field.name,
      unit: field.unit
    }
    
    // 获取每个实验的值
    const values: (number | string | null)[] = experiments.map((exp: any) => {
      return getNestedValue(exp, field.key)
    })
    
    // 如果是数值字段，计算最大最小值
    if (field.type === 'number') {
      const numericValues = values.map(v => 
        v !== null && v !== '' ? Number(v) : null
      ).filter(v => v !== null) as number[]
      
      if (numericValues.length > 0) {
        const maxValue = Math.max(...numericValues)
        const minValue = Math.min(...numericValues)
        
        values.forEach((v, i) => {
          if (v !== null && Number(v) === maxValue) {
            row[`highlight${i}`] = 'max-value'
          } else if (v !== null && Number(v) === minValue) {
            row[`highlight${i}`] = 'min-value'
          }
        })
      }
    }
    
    // 设置每列的值
    values.forEach((v, i) => {
      row[`value${i}`] = v !== null && v !== '' ? v : '-'
    })
    
    rows.push(row)
  })
  
  return rows
})

// 获取嵌套对象的值
function getNestedValue(obj: any, path: string) {
  return path.split('.').reduce((current, key) => current?.[key], obj)
}

// 获取行类名
function getRowClassName({ row, rowIndex }: any) {
  return row.category !== comparisonTableData.value[rowIndex - 1]?.category
    ? 'category-divider'
    : ''
}
</script>

<style scoped>
.compare-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
}

.back-button {
  /* 让返回按钮稍微突出一点 */
  border: 1px solid #dcdfe6;
}

.back-button:hover {
  color: #409eff;
  border-color: #409eff;
}

.header-right {
  display: flex;
  gap: 10px;
}

.page-header h2 {
  margin: 0;
  font-size: 24px;
  color: #333;
}

.selection-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.experiment-selectors {
  display: flex;
  flex-direction: column;
  gap: 15px;
  margin-bottom: 20px;
}

.selector-item {
  display: flex;
  gap: 10px;
  align-items: center;
}

.selector-label {
  min-width: 70px;
  font-weight: 500;
  color: #606266;
}

.experiment-select {
  flex: 1;
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 15px;
  padding-top: 20px;
  border-top: 1px solid #eee;
}

.comparison-card {
  margin-top: 20px;
}

.experiment-header {
  text-align: center;
}

.exp-code {
  font-weight: bold;
  font-size: 14px;
  margin-bottom: 4px;
}

.exp-date {
  font-size: 12px;
  color: #999;
}

.cell-content {
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.3s;
}

.cell-content.max-value {
  background-color: #FFF3E0;
  color: #FF6F00;
  font-weight: bold;
}

.cell-content.min-value {
  background-color: #E8F5E9;
  color: #2E7D32;
  font-weight: bold;
}

.unit {
  margin-left: 4px;
  color: #999;
  font-size: 12px;
}

:deep(.category-divider) {
  border-top: 2px solid #409eff;
}

:deep(.el-table th) {
  background-color: #f5f7fa;
}

.chart-view {
  min-height: 400px;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
