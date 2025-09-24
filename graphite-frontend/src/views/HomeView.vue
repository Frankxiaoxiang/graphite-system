<template>
  <div class="dashboard-container">
    <div class="header">
      <h1>石墨实验数据管理系统</h1>
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
      <div class="stats-cards">
        <div class="stat-card">
          <el-icon class="stat-icon"><Document /></el-icon>
          <div class="stat-info">
            <h3>总实验数</h3>
            <p class="stat-number">{{ stats.totalExperiments }}</p>
          </div>
        </div>
        
        <div class="stat-card">
          <el-icon class="stat-icon"><EditPen /></el-icon>
          <div class="stat-info">
            <h3>草稿实验</h3>
            <p class="stat-number">{{ stats.draftExperiments }}</p>
          </div>
        </div>
        
        <div class="stat-card">
          <el-icon class="stat-icon"><User /></el-icon>
          <div class="stat-info">
            <h3>我的实验</h3>
            <p class="stat-number">{{ stats.myExperiments }}</p>
          </div>
        </div>
      </div>
      
      <div class="menu-grid">
        <div 
          v-for="item in filteredMenuItems" 
          :key="item.id"
          class="menu-item"
          :class="{ disabled: item.disabled }"
          @click="handleMenuClick(item)"
        >
          <el-icon class="menu-icon" :class="item.iconClass">
            <component :is="item.icon" />
          </el-icon>
          <h3>{{ item.title }}</h3>
          <p>{{ item.description }}</p>
          <div v-if="item.disabled" class="disabled-overlay">
            <span>暂无访问权限</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Document,
  EditPen,
  User,
  ArrowDown,
  Plus,
  FolderOpened,
  DataAnalysis,
  Setting,
  Search
} from '@element-plus/icons-vue'

const router = useRouter()
const authStore = useAuthStore()

// 统计数据
const stats = ref({
  totalExperiments: 0,
  draftExperiments: 0,
  myExperiments: 0
})

// 用户角色显示文本
const userRoleText = computed(() => {
  const roleMap = {
    admin: '系统管理员',
    engineer: '工程师',
    user: '普通用户'
  }
  return roleMap[authStore.user?.role || 'user']
})

// 菜单项目
const menuItems = [
  {
    id: 'create',
    title: '创建新实验',
    description: '开始新的石墨实验数据录入',
    icon: Plus,
    iconClass: 'create-icon',
    route: '/experiments/create',
    roles: ['admin', 'engineer', 'user'],
    disabled: false
  },
  {
    id: 'drafts',
    title: '未完成实验',
    description: '查看和编辑草稿状态的实验',
    icon: EditPen,
    iconClass: 'drafts-icon',
    route: '/experiments/drafts',
    roles: ['admin', 'engineer', 'user'],
    disabled: false
  },
  {
    id: 'database',
    title: '实验数据库',
    description: '查询和管理所有实验记录',
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
    route: '/experiments/analysis',
    roles: ['admin', 'engineer'],
    disabled: false
  },
  {
    id: 'admin',
    title: '系统管理',
    description: '用户管理和系统配置',
    icon: Setting,
    iconClass: 'admin-icon',
    route: '/admin',
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

// 页面加载时获取统计数据
onMounted(() => {
  // 这里可以调用API获取实际的统计数据
  stats.value = {
    totalExperiments: 0,
    draftExperiments: 0,
    myExperiments: 0
  }
})
</script>

<style scoped>
.dashboard-container {
  min-height: 100vh;
  background: #f5f7fa;
}

.header {
  background: white;
  padding: 20px 40px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
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
  padding: 40px;
  max-width: 1200px;
  margin: 0 auto;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 40px;
}

.stat-card {
  background: white;
  padding: 25px;
  border-radius: 15px;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  gap: 15px;
}

.stat-icon {
  font-size: 40px;
  color: #667eea;
}

.stat-info h3 {
  color: #333;
  font-size: 14px;
  margin: 0 0 5px 0;
}

.stat-number {
  color: #667eea;
  font-size: 24px;
  font-weight: bold;
  margin: 0;
}

.menu-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 30px;
}

.menu-item {
  background: white;
  padding: 40px 30px;
  border-radius: 20px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  position: relative;
  overflow: hidden;
}

.menu-item:hover:not(.disabled) {
  transform: translateY(-5px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
}

.menu-item.disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.disabled-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  color: #999;
}

.menu-icon {
  font-size: 60px;
  margin-bottom: 20px;
}

.create-icon { color: #67c23a; }
.drafts-icon { color: #e6a23c; }
.database-icon { color: #409eff; }
.analysis-icon { color: #f56c6c; }
.admin-icon { color: #909399; }

.menu-item h3 {
  color: #333;
  font-size: 20px;
  margin-bottom: 10px;
}

.menu-item p {
  color: #666;
  font-size: 14px;
  line-height: 1.5;
  margin: 0;
}
</style>