<template>
  <div class="dashboard-container">
    <!-- 顶部导航栏 -->
    <div class="header">
      <h1>人工合成石墨实验数据管理系统</h1>
      <div class="user-info">
        <span>欢迎，{{ authStore.user?.real_name || authStore.user?.username }}</span>
        <el-dropdown @command="handleCommand">
          <el-button type="primary" class="user-button">
            {{ userRoleText }}
            <el-icon class="el-icon--right">
              <arrow-down />
            </el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">个人信息</el-dropdown-item>
              <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>

    <div class="main-content">
      <!-- 统计卡片区域 -->
      <div class="stats-section" v-loading="loadingStats">
        <el-row :gutter="20">
          <!-- 总实验数 -->
          <el-col :span="6">
            <el-card class="stat-card total-card" shadow="hover">
              <div class="stat-content">
                <div class="stat-icon-wrapper total-icon">
                  <el-icon :size="40"><Document /></el-icon>
                </div>
                <div class="stat-info">
                  <h3>总实验数</h3>
                  <p class="stat-number">{{ statsData.summary?.total_experiments || 0 }}</p>
                  <span class="stat-growth" :class="getGrowthClass(statsData.summary?.total_growth || 0)">
                    <el-icon><TrendCharts /></el-icon>
                    本周 +{{ statsData.summary?.total_growth || 0 }}
                  </span>
                </div>
              </div>
            </el-card>
          </el-col>

          <!-- 草稿实验 -->
          <el-col :span="6">
            <el-card class="stat-card draft-card" shadow="hover">
              <div class="stat-content">
                <div class="stat-icon-wrapper draft-icon">
                  <el-icon :size="40"><EditPen /></el-icon>
                </div>
                <div class="stat-info">
                  <h3>草稿实验</h3>
                  <p class="stat-number">{{ statsData.summary?.draft_experiments || 0 }}</p>
                  <span class="stat-growth" :class="getGrowthClass(statsData.summary?.draft_growth || 0)">
                    <el-icon><TrendCharts /></el-icon>
                    本周 +{{ statsData.summary?.draft_growth || 0 }}
                  </span>
                </div>
              </div>
            </el-card>
          </el-col>

          <!-- 我的实验 -->
          <el-col :span="6">
            <el-card class="stat-card my-card" shadow="hover">
              <div class="stat-content">
                <div class="stat-icon-wrapper my-icon">
                  <el-icon :size="40"><User /></el-icon>
                </div>
                <div class="stat-info">
                  <h3>我的实验</h3>
                  <p class="stat-number">{{ statsData.summary?.my_experiments || 0 }}</p>
                  <span class="stat-growth" :class="getGrowthClass(statsData.summary?.my_growth || 0)">
                    <el-icon><TrendCharts /></el-icon>
                    本周 +{{ statsData.summary?.my_growth || 0 }}
                  </span>
                </div>
              </div>
            </el-card>
          </el-col>

          <!-- 已提交实验 -->
          <el-col :span="6">
            <el-card class="stat-card submitted-card" shadow="hover">
              <div class="stat-content">
                <div class="stat-icon-wrapper submitted-icon">
                  <el-icon :size="40"><Select /></el-icon>
                </div>
                <div class="stat-info">
                  <h3>已提交</h3>
                  <p class="stat-number">{{ statsData.summary?.submitted_experiments || 0 }}</p>
                  <span class="stat-growth" :class="getGrowthClass(statsData.summary?.submitted_growth || 0)">
                    <el-icon><TrendCharts /></el-icon>
                    本周 +{{ statsData.summary?.submitted_growth || 0 }}
                  </span>
                </div>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </div>

      <!-- 图表区域 -->
      <div class="charts-section" v-loading="loadingCharts">
        <el-row :gutter="20">
          <!-- 状态分布饼图 -->
          <el-col :span="12">
            <el-card class="chart-card" shadow="hover">
              <div class="chart-header">
                <h3>实验状态分布</h3>
              </div>
              <div ref="statusChartRef" class="chart-container"></div>
            </el-card>
          </el-col>

          <!-- 客户分布饼图 -->
          <el-col :span="12">
            <el-card class="chart-card" shadow="hover">
              <div class="chart-header">
                <h3>客户分布</h3>
              </div>
              <div ref="customerChartRef" class="chart-container"></div>
            </el-card>
          </el-col>
        </el-row>

        <el-row :gutter="20" style="margin-top: 20px;">
          <!-- 月度趋势折线图 -->
          <el-col :span="12">
            <el-card class="chart-card" shadow="hover">
              <div class="chart-header">
                <h3>月度实验趋势</h3>
              </div>
              <div ref="trendChartRef" class="chart-container"></div>
            </el-card>
          </el-col>

          <!-- PI膜厚度分布柱状图 -->
          <el-col :span="12">
            <el-card class="chart-card" shadow="hover">
              <div class="chart-header">
                <h3>PI膜厚度分布</h3>
              </div>
              <div ref="thicknessChartRef" class="chart-container"></div>
            </el-card>
          </el-col>
        </el-row>
      </div>

      <!-- 快捷菜单区域 -->
      <div class="menu-section">
        <h2 class="section-title">快捷功能</h2>
        <div class="menu-grid">
          <div
            v-for="item in filteredMenuItems"
            :key="item.id"
            class="menu-item"
            :class="{ disabled: item.disabled }"
            @click="handleMenuClick(item)"
          >
            <el-icon :size="50" :class="item.iconClass">
              <component :is="item.icon" />
            </el-icon>
            <h3>{{ item.title }}</h3>
            <p>{{ item.description }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  ArrowDown,
  Document,
  EditPen,
  User,
  Select,
  TrendCharts,
  DataAnalysis,
  FolderOpened,
  Plus,
  Setting,
  Edit  // ✅ 新增：未完成实验图标
} from '@element-plus/icons-vue'

