<template>
  <div class="file-upload">
    <el-upload
      ref="uploadRef"
      class="upload-component"
      :action="uploadUrl"
      :headers="uploadHeaders"
      :accept="accept"
      :multiple="false"
      :show-file-list="false"
      :before-upload="beforeUpload"
      :on-success="handleSuccess"
      :on-error="handleError"
      :on-progress="handleProgress"
    >
      <template #trigger>
        <el-button type="primary" :icon="Upload" :loading="uploading">
          {{ uploading ? '上传中...' : '选择文件' }}
        </el-button>
      </template>
      
      <template #tip>
        <div class="upload-tip">
          支持格式: {{ acceptText }}, 最大{{ maxSize }}MB
        </div>
      </template>
    </el-upload>

    <!-- 上传进度 -->
    <div v-if="uploading" class="upload-progress">
      <el-progress :percentage="uploadProgress" :stroke-width="6" />
    </div>

    <!-- 已上传文件显示 -->
    <div v-if="fileInfo" class="uploaded-file">
      <div class="file-item">
        <div class="file-info">
          <el-icon class="file-icon">
            <Document v-if="isDocument" />
            <Picture v-else />
          </el-icon>
          <div class="file-details">
            <div class="file-name">{{ fileInfo.name }}</div>
            <div class="file-meta">
              {{ formatFileSize(fileInfo.size) }} | {{ formatDate(fileInfo.uploadTime) }}
            </div>
          </div>
        </div>
        
        <div class="file-actions">
          <el-button 
            type="primary" 
            size="small" 
            text 
            @click="previewFile"
            v-if="canPreview"
          >
            预览
          </el-button>
          <el-button 
            type="primary" 
            size="small" 
            text 
            @click="downloadFile"
          >
            下载
          </el-button>
          <el-button 
            type="danger" 
            size="small" 
            text 
            @click="removeFile"
          >
            删除
          </el-button>
        </div>
      </div>
    </div>

    <!-- 图片预览对话框 -->
    <el-dialog 
      v-model="previewVisible" 
      title="图片预览" 
      width="60%" 
      :center="true"
    >
      <div class="preview-container">
        <img :src="previewUrl" alt="预览图片" class="preview-image" />
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, defineProps, defineEmits } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Upload, Document, Picture } from '@element-plus/icons-vue'
import { useAuthStore } from '@/stores/auth'

interface FileInfo {
  id?: string
  name: string
  url: string
  size: number
  uploadTime: string
  type: string
}

interface Props {
  modelValue: FileInfo | null
  accept?: string
  maxSize?: number // MB
}

interface Emits {
  (e: 'update:modelValue', value: FileInfo | null): void
}

const props = withDefaults(defineProps<Props>(), {
  accept: 'image/*',
  maxSize: 10
})

const emit = defineEmits<Emits>()
const authStore = useAuthStore()

const uploadRef = ref()
const uploading = ref(false)
const uploadProgress = ref(0)
const fileInfo = ref<FileInfo | null>(props.modelValue)
const previewVisible = ref(false)
const previewUrl = ref('')

// 上传地址和请求头
const uploadUrl = computed(() => `${import.meta.env.VITE_API_BASE_URL}/api/upload`)
const uploadHeaders = computed(() => ({
  'Authorization': `Bearer ${authStore.token}`
}))

// 接受的文件类型文本
const acceptText = computed(() => {
  const acceptMap = {
    'image/*': 'JPG/PNG/GIF',
    '.pdf': 'PDF',
    '.doc,.docx': 'Word文档',
    '.xls,.xlsx': 'Excel表格'
  }
  
  for (const [key, value] of Object.entries(acceptMap)) {
    if (props.accept.includes(key)) {
      return value
    }
  }
  
  return props.accept
})

// 是否为文档类型
const isDocument = computed(() => {
  if (!fileInfo.value) return false
  const ext = getFileExtension(fileInfo.value.name)
  return ['pdf', 'doc', 'docx', 'xls', 'xlsx'].includes(ext)
})

// 是否可以预览
const canPreview = computed(() => {
  if (!fileInfo.value) return false
  const ext = getFileExtension(fileInfo.value.name)
  return ['jpg', 'jpeg', 'png', 'gif'].includes(ext)
})

