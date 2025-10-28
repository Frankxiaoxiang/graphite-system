<template>
  <div class="experiment-detail">
    <!-- 页面头部 -->
    <div class="header">
      <div class="header-left">
        <el-button @click="handleBack" :icon="ArrowLeft">返回列表</el-button>
        <h1>实验详情</h1>
      </div>
      <div class="header-actions">
        <!-- 仅草稿状态显示编辑和删除按钮 -->
        <el-button
          v-if="experimentData.status === 'draft'"
          type="warning"
          @click="handleEdit"
          :icon="Edit"
        >
          编辑
        </el-button>
        <el-button
          v-if="experimentData.status === 'draft'"
          type="danger"
          @click="handleDelete"
          :icon="Delete"
        >
          删除
        </el-button>
        <el-button type="primary" @click="handlePrint" :icon="Printer">
          打印
        </el-button>
      </div>
    </div>

    <!-- 实验编码和状态 -->
    <div class="info-card">
      <el-descriptions :column="3" border>
        <el-descriptions-item label="实验编码">
          <el-tag type="primary" size="large">
            {{ experimentData.experiment_code }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="experimentData.status === 'draft' ? 'warning' : 'success'">
            {{ experimentData.status === 'draft' ? '草稿' : '已提交' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建人">
          {{ experimentData.creator_name }}
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">
          {{ formatDateTime(experimentData.created_at) }}
        </el-descriptions-item>
        <el-descriptions-item label="提交时间">
          {{ experimentData.submitted_at ? formatDateTime(experimentData.submitted_at) : '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="最后更新">
          {{ formatDateTime(experimentData.updated_at) }}
        </el-descriptions-item>
      </el-descriptions>
    </div>

    <!-- 数据展示区域 - 7个Tab页 -->
    <div class="detail-content" v-loading="loading">
      <el-tabs v-model="activeTab" type="card">

        <!-- 1. 实验设计参数 -->
        <el-tab-pane label="实验设计参数" name="basic">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="PI膜厚度(μm)">
              {{ basicData.pi_film_thickness || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="客户类型">
              {{ basicData.customer_type || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="客户名称">
              {{ basicData.customer_name || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="PI膜型号">
              {{ basicData.pi_film_model || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="实验日期">
              {{ basicData.experiment_date || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="烧制地点">
              {{ basicData.sintering_location || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="送烧材料类型">
              {{ basicData.material_type_for_firing || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="压延方式">
              {{ basicData.rolling_method || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="实验编组">
              {{ basicData.experiment_group || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="实验目的" :span="2">
              {{ basicData.experiment_purpose || '-' }}
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 2. PI膜参数 -->
        <el-tab-pane label="PI膜参数" name="pi">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="PI膜厂商">
              {{ piData.pi_manufacturer || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="PI膜初始厚度(μm)">
              {{ piData.pi_thickness_detail || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="PI膜型号详情">
              {{ piData.pi_model_detail || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="PI重量(kg)">
              {{ piData.pi_weight || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="PI膜照片" :span="2">
              <div v-if="piData.pi_film_photo">
                <el-image
                  :src="piData.pi_film_photo"
                  fit="cover"
                  :preview-src-list="[piData.pi_film_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 3. 松卷参数 -->
        <el-tab-pane label="松卷参数" name="loose">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="松卷方式">
              {{ looseData.loose_method || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="松卷后PI膜重量(kg)">
              {{ looseData.loose_pi_weight || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="松卷后PI膜照片" :span="2">
              <div v-if="looseData.loose_pi_photo">
                <el-image
                  :src="looseData.loose_pi_photo"
                  fit="cover"
                  :preview-src-list="[looseData.loose_pi_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 4. 碳化参数 -->
        <el-tab-pane label="碳化参数" name="carbon">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="碳化炉编号">
              {{ carbonData.carbon_furnace_num || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化炉次">
              {{ carbonData.carbon_batch_num || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化最高温度(℃)">
              {{ carbonData.carbon_max_temp || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化膜厚度(μm)">
              {{ carbonData.carbon_film_thickness || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化总时长(h)">
              {{ carbonData.carbon_total_time || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化后重量(kg)">
              {{ carbonData.carbon_weight || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化成碳率(%)">
              {{ carbonData.carbon_yield_rate || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化膜照片" :span="2">
              <div v-if="carbonData.carbon_film_photo">
                <el-image
                  :src="carbonData.carbon_film_photo"
                  fit="cover"
                  :preview-src-list="[carbonData.carbon_film_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 5. 石墨化参数 -->
        <el-tab-pane label="石墨化参数" name="graphite">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="石墨炉编号">
              {{ graphiteData.graphite_furnace_num || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="气压值(MPa)">
              {{ graphiteData.pressure_value || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化最高温度(℃)">
              {{ graphiteData.graphite_max_temp || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="发泡厚度(μm)">
              {{ graphiteData.foam_thickness || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化膜厚度(μm)">
              {{ graphiteData.graphite_film_thickness || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化总时长(h)">
              {{ graphiteData.graphite_total_time || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化后重量(kg)">
              {{ graphiteData.graphite_weight || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化成碳率(%)">
              {{ graphiteData.graphite_yield_rate || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化减重率(%)">
              {{ graphiteData.graphite_weight_loss_rate || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化膜照片" :span="2">
              <div v-if="graphiteData.graphite_film_photo">
                <el-image
                  :src="graphiteData.graphite_film_photo"
                  fit="cover"
                  :preview-src-list="[graphiteData.graphite_film_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 6. 压延参数 -->
        <el-tab-pane label="压延参数" name="rolling">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="压延温度(℃)">
              {{ rollingData.rolling_temperature || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="压延次数">
              {{ rollingData.rolling_times || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="压延机速度(m/min)">
              {{ rollingData.rolling_speed || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="压延后石墨膜厚度(μm)">
              {{ rollingData.rolling_film_thickness || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="压延减薄率(%)">
              {{ rollingData.rolling_thinning_rate || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="压延后石墨膜照片" :span="2">
              <div v-if="rollingData.rolling_film_photo">
                <el-image
                  :src="rollingData.rolling_film_photo"
                  fit="cover"
                  :preview-src-list="[rollingData.rolling_film_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 7. 成品参数 -->
        <el-tab-pane label="成品参数" name="product">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="成品密度(g/cm³)">
              {{ productData.product_density || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="成品石墨膜厚度(μm)">
              {{ productData.product_film_thickness || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="成品导热系数(W/m·K)">
              {{ productData.thermal_conductivity || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="成品热扩散系数(cm²/s)">
              {{ productData.thermal_diffusivity || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="成品电阻率(μΩ·cm)">
              {{ productData.electrical_resistivity || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="成品拉伸强度(MPa)">
              {{ productData.tensile_strength || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="成品杨氏模量(GPa)">
              {{ productData.youngs_modulus || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="成品断裂伸长率(%)">
              {{ productData.elongation_at_break || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="成品XRD分析结果">
              {{ productData.xrd_analysis || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="成品Raman光谱分析结果">
              {{ productData.raman_analysis || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="成品照片" :span="2">
              <div v-if="productData.product_photo">
                <el-image
                  :src="productData.product_photo"
                  fit="cover"
                  :preview-src-list="[productData.product_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
            <el-descriptions-item label="成品测试报告" :span="2">
              <el-link v-if="productData.product_test_report" type="primary" :href="productData.product_test_report" target="_blank">
                查看报告
              </el-link>
              <span v-else>-</span>
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft, Edit, Delete, Printer } from '@element-plus/icons-vue'
import { experimentApi } from '@/api/experiments'

const router = useRouter()
const route = useRoute()

// 状态
const loading = ref(false)
const activeTab = ref('basic')
const experimentId = ref<number>(0)

// 实验数据
const experimentData = reactive<any>({
  experiment_code: '',
  status: '',
  creator_name: '',
  created_at: '',
  submitted_at: null,
  updated_at: ''
})

// 各模块数据
const basicData = reactive<any>({})
const piData = reactive<any>({})
const looseData = reactive<any>({})
const carbonData = reactive<any>({})
const graphiteData = reactive<any>({})
const rollingData = reactive<any>({})
const productData = reactive<any>({})

/**
 * 加载实验详情
 */
async function loadExperimentDetail() {
  loading.value = true
  try {
    const id = Number(route.params.id)
    if (!id) {
      ElMessage.error('无效的实验ID')
      router.push('/experiments/database')
      return
    }

    experimentId.value = id
    const response = await experimentApi.getExperimentDetail(id)

    // 填充实验基本信息
    Object.assign(experimentData, response.data.experiment)

    // 填充各模块数据
    Object.assign(basicData, response.data.basic || {})
    Object.assign(piData, response.data.pi || {})
    Object.assign(looseData, response.data.loose || {})
    Object.assign(carbonData, response.data.carbon || {})
    Object.assign(graphiteData, response.data.graphite || {})
    Object.assign(rollingData, response.data.rolling || {})
    Object.assign(productData, response.data.product || {})

  } catch (error: any) {
    console.error('加载实验详情失败:', error)
    ElMessage.error(error.message || '加载实验详情失败')
  } finally {
    loading.value = false
  }
}

/**
 * 返回列表
 */
function handleBack() {
  router.push('/experiments/database')
}

/**
 * 编辑实验
 */
function handleEdit() {
  router.push(`/experiments/edit/${experimentId.value}`)
}

/**
 * 删除实验
 */
async function handleDelete() {
  try {
    await ElMessageBox.confirm(
      `确定要删除实验 "${experimentData.experiment_code}" 吗？删除后无法恢复。`,
      '确认删除',
      {
        confirmButtonText: '确定删除',
        cancelButtonText: '取消',
        type: 'warning',
        distinguishCancelAndClose: true
      }
    )

    loading.value = true
    await experimentApi.deleteExperiment(experimentId.value)
    ElMessage.success('删除成功')

    // 跳转到列表页
    router.push('/experiments/database')

  } catch (error: any) {
    if (error !== 'cancel' && error !== 'close') {
      console.error('删除实验失败:', error)
      ElMessage.error(error.message || '删除实验失败')
    }
  } finally {
    loading.value = false
  }
}

/**
 * 打印
 */
function handlePrint() {
  window.print()
}

/**
 * 格式化日期时间
 */
function formatDateTime(datetime: string): string {
  if (!datetime) return '-'
  const date = new Date(datetime)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 页面加载时获取数据
onMounted(() => {
  loadExperimentDetail()
})
</script>

<style scoped>
.experiment-detail {
  min-height: 100vh;
  background: #f5f7fa;
  padding-bottom: 40px;
}

.header {
  background: white;
  padding: 20px 40px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 20px;
}

.header-left h1 {
  margin: 0;
  color: #2c3e50;
  font-size: 24px;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.info-card {
  background: white;
  padding: 20px 40px;
  margin: 0 40px 20px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.detail-content {
  background: white;
  padding: 20px 40px;
  margin: 0 40px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.detail-section {
  margin-top: 20px;
}

/* 打印样式 */
@media print {
  .header-actions,
  .el-tabs__nav {
    display: none !important;
  }

  .detail-content {
    box-shadow: none;
  }
}
</style>
