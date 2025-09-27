<template>
  <div class="login-container">
    <div class="login-card">
      <div class="header">
        <h1 class="title">石墨实验管理系统</h1>
        <p class="subtitle">Graphite Experiment Management System</p>
      </div>
      
      <el-form 
        ref="loginFormRef" 
        :model="loginForm" 
        :rules="rules" 
        class="login-form"
        @submit.prevent="handleLogin"
      >
        <el-form-item prop="username">
          <el-input
            v-model="loginForm.username"
            size="large"
            placeholder="请输入用户名"
            :prefix-icon="User"
            clearable
          />
        </el-form-item>
        
        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            size="large"
            placeholder="请输入密码"
            :prefix-icon="Lock"
            show-password
            @keyup.enter="handleLogin"
          />
        </el-form-item>
        
        <el-form-item>
          <el-button
            type="primary"
            size="large"
            class="login-btn"
            :loading="authStore.loading"
            @click="handleLogin"
          >
            {{ authStore.loading ? '登录中...' : '登 录' }}
          </el-button>
        </el-form-item>
      </el-form>
      
      <!-- 测试账号提示 -->
      <div class="test-info">
        <el-alert
          title="测试账号提示"
          type="info"
          :closable="false"
        >
          <p><strong>管理员：</strong>用户名包含"admin"，密码任意</p>
          <p><strong>工程师：</strong>用户名包含"engineer"，密码任意</p>
          <p><strong>普通用户：</strong>其他用户名，密码任意</p>
        </el-alert>
      </div>
      
      <div class="footer">
        <p class="version">版本 v1.0.0</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ElMessage, ElForm } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'

const router = useRouter()
const authStore = useAuthStore()

// 表单引用
const loginFormRef = ref<InstanceType<typeof ElForm>>()

// 表单数据
const loginForm = reactive({
  username: '',
  password: ''
})

// 表单验证规则
const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 1, message: '请输入密码', trigger: 'blur' }
  ]
}

// 处理登录
const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  try {
    // 表单验证
    const valid = await loginFormRef.value.validate()
    if (!valid) return
    
    console.log('📝 准备登录:', loginForm)
    
    // 调用登录API - 关键修复：传递正确的对象格式
    await authStore.login({
      username: loginForm.username,
      password: loginForm.password
    })
    
    ElMessage.success('登录成功')
    router.push('/')
    
  } catch (error: any) {
    console.error('❌ 登录失败:', error)
    ElMessage.error(error.message || '登录失败，请检查用户名和密码')
  }
}

console.log('🔑 LoginView 组件已挂载')
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.login-card {
  background: white;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  padding: 60px 50px;
  width: 100%;
  max-width: 450px;
  position: relative;
  overflow: hidden;
}

.login-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #667eea, #764ba2);
}

.header {
  text-align: center;
  margin-bottom: 40px;
}

.title {
  font-size: 28px;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 8px 0;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.subtitle {
  font-size: 14px;
  color: #7f8c8d;
  margin: 0;
  font-weight: 400;
}

.login-form {
  margin-bottom: 30px;
}

.login-btn {
  width: 100%;
  height: 48px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 12px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border: none;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
  transition: all 0.3s ease;
}

.login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.6);
}

.test-info {
  margin-bottom: 20px;
}

.test-info p {
  margin: 5px 0;
  font-size: 12px;
}

.footer {
  text-align: center;
  color: #95a5a6;
  font-size: 12px;
}

.version {
  margin: 0;
}

/* Element Plus 组件样式覆盖 */
:deep(.el-input__wrapper) {
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 0 15px;
}

:deep(.el-input__wrapper:hover) {
  box-shadow: 0 2px 12px rgba(102, 126, 234, 0.2);
}

:deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 2px 12px rgba(102, 126, 234, 0.4);
}

:deep(.el-alert) {
  border-radius: 8px;
}
</style>