// ECharts 按需导入 - 优化打包体积
import * as echarts from 'echarts/core'
import { PieChart, BarChart, LineChart } from 'echarts/charts'
import {
  TooltipComponent,
  GridComponent,
  LegendComponent
} from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'

// 注册需要的组件
echarts.use([
  TooltipComponent,
  GridComponent,
  LegendComponent,
  PieChart,
  BarChart,
  LineChart,
  CanvasRenderer
])

import { experimentApi, type ExperimentStats } from '@/api/experiments'

const router = useRouter()
const authStore = useAuthStore()

// 加载状态
const loadingStats = ref(false)
const loadingCharts = ref(false)

// 统计数据
const statsData = ref<ExperimentStats>({
  summary: {
    total_experiments: 0,
    total_growth: 0,
    draft_experiments: 0,
    draft_growth: 0,
    my_experiments: 0,
    my_growth: 0,
    submitted_experiments: 0,
    submitted_growth: 0
  },
  status_distribution: {
    draft: 0,
    submitted: 0,
    completed: 0
  },
  monthly_trend: [],
  thickness_distribution: [],
  customer_distribution: []
})

// ECharts 实例引用
const statusChartRef = ref<HTMLElement>()
const customerChartRef = ref<HTMLElement>()
const trendChartRef = ref<HTMLElement>()
const thicknessChartRef = ref<HTMLElement>()

let statusChart: echarts.ECharts | null = null
let customerChart: echarts.ECharts | null = null
let trendChart: echarts.ECharts | null = null
let thicknessChart: echarts.ECharts | null = null

// 用户角色文本
const userRoleText = computed(() => {
  const roleMap: Record<string, string> = {
    admin: '管理员',
    engineer: '工程师',
    user: '普通用户'
  }
  return roleMap[authStore.user?.role || 'user'] || '用户'
})

// 快捷菜单项
const menuItems = [
  {
    id: 'create',
    title: '创建新实验',
    description: '录入新的实验数据',
    icon: Plus,
    iconClass: 'create-icon',
    route: '/experiments/create',
    roles: ['admin', 'engineer', 'user'],
    disabled: false
  },
  {
    id: 'drafts',
    title: '未完成实验',
    description: '查看和编辑草稿实验',
    icon: Edit,
    iconClass: 'drafts-icon',
    route: '/experiments/database?status=draft',
    roles: ['admin', 'engineer', 'user'],
    disabled: false
  },
  {
    id: 'database',
    title: '实验数据库',
    description: '查看和管理所有实验数据',
    icon: FolderOpened,
    iconClass: 'database-icon',
    route: '/experiments/database',
    roles: ['admin', 'engineer'],
    disabled: false
  },
  {
    id: 'analysis',
    title: '数据对比与分析',
    description: '实验数据的统计分析和对比',
    icon: DataAnalysis,
    iconClass: 'analysis-icon',
    route: '/experiments/compare',
    roles: ['admin', 'engineer'],
    disabled: false
  },
  {
    id: 'admin',
    title: '用户管理',
    description: '用户管理和权限配置',
    icon: Setting,
    iconClass: 'admin-icon',
    route: '/admin/users',
    roles: ['admin'],
    disabled: false
  }
]

