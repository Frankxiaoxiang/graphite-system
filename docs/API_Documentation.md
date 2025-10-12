# 人工合成石墨实验数据管理系统 - API接口文档

**版本**: v1.2  
**最后更新**: 2025-10-12  
**状态**: 已修复实验编码格式错误

---

## 目录
1. [认证接口](#1-认证接口)
2. [实验数据接口](#2-实验数据接口)
3. [下拉选项接口](#3-下拉选项接口)
4. [文件上传接口](#4-文件上传接口)
5. [错误码说明](#5-错误码说明)

---

## 1. 认证接口

### 1.1 用户登录

**接口**: `POST /api/auth/login`  
**描述**: 用户登录，获取JWT Token  
**认证**: 无需认证  

**请求体**:
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**响应示例**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "admin",
    "role": "admin",
    "real_name": "系统管理员",
    "email": "admin@example.com"
  }
}
```

**状态码**:
- `200 OK`: 登录成功
- `401 Unauthorized`: 用户名或密码错误

---

### 1.2 退出登录

**接口**: `POST /api/auth/logout`  
**描述**: 退出登录，清除Token  
**认证**: 需要Bearer Token  

**请求头**:
```
Authorization: Bearer <access_token>
```

**响应示例**:
```json
{
  "message": "登出成功"
}
```

---

### 1.3 获取当前用户信息

**接口**: `GET /api/auth/profile`  
**描述**: 获取当前登录用户的详细信息  
**认证**: 需要Bearer Token  

**响应示例**:
```json
{
  "id": 1,
  "username": "admin",
  "role": "admin",
  "real_name": "系统管理员",
  "email": "admin@example.com",
  "created_at": "2025-01-01T00:00:00",
  "last_login": "2025-10-12T08:00:00"
}
```

---

## 2. 实验数据接口

### 2.1 保存草稿

**接口**: `POST /api/experiments/draft`  
**描述**: 保存实验草稿，只需验证基本参数（10个必填字段）  
**认证**: 需要Bearer Token  

**必填字段** (基本参数):
- `pi_film_thickness`: PI膜厚度 (number)
- `customer_type`: 客户类型 (string)
- `customer_name`: 客户名称 (string)
- `pi_film_model`: PI膜型号 (string)
- `experiment_date`: 实验日期 (YYYY-MM-DD)
- `sintering_location`: 烧制地点 (string)
- `material_type_for_firing`: 送烧材料类型 (string)
- `rolling_method`: 压延方式 (string)
- `experiment_group`: 实验编组 (number)
- `experiment_purpose`: 实验目的 (string)

**关键特性**:
- ✅ 前端自动生成实验编码（格式：`段1-段2-段3-段4`，共3个连字符）
- ✅ 后端验证编码格式和唯一性
- ✅ 自动去除PI膜型号中的连字符和空格

**实验编码规则**:
```
格式：[段1]-[段2]-[段3]-[段4]  (共3个连字符)

段1: PI膜厚度 + 客户类型 + 客户代码        (如：100ISA)
段2: PI膜型号（去除连字符和空格）           (如：TH5100，原始为TH5-100)
段3: 实验日期(YYMMDD) + 烧制地点          (如：251008DG)
段4: 材料类型 + 压延方式 + 实验编组         (如：RIF01)

完整示例：100ISA-TH5100-251008DG-RIF01
```

**请求体示例**:
```json
{
  "experiment_code": "100ISA-TH5100-251008DG-RIF01",
  "pi_film_thickness": 100,
  "customer_type": "I",
  "customer_name": "SA",
  "pi_film_model": "TH5-100",
  "experiment_date": "2025-10-08",
  "sintering_location": "DG",
  "material_type_for_firing": "R",
  "rolling_method": "IF",
  "experiment_group": 1,
  "experiment_purpose": "测试新工艺参数对产品性能的影响"
}
```

**响应示例**:
```json
{
  "message": "草稿保存成功",
  "id": 123,
  "experiment_code": "100ISA-TH5100-251008DG-RIF01"
}
```

**状态码**:
- `201 Created`: 草稿创建成功
- `400 Bad Request`: 请求参数错误
  - 缺少必填字段
  - 实验编码格式错误（包含4个连字符而非3个）
  - 实验编码已存在
- `401 Unauthorized`: 未认证或Token过期
- `500 Internal Server Error`: 服务器内部错误

---

### 2.2 更新草稿

**接口**: `PUT /api/experiments/{id}/draft`  
**描述**: 更新已有草稿，只验证基本参数  
**认证**: 需要Bearer Token  

**路径参数**:
- `id`: 实验ID (integer)

**权限规则**:
- 只能更新自己创建的草稿
- 只能更新状态为 `draft` 的实验

**请求体**: 同"保存草稿"接口

**响应示例**:
```json
{
  "message": "草稿更新成功",
  "id": 123,
  "experiment_code": "100ISA-TH5100-251008DG-RIF01"
}
```

**状态码**:
- `200 OK`: 更新成功
- `400 Bad Request`: 请求参数错误或只能更新草稿状态的实验
- `403 Forbidden`: 无权限更新此实验
- `404 Not Found`: 实验不存在

---

### 2.3 提交实验（正式提交）

**接口**: `POST /api/experiments`  
**描述**: 正式提交实验，验证所有必填字段（约40个）  
**认证**: 需要Bearer Token  

**必填字段分类**:

#### 基本参数 (10个) - experiment_basic表
- `pi_film_thickness`: PI膜厚度
- `customer_type`: 客户类型
- `customer_name`: 客户名称
- `pi_film_model`: PI膜型号
- `experiment_date`: 实验日期
- `sintering_location`: 烧制地点
- `material_type_for_firing`: 送烧材料类型
- `rolling_method`: 压延方式
- `experiment_group`: 实验编组
- `experiment_purpose`: 实验目的

#### PI膜参数 (4个) - experiment_pi表
- `pi_manufacturer`: PI膜厂商
- `pi_thickness_detail`: PI膜初始厚度
- `pi_model_detail`: PI膜型号详情
- `pi_weight`: PI重量

#### 碳化参数 (7个) - experiment_carbon表
- `carbon_furnace_num`: 碳化炉编号
- `carbon_batch_num`: 碳化炉次
- `carbon_max_temp`: 碳化最高温度
- `carbon_film_thickness`: 碳化膜厚度
- `carbon_total_time`: 碳化总时长
- `carbon_weight`: 碳化后重量
- `carbon_yield_rate`: 碳化成碳率

#### 石墨化参数 (9个) - experiment_graphite表
- `graphite_furnace_num`: 石墨炉编号
- `pressure_value`: 气压值
- `graphite_max_temp`: 石墨化最高温度
- `foam_thickness`: 发泡厚度
- `graphite_width`: 石墨宽幅
- `shrinkage_ratio`: 收缩比
- `graphite_total_time`: 石墨化总时长
- `graphite_weight`: 石墨化后重量
- `graphite_yield_rate`: 石墨化成碳率

#### 成品参数 (10个) - experiment_product表
- `product_avg_thickness`: 样品平均厚度
- `product_spec`: 规格
- `product_avg_density`: 平均密度
- `thermal_diffusivity`: 热扩散系数
- `thermal_conductivity`: 导热系数
- `specific_heat`: 比热
- `cohesion`: 内聚力
- `peel_strength`: 剥离力
- `roughness`: 粗糙度
- `appearance_description`: 外观描述

**请求体示例** (完整数据):
```json
{
  "experiment_code": "100ISA-TH5100-251008DG-RIF01",
  
  // 基本参数
  "pi_film_thickness": 100,
  "customer_type": "I",
  "customer_name": "SA",
  "pi_film_model": "TH5-100",
  "experiment_date": "2025-10-08",
  "sintering_location": "DG",
  "material_type_for_firing": "R",
  "rolling_method": "IF",
  "experiment_group": 1,
  "experiment_purpose": "测试新工艺参数对产品性能的影响",
  
  // PI膜参数
  "pi_manufacturer": "SKC",
  "pi_thickness_detail": 100,
  "pi_model_detail": "TH5-100",
  "pi_weight": 50.5,
  
  // 碳化参数
  "carbon_furnace_num": "C-001",
  "carbon_batch_num": "20251008-01",
  "carbon_max_temp": 1200,
  "carbon_film_thickness": 95,
  "carbon_total_time": 180,
  "carbon_weight": 45.2,
  "carbon_yield_rate": 89.5,
  
  // 石墨化参数
  "graphite_furnace_num": "G-001",
  "pressure_value": 0.8,
  "graphite_max_temp": 2800,
  "foam_thickness": 2.5,
  "graphite_width": 500,
  "shrinkage_ratio": 5.2,
  "graphite_total_time": 240,
  "graphite_weight": 42.8,
  "graphite_yield_rate": 94.7,
  
  // 成品参数
  "product_avg_thickness": 90,
  "product_spec": "500x600mm",
  "product_avg_density": 2.15,
  "thermal_diffusivity": 450,
  "thermal_conductivity": 1500,
  "specific_heat": 0.71,
  "cohesion": 85,
  "peel_strength": 120,
  "roughness": "Ra 0.8",
  "appearance_description": "表面光滑，无明显缺陷"
}
```

**响应示例**:
```json
{
  "message": "实验提交成功",
  "id": 123,
  "experiment_code": "100ISA-TH5100-251008DG-RIF01"
}
```

**状态码**:
- `201 Created`: 提交成功
- `400 Bad Request`: 缺少必填字段或数据验证失败
- `401 Unauthorized`: 未认证或Token过期
- `500 Internal Server Error`: 服务器内部错误

---

### 2.4 获取实验列表

**接口**: `GET /api/experiments`  
**描述**: 获取实验列表（分页）  
**认证**: 需要Bearer Token  

**查询参数**:
- `page`: 页码（默认：1）
- `size`: 每页数量（默认：20）
- `status`: 状态过滤（draft/submitted/approved）
- `customer_name`: 客户名称搜索
- `pi_film_model`: PI膜型号搜索
- `experiment_code`: 实验编码搜索
- `date_from`: 起始日期（YYYY-MM-DD）
- `date_to`: 结束日期（YYYY-MM-DD）

**请求示例**:
```
GET /api/experiments?page=1&size=20&status=submitted
```

**响应示例**:
```json
{
  "data": [
    {
      "id": 123,
      "experiment_code": "100ISA-TH5100-251008DG-RIF01",
      "status": "submitted",
      "pi_film_thickness": 100,
      "customer_name": "SA",
      "pi_film_model": "TH5-100",
      "experiment_date": "2025-10-08",
      "created_by_name": "张工程师",
      "created_at": "2025-10-08T10:30:00",
      "updated_at": "2025-10-08T15:45:00",
      "submitted_at": "2025-10-08T15:45:00"
    }
  ],
  "total": 100,
  "page": 1,
  "size": 20,
  "pages": 5
}
```

---

### 2.5 获取实验详情

**接口**: `GET /api/experiments/{id}`  
**描述**: 获取单个实验的完整数据  
**认证**: 需要Bearer Token  

**路径参数**:
- `id`: 实验ID

**响应示例**:
```json
{
  "id": 123,
  "experiment_code": "100ISA-TH5100-251008DG-RIF01",
  "status": "submitted",
  
  // 包含所有模块的完整数据
  "pi_film_thickness": 100,
  "customer_type": "I",
  "customer_name": "SA",
  // ... 其他所有字段
  
  "created_by": 1,
  "created_by_name": "张工程师",
  "created_at": "2025-10-08T10:30:00",
  "updated_at": "2025-10-08T15:45:00",
  "submitted_at": "2025-10-08T15:45:00"
}
```

---

### 2.6 删除实验

**接口**: `DELETE /api/experiments/{id}`  
**描述**: 删除实验记录  
**认证**: 需要Bearer Token  

**权限规则**:
- 只能删除自己创建的实验
- 只能删除草稿状态的实验

**响应示例**:
```json
{
  "message": "实验删除成功"
}
```

**状态码**:
- `200 OK`: 删除成功
- `403 Forbidden`: 无权限删除此实验
- `404 Not Found`: 实验不存在

---

## 3. 下拉选项接口

### 3.1 获取下拉选项

**接口**: `GET /api/dropdown/options/{field_name}`  
**描述**: 获取指定字段的下拉选项  
**认证**: 需要Bearer Token  

**路径参数**:
- `field_name`: 字段名称

**支持的字段**:
- `customer_type`: 客户类型
- `customer_name`: 客户名称
- `pi_film_model`: PI膜型号
- `pi_manufacturer`: PI膜厂商
- `pi_film_thickness`: PI膜厚度
- `sintering_location`: 烧制地点
- `material_type_for_firing`: 送烧材料类型
- `rolling_method`: 压延方式

**请求示例**:
```
GET /api/dropdown/options/customer_type
```

**响应示例**:
```json
{
  "field_name": "customer_type",
  "options": [
    {
      "value": "I",
      "label": "I：国际客户（International）",
      "sort_order": 1
    },
    {
      "value": "D",
      "label": "D：国内客户（Domestic）",
      "sort_order": 2
    },
    {
      "value": "N",
      "label": "N：内部客户（Neibu）",
      "sort_order": 3
    }
  ]
}
```

---

### 3.2 搜索下拉选项

**接口**: `GET /api/dropdown/options/{field_name}/search`  
**描述**: 搜索下拉选项（用于可搜索字段）  
**认证**: 需要Bearer Token  

**查询参数**:
- `q`: 搜索关键词

**请求示例**:
```
GET /api/dropdown/options/customer_name/search?q=SA
```

**响应示例**:
```json
{
  "field_name": "customer_name",
  "options": [
    {
      "value": "SA",
      "label": "SA/三星"
    }
  ]
}
```

---

## 4. 文件上传接口

### 4.1 上传文件

**接口**: `POST /api/files/upload`  
**描述**: 上传实验相关文件（图片、文档等）  
**认证**: 需要Bearer Token  

**请求类型**: `multipart/form-data`

**表单字段**:
- `file`: 文件对象
- `experiment_id`: 实验ID（可选）
- `field_name`: 字段名称

**文件限制**:
- 最大文件大小：10MB
- 支持的文件类型：
  - 图片：JPG, PNG, GIF
  - 文档：PDF, DOC, DOCX, XLS, XLSX

**响应示例**:
```json
{
  "id": "file_12345",
  "name": "sample.jpg",
  "url": "/uploads/2025/10/sample_12345.jpg",
  "size": 1048576,
  "uploadTime": "2025-10-12T10:30:00",
  "type": "image/jpeg"
}
```

---

## 5. 错误码说明

### HTTP状态码

| 状态码 | 说明 | 常见原因 |
|--------|------|----------|
| 200 | 成功 | 请求成功处理 |
| 201 | 已创建 | 资源创建成功 |
| 400 | 错误请求 | 参数验证失败、数据格式错误 |
| 401 | 未认证 | Token缺失、过期或无效 |
| 403 | 禁止访问 | 权限不足 |
| 404 | 未找到 | 资源不存在 |
| 500 | 服务器错误 | 服务器内部错误 |

### 业务错误码

**认证相关**:
```json
{
  "error": "缺少认证令牌"
}
```

**验证相关**:
```json
{
  "error": "缺少必填字段",
  "missing_fields": ["pi_weight", "carbon_furnace_num"]
}
```

**实验编码相关**:
```json
{
  "error": "实验编码格式错误：应包含3个连字符（-），当前有4个"
}
```

```json
{
  "error": "实验编码 100ISA-TH5100-251008DG-RIF01 已存在"
}
```

---

## 附录：实验编码生成算法

### 前端实现 (CreateExperiment.vue)

```typescript
function generateExperimentCode() {
  // 段1: PI膜厚度 + 客户类型 + 客户名称代码
  const segment1 = `${formData.pi_film_thickness}${formData.customer_type}${formData.customer_name}`
  
  // 段2: PI膜型号（去除连字符和空格） ✅ 关键修复
  const segment2 = formData.pi_film_model.replace(/-/g, '').replace(/\s/g, '')
  
  // 段3: 实验日期(YYMMDD) + 烧制地点
  const dateStr = formData.experiment_date.replace(/-/g, '').substring(2)
  const segment3 = `${dateStr}${formData.sintering_location}`
  
  // 段4: 材料类型 + 压延方式 + 实验编组
  const groupStr = String(formData.experiment_group).padStart(2, '0')
  const segment4 = `${formData.material_type_for_firing}${formData.rolling_method}${groupStr}`
  
  // 组装编码：共3个连字符
  return `${segment1}-${segment2}-${segment3}-${segment4}`
}
```

### 后端验证 (experiment_code.py)

```python
def validate_experiment_code_format(code: str) -> tuple[bool, str]:
    """验证实验编码格式"""
    if not code:
        return False, "实验编码不能为空"
    
    # 检查连字符数量（应该是3个）
    hyphen_count = code.count('-')
    if hyphen_count != 3:
        return False, f"实验编码格式错误：应包含3个连字符（-），当前有{hyphen_count}个"
    
    # 分割编码
    parts = code.split('-')
    if len(parts) != 4:
        return False, "实验编码格式错误：应包含4个段落"
    
    # 验证各段格式
    # 段1: 数字+字母 (如：100ISA)
    # 段2: 字母数字组合 (如：TH5100) - 不应包含连字符
    # 段3: 6位数字+字母 (如：251008DG)
    # 段4: 字母+数字 (如：RIF01)
    
    return True, ""
```

---

**文档结束**
