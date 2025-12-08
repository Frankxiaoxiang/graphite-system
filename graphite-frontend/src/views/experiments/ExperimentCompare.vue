<template>
  <div class="compare-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2>实验数据对比</h2>
      <el-button 
        v-if="comparisonData" 
        type="primary" 
        @click="handleExport"
      >
        <el-icon><Download /></el-icon>
        导出对比报告
      </el-button>
    </div>

    <!-- 实验选择卡片 -->
    <el-card class="selection-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <span>选择要对比的实验（2-10个）</span>
          <el-button 
            type="primary" 
            size="small" 
            :disabled="selectedExperiments.length >= MAX_EXPERIMENTS"
            @click="addExperiment"
          >
            <el-icon><Plus /></el-icon>
            添加实验
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
            class="experiment-select"
            placeholder="点击选择或输入搜索实验"
            filterable
            remote
            clearable
            :remote-method="searchExperiments"
            :loading="searching"
            @change="handleExperimentChange"
            @focus="handleSelectFocus"
          >
            <el-option
              v-for="exp in experimentOptions"
              :key="exp.id"
              :label="`${exp.experiment_code} - ${exp.customer_name || ''}`"
              :value="exp.id"
              :disabled="selectedExperiments.filter(id => id !== null).includes(exp.id)"
            >
              <div class="experiment-option">
                <div class="exp-code">{{ exp.experiment_code }}</div>
                <div class="exp-info">
                  {{ exp.customer_name }} | {{ exp.pi_film_thickness }}μm | {{ exp.experiment_date }}
                </div>
              </div>
            </el-option>
          </el-select>
          <el-button 
            v-if="selectedExperiments.length > MIN_EXPERIMENTS"
            type="danger" 
            circle 
            @click="removeExperiment(index)"
          >
            <el-icon><Close /></el-icon>
          </el-button>
        </div>
      </div>

      <div class="action-buttons">
        <el-button 
          type="primary" 
          size="large"
          :disabled="validExperimentCount < MIN_EXPERIMENTS"
          :loading="comparing"
          @click="handleCompare"
        >
          <el-icon><TrendCharts /></el-icon>
          开始对比（已选 {{ validExperimentCount }} 个）
        </el-button>
        <el-button 
          size="large"
          @click="handleReset"
        >
          <el-icon><RefreshLeft /></el-icon>
          重置
        </el-button>
      </div>
    </el-card>

    <!-- 对比结果卡片 -->
    <el-card 
      v-if="comparisonData" 
      class="comparison-card" 
      shadow="hover"
    >
      <template #header>
        <div class="card-header">
          <span>对比结果</span>
          <div class="legend">
            <span class="legend-item">
              <span class="legend-color max"></span>
              最大值（橙色）
            </span>
            <span class="legend-item">
              <span class="legend-color min"></span>
              最小值（绿色）
            </span>
          </div>
        </div>
      </template>

      <!-- 对比表格 -->
      <el-table 
        :data="comparisonTableData" 
        border
        :row-class-name="getRowClassName"
        max-height="600"
      >
        <!-- 字段名列 -->
        <el-table-column 
          prop="fieldName" 
          label="参数名称" 
          width="200" 
          fixed="left"
        >
          <template #default="{ row }">
            <div class="field-name-cell">
              <strong>{{ row.fieldName }}</strong>
              <span v-if="row.unit" class="unit">（{{ row.unit }}）</span>
            </div>
          </template>
        </el-table-column>

        <!-- 动态实验列 -->
        <el-table-column
          v-for="(exp, index) in comparisonData.experiments"
          :key="exp.id"
          :label="`实验 ${index + 1}`"
          align="center"
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
              <span v-if="row.unit && row[`value${index}`] !== '-'" class="unit">{{ row.unit }}</span>
            </div>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 空状态 -->
    <el-empty 
      v-if="!comparisonData && !comparing"
      description="请选择2个或更多实验进行对比"
      :image-size="200"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Download, Plus, Close, TrendCharts, RefreshLeft } from '@element-plus/icons-vue'
import { debounce } from 'lodash-es'
import * as compareApi from '@/api/compare'
import type { Experiment, ComparisonData, ComparisonField } from '@/api/compare'

// 常量定义
const MIN_EXPERIMENTS = 2
const MAX_EXPERIMENTS = 10

// 响应式数据
const selectedExperiments = ref<(number | null)[]>([null, null])
const experimentOptions = ref<Experiment[]>([])
const comparisonData = ref<ComparisonData | null>(null)
const searching = ref(false)
const comparing = ref(false)

// 计算有效的实验数量
const validExperimentCount = computed(() => {
  return selectedExperiments.value.filter(id => id !== null).length
})

// 加载初始实验列表
async function loadInitialExperiments() {
  if (searching.value) return // 防止重复请求
  
  searching.value = true
  try {
    const response = await compareApi.getExperimentsForCompare({
      page: 1,
      page_size: 20,
      status: 'submitted'
    })
    
    // 直接使用返回的experiments数组
    experimentOptions.value = response.experiments || []
    
    console.log('✅ 加载实验列表成功:', experimentOptions.value.length, '条')
  } catch (error: any) {
    console.error('❌ 加载实验列表失败:', error)
    ElMessage.error(error.message || '加载实验列表失败')
  } finally {
    searching.value = false
  }
}

