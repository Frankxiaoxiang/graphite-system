<template>
  <div id="app">
    <!-- 这是关键！Vue Router 的视图容器 -->
    <router-view />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

// 应用启动时初始化认证状态
onMounted(() => {
  console.log('🚀 App.vue 挂载完成，初始化认证状态...')
  authStore.initAuth()
  console.log('✅ 认证状态初始化完成')
})
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background-color: #f5f7fa;
}
</style>