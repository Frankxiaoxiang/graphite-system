<template>
  <div class="searchable-select">
    <el-select
      v-model="selectedValue"
      :placeholder="placeholder"
      filterable
      remote
      clearable
      :remote-method="handleSearch"
      :loading="loading"
      @change="handleChange"
      @clear="handleClear"
    >
      <el-option
        v-for="option in filteredOptions"
        :key="option.value"
        :label="option.label"
        :value="option.value"
      />
      
      <!-- 新增选项按钮 -->
      <template #footer v-if="canAdd && searchKeyword.length >= 2">
        <div class="add-option-footer">
          <el-button
            type="primary"
            size="small"
            @click="handleAddNew"
            :icon="Plus"
          >
            新增 "{{ searchKeyword }}"
          </el-button>
        </div>
      </template>
    </el-select>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, defineProps, defineEmits } from 'vue'
import { Plus } from '@element-plus/icons-vue'

interface Option {
  value: string | number
  label: string
}

interface Props {
  modelValue: string | number | null
  placeholder?: string
  options?: Option[]
  type?: 'text' | 'number'
  canAdd?: boolean
}

interface Emits {
  (e: 'update:modelValue', value: string | number | null): void
  (e: 'search', keyword: string): void
  (e: 'add-new', value: string): void
  (e: 'change', value: string | number | null): void
}

const props = withDefaults(defineProps<Props>(), {
  placeholder: '请选择或输入',
  options: () => [],
  type: 'text',
  canAdd: false
})

const emit = defineEmits<Emits>()

const selectedValue = ref(props.modelValue)
const searchKeyword = ref('')
const loading = ref(false)

// 过滤后的选项
const filteredOptions = computed(() => {
  if (!searchKeyword.value) {
    return props.options
  }
  
  return props.options.filter(option =>
    option.label.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
    option.value.toString().toLowerCase().includes(searchKeyword.value.toLowerCase())
  )
})

// 监听外部值变化
watch(() => props.modelValue, (newValue) => {
  selectedValue.value = newValue
})

// 监听内部值变化
watch(selectedValue, (newValue) => {
  emit('update:modelValue', newValue)
})

// 处理搜索
async function handleSearch(keyword: string) {
  searchKeyword.value = keyword
  
  if (keyword.length >= 2) {
    loading.value = true
    try {
      emit('search', keyword)
    } finally {
      // 延迟取消loading，给外部组件时间更新选项
      setTimeout(() => {
        loading.value = false
      }, 300)
    }
  }
}

// 处理选择变化
function handleChange(value: string | number | null) {
  emit('change', value)
}

// 处理清空
function handleClear() {
  searchKeyword.value = ''
  emit('change', null)
}

// 处理新增选项
function handleAddNew() {
  if (searchKeyword.value.trim()) {
    let value = searchKeyword.value.trim()
    
    // 如果是数字类型，转换为数字
    if (props.type === 'number' && !isNaN(Number(value))) {
      value = Number(value)
    }
    
    emit('add-new', value)
    searchKeyword.value = ''
  }
}
</script>

<style scoped>
.searchable-select {
  width: 100%;
}

.add-option-footer {
  padding: 8px 12px;
  border-top: 1px solid #e4e7ed;
  background: #f8f9fa;
}

.add-option-footer .el-button {
  width: 100%;
}

:deep(.el-select) {
  width: 100%;
}

:deep(.el-select__popper) {
  max-height: 300px;
}
</style>