// 根据用户权限过滤菜单项
const filteredMenuItems = computed(() => {
  const userRole = authStore.user?.role
  return menuItems.map(item => ({
    ...item,
    disabled: !item.roles.includes(userRole || 'user')
  }))
})

// 获取增长样式类
const getGrowthClass = (growth: number) => {
  if (growth > 0) return 'growth-positive'
  if (growth < 0) return 'growth-negative'
  return 'growth-zero'
}

// 处理菜单点击
const handleMenuClick = (item: any) => {
  if (item.disabled) {
    ElMessage.warning('您暂时无法访问此页面')
    return
  }
  router.push(item.route)
}

// 处理用户下拉菜单
const handleCommand = async (command: string) => {
  switch (command) {
    case 'profile':
      ElMessage.info('个人信息功能开发中')
      break
    case 'logout':
      try {
        await ElMessageBox.confirm('确认要退出登录吗？', '退出确认', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })
        await authStore.logout()
        ElMessage.success('已退出登录')
        router.push('/login')
      } catch {
        // 用户取消
      }
      break
  }
}

// 加载统计数据
const loadStats = async () => {
  loadingStats.value = true
  loadingCharts.value = true

  try {
    const stats = await experimentApi.getExperimentStats()
    statsData.value = stats

    // 延迟渲染图表，确保DOM已更新
    setTimeout(() => {
      initCharts()
      loadingCharts.value = false
    }, 100)
  } catch (error: any) {
    console.error('加载统计数据失败:', error)
    ElMessage.error(error.message || '加载统计数据失败')
  } finally {
    loadingStats.value = false
  }
}

// 初始化所有图表
const initCharts = () => {
  initStatusChart()
  initCustomerChart()
  initTrendChart()
  initThicknessChart()
}

// 初始化状态分布饼图
const initStatusChart = () => {
  if (!statusChartRef.value) return

  // 销毁旧实例
  if (statusChart) {
    statusChart.dispose()
  }

  statusChart = echarts.init(statusChartRef.value)

  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      right: '10%',
      top: 'center',
      data: ['草稿', '已提交', '已完成']
    },
    series: [
      {
        name: '实验状态',
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['35%', '50%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 10,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: false,
          position: 'center'
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 20,
            fontWeight: 'bold'
          }
        },
        labelLine: {
          show: false
        },
        data: [
          {
            value: statsData.value.status_distribution.draft,
            name: '草稿',
            itemStyle: { color: '#909399' }
          },
          {
            value: statsData.value.status_distribution.submitted,
            name: '已提交',
            itemStyle: { color: '#67C23A' }
          },
          {
            value: statsData.value.status_distribution.completed,
            name: '已完成',
            itemStyle: { color: '#409EFF' }
          }
        ]
      }
    ]
  }

  statusChart.setOption(option)
}

// 初始化客户分布饼图
const initCustomerChart = () => {
  if (!customerChartRef.value) return

  if (customerChart) {
    customerChart.dispose()
  }

  customerChart = echarts.init(customerChartRef.value)

  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      right: '10%',
      top: 'center',
      type: 'scroll'
    },
    series: [
      {
        name: '客户分布',
        type: 'pie',
        radius: '60%',
        center: ['35%', '50%'],
        data: statsData.value.customer_distribution.map(item => ({
          value: item.count,
          name: item.customer
        })),
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  }

  customerChart.setOption(option)
}

// 初始化月度趋势折线图
const initTrendChart = () => {
  if (!trendChartRef.value) return

  if (trendChart) {
    trendChart.dispose()
  }

  trendChart = echarts.init(trendChartRef.value)

  const months = statsData.value.monthly_trend.map(item => item.month)
  const counts = statsData.value.monthly_trend.map(item => item.count)

  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'cross'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      boundaryGap: false,
      data: months,
      axisLabel: {
        rotate: 45
      }
    },
    yAxis: {
      type: 'value',
      name: '实验数量'
    },
    series: [
      {
        name: '实验数量',
        type: 'line',
        smooth: true,
        data: counts,
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              {
                offset: 0,
                color: 'rgba(64, 158, 255, 0.5)'
              },
              {
                offset: 1,
                color: 'rgba(64, 158, 255, 0.1)'
              }
            ]
          }
        },
        itemStyle: {
          color: '#409EFF'
        },
        lineStyle: {
          width: 3
        }
      }
    ]
  }

  trendChart.setOption(option)
}

