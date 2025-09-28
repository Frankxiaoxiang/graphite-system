<template>
  <el-dialog
    v-model="dialogVisible"
    :title="`新增${fieldLabel}`"
    width="500px"
    :close-on-click-modal="false"
    @close="handleClose"
  >
    <el-form
      ref="formRef"
      :model="formData"
      :rules="formRules"
      label-width="100px"
    >
      <!-- 根据字段类型显示不同的表单 -->
      <template v-if="fieldName === 'customer_name'">
        <el-form-item label="客户代码" prop="code" required>
          <el-input 
            v-model="formData.code" 
            placeholder="请输入客户代码，如: SA"
            maxlength="10"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="客户全名" prop="fullName" required>
          <el-input 
            v-model="formData.fullName" 
            placeholder="请输入客户全名，如: 三星"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="预览" v-if="formData.code && formData.fullName">
          <el-tag type="info">{{ formData.code }}/{{ formData.fullName }}</el-tag>
        </el-form-item>
      </template>

      <template v-else-if="fieldName === 'pi_film_model'">
        <el-form-item label="型号代码" prop="model" required>
          <el-input 
            v-model="formData.model" 
            placeholder="请输入PI膜型号，如: THS55"
            maxlength="20"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="规格说明" prop="description">
          <el-input 
            v-model="formData.description" 
            type="textarea"
            :rows="2"
            placeholder="可选，输入型号规格说明"
            maxlength="100"
            show-word-limit
          />
        </el-form-item>
      </template>

      <template v-else-if="fieldName === 'pi_manufacturer'">
        <el-form-item label="厂商名称" prop="name" required>
          <el-input 
            v-model="formData.name" 
            placeholder="请输入PI膜厂商名称"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="厂商代码" prop="code">
          <el-input 
            v-model="formData.code" 
            placeholder="可选，输入厂商代码"
            maxlength="10"
            show-word-limit
          />
        </el-form-item>
      </template>

      <template v-else-if="fieldName === 'sintering_location'">
        <el-form-item label="地点代码" prop="code" required>
          <el-input 
            v-model="formData.code" 
            placeholder="请输入地点代码，如: SZ"
            maxlength="10"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="地点全名" prop="fullName" required>
          <el-input 
            v-model="formData.fullName" 
            placeholder="请输入地点全名，如: 深圳"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="预览" v-if="formData.code && formData.fullName">
          <el-tag type="warning">{{ formData.code }}/{{ formData.fullName }}</el-tag>
        </el-form-item>
        
        <el-alert
          title="注意：烧制地点需要管理员审批后才能生效"
          type="warning"
          :closable="false"
          show-icon
        />
      </template>

      <!-- 通用字段 -->
      <template v-else>
        <el-form-item label="选项值" prop="value" required>
          <el-input 
            v-model="formData.value" 
            :placeholder="`请输入${fieldLabel}`"
            maxlength="100"
            show-word-limit
          />
        </el-form-item>
        
        <el-form-item label="描述" prop="description">
          <el-input 
            v-model="formData.description" 
            type="textarea"
            :rows="2"
            placeholder="可选，输入描述信息"
            maxlength="200"
            show-word-limit
          />
        </el-form-item>
      </template>
    </el-form>

    <template #footer>
      <div class="dialog-footer">
        <el-button @click="handleClose">取消</el-button>
        <el-button type="primary" @click="handleConfirm" :loading="loading">
          确认添加
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, watch, computed, defineProps, defineEmits } from 'vue'
import { ElMessage, ElForm } from 'element-plus'

interface Props {
  modelValue: boolean
  fieldName: string
  fieldLabel: string
}

interface Emits {
  (e: 'update:modelValue', value: boolean): void
  (e: 'confirm', data: any): void
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const formRef = ref<InstanceType<typeof ElForm>>()
const dialogVisible = ref(props.modelValue)
const loading = ref(false)

// 表单数据
const formData = reactive({
  code: '',
  fullName: '',
  name: '',
  model: '',
  value: '',
  description: ''
})

// 表单验证规则
const formRules = computed(() => {
  const baseRules = {
    required: { required: true, message: '此项不能为空', trigger: 'blur' },
    code: { 
      pattern: /^[A-Z0-9]+$/, 
      message: '代码只能包含大写字母和数字', 
      trigger: 'blur' 
    }
  }

  switch (props.fieldName) {
    case 'customer_name':
      return {
        code: [baseRules.required, baseRules.code],
        fullName: [baseRules.required]
      }
    
    case 'pi_film_model':
      return {
        model: [baseRules.required]
      }
    
    case 'pi_manufacturer':
      return {
        name: [baseRules.required]
      }
    
    case 'sintering_location':
      return {
        code: [baseRules.required, baseRules.code],
        fullName: [baseRules.required]
      }
    
    default:
      return {
        value: [baseRules.required]
      }
  }
})

// 监听外部visible变化
watch(() => props.modelValue, (newValue) => {
  dialogVisible.value = newValue
  if (newValue) {
    resetForm()
  }
})

// 监听内部visible变化
watch(dialogVisible, (newValue) => {
  emit('update:modelValue', newValue)
})

// 重置表单
function resetForm() {
  formData.code = ''
  formData.fullName = ''
  formData.name = ''
  formData.model = ''
  formData.value = ''
  formData.description = ''
  
  if (formRef.value) {
    formRef.value.clearValidate()
  }
}

// 关闭对话框
function handleClose() {
  dialogVisible.value = false
  resetForm()
}

// 确认添加
async function handleConfirm() {
  if (!formRef.value) return

  try {
    await formRef.value.validate()
    
    loading.value = true
    
    // 根据字段类型构造不同的数据格式
    let submitData: any = {}
    
    switch (props.fieldName) {
      case 'customer_name':
        submitData = {
          value: `${formData.code}/${formData.fullName}`,
          label: `${formData.code}/${formData.fullName}`,
          code: formData.code,
          fullName: formData.fullName
        }
        break
      
      case 'pi_film_model':
        submitData = {
          value: formData.model,
          label: formData.model,
          description: formData.description
        }
        break
      
      case 'pi_manufacturer':
        submitData = {
          value: formData.name,
          label: formData.name,
          code: formData.code,
          description: formData.description
        }
        break
      
      case 'sintering_location':
        submitData = {
          value: `${formData.code}/${formData.fullName}`,
          label: `${formData.code}/${formData.fullName}`,
          code: formData.code,
          fullName: formData.fullName,
          needsApproval: true
        }
        break
      
      default:
        submitData = {
          value: formData.value,
          label: formData.value,
          description: formData.description
        }
        break
    }
    
    emit('confirm', submitData)
    
    // 成功后关闭对话框
    setTimeout(() => {
      dialogVisible.value = false
      resetForm()
    }, 100)
    
  } catch (error) {
    console.error('表单验证失败:', error)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.dialog-footer {
  text-align: right;
}

:deep(.el-form-item__label) {
  font-weight: 500;
}

:deep(.el-alert) {
  margin-top: 12px;
}

:deep(.el-tag) {
  padding: 4px 8px;
  font-size: 13px;
}
</style>