// 搜索实验（带防抖）
const searchExperimentsDebounced = debounce(async (query: string) => {
  if (!query || query.length < 2) {
    // 如果查询为空或太短，加载初始列表
    await loadInitialExperiments()
    return
  }
  
  searching.value = true
  try {
    const response = await compareApi.getExperimentsForCompare({
      search: query,
      page: 1,
      page_size: 20,
      status: 'submitted'
    })
    
    // 直接使用返回的experiments数组
    experimentOptions.value = response.experiments || []
    
    console.log('✅ 搜索实验成功:', experimentOptions.value.length, '条')
  } catch (error: any) {
    console.error('❌ 搜索实验失败:', error)
    ElMessage.error(error.message || '搜索实验失败')
  } finally {
    searching.value = false
  }
}, 300)

// 搜索实验
function searchExperiments(query: string) {
  searchExperimentsDebounced(query)
}

// 处理下拉框聚焦 - 关键修复！
function handleSelectFocus() {
  // 如果还没有加载数据，或者数据为空，立即加载
  if (experimentOptions.value.length === 0 && !searching.value) {
    console.log('🔍 下拉框聚焦，加载实验列表...')
    loadInitialExperiments()
  }
}

// 组件挂载时加载初始数据
onMounted(() => {
  console.log('🚀 ExperimentCompare 组件挂载，开始加载数据...')
  loadInitialExperiments()
})

// 添加实验选择器
function addExperiment() {
  if (selectedExperiments.value.length < MAX_EXPERIMENTS) {
    selectedExperiments.value.push(null)
  }
}

// 移除实验选择器
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
  
  if (validIds.length < MIN_EXPERIMENTS) {
    ElMessage.warning(`请至少选择${MIN_EXPERIMENTS}个实验进行对比`)
    return
  }
  
  if (validIds.length > MAX_EXPERIMENTS) {
    ElMessage.warning(`最多只能同时对比${MAX_EXPERIMENTS}个实验`)
    return
  }
  
  comparing.value = true
  try {
    const response = await compareApi.compareExperiments({ 
      experiment_ids: validIds 
    })
    comparisonData.value = response
    ElMessage.success('对比成功！')
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
  // 不清空 experimentOptions，保持已加载的列表
}

// 导出报告（预留）
function handleExport() {
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
    
    // 如果是数值字段，计算最大最小值并标记
    if (field.type === 'number') {
      const numericValues = values
        .map(v => v !== null && v !== '' ? Number(v) : null)
        .filter(v => v !== null) as number[]
      
      if (numericValues.length > 1) {
        const maxValue = Math.max(...numericValues)
        const minValue = Math.min(...numericValues)
        
        values.forEach((v, i) => {
          if (v !== null && v !== '') {
            const numValue = Number(v)
            if (numValue === maxValue) {
              row[`highlight${i}`] = 'max-value'
            } else if (numValue === minValue) {
              row[`highlight${i}`] = 'min-value'
            }
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

// 获取行类名（用于分类分隔线）
function getRowClassName({ row, rowIndex }: any) {
  if (rowIndex === 0) return ''
  return row.category !== comparisonTableData.value[rowIndex - 1]?.category
    ? 'category-divider'
    : ''
}
</script>

<style scoped>
.compare-container {
  padding: 24px;
  background-color: #f5f7fa;
  min-height: calc(100vh - 60px);
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-header h2 {
  margin: 0;
  font-size: 28px;
  font-weight: 600;
  color: #303133;
}

.selection-card {
  margin-bottom: 24px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
  font-size: 16px;
}

.experiment-selectors {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 24px;
}

.selector-item {
  display: flex;
  gap: 12px;
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

.experiment-option {
  padding: 4px 0;
}

.experiment-option .exp-code {
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.experiment-option .exp-info {
  font-size: 12px;
  color: #909399;
}

.action-buttons {
  display: flex;
  justify-content: center;
  gap: 16px;
  padding-top: 24px;
  border-top: 1px solid #ebeef5;
}

.comparison-card {
  margin-top: 24px;
}

.legend {
  display: flex;
  gap: 24px;
  font-size: 14px;
  font-weight: normal;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.legend-color {
  width: 24px;
  height: 16px;
  border-radius: 4px;
}

.legend-color.max {
  background-color: #FFF3E0;
  border: 1px solid #FF6F00;
}

.legend-color.min {
  background-color: #E8F5E9;
  border: 1px solid #2E7D32;
}

.experiment-header {
  text-align: center;
  padding: 4px 0;
}

.exp-code {
  font-weight: 600;
  font-size: 13px;
  color: #303133;
  margin-bottom: 4px;
}

.exp-date {
  font-size: 12px;
  color: #909399;
}

.field-name-cell {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.field-name-cell strong {
  color: #303133;
}

.cell-content {
  padding: 8px;
  border-radius: 4px;
  transition: all 0.3s;
  font-weight: 500;
}

.cell-content.max-value {
  background-color: #FFF3E0;
  color: #FF6F00;
  font-weight: 700;
}

.cell-content.min-value {
  background-color: #E8F5E9;
  color: #2E7D32;
  font-weight: 700;
}

.unit {
  margin-left: 4px;
  color: #909399;
  font-size: 12px;
  font-weight: normal;
}

/* 分类分隔线 */
:deep(.category-divider) {
  border-top: 2px solid #409eff;
}

:deep(.el-table th) {
  background-color: #f5f7fa;
  font-weight: 600;
}

:deep(.el-table) {
  font-size: 14px;
}

:deep(.el-table td) {
  padding: 12px 0;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .compare-container {
    padding: 16px;
  }
  
  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .selector-item {
    flex-direction: column;
    align-items: stretch;
  }
  
  .selector-label {
    min-width: auto;
  }
}
</style>
