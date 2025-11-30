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
      @focus="handleFocus"
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
  modelValue: string | number | null | undefined  // 添加 undefined
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

const selectedValue = ref(props.modelValue ?? null)  // 将undefined转为null
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

  console.log('🔍 SearchableSelect: 搜索触发', { keyword, length: keyword.length })

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
  } else if (keyword.length === 0) {
    // ✅ 修复：当搜索关键词为空时，也触发搜索事件
    // 这样父组件可以重新加载完整的选项列表
    console.log('🔄 SearchableSelect: 关键词为空，请求重新加载完整列表')
    emit('search', '')
  }
}

// 处理选择变化
function handleChange(value: string | number | null) {
  emit('change', value)
}

// ✅ 修复：处理清空
function handleClear() {
  console.log('🧹 SearchableSelect: 清空选项')
  searchKeyword.value = ''

  // ✅ 关键修复：触发搜索空字符串，让父组件重新加载完整列表
  emit('search', '')
  emit('change', null)
}

// ✅ 新增：处理获得焦点
function handleFocus() {
  console.log('👀 SearchableSelect: 获得焦点', {
    hasValue: !!selectedValue.value,
    optionsCount: props.options.length,
    keyword: searchKeyword.value
  })

  // 如果没有选中值且选项列表为空，重新加载
  if (!selectedValue.value && props.options.length === 0) {
    console.log('🔄 SearchableSelect: 选项为空，重新加载')
    emit('search', '')
  }
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
