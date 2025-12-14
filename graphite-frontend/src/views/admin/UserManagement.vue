<template>
  <div class="user-management">
    <!-- 页面标题 -->
    <div class="page-header">
      <h2>用户管理</h2>
      <el-button type="primary" @click="handleAddUser">
        <el-icon><Plus /></el-icon>
        添加用户
      </el-button>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="20" class="statistics-cards">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <el-icon class="stat-icon" color="#409EFF"><UserFilled /></el-icon>
            <div class="stat-content">
              <div class="stat-value">{{ statistics.total_users }}</div>
              <div class="stat-label">总用户数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <el-icon class="stat-icon" color="#67C23A"><CircleCheck /></el-icon>
            <div class="stat-content">
              <div class="stat-value">{{ statistics.active_users }}</div>
              <div class="stat-label">活跃用户</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <el-icon class="stat-icon" color="#E6A23C"><User /></el-icon>
            <div class="stat-content">
              <div class="stat-value">{{ statistics.by_role.engineer }}</div>
              <div class="stat-label">工程师</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <el-icon class="stat-icon" color="#F56C6C"><Lock /></el-icon>
            <div class="stat-content">
              <div class="stat-value">{{ statistics.by_role.admin }}</div>
              <div class="stat-label">管理员</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 搜索和筛选 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm">
        <el-form-item label="搜索">
          <el-input
            v-model="searchForm.search"
            placeholder="用户名/姓名/邮箱"
            clearable
            @clear="handleSearch"
            @keyup.enter="handleSearch"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="角色">
          <el-select v-model="searchForm.role" placeholder="全部角色" clearable @change="handleSearch">
            <el-option label="管理员" value="admin" />
            <el-option label="工程师" value="engineer" />
            <el-option label="普通用户" value="user" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.is_active" placeholder="全部状态" clearable @change="handleSearch">
            <el-option label="启用" :value="true" />
            <el-option label="禁用" :value="false" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 用户列表 -->
    <el-card class="table-card">
      <el-table
        v-loading="loading"
        :data="userList"
        style="width: 100%"
        stripe
        border
      >
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="150" />
        <el-table-column prop="real_name" label="真实姓名" width="150" />
        <el-table-column prop="email" label="邮箱" width="200" />
        <el-table-column prop="role" label="角色" width="120">
          <template #default="{ row }">
            <el-tag :type="getRoleColor(row.role)">
              {{ getRoleLabel(row.role) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="is_active" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.is_active ? 'success' : 'info'">
              {{ row.is_active ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column prop="last_login" label="最后登录" width="180">
          <template #default="{ row }">
            {{ formatDateTime(row.last_login) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button size="small" type="warning" @click="handleResetPassword(row)">
              重置密码
            </el-button>
            <el-button
              size="small"
              :type="row.is_active ? 'info' : 'success'"
              @click="handleToggleStatus(row)"
            >
              {{ row.is_active ? '禁用' : '启用' }}
            </el-button>
            <el-button size="small" type="danger" @click="handleDelete(row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.page_size"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </el-card>

    <!-- 添加/编辑用户对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEditMode ? '编辑用户' : '添加用户'"
      width="500px"
      @close="handleDialogClose"
    >
      <el-form
        ref="userFormRef"
        :model="userForm"
        :rules="userFormRules"
        label-width="100px"
      >
        <el-form-item label="用户名" prop="username">
          <el-input
            v-model="userForm.username"
            :disabled="isEditMode"
            placeholder="请输入用户名"
          />
        </el-form-item>
        <el-form-item v-if="!isEditMode" label="密码" prop="password">
          <el-input
            v-model="userForm.password"
            type="password"
            placeholder="请输入密码（至少6位）"
            show-password
          />
        </el-form-item>
        <el-form-item label="真实姓名" prop="real_name">
          <el-input v-model="userForm.real_name" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="userForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="userForm.role" placeholder="请选择角色" style="width: 100%">
            <el-option label="管理员" value="admin" />
            <el-option label="工程师" value="engineer" />
            <el-option label="普通用户" value="user" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="is_active">
          <el-switch
            v-model="userForm.is_active"
            active-text="启用"
            inactive-text="禁用"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">
          确定
        </el-button>
      </template>
    </el-dialog>

    <!-- 重置密码对话框 -->
    <el-dialog
      v-model="passwordDialogVisible"
      title="重置密码"
      width="400px"
      @close="handlePasswordDialogClose"
    >
      <el-form
        ref="passwordFormRef"
        :model="passwordForm"
        :rules="passwordFormRules"
        label-width="100px"
      >
        <el-form-item label="新密码" prop="new_password">
          <el-input
            v-model="passwordForm.new_password"
            type="password"
            placeholder="请输入新密码（至少6位）"
            show-password
          />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirm_password">
          <el-input
            v-model="passwordForm.confirm_password"
            type="password"
            placeholder="请再次输入新密码"
            show-password
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="passwordDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmitPassword" :loading="submitting">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import {
  Plus,
  Search,
  UserFilled,
  CircleCheck,
  User,
  Lock
} from '@element-plus/icons-vue'
import {
  getUserList,
  createUser,
  updateUser,
  deleteUser,
  resetUserPassword,
  toggleUserStatus,
  getUserStatistics
} from '@/api/admin'
import type {
  User as UserType,
  UserQueryParams,
  CreateUserRequest,
  UpdateUserRequest,
  UserStatistics
} from '@/types/admin'
import { ROLE_LABELS, ROLE_COLORS } from '@/types/admin'

// ==================== 数据 ====================

// 用户列表
const userList = ref<UserType[]>([])
const loading = ref(false)

// 统计信息
const statistics = ref<UserStatistics>({
  total_users: 0,
  active_users: 0,
  inactive_users: 0,
  by_role: {
    admin: 0,
    engineer: 0,
    user: 0
  }
})

// 搜索表单
const searchForm = reactive<UserQueryParams>({
  page: 1,
  page_size: 10,
  search: '',
  role: '',
  is_active: ''
})

// 分页
const pagination = reactive({
  page: 1,
  page_size: 10,
  total: 0
})

// 对话框
const dialogVisible = ref(false)
const isEditMode = ref(false)
const currentUserId = ref<number | null>(null)
const userFormRef = ref<FormInstance>()
const userForm = reactive<Partial<CreateUserRequest & { id: number }>>({
  username: '',
  password: '',
  real_name: '',
  email: '',
  role: 'user',
  is_active: true
})

// 密码重置对话框
const passwordDialogVisible = ref(false)
const passwordFormRef = ref<FormInstance>()
const passwordForm = reactive({
  new_password: '',
  confirm_password: ''
})

// 提交状态
const submitting = ref(false)

// ==================== 表单验证规则（完善版）====================

// ✅ 用户表单验证规则
const userFormRules: FormRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 50, message: '用户名长度为 3-50 个字符', trigger: 'blur' },
    { 
      pattern: /^[a-zA-Z0-9_]+$/, 
      message: '用户名只能包含字母、数字和下划线', 
      trigger: 'blur' 
    }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少为 6 个字符', trigger: 'blur' },
    { max: 50, message: '密码长度不能超过 50 个字符', trigger: 'blur' }
  ],
  email: [
    { 
      pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/, 
      message: '请输入正确的邮箱格式', 
      trigger: 'blur' 
    }
  ],
  real_name: [
    { max: 100, message: '真实姓名不能超过 100 个字符', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' }
  ]
}

// ✅ 密码重置表单验证规则
const passwordFormRules: FormRules = {
  new_password: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少为 6 个字符', trigger: 'blur' },
    { max: 50, message: '密码长度不能超过 50 个字符', trigger: 'blur' }
  ],
  confirm_password: [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    { 
      validator: (rule, value, callback) => {
        if (value !== passwordForm.new_password) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      }, 
      trigger: 'blur' 
    }
  ]
}

// ==================== 方法 ====================

// ✅ 加载用户列表（优化错误处理）
const loadUserList = async () => {
  try {
    loading.value = true
    const params: UserQueryParams = {
      page: pagination.page,
      page_size: pagination.page_size,
      search: searchForm.search || undefined,
      role: searchForm.role || undefined,
      is_active: searchForm.is_active !== '' ? searchForm.is_active : undefined
    }
    const response = await getUserList(params)
    userList.value = response.users
    pagination.total = response.total
  } catch (error: any) {
    // ✅ 拦截器已处理错误提示，这里只记录日志
    if (!error.handled) {
      console.error('加载用户列表失败:', error)
      ElMessage.error('加载用户列表失败')
    }
  } finally {
    loading.value = false
  }
}

// ✅ 加载统计信息（静默失败）
const loadStatistics = async () => {
  try {
    statistics.value = await getUserStatistics()
  } catch (error: any) {
    // ✅ 统计信息加载失败不显示错误（静默失败）
    if (!error.handled) {
      console.error('加载统计信息失败:', error)
    }
  }
}

// 搜索
const handleSearch = () => {
  pagination.page = 1
  loadUserList()
}

// 重置搜索
const handleReset = () => {
  searchForm.search = ''
  searchForm.role = ''
  searchForm.is_active = ''
  pagination.page = 1
  loadUserList()
}

// 分页改变
const handlePageChange = (page: number) => {
  pagination.page = page
  loadUserList()
}

// 每页大小改变
const handleSizeChange = (size: number) => {
  pagination.page_size = size
  pagination.page = 1
  loadUserList()
}

// 添加用户
const handleAddUser = () => {
  isEditMode.value = false
  currentUserId.value = null
  Object.assign(userForm, {
    username: '',
    password: '',
    real_name: '',
    email: '',
    role: 'user',
    is_active: true
  })
  dialogVisible.value = true
}

// 编辑用户
const handleEdit = (user: UserType) => {
  isEditMode.value = true
  currentUserId.value = user.id
  Object.assign(userForm, {
    username: user.username,
    real_name: user.real_name || '',
    email: user.email || '',
    role: user.role,
    is_active: user.is_active
  })
  dialogVisible.value = true
}

// ✅ 提交表单（优化错误处理）
const handleSubmit = async () => {
  if (!userFormRef.value) return
  
  try {
    // 表单验证
    await userFormRef.value.validate()
    submitting.value = true
    
    if (isEditMode.value && currentUserId.value) {
      // 编辑模式
      const data: UpdateUserRequest = {
        real_name: userForm.real_name,
        email: userForm.email,
        role: userForm.role,
        is_active: userForm.is_active
      }
      await updateUser(currentUserId.value, data)
      ElMessage.success('用户信息更新成功')
    } else {
      // 新增模式
      const data: CreateUserRequest = {
        username: userForm.username!,
        password: userForm.password!,
        real_name: userForm.real_name,
        email: userForm.email,
        role: userForm.role,
        is_active: userForm.is_active
      }
      await createUser(data)
      ElMessage.success('用户创建成功')
    }
    
    dialogVisible.value = false
    loadUserList()
    loadStatistics()
  } catch (error: any) {
    // ✅ 拦截器已处理错误提示，这里不再重复
    if (!error.handled) {
      console.error('操作失败:', error)
      ElMessage.error('操作失败，请重试')
    }
  } finally {
    submitting.value = false
  }
}

// 关闭对话框
const handleDialogClose = () => {
  userFormRef.value?.resetFields()
}

// 重置密码
const handleResetPassword = (user: UserType) => {
  currentUserId.value = user.id
  passwordForm.new_password = ''
  passwordForm.confirm_password = ''
  passwordDialogVisible.value = true
}

// ✅ 提交密码重置（优化错误处理）
const handleSubmitPassword = async () => {
  if (!passwordFormRef.value || !currentUserId.value) return
  
  try {
    await passwordFormRef.value.validate()
    submitting.value = true
    
    await resetUserPassword(currentUserId.value, {
      new_password: passwordForm.new_password
    })
    
    ElMessage.success('密码重置成功')
    passwordDialogVisible.value = false
  } catch (error: any) {
    // ✅ 拦截器已处理错误提示
    if (!error.handled) {
      console.error('密码重置失败:', error)
      ElMessage.error('密码重置失败，请重试')
    }
  } finally {
    submitting.value = false
  }
}

// 关闭密码对话框
const handlePasswordDialogClose = () => {
  passwordFormRef.value?.resetFields()
}

// ✅ 切换用户状态（优化错误处理）
const handleToggleStatus = async (user: UserType) => {
  const action = user.is_active ? '禁用' : '启用'
  try {
    await ElMessageBox.confirm(
      `确定要${action}用户 "${user.username}" 吗？`,
      '确认操作',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await toggleUserStatus(user.id, { is_active: !user.is_active })
    ElMessage.success(`${action}成功`)
    loadUserList()
    loadStatistics()
  } catch (error: any) {
    // 用户取消操作
    if (error === 'cancel') {
      return
    }
    // ✅ 拦截器已处理错误提示
    if (!error.handled) {
      console.error(`${action}失败:`, error)
      ElMessage.error(`${action}失败，请重试`)
    }
  }
}

// ✅ 删除用户（优化错误处理）
const handleDelete = async (user: UserType) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除用户 "${user.username}" 吗？此操作将禁用该用户账号。`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await deleteUser(user.id)
    ElMessage.success('用户已删除')
    loadUserList()
    loadStatistics()
  } catch (error: any) {
    // 用户取消操作
    if (error === 'cancel') {
      return
    }
    // ✅ 拦截器已处理错误提示
    if (!error.handled) {
      console.error('删除失败:', error)
      ElMessage.error('删除失败，请重试')
    }
  }
}

// 获取角色标签
const getRoleLabel = (role: string) => {
  return ROLE_LABELS[role as keyof typeof ROLE_LABELS] || role
}

// 获取角色颜色
const getRoleColor = (role: string) => {
  return ROLE_COLORS[role as keyof typeof ROLE_COLORS] || 'info'
}

// 格式化日期时间
const formatDateTime = (dateStr: string | null | undefined) => {
  if (!dateStr) return '-'
  const date = new Date(dateStr)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// ==================== 生命周期 ====================

onMounted(() => {
  loadUserList()
  loadStatistics()
})
</script>

<style scoped lang="scss">
.user-management {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;

  h2 {
    margin: 0;
    font-size: 24px;
    font-weight: 600;
  }
}

.statistics-cards {
  margin-bottom: 20px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 15px;

  .stat-icon {
    font-size: 40px;
  }

  .stat-content {
    flex: 1;

    .stat-value {
      font-size: 28px;
      font-weight: 600;
      color: #303133;
      margin-bottom: 5px;
    }

    .stat-label {
      font-size: 14px;
      color: #909399;
    }
  }
}

.search-card {
  margin-bottom: 20px;
}

.table-card {
  .pagination-container {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
  }
}
</style>
