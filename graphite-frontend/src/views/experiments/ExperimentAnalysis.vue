<template>
  <div class="experiment-analysis">
    <div class="header">
      <h1>数据对比与分析</h1>
      <el-button @click="$router.go(-1)">返回</el-button>
    </div>
    
    <div class="content">
      <el-alert
        title="数据分析功能正在开发中"
        type="info"
        :closable="false"
        show-icon
      />
      
      <div class="placeholder">
        <el-icon class="large-icon"><DataAnalysis /></el-icon>
        <h3>数据对比与分析</h3>
        <p>实验数据的统计分析和可视化</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { DataAnalysis } from '@element-plus/icons-vue'
</script>

<style scoped>
.experiment-analysis {
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
</style>