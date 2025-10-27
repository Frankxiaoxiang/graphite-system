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
        }
      ]
    },
    {
      path: '/admin',
      name: 'admin',
      component: () => import('@/views/experiments/admin/AdminView.vue'),
      meta: { requiresAuth: true, roles: ['admin'] }
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