// 初始化厚度分布柱状图
const initThicknessChart = () => {
  if (!thicknessChartRef.value) return

  if (thicknessChart) {
    thicknessChart.dispose()
  }

  thicknessChart = echarts.init(thicknessChartRef.value)

  const thicknesses = statsData.value.thickness_distribution.map(item => item.thickness)
  const counts = statsData.value.thickness_distribution.map(item => item.count)

  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: thicknesses,
      axisLabel: {
        rotate: 45
      }
    },
    yAxis: {
      type: 'value',
      name: '实验数量'
    },
    series: [
      {
        name: '实验数量',
        type: 'bar',
        data: counts,
        itemStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: '#83bff6' },
              { offset: 0.5, color: '#188df0' },
              { offset: 1, color: '#188df0' }
            ]
          }
        },
        emphasis: {
          itemStyle: {
            color: {
              type: 'linear',
              x: 0,
              y: 0,
              x2: 0,
              y2: 1,
              colorStops: [
                { offset: 0, color: '#2378f7' },
                { offset: 0.7, color: '#2378f7' },
                { offset: 1, color: '#83bff6' }
              ]
            }
          }
        }
      }
    ]
  }

  thicknessChart.setOption(option)
}

// 窗口大小改变时重绘图表
const handleResize = () => {
  statusChart?.resize()
  customerChart?.resize()
  trendChart?.resize()
  thicknessChart?.resize()
}

// 组件挂载时加载数据
onMounted(() => {
  loadStats()
  window.addEventListener('resize', handleResize)
})

// 组件卸载时清理
onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  statusChart?.dispose()
  customerChart?.dispose()
  trendChart?.dispose()
  thicknessChart?.dispose()
})
</script>

<style scoped>
.dashboard-container {
  min-height: 100vh;
  background: #f0f2f5;
}

.header {
  background: white;
  padding: 20px 40px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header h1 {
  color: #333;
  font-size: 24px;
  margin: 0;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.user-info span {
  color: #666;
  font-size: 14px;
}

.main-content {
  padding: 20px 40px;
}

/* 统计卡片样式 */
.stats-section {
  margin-bottom: 20px;
}

.stat-card {
  border-radius: 12px;
  transition: all 0.3s ease;
  cursor: pointer;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.stat-icon-wrapper {
  width: 80px;
  height: 80px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.total-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.draft-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.my-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
}

.submitted-icon {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  color: white;
}

.stat-info {
  flex: 1;
}

.stat-info h3 {
  font-size: 14px;
  color: #666;
  margin: 0 0 8px 0;
  font-weight: normal;
}

.stat-number {
  font-size: 32px;
  font-weight: bold;
  margin: 0 0 8px 0;
  color: #333;
}

.stat-growth {
  font-size: 12px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.growth-positive {
  color: #67C23A;
}

.growth-negative {
  color: #F56C6C;
}

.growth-zero {
  color: #909399;
}

/* 图表样式 */
.charts-section {
  margin-bottom: 20px;
}

.chart-card {
  border-radius: 12px;
}

.chart-header {
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 10px;
}

.chart-header h3 {
  font-size: 16px;
  color: #333;
  margin: 0;
}

.chart-container {
  width: 100%;
  height: 350px;
}

/* 快捷菜单样式 */
.menu-section {
  margin-top: 20px;
}

.section-title {
  font-size: 20px;
  color: #333;
  margin-bottom: 20px;
  padding-left: 10px;
  border-left: 4px solid #409EFF;
}

.menu-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
}

.menu-item {
  background: white;
  padding: 30px;
  border-radius: 12px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.menu-item:not(.disabled):hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
  border-color: #409EFF;
}

.menu-item.disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.menu-item h3 {
  margin: 15px 0 10px 0;
  font-size: 18px;
  color: #333;
}

.menu-item p {
  color: #666;
  font-size: 14px;
  margin: 0;
}

/* 图标颜色 */
.create-icon {
  color: #67C23A;
}

.drafts-icon {
  color: #E6A23C;
}

.database-icon {
  color: #409EFF;
}

.analysis-icon {
  color: #E6A23C;
}

.admin-icon {
  color: #F56C6C;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .menu-grid {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  }
}

@media (max-width: 768px) {
  .main-content {
    padding: 10px 20px;
  }

  .stats-section :deep(.el-col) {
    margin-bottom: 10px;
  }

  .menu-grid {
    grid-template-columns: 1fr;
  }
}
</style>
