# 技术决策记录 (Technical Decisions Record)

**项目**: 人工合成石墨实验数据管理系统  
**最后更新**: 2024-12-13  
**项目进度**: 95% (用户管理模块已完成)

---

## 📋 目录

1. [认证与权限系统](#1-认证与权限系统)
2. [数据库设计](#2-数据库设计)
3. [前端架构](#3-前端架构)
4. [后端架构](#4-后端架构)
5. [文件管理](#5-文件管理)
6. [API设计规范](#6-api设计规范)
7. [数据对比与分析](#7-数据对比与分析)
8. [环境配置](#8-环境配置)

---

## 1. 认证与权限系统

### 1.1 JWT Token 规范

**核心决策**: JWT Identity 存储用户ID（整数）

```python
# ✅ 正确使用方式
# 登录时 (auth.py)
access_token = create_access_token(identity=user.id)

# 权限验证时 (decorators.py)
current_user_id = get_jwt_identity()
user = User.query.get(int(current_user_id))
```

**为什么这样做**:
- ✅ ID是主键，查询效率高 (`O(1)` vs `O(n)`)
- ✅ ID不可变，username可能会修改
- ✅ ID唯一性由数据库保证
- ✅ 减少token体积

**⚠️ 常见错误**:
```python
# ❌ 错误！不要用username查询
user = User.query.filter_by(username=current_user_id).first()

# ✅ 正确
user = User.query.get(int(current_user_id))
```

**相关文件**:
- `graphite-backend/app/routes/auth.py` - 登录逻辑
- `graphite-backend/app/utils/decorators.py` - 权限装饰器
- `graphite-backend/app/routes/experiments.py` - 实验API（获取当前用户）
- `graphite-backend/app/routes/admin.py` - 管理API

**Token配置**:
- **Access Token有效期**: 24小时
- **Refresh Token有效期**: 30天
- **Secret Key**: 通过环境变量配置（`JWT_SECRET_KEY`）

---

### 1.2 用户角色与权限

**三种角色**:

| 角色 | 英文标识 | 权限 |
|------|---------|------|
| 管理员 | `admin` | 全部权限：用户管理、系统配置、查看所有实验 |
| 工程师 | `engineer` | 创建/编辑/删除实验、查看自己的实验 |
| 普通用户 | `user` | 查看被分配的实验（只读） |

**权限装饰器**:

```python
# 1. 仅管理员可访问
@admin_required()
def admin_only_route():
    pass

# 2. 多角色可访问
@role_required(['admin', 'engineer'])
def engineer_and_admin_route():
    pass

# 3. 必须与 @jwt_required() 一起使用
@jwt_required()
@admin_required()
def protected_route():
    pass
```

**⚠️ 使用注意**:
- 装饰器顺序：`@jwt_required()` 必须在权限装饰器之上
- 所有权限装饰器都需要括号：`@admin_required()` 而非 `@admin_required`

---

### 1.3 密码管理规范

**核心规则**：始终使用 User 模型的方法，不直接操作 password_hash

**正确做法**：
- 设置密码：`user.set_password(password)`
- 验证密码：`user.check_password(password)`

**为什么**：
- User 模型统一使用 bcrypt 进行密码哈希
- 直接使用其他库会导致格式不兼容

**⚠️ 禁止**：
- 不要使用 `werkzeug.generate_password_hash`
- 不要直接赋值 `user.password_hash`

**相关文件**：
- `app/models/user.py` - User 模型
- `app/routes/admin.py` - 用户管理
- `app/routes/auth.py` - 认证

## 2. 数据库设计

### 2.1 实验编码规则

**格式**: `[段1]-[段2]-[段3]-[段4]` (共3个连字符)

**示例**: `100ISA-TH5100-251008DG-RIF01`

**各段含义**:
- **段1**: 客户编号 + 厚度（如 `100ISA` = 客户100 + 厚度ISA）
- **段2**: PI膜型号（如 `TH5100`，⚠️ 需去除连字符和空格）
- **段3**: 日期 + 实验人员（如 `251008DG` = 2025年10月8日 + DG）
- **段4**: 第几炉第几次（如 `RIF01` = 第1炉第1次）

**⚠️ 关键处理**:
```javascript
// 前端生成编码时（CreateExperiment.vue）
const piFilmModel = formData.piFilm.model
  .replace(/-/g, '')    // ← 必须去除连字符
  .replace(/\s/g, '')   // ← 必须去除空格

const experimentCode = `${segment1}-${piFilmModel}-${segment3}-${segment4}`
```

**为什么去除连字符**:
- 避免编码中出现多个连续连字符（如 `100ISA-TH-5100-...`）
- 保持编码格式统一
- 便于后续解析和查询

**相关文件**:
- `graphite-frontend/src/views/experiments/CreateExperiment.vue` (生成逻辑)
- `graphite-backend/app/models/experiment.py` (存储字段)

---

### 2.2 必填字段定义

**总计**: 40个必填字段

**分布**:
- **基本参数**: 10个
  - 客户编号、实验编号、厚度、日期、实验人员等
  
- **PI膜参数**: 4个
  - 型号、供应商、批次号、PI膜重量
  
- **碳化参数**: 7个
  - 温度、升温速率、保温时间、气氛等
  
- **石墨化参数**: 9个
  - 温度、升温速率、保温时间、气氛等
  
- **成品参数**: 10个
  - 电阻率、密度、抗拉强度、厚度等

**验证逻辑**:
- **前端**: 表单提交时验证（Element Plus validation）
- **后端**: API接收时验证（Flask validation）
- **数据库**: NOT NULL 约束

**相关文件**:
- `graphite-backend/app/utils/validation.py` (验证逻辑)
- `graphite-frontend/src/views/experiments/CreateExperiment.vue` (表单验证规则)

---

### 2.3 实验状态管理

**三种状态**:

| 状态 | 英文标识 | 说明 | 可编辑 |
|------|---------|------|--------|
| 草稿 | `draft` | 保存但未提交 | ✅ 是 |
| 已提交 | `submitted` | 已提交待审核 | ❌ 否 |
| 已完成 | `completed` | 实验完成 | ❌ 否 |

**状态转换**:
```
draft → submitted → completed
  ↑         ↓
  └─────────┘ (管理员可退回)
```

**相关API**:
- `POST /api/experiments/draft` - 保存草稿
- `POST /api/experiments` - 正式提交（自动设为submitted）

---

## 3. 前端架构

### 3.1 技术栈

**核心框架**:
- **Vue**: 3.4.x
- **TypeScript**: 5.x
- **Vite**: 5.x (构建工具)

**UI框架**:
- **Element Plus**: 2.5.x
- **图表**: ECharts 5.x

**状态管理**:
- **Pinia**: 2.x (替代Vuex)

**路由**:
- **Vue Router**: 4.x

**HTTP客户端**:
- **Axios**: 1.6.x

**样式预处理器**:
- **SCSS**: sass-embedded

---

### 3.2 项目结构

```
graphite-frontend/
├── src/
│   ├── api/              # API接口定义
│   │   ├── auth.ts       # 认证API
│   │   ├── experiments.ts # 实验API
│   │   ├── admin.ts      # 管理API
│   │   └── compare.ts    # 对比API
│   ├── components/       # 公共组件
│   ├── router/           # 路由配置
│   ├── stores/           # Pinia stores
│   │   └── auth.ts       # 认证状态管理
│   ├── types/            # TypeScript类型定义
│   ├── utils/            # 工具函数
│   │   └── request.ts    # Axios配置
│   └── views/            # 页面组件
│       ├── experiments/  # 实验相关页面
│       ├── admin/        # 管理相关页面
│       └── HomeView.vue  # 首页
└── public/
```

---

### 3.3 Axios 配置规范

**Base配置** (`src/utils/request.ts`):

```typescript
const api = axios.create({
  baseURL: 'http://localhost:5000',  // 开发环境
  timeout: 30000,                     // 30秒超时
  headers: {
    'Content-Type': 'application/json'
  }
})
```

**请求拦截器** (自动添加Token):

```typescript
api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  }
)
```

**响应拦截器** (统一错误处理):

```typescript
api.interceptors.response.use(
  response => response.data,
  error => {
    if (error.response?.status === 401) {
      // Token过期，跳转登录
      router.push('/login')
    }
    return Promise.reject(error)
  }
)
```

**⚠️ 注意**:
- 所有API请求统一使用 `src/utils/request.ts` 导出的实例
- 不要直接使用 `axios`，避免配置不一致

---

### 3.4 路由配置

**路由守卫** (`src/router/index.ts`):

```typescript
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  // 1. 检查是否需要认证
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
    return
  }
  
  // 2. 检查是否需要管理员权限
  if (to.meta.requiresAdmin && authStore.user?.role !== 'admin') {
    ElMessage.error('权限不足：仅管理员可访问')
    next('/')
    return
  }
  
  next()
})
```

**路由配置示例**:

```typescript
{
  path: '/admin/users',
  component: () => import('@/views/admin/UserManagement.vue'),
  meta: {
    requiresAuth: true,
    requiresAdmin: true
  }
}
```

---

## 4. 后端架构

### 4.1 技术栈

**核心框架**:
- **Flask**: 3.x
- **SQLAlchemy**: 2.x (ORM)
- **MySQL**: 8.0

**认证**:
- **Flask-JWT-Extended**: 4.x

**跨域**:
- **Flask-CORS**: 4.x

**序列化**:
- **Flask-Marshmallow**: 1.x

---

### 4.2 项目结构

```
graphite-backend/
├── app/
│   ├── __init__.py       # 应用工厂
│   ├── models/           # 数据模型
│   │   ├── user.py
│   │   ├── experiment.py
│   │   └── dropdown.py
│   ├── routes/           # 路由/控制器
│   │   ├── auth.py       # 认证路由
│   │   ├── experiments.py # 实验路由
│   │   ├── admin.py      # 管理路由
│   │   ├── compare.py    # 对比路由
│   │   └── files.py      # 文件路由
│   ├── utils/            # 工具函数
│   │   ├── decorators.py # 权限装饰器
│   │   └── validation.py # 验证工具
│   └── schemas/          # 序列化Schema
├── uploads/              # 文件上传目录
├── .env                  # 环境变量
├── app.py                # 应用入口
└── run.py                # 启动脚本
```

---

### 4.3 蓝图注册规范

**所有蓝图统一在 `__init__.py` 中注册**:

```python
# app/__init__.py

def create_app():
    # ... 配置初始化
    
    # 注册蓝图
    from app.routes.auth import auth_bp
    from app.routes.experiments import experiments_bp
    from app.routes.admin import admin_bp
    from app.routes.compare import compare_bp
    from app.routes.files import files_bp
    from app.routes.dropdown import dropdown_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(experiments_bp, url_prefix='/api/experiments')
    app.register_blueprint(admin_bp, url_prefix='/api/admin')
    app.register_blueprint(compare_bp, url_prefix='/api/compare')
    app.register_blueprint(files_bp, url_prefix='/api/files')
    app.register_blueprint(dropdown_bp, url_prefix='/api/dropdown')
    
    return app
```

**⚠️ 重要规则**:
1. **蓝图定义时不设置 `url_prefix`**
   ```python
   # ✅ 正确
   admin_bp = Blueprint('admin', __name__)
   
   # ❌ 错误（会导致路径重复）
   admin_bp = Blueprint('admin', __name__, url_prefix='/api/admin')
   ```

2. **统一在 `register_blueprint` 时设置前缀**
   ```python
   app.register_blueprint(admin_bp, url_prefix='/api/admin')
   ```

3. **新增蓝图后必须重启服务**
   - Flask自动重载只针对已加载的文件
   - 新增蓝图需要完全重启

---

### 4.4 CORS 配置

**配置位置**: `app/__init__.py`

**开发环境配置**:

```python
CORS(app, resources={
    r"/api/*": {
        "origins": "*",  # 开发环境允许所有来源
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"],
        "expose_headers": ["Content-Type", "Authorization"],
        "supports_credentials": True,
        "max_age": 3600
    }
})
```

**⚠️ 生产环境需修改**:

```python
"origins": [
    "https://your-production-domain.com",
    "https://www.your-production-domain.com"
]
```

---

## 5. 文件管理

### 5.1 文件上传配置

**存储路径**:
- **根目录**: `graphite-backend/uploads/`
- **子目录结构**: `YYYY/MM/DD/` (按日期组织)
- **文件命名**: `{timestamp}_{原文件名}`

**示例**:
```
uploads/
├── 2024/
│   └── 12/
│       └── 13/
│           ├── 1702456789_sample.jpg
│           └── 1702456790_report.pdf
```

**配置参数** (`app/__init__.py`):

```python
# 文件上传根目录
app.config['UPLOAD_FOLDER'] = os.path.join(BASE_DIR, 'uploads')

# 文件大小限制（10MB）
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024

# 允许的文件扩展名
app.config['ALLOWED_EXTENSIONS'] = {
    'png', 'jpg', 'jpeg', 'gif',    # 图片
    'pdf',                           # PDF
    'doc', 'docx',                  # Word
    'xls', 'xlsx'                   # Excel
}
```

---

### 5.2 文件字段配置

**实验数据包含10个文件字段**:

| 字段名 | 用途 | 必填 |
|--------|------|------|
| `pi_film_picture` | PI膜照片 | ❌ |
| `loose_roll_picture` | 松卷照片 | ❌ |
| `carbonization_picture` | 碳化照片 | ❌ |
| `graphitization_picture` | 石墨化照片 | ❌ |
| `rolling_picture` | 压延照片 | ❌ |
| `product_picture` | 成品照片 | ❌ |
| `tem_picture` | TEM照片 | ❌ |
| `xrd_picture` | XRD照片 | ❌ |
| `raman_picture` | Raman照片 | ❌ |
| `other_file` | 其他文件 | ❌ |

**文件URL生成**:
```python
# 存储：相对路径
file_path = "2024/12/13/1702456789_sample.jpg"

# 访问：完整URL
file_url = f"http://localhost:5000/files/{file_path}"
```

---

## 6. API设计规范

### 6.1 统一响应格式

**成功响应**:

```json
{
  "data": { ... },
  "message": "操作成功"
}
```

**失败响应**:

```json
{
  "error": "错误类型",
  "message": "用户友好的错误信息"
}
```

**分页响应**:

```json
{
  "data": [...],
  "total": 100,
  "page": 1,
  "page_size": 10,
  "total_pages": 10
}
```

---

### 6.2 HTTP状态码规范

| 状态码 | 含义 | 使用场景 |
|--------|------|---------|
| **200** | OK | 成功 |
| **201** | Created | 创建成功 |
| **400** | Bad Request | 参数错误、验证失败 |
| **401** | Unauthorized | 未认证（无token或token过期） |
| **403** | Forbidden | 已认证但权限不足 |
| **404** | Not Found | 资源不存在 |
| **500** | Internal Server Error | 服务器错误 |

**⚠️ 常见错误**:
- 用户不存在 → 404
- 权限不足 → 403
- Token过期 → 401

---

### 6.3 API端点命名规范

**RESTful规范**:

| 操作 | HTTP方法 | 端点 | 示例 |
|------|---------|------|------|
| 获取列表 | GET | `/api/resource` | `GET /api/experiments` |
| 获取单个 | GET | `/api/resource/:id` | `GET /api/experiments/123` |
| 创建 | POST | `/api/resource` | `POST /api/experiments` |
| 更新 | PUT | `/api/resource/:id` | `PUT /api/experiments/123` |
| 删除 | DELETE | `/api/resource/:id` | `DELETE /api/experiments/123` |

**特殊端点**:
- 统计数据：`GET /api/resource/stats`
- 批量操作：`POST /api/resource/batch`
- 自定义动作：`POST /api/resource/:id/action`

---

### 6.4 主要API端点

**认证相关**:
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/logout` - 用户登出

**实验管理**:
- `GET /api/experiments` - 获取实验列表
- `POST /api/experiments` - 创建实验（正式提交）
- `GET /api/experiments/:id` - 获取实验详情
- `PUT /api/experiments/:id` - 更新实验
- `DELETE /api/experiments/:id` - 删除实验
- `POST /api/experiments/draft` - 保存草稿
- `GET /api/experiments/stats` - 获取统计数据

**用户管理** (仅管理员):
- `GET /api/admin/users` - 获取用户列表
- `POST /api/admin/users` - 创建用户
- `GET /api/admin/users/:id` - 获取用户详情
- `PUT /api/admin/users/:id` - 更新用户
- `DELETE /api/admin/users/:id` - 删除用户（软删除）
- `PUT /api/admin/users/:id/password` - 重置密码
- `PUT /api/admin/users/:id/status` - 切换用户状态
- `GET /api/admin/statistics/users` - 用户统计

**数据对比**:
- `POST /api/compare/data` - 获取对比数据（2-10个实验）

**下拉选项**:
- `GET /api/dropdown/customers` - 获取客户列表
- `GET /api/dropdown/pi-films` - 获取PI膜型号列表
- 等...

---

## 7. 数据对比与分析

### 7.1 对比功能设计

**支持范围**: 2-10个实验同时对比

**对比维度**:
- 基本参数对比
- 工艺参数对比
- 成品性能对比
- 文件资料对比

**智能高亮规则**:
- 数值型字段：
  - 最大值 → 🔴 红色
  - 最小值 → 🔵 蓝色
- 文本型字段：
  - 与第一个不同 → 🟡 黄色

**API端点**:
- `POST /api/compare/data`
  ```json
  {
    "experiment_ids": [1, 2, 3, 4, 5]
  }
  ```

**相关文件**:
- `graphite-backend/app/routes/compare.py`
- `graphite-frontend/src/views/experiments/ExperimentCompare.vue`

---

### 7.2 数据分析（规划中）

**将要实现的功能**:
- 回归分析
- 相关性分析
- 趋势图表
- DOE优化建议

**技术选型**:
- 图表：ECharts（已使用）
- 前端计算：如需复杂计算考虑Web Worker
- 后端计算：NumPy + SciPy（待定）

---

## 8. 环境配置

### 8.1 开发环境

**端口配置**:
- 前端：`http://localhost:5173`
- 后端：`http://localhost:5000`

**数据库**:
- Host: `localhost`
- Port: `3306`
- Database: `graphite_db`
- Charset: `utf8mb4`

**启动命令**:

```bash
# 后端
cd graphite-backend
source venv/bin/activate  # Linux/Mac
.\venv\Scripts\activate   # Windows
python run.py

# 前端
cd graphite-frontend
npm run dev
```

---

### 8.2 环境变量配置

**后端环境变量** (`.env`):

```bash
# 数据库配置
DATABASE_URL=mysql+pymysql://root:password@localhost/graphite_db

# JWT配置
SECRET_KEY=your-secret-key-change-in-production
JWT_SECRET_KEY=jwt-secret-string

# 文件上传配置
UPLOAD_FOLDER=uploads
MAX_CONTENT_LENGTH=10485760  # 10MB

# 开发/生产环境
FLASK_ENV=development
DEBUG=True
```

**前端环境变量** (`.env.development`):

```bash
VITE_API_BASE_URL=http://localhost:5000
VITE_FILE_BASE_URL=http://localhost:5000/files
```

---

### 8.3 依赖版本锁定

**前端关键依赖**:
```json
{
  "vue": "^3.4.0",
  "vue-router": "^4.2.0",
  "pinia": "^2.1.0",
  "element-plus": "^2.5.0",
  "axios": "^1.6.0",
  "echarts": "^5.4.0",
  "sass-embedded": "^1.69.0"
}
```

**后端关键依赖**:
```
Flask==3.0.0
Flask-SQLAlchemy==3.1.1
Flask-JWT-Extended==4.6.0
Flask-CORS==4.0.0
Flask-Marshmallow==1.2.0
PyMySQL==1.1.0
python-dotenv==1.0.0
```

---

## 9. 开发规范

### 9.1 代码注释规范

**关键位置必须添加注释**:

```python
# ✅ 好的注释（说明"为什么"）
# 注意：JWT存储的是user.id（参考TECH_DECISIONS.md），
# 因此这里用ID查询，不能用username
user = User.query.get(int(user_id))

# ❌ 不好的注释（只说"做什么"）
# 查询用户
user = User.query.get(int(user_id))
```

**需要注释的场景**:
- 技术决策的关键点
- 不符合直觉的代码
- 复杂的业务逻辑
- 性能优化的代码
- 临时解决方案（需标注TODO）

---

### 9.2 Git提交规范

**提交信息格式**:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type类型**:
- `feat`: 新功能
- `fix`: Bug修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `test`: 测试
- `chore`: 构建/工具变动

**示例**:
```
fix(auth): 修复JWT使用user.id而非username的问题

- 修改 decorators.py 中的用户查询逻辑
- 将 filter_by(username=...) 改为 query.get(user_id)
- 更新相关注释说明

Closes #123
```

---

### 9.3 测试策略

**当前测试方式**:
- ✅ 手动测试（主要方式）
- ✅ 前后端日志调试
- ⏳ 自动化测试（待添加）

**建议的测试优先级**:
1. **关键路径测试**（最重要）
   - 登录 → 访问受保护资源
   - 创建实验 → 提交 → 查看
   
2. **集成测试**
   - 完整业务流程测试
   
3. **单元测试**（可选）
   - 工具函数测试
   - 验证逻辑测试

---

## 10. 常见问题（FAQ）

### Q1: 为什么 admin 路由返回 404？

**A**: 检查以下几点：
1. 后端是否重启？（新增蓝图需要重启）
2. `admin.py` 中是否设置了重复的 `url_prefix`？
3. `decorators.py` 中是否用正确的字段查询用户？

**正确做法**:
```python
# admin.py
admin_bp = Blueprint('admin', __name__)  # 不设置url_prefix

# __init__.py
app.register_blueprint(admin_bp, url_prefix='/api/admin')

# decorators.py
user = User.query.get(int(user_id))  # 用ID查询
```

---

### Q2: 前端无法连接后端？

**A**: 检查：
1. 后端是否启动？（`python run.py`）
2. CORS 是否配置？（开发环境用 `"origins": "*"`）
3. 端口是否正确？（后端5000，前端5173）

---

### Q3: 文件上传失败？

**A**: 检查：
1. 文件大小是否超过10MB？
2. 文件类型是否允许？
3. `uploads` 目录是否存在且有写权限？

---

### Q4: JWT Token 过期怎么办？

**A**: 
- Token有效期24小时
- 过期后需要重新登录
- 前端会自动跳转到登录页

---

## 11. 变更记录

| 日期 | 变更内容 | 原因 | 影响范围 |
|------|---------|------|---------|
| 2024-12-13 | JWT使用user.id而非username | 修复管理员权限检查404问题 | `decorators.py`, `role_required()` |
| 2024-12-13 | admin蓝图不设置url_prefix | 避免路径重复 | `admin.py` |
| 2024-12-13 | 添加sass-embedded依赖 | 支持SCSS编译 | `package.json` |

---

## 📚 相关文档

- **需求文档**: `graphite_requirements_doc.md`
- **项目状态**: `PROJECT_STATUS_SUMMARY.md`
- **数据库设计**: `graphite-db-schema.sql`
- **API文档**: （建议创建 `API_ENDPOINTS.md`）

---

## 🔄 文档维护

### 何时更新此文档？

1. **新增技术决策时**
   - 引入新的技术栈
   - 定义新的跨模块规范
   - 修复影响架构的Bug

2. **重要Bug修复后**
   - 记录问题原因
   - 记录解决方案
   - 添加预防措施

3. **架构变更时**
   - 数据库模型变更
   - API设计变更
   - 认证/权限逻辑变更

### 更新流程

1. 在相关章节添加/修改内容
2. 更新"变更记录"表格
3. 更新"最后更新"日期
4. 提交到版本控制

---

**维护者**: Claude + Frank  
**联系方式**: （可添加）

---

## 📝 模板：新增技术决策

```markdown
### [决策编号]. [决策名称]

**核心决策**: 简述做了什么决定

**为什么这样做**:
- 原因1
- 原因2

**使用方式**:
```代码示例```

**⚠️ 注意事项**:
- 注意点1
- 注意点2

**相关文件**:
- 文件1
- 文件2

**示例**: （可选）
```代码示例```
```

---

**END OF DOCUMENT**
