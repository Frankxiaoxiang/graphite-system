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
            <el-descriptions-item label="PI膜厚度(μm)">
              {{ piData.pi_thickness_detail || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="PI膜型号">
              {{ piData.pi_model_detail || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="PI膜宽幅(mm)">
              {{ piData.pi_width || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="批次号">
              {{ piData.batch_number || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="PI重量(kg)">
              {{ piData.pi_weight || '-' }}
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 3. 松卷参数 -->
        <el-tab-pane label="松卷参数" name="loose">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="卷芯筒类型">
              {{ looseData.core_tube_type || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="松卷间隙卷内(μm)">
              {{ looseData.loose_gap_inner || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="松卷间隙卷中(μm)">
              {{ looseData.loose_gap_middle || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="松卷间隙卷外(μm)">
              {{ looseData.loose_gap_outer || '-' }}
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 4. 碳化参数 -->
        <el-tab-pane label="碳化参数" name="carbon">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="碳化炉编号">
              {{ carbonData.carbon_furnace_number || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化炉次">
              {{ carbonData.carbon_furnace_batch || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="舟模型">
              {{ carbonData.boat_model || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="包覆方式">
              {{ carbonData.wrapping_method || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="真空度">
              {{ carbonData.vacuum_degree || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="功率消耗">
              {{ carbonData.power_consumption || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="开始时间">
              {{ formatDateTime(carbonData.start_time) }}
            </el-descriptions-item>
            <el-descriptions-item label="结束时间">
              {{ formatDateTime(carbonData.end_time) }}
            </el-descriptions-item>

          <!-- ✅ 新增：碳化温度/厚度字段 -->
            <el-descriptions-item label="碳化温度1(℃)">
              {{ carbonData.carbon_temp1 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化厚度1(μm)">
              {{ carbonData.carbon_thickness1 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化温度2(℃)">
              {{ carbonData.carbon_temp2 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化厚度2(μm)">
              {{ carbonData.carbon_thickness2 || '-' }}
            </el-descriptions-item>

            <el-descriptions-item label="碳化最高温度(℃)">
              {{ carbonData.carbon_max_temp || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化总时长(min)">
              {{ carbonData.carbon_total_time || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化膜厚度(μm)">
              {{ carbonData.carbon_film_thickness || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化后重量(kg)">
              {{ carbonData.carbon_after_weight || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化成碳率(%)">
              {{ carbonData.carbon_yield_rate || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="碳化装载方式照片" :span="2">
              <div v-if="carbonData.carbon_loading_photo">
                <el-image
                  :src="carbonData.carbon_loading_photo"
                  fit="cover"
                  :preview-src-list="[carbonData.carbon_loading_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
            <el-descriptions-item label="碳化样品照片" :span="2">
              <div v-if="carbonData.carbon_sample_photo">
                <el-image
                  :src="carbonData.carbon_sample_photo"
                  fit="cover"
                  :preview-src-list="[carbonData.carbon_sample_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
            <el-descriptions-item label="碳化其它参数" :span="2">
              <el-link v-if="carbonData.carbon_other_params" type="primary" :href="carbonData.carbon_other_params" target="_blank">
                查看文件
              </el-link>
              <span v-else>-</span>
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 5. 石墨化参数 -->
        <el-tab-pane label="石墨化参数" name="graphite">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="石墨炉编号">
              {{ graphiteData.graphite_furnace_number || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨炉次">
              {{ graphiteData.graphite_furnace_batch || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="开始时间">
              {{ formatDateTime(graphiteData.graphite_start_time) }}
            </el-descriptions-item>
            <el-descriptions-item label="结束时间">
              {{ formatDateTime(graphiteData.graphite_end_time) }}
            </el-descriptions-item>
            <el-descriptions-item label="气体压力">
              {{ graphiteData.gas_pressure || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化功率">
              {{ graphiteData.graphite_power || '-' }}
            </el-descriptions-item>

            <!-- ✅ 新增：石墨化温度/厚度字段 -->
            <el-descriptions-item label="石墨化温度1(℃)">
              {{ graphiteData.graphite_temp1 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化厚度1(μm)">
              {{ graphiteData.graphite_thickness1 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化温度2(℃)">
              {{ graphiteData.graphite_temp2 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化厚度2(μm)">
              {{ graphiteData.graphite_thickness2 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化温度3(℃)">
              {{ graphiteData.graphite_temp3 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化厚度3(μm)">
              {{ graphiteData.graphite_thickness3 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化温度4(℃)">
              {{ graphiteData.graphite_temp4 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化厚度4(μm)">
              {{ graphiteData.graphite_thickness4 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化温度5(℃)">
              {{ graphiteData.graphite_temp5 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化厚度5(μm)">
              {{ graphiteData.graphite_thickness5 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化温度6(℃)">
              {{ graphiteData.graphite_temp6 || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化厚度6(μm)">
              {{ graphiteData.graphite_thickness6 || '-' }}
            </el-descriptions-item>

            <el-descriptions-item label="发泡厚度(μm)">
              {{ graphiteData.foam_thickness || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化最高温度(℃)">
              {{ graphiteData.graphite_max_temp || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化宽度(mm)">
              {{ graphiteData.graphite_width || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="收缩率">
              {{ graphiteData.shrinkage_ratio || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化总时长(min)">
              {{ graphiteData.graphite_total_time || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化后重量(kg)">
              {{ graphiteData.graphite_after_weight || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化成碳率(%)">
              {{ graphiteData.graphite_yield_rate || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化最小厚度(μm)">
              {{ graphiteData.graphite_min_thickness || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="石墨化装载方式照片" :span="2">
              <div v-if="graphiteData.graphite_loading_photo">
                <el-image
                  :src="graphiteData.graphite_loading_photo"
                  fit="cover"
                  :preview-src-list="[graphiteData.graphite_loading_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
            <el-descriptions-item label="石墨化样品照片" :span="2">
              <div v-if="graphiteData.graphite_sample_photo">
                <el-image
                  :src="graphiteData.graphite_sample_photo"
                  fit="cover"
                  :preview-src-list="[graphiteData.graphite_sample_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
            <el-descriptions-item label="石墨化其它参数" :span="2">
              <el-link v-if="graphiteData.graphite_other_params" type="primary" :href="graphiteData.graphite_other_params" target="_blank">
                查看文件
              </el-link>
              <span v-else>-</span>
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 6. 压延参数 -->
        <el-tab-pane label="压延参数" name="rolling">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="压延机台">
              {{ rollingData.rolling_machine || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="压延压力(MPa)">
              {{ rollingData.rolling_pressure || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="压延张力">
              {{ rollingData.rolling_tension || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="压延速度(m/s)">
              {{ rollingData.rolling_speed || '-' }}
            </el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>

        <!-- 7. 成品参数 (7/7) -->
        <el-tab-pane label="成品参数" name="product">
          <el-descriptions :column="2" border class="detail-section">
            <el-descriptions-item label="成品编码">
              {{ productData.product_code || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="样品平均厚度(μm)">
              {{ productData.avg_thickness || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="规格(宽幅mm×长m)">
              {{ productData.specification || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="平均密度(g/cm³)">
              {{ productData.avg_density || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="热扩散系数(mm²/s)">
              {{ productData.thermal_diffusivity || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="导热系数(W/m·K)">
              {{ productData.thermal_conductivity || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="比热(J/g·K)">
              {{ productData.specific_heat || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="内聚力(gf)">
              {{ productData.cohesion || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="剥离力(gf)">
              {{ productData.peel_strength || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="粗糙度">
              {{ productData.roughness || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="外观及不良情况描述" :span="2">
              {{ productData.appearance_desc || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="外观不良照片" :span="2">
              <div v-if="productData.appearance_defect_photo">
                <el-image
                  :src="productData.appearance_defect_photo"
                  fit="cover"
                  :preview-src-list="[productData.appearance_defect_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
            <el-descriptions-item label="样品照片" :span="2">
              <div v-if="productData.sample_photo">
                <el-image
                  :src="productData.sample_photo"
                  fit="cover"
                  :preview-src-list="[productData.sample_photo]"
                  style="width: 100px; height: 100px;"
                />
              </div>
              <span v-else>-</span>
            </el-descriptions-item>
            <el-descriptions-item label="实验总结" :span="2">
              {{ productData.experiment_summary || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="其它文件" :span="2">
              <el-link v-if="productData.other_files" type="primary" :href="productData.other_files" target="_blank">
                查看文件
              </el-link>
              <span v-else>-</span>
            </el-descriptions-item>
            <el-descriptions-item label="备注" :span="2">
              {{ productData.remarks || '-' }}
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
    console.log('✅ API 响应:', response)

    // 处理嵌套的 experiment 字段
    const data = response.data || response
    const exp = data.experiment || data
    console.log('📦 完整响应数据:', data)
    console.log('📦 解析后的实验数据:', exp)

    if (!exp) {
      throw new Error('实验数据为空')
    }

    // 填充实验基本信息
    Object.assign(experimentData, {
      experiment_code: exp.experiment_code,
      status: exp.status,
      creator_name: exp.creator_name || exp.created_by,
      created_at: exp.created_at,
      submitted_at: exp.submitted_at,
      updated_at: exp.updated_at
    })

    // 填充各模块数据 - 根据后端返回的实际数据结构
    // 如果后端返回分模块数据，使用模块数据；否则从主数据中提取
    if (exp.basic || exp.experiment_basic) {
      Object.assign(basicData, exp.basic || exp.experiment_basic)
    }

    if (exp.pi || exp.experiment_pi) {
      Object.assign(piData, exp.pi || exp.experiment_pi)
    }

    if (exp.loose || exp.experiment_loose) {
      Object.assign(looseData, exp.loose || exp.experiment_loose)
    }

    if (exp.carbon || exp.experiment_carbon) {
      Object.assign(carbonData, exp.carbon || exp.experiment_carbon)
    }

    if (exp.graphite || exp.experiment_graphite) {
      Object.assign(graphiteData, exp.graphite || exp.experiment_graphite)
    }

    if (exp.rolling || exp.experiment_rolling) {
      Object.assign(rollingData, exp.rolling || exp.experiment_rolling)
    }

    if (exp.product || exp.experiment_product) {
      Object.assign(productData, exp.product || exp.experiment_product)
    }

    console.log('✅ 各模块数据加载完成')
    console.log('基本参数:', basicData)
    console.log('PI膜参数:', piData)
    console.log('松卷参数:', looseData)
    console.log('碳化参数:', carbonData)
    console.log('石墨化参数:', graphiteData)
    console.log('压延参数:', rollingData)
    console.log('成品参数:', productData)

  } catch (error: any) {
    console.error('❌ 加载实验详情失败:', error)
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