// 监听外部值变化
watch(() => props.modelValue, (newValue) => {
  fileInfo.value = newValue
})

// 监听内部值变化
watch(fileInfo, (newValue) => {
  emit('update:modelValue', newValue)
}, { deep: true })

// 上传前验证
function beforeUpload(file: File) {
  // 检查文件大小
  const isLtMaxSize = file.size / 1024 / 1024 < props.maxSize
  if (!isLtMaxSize) {
    ElMessage.error(`文件大小不能超过 ${props.maxSize}MB`)
    return false
  }

  // 检查文件类型
  if (props.accept !== '*') {
    const acceptTypes = props.accept.split(',').map(type => type.trim())
    const isValidType = acceptTypes.some(type => {
      if (type.startsWith('.')) {
        // 扩展名匹配
        const ext = '.' + getFileExtension(file.name)
        return type === ext
      } else if (type.includes('*')) {
        // MIME类型匹配
        const [mainType] = type.split('/')
        return file.type.startsWith(mainType)
      } else {
        // 完整MIME类型匹配
        return file.type === type
      }
    })
    
    if (!isValidType) {
      ElMessage.error(`不支持的文件类型，请上传 ${acceptText.value} 格式的文件`)
      return false
    }
  }

  uploading.value = true
  uploadProgress.value = 0
  return true
}

// 上传进度
function handleProgress(event: any) {
  uploadProgress.value = Math.round(event.percent)
}

// 上传成功
function handleSuccess(response: any) {
  uploading.value = false
  uploadProgress.value = 100
  
  if (response.success) {
    fileInfo.value = {
      id: response.data.id,
      name: response.data.originalName,
      url: response.data.url,
      size: response.data.size,
      uploadTime: new Date().toISOString(),
      type: response.data.mimeType
    }
    
    ElMessage.success('文件上传成功')
  } else {
    ElMessage.error(response.message || '上传失败')
  }
}

// 上传失败
function handleError(error: any) {
  uploading.value = false
  uploadProgress.value = 0
  console.error('上传失败:', error)
  ElMessage.error('文件上传失败')
}

// 预览文件
function previewFile() {
  if (fileInfo.value && canPreview.value) {
    previewUrl.value = fileInfo.value.url
    previewVisible.value = true
  }
}

// 下载文件
function downloadFile() {
  if (fileInfo.value) {
    const link = document.createElement('a')
    link.href = fileInfo.value.url
    link.download = fileInfo.value.name
    link.target = '_blank'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }
}

// 删除文件
async function removeFile() {
  try {
    await ElMessageBox.confirm('确认删除此文件吗？', '确认删除', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    fileInfo.value = null
    ElMessage.success('文件已删除')
  } catch {
    // 用户取消删除
  }
}

// 获取文件扩展名
function getFileExtension(filename: string): string {
  return filename.split('.').pop()?.toLowerCase() || ''
}

// 格式化文件大小
function formatFileSize(size: number): string {
  if (size < 1024) {
    return size + ' B'
  } else if (size < 1024 * 1024) {
    return (size / 1024).toFixed(1) + ' KB'
  } else {
    return (size / (1024 * 1024)).toFixed(1) + ' MB'
  }
}

// 格式化日期
function formatDate(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleString('zh-CN')
}
</script>

<style scoped>
.file-upload {
  width: 100%;
}

.upload-component {
  width: 100%;
}

.upload-tip {
  color: #909399;
  font-size: 12px;
  margin-top: 8px;
}

.upload-progress {
  margin-top: 12px;
}

.uploaded-file {
  margin-top: 12px;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  background: #f8f9fa;
}

.file-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
}

.file-info {
  display: flex;
  align-items: center;
  flex: 1;
}

.file-icon {
  font-size: 24px;
  color: #409eff;
  margin-right: 12px;
}

.file-details {
  flex: 1;
}

.file-name {
  font-weight: 500;
  color: #2c3e50;
  margin-bottom: 4px;
  word-break: break-all;
}

.file-meta {
  font-size: 12px;
  color: #909399;
}

.file-actions {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

.preview-container {
  text-align: center;
}

.preview-image {
  max-width: 100%;
  max-height: 70vh;
  object-fit: contain;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .file-item {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .file-actions {
    justify-content: center;
  }
}
</style>