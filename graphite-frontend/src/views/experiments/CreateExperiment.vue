<template>
  <div class="create-experiment">
    <div class="header">
      <h1>创建新实验</h1>
      <el-button @click="$router.go(-1)">返回</el-button>
    </div>
    
    <div class="content">
      <el-alert
        title="实验录入功能正在开发中"
        type="info"
        :closable="false"
        show-icon
      />
      
      <div class="placeholder">
        <el-icon class="large-icon"><DocumentAdd /></el-icon>
        <h3>实验数据录入表单</h3>
        <p>包含7个模块的完整实验数据录入界面</p>
        <ul>
          <li>实验设计参数</li>
          <li>PI膜参数</li>
          <li>松卷参数</li>
          <li>碳化参数</li>
          <li>石墨化参数</li>
          <li>压延参数</li>
          <li>成品参数</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { DocumentAdd } from '@element-plus/icons-vue'
</script>

<style scoped>
.create-experiment {
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

.content {
  padding: 40px;
  max-width: 800px;
  margin: 0 auto;
}

.placeholder {
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 15px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.large-icon {
  font-size: 80px;
  color: #667eea;
  margin-bottom: 20px;
}

.placeholder h3 {
  color: #2c3e50;
  margin-bottom: 15px;
  font-size: 24px;
}

.placeholder p {
  color: #7f8c8d;
  margin-bottom: 30px;
  font-size: 16px;
}

.placeholder ul {
  text-align: left;
  display: inline-block;
  color: #34495e;
}

.placeholder li {
  margin-bottom: 8px;
}
</style>