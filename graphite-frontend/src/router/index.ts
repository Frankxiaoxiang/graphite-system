import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: { requiresAuth: false }
    },
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/HomeView.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/experiments',
      name: 'experiments',
      children: [
        {
          path: 'create',
          name: 'experiment-create',
          component: () => import('@/views/experiments/CreateExperiment.vue'),
          meta: { requiresAuth: true }
        },
        {
          path: 'drafts',
          name: 'experiment-drafts',
          component: () => import('@/views/experiments/DraftExperiments.vue'),
          meta: { requiresAuth: true }
        },
        {
          path: 'database',
          name: 'experiment-database',
          component: () => import('@/views/experiments/ExperimentDatabase.vue'),
          meta: { requiresAuth: true, roles: ['admin', 'engineer'] }
        },
        {
          path: 'analysis',
          name: 'experiment-analysis',
          component: () => import('@/views/experiments/ExperimentAnalysis.vue'),
          meta: { requiresAuth: true, roles: ['admin', 'engineer'] }
        }
      ]
    },
    {
      path: '/admin',
      name: 'admin',
      // 核心修复：使用正确的AdminView.vue路径
      component: () => import('@/views/experiments/admin/AdminView.vue'),
      meta: { requiresAuth: true, roles: ['admin'] }
    }
  ]
})

// 路由守卫 - 移除调试日志
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  // 初始化认证状态
  if (!authStore.user) {
    authStore.initAuth()
  }
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else if (to.meta.roles && !to.meta.roles.includes(authStore.user?.role)) {
    next('/')
  } else if (to.path === '/login' && authStore.isAuthenticated) {
    next('/')
  } else {
    next()
  }
})

export default router