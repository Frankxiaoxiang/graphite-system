# 人工合成石墨实验数据管理系统 - 前端组件文档

**版本**: v1.2  
**最后更新**: 2025-10-12  
**状态**: 已修复实验编码生成逻辑

---

## 目录
1. [CreateExperiment.vue - 实验创建组件](#1-createexperimentvue---实验创建组件)
2. [SearchableSelect.vue - 可搜索下拉组件](#2-searchableselectvue---可搜索下拉组件)
3. [FileUpload.vue - 文件上传组件](#3-fileuploadvue---文件上传组件)
4. [实验编码生成逻辑](#4-实验编码生成逻辑)
5. [数据验证规则](#5-数据验证规则)

---

## 1. CreateExperiment.vue - 实验创建组件

### 1.1 组件概述

**文件路径**: `graphite-frontend/src/views/experiments/CreateExperiment.vue`

**功能描述**:
- 创建新实验数据
- 支持7个模块的数据录入（基本参数、PI膜、松卷、碳化、石墨化、压延、成品）
- 自动生成实验编码
- 草稿保存和正式提交
- 表单验证

### 1.2 组件结构

```vue
<template>
  <div class="create-experiment">
    <!-- 页面头部 -->
    <div class="header">
      <h1>创建新实验</h1>
      <div class="header-actions">
        <el-button @click="handleBack">返回</el-button>
        <el-button type="primary" @click="handleSaveDraft" :loading="loading.draft">
          保存草稿
        </el-button>
        <el-button type="success" @click="handleSubmit" :loading="loading.submit">
          提交实验
        </el-button>
      </div>
    </div>

    <!-- 实验编码预览 -->
    <div class="code-preview" v-if="experimentCode">
      <el-alert type="success" :closable="false">
        <template #title>
          实验编码：{{ experimentCode }}
        </template>
      </el-alert>
    </div>

    <!-- 表单内容 - 7个标签页 -->
    <el-form ref="formRef" :model="formData" :rules="rules">
      <el-tabs v-model="activeTab">
        <el-tab-pane label="实验设计参数" name="basic">
          <!-- 基本参数表单 -->
        </el-tab-pane>
        <el-tab-pane label="PI膜参数" name="pi">
          <!-- PI膜参数表单 -->
        </el-tab-pane>
        <!-- 其他5个标签页... -->
      </el-tabs>
    </el-form>
  </div>
</template>
```

### 1.3 核心功能

#### 1.3.1 实验编码自动生成

**触发条件**: 当以下9个基本参数全部填写完成时自动生成

```typescript
// 监听的字段
const basicFields = [
  'pi_film_thickness',    // PI膜厚度
  'customer_type',        // 客户类型
  'customer_name',        // 客户名称
  'pi_film_model',        // PI膜型号
  'experiment_date',      // 实验日期
  'sintering_location',   // 烧制地点
  'material_type_for_firing',  // 送烧材料类型
  'rolling_method',       // 压延方式
  'experiment_group'      // 实验编组
]

// 监听函数
watchEffect(() => {
  const allFilled = basicFields.every(field => {
    const value = formData[field]
    return value !== null && value !== undefined && value !== ''
  })
  
  if (allFilled) {
    experimentCode.value = generateExperimentCode()
  } else {
    experimentCode.value = ''
  }
})
```

#### 1.3.2 实验编码生成算法（✅ 已修复）

**修复内容**: 去除PI膜型号中的连字符，确保编码只包含3个连字符

```typescript
function generateExperimentCode(): string {
  // 段1: PI膜厚度 + 客户类型 + 客户名称代码
  // 示例: 100 + I + SA = 100ISA
  const segment1 = `${formData.pi_film_thickness}${formData.customer_type}${formData.customer_name}`
  
  // 段2: PI膜型号（✅ 去除所有连字符和空格）
  // 示例: TH5-100 → TH5100
  // 示例: GP-65 → GP65
  const segment2 = formData.pi_film_model
    .replace(/-/g, '')   // 去除连字符
    .replace(/\s/g, '')  // 去除空格
  
  // 段3: 实验日期(YYMMDD) + 烧制地点
  // 示例: 2025-10-08 → 251008, DG → 251008DG
  const dateStr = formData.experiment_date.replace(/-/g, '').substring(2)
  const segment3 = `${dateStr}${formData.sintering_location}`
  
  // 段4: 材料类型 + 压延方式 + 实验编组(两位数)
  // 示例: R + IF + 1 → RIF01
  const groupStr = String(formData.experiment_group).padStart(2, '0')
  const segment4 = `${formData.material_type_for_firing}${formData.rolling_method}${groupStr}`
  
  // ✅ 最终编码：只包含3个连字符
  // 格式：段1-段2-段3-段4
  // 示例：100ISA-TH5100-251008DG-RIF01
  return `${segment1}-${segment2}-${segment3}-${segment4}`
}
```

**编码示例**:

| 输入 | 输出 |
|------|------|
| 厚度:100, 客户:ISA, 型号:TH5-100, 日期:2025-10-08, 地点:DG, 材料:R, 压延:IF, 编组:1 | `100ISA-TH5100-251008DG-RIF01` ✅ |
| 厚度:50, 客户:DRD, 型号:GP-65, 日期:2025-10-12, 地点:XT, 材料:P, 压延:OR, 编组:5 | `50DRD-GP65-251012XT-POR05` ✅ |

#### 1.3.3 草稿保存功能

**功能特点**:
- ✅ 只验证10个基本参数
- ✅ 支持创建新草稿和更新已有草稿
- ✅ 自动保存实验ID，避免重复创建

```typescript
async function handleSaveDraft() {
  // 1. 验证基本参数（10个必填字段）
  const basicFields = [
    'pi_film_thickness', 'customer_type', 'customer_name', 'pi_film_model',
    'experiment_date', 'sintering_location', 'material_type_for_firing',
    'rolling_method', 'experiment_group', 'experiment_purpose'
  ]

  const missingFields = basicFields.filter(field => {
    const value = formData[field]
    return value === null || value === undefined || value === ''
  })

  if (missingFields.length > 0) {
    ElMessage.warning('请先完善实验设计参数中的必填字段')
    activeTab.value = 'basic'
    return
  }

  // 2. 检查实验编码是否已生成
  if (!experimentCode.value) {
    ElMessage.error('实验编码未生成，请检查基本参数是否填写完整')
    activeTab.value = 'basic'
    return
  }

  loading.draft = true

  try {
    // 准备提交数据
    const draftData = prepareSubmitData()
    let response: { id: number; experiment_code: string }

    // ✅ 关键修复：判断是创建还是更新
    if (experimentId.value) {
      // 已有草稿 → 更新
      console.log('📝 更新已有草稿，ID:', experimentId.value)
      response = await experimentApi.updateDraft(experimentId.value, draftData)

      ElMessage.success({
        message: `草稿更新成功！实验编码：${response.experiment_code}`,
        duration: 3000
      })
    } else {
      // 首次保存 → 创建
      console.log('📝 创建新草稿')
      response = await experimentApi.saveDraft(draftData)

      // ✅ 保存返回的实验 ID，后续保存将使用更新接口
      experimentId.value = response.id

      ElMessage.success({
        message: `草稿保存成功！实验编码：${response.experiment_code}`,
        duration: 3000
      })
    }

    console.log('✅ 草稿操作成功，实验ID:', response.id, '编码:', response.experiment_code)

  } catch (error: any) {
    console.error('保存草稿失败:', error)
    // 错误处理...
  } finally {
    loading.draft = false
  }
}
```

#### 1.3.4 实验提交功能

**功能特点**:
- ✅ 验证所有必填字段（约40个）
- ✅ 提交前二次确认
- ✅ 提交成功后跳转到数据库页面

```typescript
async function handleSubmit() {
  if (!formRef.value) return

  // 1. 检查实验编码
  if (!experimentCode.value) {
    ElMessage.error('实验编码未生成，请检查基本参数是否填写完整')
    activeTab.value = 'basic'
    return
  }

  loading.submit = true

  try {
    // 2. 验证所有必填字段
    await formRef.value.validate()

    // 3. 确认提交对话框
    await ElMessageBox.confirm(
      '确认提交实验数据吗？提交后将无法修改。',
      '确认提交',
      {
        confirmButtonText: '确认提交',
        cancelButtonText: '取消',
        type: 'warning',
        distinguishCancelAndClose: true
      }
    )

    // 4. 准备提交数据
    const submitData = prepareSubmitData()

    // 5. 调用API提交实验
    const response = await experimentApi.submitExperiment(submitData)

    // 6. 提交成功提示
    ElMessage.success({
      message: `实验提交成功！实验编码：${response.experiment_code}`,
      duration: 3000
    })

    // 7. 延迟跳转到实验数据库页面
    setTimeout(() => {
      router.push('/experiments/database')
    }, 1500)

  } catch (error: any) {
    // 错误处理...
  } finally {
    loading.submit = false
  }
}
```

### 1.4 数据结构

#### 1.4.1 表单数据类型

```typescript
interface ExperimentFormData {
  // 基本参数 (10个必填)
  pi_film_thickness: number | null
  customer_type: string
  customer_name: string
  pi_film_model: string
  experiment_date: string
  sintering_location: string
  material_type_for_firing: string
  rolling_method: string
  experiment_group: number | null
  experiment_purpose: string
  
  // PI膜参数 (4个必填)
  pi_manufacturer: string
  pi_thickness_detail: number | null
  pi_model_detail: string
  pi_weight: number | null
  
  // 松卷参数 (可选)
  loose_roll_type: string
  loose_roll_speed: number | null
  loose_roll_tension: number | null
  
  // 碳化参数 (7个必填)
  carbon_furnace_num: string
  carbon_batch_num: string
  carbon_max_temp: number | null
  carbon_film_thickness: number | null
  carbon_total_time: number | null
  carbon_weight: number | null
  carbon_yield_rate: number | null
  
  // 石墨化参数 (9个必填)
  graphite_furnace_num: string
  pressure_value: number | null
  graphite_max_temp: number | null
  foam_thickness: number | null
  graphite_width: number | null
  shrinkage_ratio: number | null
  graphite_total_time: number | null
  graphite_weight: number | null
  graphite_yield_rate: number | null
  
  // 压延参数 (可选)
  rolling_temperature: number | null
  rolling_pressure: number | null
  rolling_speed: number | null
  
  // 成品参数 (10个必填)
  product_avg_thickness: number | null
  product_spec: string
  product_avg_density: number | null
  thermal_diffusivity: number | null
  thermal_conductivity: number | null
  specific_heat: number | null
  cohesion: number | null
  peel_strength: number | null
  roughness: string
  appearance_description: string
  
  // 系统字段
  experiment_code?: string
  status?: string
}
```

### 1.5 使用示例

#### 路由配置

```typescript
// router/index.ts
{
  path: '/experiments/create',
  name: 'CreateExperiment',
  component: () => import('@/views/experiments/CreateExperiment.vue'),
  meta: {
    title: '创建实验',
    requiresAuth: true
  }
}
```

#### 页面访问

```
http://localhost:5173/experiments/create
```

---

## 2. SearchableSelect.vue - 可搜索下拉组件

### 2.1 组件概述

**文件路径**: `graphite-frontend/src/components/SearchableSelect.vue`

**功能描述**:
- 支持输入搜索和下拉选择
- 本地数据过滤
- 可选的远程搜索
- 支持添加新选项（预留功能）

### 2.2 组件使用

```vue
<template>
  <SearchableSelect
    v-model="formData.customer_name"
    placeholder="输入或选择客户名称"
    :options="dropdownOptions.customer_name"
    field-name="customer_name"
    field-label="客户名称"
    @search="handleSearch('customer_name', $event)"
  />
</template>

<script setup lang="ts">
import SearchableSelect from '@/components/SearchableSelect.vue'

// 下拉选项数据
const dropdownOptions = reactive({
  customer_name: [
    { value: 'SA', label: 'SA/三星' },
    { value: 'AP', label: 'AP/苹果' },
    { value: 'LG', label: 'LG/LG电子' }
  ]
})

// 搜索处理（可选）
function handleSearch(fieldName: string, keyword: string) {
  console.log(`搜索 ${fieldName}:`, keyword)
  // 可以实现远程搜索逻辑
}
</script>
```

### 2.3 Props 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `modelValue` | `string \| number` | - | v-model绑定的值 |
| `options` | `Array<{value, label}>` | `[]` | 下拉选项数据 |
| `placeholder` | `string` | `'请选择'` | 占位符文本 |
| `fieldName` | `string` | - | 字段名称 |
| `fieldLabel` | `string` | - | 字段显示名称 |
| `clearable` | `boolean` | `true` | 是否可清除 |
| `disabled` | `boolean` | `false` | 是否禁用 |
| `filterable` | `boolean` | `true` | 是否支持搜索 |

### 2.4 Events 事件

| 事件名 | 参数 | 说明 |
|--------|------|------|
| `update:modelValue` | `value: string \| number` | 值变化时触发 |
| `search` | `keyword: string` | 搜索时触发 |
| `change` | `value: string \| number` | 选择变化时触发 |

---

## 3. FileUpload.vue - 文件上传组件

### 3.1 组件概述

**文件路径**: `graphite-frontend/src/components/FileUpload.vue`

**功能描述**:
- 支持图片和文档上传
- 文件大小和类型验证
- 图片预览功能
- 上传进度显示

### 3.2 组件使用

```vue
<template>
  <FileUpload
    v-model="formData.carbon_loading_photo"
    accept="image/*"
    :max-size="10"
  />
</template>

<script setup lang="ts">
import FileUpload from '@/components/FileUpload.vue'

interface FileInfo {
  id: string
  name: string
  url: string
  size: number
  uploadTime: string
  type: string
}

const formData = reactive({
  carbon_loading_photo: null as FileInfo | null
})
</script>
```

### 3.3 Props 属性

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `modelValue` | `FileInfo \| null` | `null` | v-model绑定的文件信息 |
| `accept` | `string` | `'image/*'` | 接受的文件类型 |
| `maxSize` | `number` | `10` | 最大文件大小（MB） |

### 3.4 文件类型支持

| accept值 | 说明 |
|----------|------|
| `image/*` | 所有图片格式 (JPG, PNG, GIF) |
| `.pdf` | PDF文档 |
| `.doc,.docx` | Word文档 |
| `.xls,.xlsx` | Excel表格 |

### 3.5 文件信息结构

```typescript
interface FileInfo {
  id: string           // 文件ID
  name: string         // 文件名
  url: string          // 文件访问URL
  size: number         // 文件大小（字节）
  uploadTime: string   // 上传时间
  type: string         // MIME类型
}
```

---

## 4. 实验编码生成逻辑

### 4.1 编码规则说明

**格式**: `段1-段2-段3-段4` (共3个连字符)

| 段 | 组成 | 示例 | 说明 |
|----|------|------|------|
| 段1 | PI膜厚度 + 客户类型 + 客户名称代码 | `100ISA` | 100μm + 国际(I) + 三星(SA) |
| 段2 | PI膜型号（去除连字符和空格） | `TH5100` | 原始型号：TH5-100 |
| 段3 | 实验日期(YYMMDD) + 烧制地点 | `251008DG` | 2025-10-08 + 东莞(DG) |
| 段4 | 材料类型 + 压延方式 + 实验编组 | `RIF01` | 卷材(R) + 内部平压(IF) + 第1组 |

### 4.2 编码生成流程图

```
用户填写基本参数
        ↓
监听9个关键字段
        ↓
所有字段已填写？
    ↙          ↘
  否              是
  ↓               ↓
清空编码      生成编码
              ↓
        去除PI膜型号中的连字符
              ↓
        组装4个段落（用"-"连接）
              ↓
        显示在编码预览区
```

### 4.3 常见编码示例

| 场景 | 参数 | 生成的编码 |
|------|------|-----------|
| 标准实验 | 厚度:100, 客户:ISA, 型号:TH5-100, 日期:2025-10-08, 地点:DG, 材料:R, 压延:IF, 编组:1 | `100ISA-TH5100-251008DG-RIF01` |
| 含空格型号 | 厚度:50, 客户:DRD, 型号:GP 65, 日期:2025-10-12, 地点:XT, 材料:P, 压延:OR, 编组:5 | `50DRD-GP65-251012XT-POR05` |
| 复杂型号 | 厚度:75, 客户:NMP, 型号:TH-5-100, 日期:2025-10-15, 地点:DX, 材料:R, 压延:IR, 编组:10 | `75NMP-TH5100-251015DX-RIR10` |

### 4.4 错误处理

**前端验证**:
- 9个基本参数必须全部填写
- 实验编码自动生成，不可手动输入

**后端验证**:
```python
# 错误示例1：连字符数量错误
编码: "100ISA-TH5-100-251008DG-RIF01"  # 4个连字符 ❌
错误: "实验编码格式错误：应包含3个连字符（-），当前有4个"

# 正确示例
编码: "100ISA-TH5100-251008DG-RIF01"   # 3个连字符 ✅
```

---

## 5. 数据验证规则

### 5.1 必填字段验证

**草稿保存** (10个必填):
```typescript
const basicRequiredFields = [
  'pi_film_thickness',
  'customer_type',
  'customer_name',
  'pi_film_model',
  'experiment_date',
  'sintering_location',
  'material_type_for_firing',
  'rolling_method',
  'experiment_group',
  'experiment_purpose'
]
```

**正式提交** (约40个必填):
- 基本参数: 10个
- PI膜参数: 4个
- 碳化参数: 7个
- 石墨化参数: 9个
- 成品参数: 10个

### 5.2 Element Plus 表单验证规则

```typescript
const rules = {
  // 数字类型验证
  pi_film_thickness: [
    { required: true, message: '请输入PI膜厚度', trigger: 'blur' },
    { type: 'number', message: '必须是数字', trigger: 'blur' },
    { min: 10, max: 500, message: '厚度范围：10-500μm', trigger: 'blur', type: 'number' }
  ],
  
  // 字符串类型验证
  customer_name: [
    { required: true, message: '请选择客户名称', trigger: 'change' }
  ],
  
  // 日期类型验证
  experiment_date: [
    { required: true, message: '请选择实验日期', trigger: 'change' },
    { 
      validator: (rule, value, callback) => {
        if (new Date(value) > new Date()) {
          callback(new Error('实验日期不能晚于今天'))
        } else {
          callback()
        }
      }, 
      trigger: 'change' 
    }
  ]
}
```

### 5.3 自定义验证函数

```typescript
// 验证实验编组范围
function validateExperimentGroup(value: number): boolean {
  return value >= 1 && value <= 99
}

// 验证温度范围
function validateTemperature(value: number, min: number, max: number): boolean {
  return value >= min && value <= max
}

// 验证成碳率范围
function validateYieldRate(value: number): boolean {
  return value >= 0 && value <= 100
}
```

---

## 6. 常见问题

### Q1: 实验编码显示有4个连字符怎么办？

**原因**: PI膜型号字段包含连字符（如 `TH5-100`），前端未正确处理

**解决方案**: 
```typescript
// ✅ 正确做法
const segment2 = formData.pi_film_model
  .replace(/-/g, '')   // 去除连字符
  .replace(/\s/g, '')  // 去除空格

// ❌ 错误做法
const segment2 = formData.pi_film_model  // 直接使用原始值
```

### Q2: 草稿保存后再次保存时提示"实验编码已存在"？

**原因**: 草稿保存成功后，未保存返回的实验ID，导致再次保存时创建了新记录

**解决方案**: 
```typescript
// ✅ 保存实验ID
if (experimentId.value) {
  // 更新已有草稿
  response = await experimentApi.updateDraft(experimentId.value, draftData)
} else {
  // 创建新草稿
  response = await experimentApi.saveDraft(draftData)
  experimentId.value = response.id  // 保存ID
}
```

### Q3: 提交实验时提示"缺少必填字段"？

**原因**: 用户未填写所有必填字段

**解决方案**: 
1. 检查表单验证规则是否正确
2. 在提交前使用 `formRef.value.validate()` 验证
3. 后端错误信息会返回具体缺失的字段名

### Q4: Token过期怎么办？

**原因**: JWT Token默认有效期为24小时

**解决方案**: 
1. 重新登录（立即解决）
2. 实现Token自动刷新（长期方案）
3. 调整Token有效期配置（开发环境）

---

## 7. 开发调试技巧

### 7.1 浏览器控制台调试

```javascript
// 清除控制台
console.clear()

// 查看表单数据
console.log('表单数据:', formData)

// 查看实验编码
console.log('实验编码:', experimentCode.value)

// 查看验证错误
formRef.value.validate((valid, fields) => {
  console.log('验证结果:', valid)
  console.log('错误字段:', fields)
})
```

### 7.2 Vue Devtools

1. 安装 Vue Devtools 浏览器扩展
2. 打开开发者工具 → Vue 标签
3. 查看组件状态和Props
4. 监听事件触发

### 7.3 网络请求调试

```javascript
// 查看API请求
// 打开浏览器开发者工具 → Network 标签
// 筛选 XHR 请求
// 查看请求头、请求体和响应

// 示例：查看草稿保存请求
POST /api/experiments/draft
Request Headers:
  Authorization: Bearer eyJh...
Request Payload:
  {experiment_code: "100ISA-TH5100-251008DG-RIF01", ...}
Response:
  {id: 123, experiment_code: "100ISA-TH5100-251008DG-RIF01"}
```

---

## 8. 版本更新记录

### v1.2 (2025-10-12)
- ✅ **修复**: 实验编码生成逻辑，去除PI膜型号中的连字符
- ✅ **修复**: 草稿更新功能，避免重复创建实验
- ✅ **改进**: 错误提示更加详细友好
- ✅ **更新**: API接口文档和前端组件文档

### v1.1 (2025-10-10)
- ✅ **新增**: JWT认证和Token拦截器
- ✅ **新增**: 草稿保存和更新功能
- ✅ **修复**: CORS跨域问题

### v1.0 (2025-10-01)
- ✅ **完成**: 7个表单模块开发
- ✅ **完成**: 下拉选项功能
- ✅ **完成**: 基础UI框架

---

**文档结束**
