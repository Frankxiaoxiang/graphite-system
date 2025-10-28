<template>
  <div class="experiment-database">
    <!-- 页面标题 -->
    <div class="page-header">
      <h1>🧪 实验数据库</h1>
      <div class="header-actions">
        <el-button @click="goToHome" :icon="HomeFilled">
          返回主页
        </el-button>
        <el-button type="primary" @click="goToCreate" :icon="Plus">
          创建新实验
        </el-button>
      </div>
    </div>

    <!-- 搜索和筛选区域 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="实验编码">
          <el-input
            v-model="searchForm.experiment_code"
            placeholder="请输入实验编码"
            clearable
            @keyup.enter="handleSearch"
            style="width: 200px"
          />
        </el-form-item>

        <el-form-item label="客户名称">
          <el-input
            v-model="searchForm.customer_name"
            placeholder="请输入客户名称"
            clearable
            @keyup.enter="handleSearch"
            style="width: 200px"
          />
        </el-form-item>

        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="全部状态" clearable style="width: 150px">
            <el-option label="草稿" value="draft" />
            <el-option label="已提交" value="submitted" />
          </el-select>
        </el-form-item>

        <el-form-item label="实验日期">
          <el-date-picker
            v-model="searchForm.date_from"
            type="date"
            placeholder="开始日期"
            clearable
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 150px"
          />
          <span style="margin: 0 8px">至</span>
          <el-date-picker
            v-model="searchForm.date_to"
            type="date"
            placeholder="结束日期"
            clearable
            format="YYYY-MM-DD"
            value-format="YYYY-MM-DD"
            style="width: 150px"
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSearch" :icon="Search">
            搜索
          </el-button>
          <el-button @click="handleReset" :icon="Refresh">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table
        :data="tableData"
        v-loading="loading"
        stripe
        border
        style="width: 100%"
        :row-class-name="getRowClassName"
      >
        <el-table-column type="index" label="序号" width="60" align="center" />

        <el-table-column prop="experiment_code" label="实验编码" width="220" fixed>
          <template #default="{ row }">
            <el-link type="primary" @click="viewDetail(row.id)">
              {{ row.experiment_code }}
            </el-link>
          </template>
        </el-table-column>

        <el-table-column prop="customer_name" label="客户名称" width="150" />

        <el-table-column prop="pi_film_thickness" label="PI膜厚度" width="100" align="center">
          <template #default="{ row }">
            {{ row.pi_film_thickness ? `${row.pi_film_thickness}μm` : '-' }}
          </template>
        </el-table-column>

        <el-table-column prop="experiment_date" label="实验日期" width="120" align="center" />

        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.status === 'draft'" type="info" size="small">
              草稿
            </el-tag>
            <el-tag v-else-if="row.status === 'submitted'" type="success" size="small">
              已提交
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column prop="created_at" label="创建时间" width="160" align="center" />

        <el-table-column prop="created_by_name" label="创建人" width="100" align="center" />

        <el-table-column label="操作" width="200" fixed="right" align="center">
          <template #default="{ row }">
            <el-button
              type="primary"
              size="small"
              @click="viewDetail(row.id)"
              :icon="View"
            >
              查看
            </el-button>
            <el-button
              v-if="canDelete(row)"
              type="danger"
              size="small"
              @click="deleteExperiment(row)"
              :icon="Delete"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.size"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Refresh, Plus, View, Delete, HomeFilled } from '@element-plus/icons-vue'
import { experimentApi } from '@/api/experiments'

const router = useRouter()
const route = useRoute()

const loading = ref(false)

const searchForm = reactive({
  experiment_code: '',
  customer_name: '',
  status: '',
  date_from: '',
  date_to: ''
})

const tableData = ref<any[]>([])

const pagination = reactive({
  page: 1,
  size: 20,
  total: 0
})

const currentUser = JSON.parse(localStorage.getItem('user') || '{}')

/**
 * 获取实验列表
 */
async function fetchExperiments() {
  loading.value = true
  try {
    const params: any = {
      page: pagination.page,
      size: pagination.size
    }

    if (searchForm.experiment_code) {
      params.experiment_code = searchForm.experiment_code
    }
    if (searchForm.customer_name) {
      params.customer_name = searchForm.customer_name
    }
    if (searchForm.status) {
      params.status = searchForm.status
    }
    if (searchForm.date_from) {
      params.date_from = searchForm.date_from
    }
    if (searchForm.date_to) {
      params.date_to = searchForm.date_to
    }

    const response = await experimentApi.getExperiments(params)

    tableData.value = response.data
    pagination.total = response.total

    console.log('✅ 获取实验列表成功:', response)
  } catch (error: any) {
    console.error('❌ 获取实验列表失败:', error)
    ElMessage.error(error.message || '获取数据失败')
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  pagination.page = 1
  fetchExperiments()
}

function handleReset() {
  searchForm.experiment_code = ''
  searchForm.customer_name = ''
  searchForm.status = ''
  searchForm.date_from = ''
  searchForm.date_to = ''
  pagination.page = 1
  fetchExperiments()
}

function goToHome() {
  router.push({ name: 'home' })
}

function goToCreate() {
  router.push({ name: 'experiment-create' })
}

function viewDetail(id: number) {
  console.log('查看详情 ID:', id)
  router.push(`/experiments/${id}`)  // ← 添加路由跳转
}

function canDelete(row: any): boolean {
  return row.status === 'draft' && row.created_by === currentUser.id
}

async function deleteExperiment(row: any) {
  try {
    await ElMessageBox.confirm(
      `确认删除实验"${row.experiment_code}"吗？此操作不可恢复！`,
      '删除确认',
      {
        confirmButtonText: '确认删除',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    await experimentApi.deleteExperiment(row.id)
    ElMessage.success('删除成功')
    fetchExperiments()
  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('❌ 删除失败:', error)
      ElMessage.error(error.message || '删除失败')
    }
  }
}

function handleSizeChange(size: number) {
  pagination.size = size
  pagination.page = 1
  fetchExperiments()
}

function handlePageChange(page: number) {
  pagination.page = page
  fetchExperiments()
}

function getRowClassName({ row }: { row: any }): string {
  const highlightId = route.query.highlight
  if (highlightId && row.id === Number(highlightId)) {
    return 'highlight-row'
  }
  return ''
}

onMounted(() => {
  // 检查路由参数，自动设置筛选条件
  const statusParam = route.query.status
  if (statusParam) {
    searchForm.status = statusParam as string
    console.log('🔍 自动筛选状态:', statusParam)
  }

  fetchExperiments()
})
</script>

<style scoped>
.experiment-database {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h1 {
  font-size: 24px;
  margin: 0;
  color: #303133;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.search-card {
  margin-bottom: 20px;
}

.search-form {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.table-card {
  min-height: 600px;
}

.pagination-container {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

:deep(.highlight-row) {
  background-color: #ecf5ff !important;
  animation: highlight-fade 3s ease-out;
}

@keyframes highlight-fade {
  0% {
    background-color: #409eff;
  }
  100% {
    background-color: #ecf5ff;
  }
}
</style>
