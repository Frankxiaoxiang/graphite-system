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
    // ✅ 新增：数据分析路由 (仅管理员和工程师)
    {
      path: '/analysis',
      name: 'DataAnalysis',
      component: () => import('@/views/analysis/DataAnalysis.vue'),
      meta: {
        requiresAuth: true,
        roles: ['admin', 'engineer'] // 修正为 roles 以匹配现有守卫逻辑
      }
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
          redirect: {
            name: 'experiment-database',
            query: { status: 'draft' }
          },
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
        },
        {
          path: 'compare',
          name: 'experiment-compare',
          component: () => import('@/views/experiments/ExperimentCompare.vue'),
          meta: {
            title: '实验数据对比',
            requiresAuth: true,
            roles: ['admin', 'engineer']
          }
        },
        {
          path: 'edit/:id',
          name: 'experiment-edit',
          component: () => import('@/views/experiments/CreateExperiment.vue'),
          meta: { title: '编辑实验', requiresAuth: true }
        },
        {
          path: ':id',
          name: 'experiment-detail',
          component: () => import('@/views/experiments/ExperimentDetail.vue'),
          meta: { title: '实验详情', requiresAuth: true }
        }
      ]
    },
    {
      path: '/admin/users',
      name: 'user-management',
      component: () => import('@/views/admin/UserManagement.vue'),
      meta: { requiresAuth: true, requiresAdmin: true }
    },
    {
      path: '/admin/backup',
      name: 'database-backup',
      component: () => import('@/views/admin/DatabaseBackup.vue'),
      meta: { requiresAuth: true, requiresAdmin: true }
    }
  ]
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()

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
