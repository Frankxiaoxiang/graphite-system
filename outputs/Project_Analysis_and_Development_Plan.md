# 石墨实验数据管理系统 - 项目综合分析与开发规划

**文档版本**: v2.0  
**创建日期**: 2025-10-12  
**状态**: 编码问题已修复，准备进入下一阶段  

---

## 📊 一、项目当前状态总览

### 1.1 已完成功能 ✅

#### **Phase 1-3: 基础架构 (100%完成)**
- ✅ 前端框架搭建 (Vue 3 + TypeScript + Element Plus)
- ✅ 后端框架搭建 (Flask + SQLAlchemy + MySQL)
- ✅ 数据库设计完成 (15张表，99个字段)
- ✅ JWT认证系统完整实现
- ✅ 用户登录/登出功能正常

#### **Phase 4A: 表单UI开发 (100%完成)**
- ✅ CreateExperiment.vue 完整实现 (7个Tab页)
- ✅ 9个搜索下拉框功能正常
- ✅ 表单验证规则完整
- ✅ 实验编码自动生成逻辑已修复

#### **Phase 4B: 草稿保存功能 (100%完成)** 
- ✅ POST /api/experiments/draft - 草稿保存API
- ✅ PUT /api/experiments/{id}/draft - 草稿更新API
- ✅ 前端草稿保存逻辑完善
- ✅ 实验编码格式问题已修复（3个连字符）
- ✅ JWT Token认证正常工作

---

### 1.2 已知但可接受的问题 ⚠️

1. **搜索API CORS错误** (不影响使用)
   - 现象：搜索API返回CORS错误
   - 影响：会自动fallback到本地过滤
   - 优先级：低 (可延后处理)

2. **pi_thickness_detail字段无数据** (数据库问题)
   - 现象：数据库中确实没有这个字段的数据
   - 影响：字段显示为空
   - 优先级：低 (可延后填充)

---

### 1.3 待开发功能 🚧

#### **优先级 P0 - 立即开始 (1-2天)**
- ⏳ **正式提交功能** - POST /api/experiments
  - 验证所有40个必填字段
  - 状态变更为 'submitted'
  - 提交成功后跳转到数据库页面

#### **优先级 P1 - 本周完成 (2-3天)**
- ⏳ **实验数据管理页面** - ExperimentDatabase.vue
  - 实验列表查询 (分页、搜索、筛选)
  - 实验详情查看
  - 实验数据编辑 (复用CreateExperiment.vue)
  - 实验数据删除 (权限控制)
  - 数据导出 (CSV格式)

#### **优先级 P2 - 下周完成 (2-3天)**
- ⏳ **文件上传功能** (9个字段)
  - 测试已有 FileUpload.vue 组件
  - 集成文件上传到实验提交流程
  - 文件预览和下载功能

#### **优先级 P3 - 可延后 (1-2天)**
- ⏳ **搜索下拉优化**
  - 修复CORS问题
  - 实现"添加新值"功能
  - 优化用户体验

---

## 🎯 二、关键决策：下一步做什么？

### 2.1 问题分析

您提到的两个方向：
1. **Phase 4B (继续)**: 实验数据提交API、文件上传、数据验证
2. **Phase 4C (开始)**: 数据管理功能、列表查询、编辑删除、导出

**核心矛盾**：
- 前端表单UI已完成，但**只能保存草稿，无法正式提交**
- 草稿保存后，用户**无法查看已保存的数据**
- 系统**缺少完整的数据闭环**

---

### 2.2 推荐方案：**混合开发策略** ⭐⭐⭐

#### **阶段1：完成核心数据流 (2-3天，最高优先级)**

**为什么这样安排？**
- 用户已经能创建实验、保存草稿
- 但无法正式提交、无法查看已保存的内容
- 这是**数据闭环的最后一公里**

**具体任务**：

##### **任务A：实验正式提交功能 (优先级 P0)** - 1天
```
目标：让用户能够完成实验数据的正式提交

后端开发 (4小时)：
✓ 完善 POST /api/experiments API
✓ 实现40个必填字段验证
✓ 状态变更为 'submitted'
✓ 记录 submitted_at 时间

前端开发 (2小时)：
✓ 完善 handleSubmit() 函数
✓ 添加提交前二次确认
✓ 添加提交成功后的跳转逻辑
✓ 优化错误提示

测试验证 (2小时)：
✓ 测试必填字段验证
✓ 测试提交成功流程
✓ 测试权限控制
✓ 测试错误处理
```

##### **任务B：实验列表查询页面 (优先级 P1)** - 1.5天
```
目标：让用户能够查看已保存/提交的实验

后端开发 (4小时)：
✓ GET /api/experiments - 列表查询API
✓ 支持分页、搜索、筛选
✓ 支持状态筛选 (draft/submitted)
✓ 权限控制 (用户只能看自己的)

前端开发 (8小时)：
✓ 创建 ExperimentDatabase.vue 页面
✓ 实现数据表格展示
✓ 实现搜索和筛选功能
✓ 实现分页功能
✓ 实现查看详情按钮

测试验证 (2小时)：
✓ 测试列表加载
✓ 测试搜索功能
✓ 测试筛选功能
✓ 测试分页功能
```

##### **任务C：实验详情查看页面 (优先级 P1)** - 0.5天
```
目标：让用户能够查看实验的完整数据

前端开发 (4小时)：
✓ 创建 ExperimentDetail.vue 页面
✓ 显示7个模块的完整数据
✓ 添加打印功能
✓ 添加返回列表按钮

后端无需开发：
- 已有 GET /api/experiments/{id} API

测试验证 (1小时)：
✓ 测试详情页面展示
✓ 测试打印功能
```

**完成后的效果**：
- ✅ 用户能创建实验 → 保存草稿 → 正式提交
- ✅ 用户能查看所有实验 → 查看详情 → 打印报告
- ✅ 完整的数据闭环形成

---

#### **阶段2：完善数据管理功能 (2-3天)**

##### **任务D：编辑和删除功能 (优先级 P1)** - 1.5天
```
目标：让用户能够修改和删除实验数据

后端开发 (4小时)：
✓ PUT /api/experiments/{id} - 更新实验
✓ DELETE /api/experiments/{id} - 删除实验
✓ 权限控制 (只能删除草稿)
✓ 权限控制 (只能删除自己的)

前端开发 (8小时)：
✓ 实现编辑按钮 (复用CreateExperiment.vue)
✓ 加载已有数据到表单
✓ 实现删除按钮 (二次确认)
✓ 更新列表页面的按钮状态

测试验证 (2小时)：
✓ 测试编辑功能
✓ 测试删除功能
✓ 测试权限控制
```

##### **任务E：数据导出功能 (优先级 P1)** - 0.5天
```
目标：让用户能够导出实验数据

后端开发 (3小时)：
✓ POST /api/experiments/export - 导出CSV
✓ 支持批量导出
✓ 支持筛选条件

前端开发 (1小时)：
✓ 添加导出按钮
✓ 实现文件下载

测试验证 (1小时)：
✓ 测试导出功能
✓ 测试CSV格式
```

---

#### **阶段3：文件上传功能 (2-3天)**

##### **任务F：文件上传集成 (优先级 P2)** - 2天
```
目标：让9个文件上传字段能够正常工作

后端开发 (4小时)：
✓ 测试已有 POST /api/files/upload API
✓ 实现文件存储逻辑
✓ 实现文件压缩功能
✓ 实现文件大小限制

前端开发 (10小时)：
✓ 测试 FileUpload.vue 组件
✓ 集成文件上传到实验表单
✓ 实现文件预览功能
✓ 实现文件删除功能

测试验证 (2小时)：
✓ 测试9个文件字段
✓ 测试文件上传
✓ 测试文件预览
✓ 测试文件删除
```

---

#### **阶段4：优化和完善 (1-2天)**

##### **任务G：搜索下拉优化 (优先级 P3)** - 1天
```
目标：优化搜索下拉组件的用户体验

后端开发 (2小时)：
✓ 修复CORS问题
✓ 实现"添加新值"API

前端开发 (4小时)：
✓ 重构 SearchableSelect.vue
✓ 实现"添加新值"功能
✓ 优化用户体验

测试验证 (1小时)：
✓ 测试搜索功能
✓ 测试添加新值
```

---

## 📅 三、详细开发计划

### 第1周：核心功能完成 (5个工作日)

#### **Day 1-2：实验提交 + 列表查询**
- 上午：开发实验正式提交API
- 下午：开发实验列表查询API
- 晚上：开发ExperimentDatabase.vue页面

#### **Day 3：实验详情 + 编辑删除**
- 上午：开发ExperimentDetail.vue页面
- 下午：开发编辑和删除API
- 晚上：集成编辑和删除功能

#### **Day 4：数据导出 + 测试**
- 上午：开发数据导出功能
- 下午：系统功能测试
- 晚上：修复发现的问题

#### **Day 5：文件上传集成**
- 上午：测试FileUpload.vue组件
- 下午：集成文件上传到表单
- 晚上：测试文件上传功能

---

### 第2周：优化和完善 (5个工作日)

#### **Day 6-7：文件上传完善**
- 文件预览功能
- 文件下载功能
- 文件大小限制
- 文件类型验证

#### **Day 8：搜索下拉优化**
- 修复CORS问题
- 实现"添加新值"功能
- 优化用户体验

#### **Day 9-10：系统测试和优化**
- 功能测试
- 性能优化
- 用户体验调优
- 文档更新

---

## 🔑 四、关键技术要点

### 4.1 实验提交API设计

```python
@experiments_bp.route('', methods=['POST'])
def create_experiment():
    """
    正式提交实验 - 验证所有必填字段
    
    必填字段 (40个)：
    - 基本参数 (10个)
    - PI膜参数 (4个)
    - 碳化参数 (7个)
    - 石墨化参数 (9个)
    - 成品参数 (10个)
    """
    
    # 1. JWT验证
    verify_jwt_in_request()
    current_user_id = int(get_jwt_identity())
    
    # 2. 获取数据
    data = request.get_json()
    experiment_code = data.get('experiment_code')
    
    # 3. 验证实验编码格式
    is_valid, error_msg = validate_experiment_code_format(experiment_code)
    if not is_valid:
        return jsonify({'error': error_msg}), 400
    
    # 4. 验证实验编码唯一性
    existing = Experiment.query.filter_by(experiment_code=experiment_code).first()
    if existing:
        return jsonify({'error': f'实验编码 {experiment_code} 已存在'}), 400
    
    # 5. 验证所有必填字段
    required_fields = get_required_fields_for_submission()
    missing_fields = []
    
    for field in required_fields:
        value = data.get(field)
        if value is None or value == '' or value == []:
            missing_fields.append(field)
    
    if missing_fields:
        return jsonify({
            'error': '缺少必填字段',
            'missing_fields': missing_fields
        }), 400
    
    # 6. 创建实验记录
    experiment = Experiment(
        experiment_code=experiment_code,
        creator_id=current_user_id,
        status='submitted',  # ← 关键：状态为submitted
        submitted_at=datetime.now()  # ← 关键：记录提交时间
    )
    db.session.add(experiment)
    db.session.flush()
    
    # 7. 保存所有模块数据
    _save_basic_params(experiment.id, data)
    _save_pi_params(experiment.id, data)
    _save_loose_params(experiment.id, data)
    _save_carbon_params(experiment.id, data)
    _save_graphite_params(experiment.id, data)
    _save_rolling_params(experiment.id, data)
    _save_product_params(experiment.id, data)
    
    db.session.commit()
    
    return jsonify({
        'message': '实验提交成功',
        'id': experiment.id,
        'experiment_code': experiment_code
    }), 201
```

---

### 4.2 实验列表查询API设计

```python
@experiments_bp.route('', methods=['GET'])
def get_experiments():
    """
    获取实验列表 - 支持分页、搜索、筛选
    
    查询参数：
    - page: 页码 (默认1)
    - per_page: 每页数量 (默认20)
    - status: 状态筛选 (draft/submitted)
    - search: 搜索关键词 (实验编码、客户名称)
    - customer_name: 客户名称筛选
    - date_from: 开始日期
    - date_to: 结束日期
    """
    
    # 1. JWT验证
    verify_jwt_in_request()
    current_user_id = int(get_jwt_identity())
    current_user = User.query.get(current_user_id)
    
    # 2. 获取查询参数
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    status = request.args.get('status', None)
    search = request.args.get('search', None)
    customer_name = request.args.get('customer_name', None)
    date_from = request.args.get('date_from', None)
    date_to = request.args.get('date_to', None)
    
    # 3. 构建查询
    query = Experiment.query
    
    # 权限控制：普通用户只能看自己的数据
    if current_user.role == 'user':
        query = query.filter_by(creator_id=current_user_id)
    
    # 状态筛选
    if status:
        query = query.filter_by(status=status)
    
    # 搜索关键词
    if search:
        query = query.join(ExperimentBasic).filter(
            db.or_(
                Experiment.experiment_code.like(f'%{search}%'),
                ExperimentBasic.customer_name.like(f'%{search}%')
            )
        )
    
    # 客户名称筛选
    if customer_name:
        query = query.join(ExperimentBasic).filter(
            ExperimentBasic.customer_name == customer_name
        )
    
    # 日期筛选
    if date_from:
        query = query.join(ExperimentBasic).filter(
            ExperimentBasic.experiment_date >= date_from
        )
    if date_to:
        query = query.join(ExperimentBasic).filter(
            ExperimentBasic.experiment_date <= date_to
        )
    
    # 4. 分页查询
    pagination = query.order_by(Experiment.created_at.desc()).paginate(
        page=page,
        per_page=per_page,
        error_out=False
    )
    
    # 5. 格式化响应
    experiments = []
    for exp in pagination.items:
        basic = ExperimentBasic.query.filter_by(experiment_id=exp.id).first()
        experiments.append({
            'id': exp.id,
            'experiment_code': exp.experiment_code,
            'customer_name': basic.customer_name if basic else None,
            'experiment_date': basic.experiment_date if basic else None,
            'status': exp.status,
            'created_at': exp.created_at.isoformat(),
            'creator_name': exp.creator.real_name if exp.creator else None
        })
    
    return jsonify({
        'experiments': experiments,
        'total': pagination.total,
        'page': page,
        'per_page': per_page,
        'pages': pagination.pages
    }), 200
```

---

### 4.3 前端表单提交逻辑

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

    // 7. 跳转到数据库页面
    router.push({
      name: 'ExperimentDatabase',
      query: { highlight: response.id }
    })

  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('提交实验失败:', error)
      
      // 显示详细错误信息
      if (error.response?.data?.missing_fields) {
        const fields = error.response.data.missing_fields
        ElMessage.error({
          message: `缺少必填字段：${fields.join(', ')}`,
          duration: 5000
        })
      } else {
        ElMessage.error(error.message || '提交失败')
      }
    }
  } finally {
    loading.submit = false
  }
}
```

---

## 🚀 五、立即行动计划

### 今天下午 (2-3小时)

1. **开发实验正式提交API**
   ```bash
   # 编辑文件
   graphite-backend/app/routes/experiments.py
   
   # 完善 create_experiment() 函数
   # 实现40个必填字段验证
   # 实现状态变更为 'submitted'
   ```

2. **测试提交功能**
   ```bash
   # 启动后端
   cd graphite-backend
   python run.py
   
   # 启动前端
   cd graphite-frontend
   npm run dev
   
   # 测试提交流程
   ```

---

### 明天上午 (3-4小时)

1. **开发实验列表查询API**
   ```bash
   # 编辑文件
   graphite-backend/app/routes/experiments.py
   
   # 实现 get_experiments() 函数
   # 支持分页、搜索、筛选
   ```

2. **创建ExperimentDatabase.vue页面**
   ```bash
   # 创建文件
   graphite-frontend/src/views/experiments/ExperimentDatabase.vue
   
   # 实现数据表格展示
   # 实现搜索和筛选功能
   ```

---

### 明天下午 (3-4小时)

1. **创建ExperimentDetail.vue页面**
   ```bash
   # 创建文件
   graphite-frontend/src/views/experiments/ExperimentDetail.vue
   
   # 显示7个模块的完整数据
   ```

2. **配置路由**
   ```bash
   # 编辑文件
   graphite-frontend/src/router/index.ts
   
   # 添加路由配置
   ```

---

## 📝 六、总结和建议

### 6.1 为什么推荐这个方案？

1. **快速形成数据闭环** (2-3天)
   - 用户能完整体验：创建 → 保存 → 提交 → 查看
   - 系统具备核心价值

2. **渐进式开发**
   - 每个阶段都能交付可用功能
   - 降低开发风险
   - 便于测试和调试

3. **优先级明确**
   - P0: 核心数据流 (必须)
   - P1: 数据管理 (重要)
   - P2: 文件上传 (补充)
   - P3: 优化完善 (锦上添花)

---

### 6.2 关键成功因素

1. **保持专注**
   - 不要被次要功能分散精力
   - 先完成核心流程

2. **快速迭代**
   - 每天都有可展示的进展
   - 及时发现和解决问题

3. **充分测试**
   - 每个功能开发完立即测试
   - 不要积累技术债务

---

### 6.3 风险提示

1. **时间估算**
   - 实际开发可能需要更多时间
   - 预留缓冲时间

2. **依赖问题**
   - 注意前后端接口对接
   - 及时沟通和调试

3. **用户体验**
   - 不要忽视细节
   - 错误提示要友好

---

## 🎯 七、下一步行动

### 立即开始 (现在)

1. **阅读项目知识库中的API文档**
   - docs/API_Documentation.md
   - docs/Frontend_Components_Documentation.md

2. **创建工作分支**
   ```bash
   git checkout -b feature/experiment-submission
   ```

3. **开始开发实验提交API**
   - 编辑 graphite-backend/app/routes/experiments.py
   - 实现 create_experiment() 函数
   - 添加40个必填字段验证

---

### 需要帮助？

如果在开发过程中遇到问题，可以：
1. 查阅项目知识库中的文档
2. 查看之前的聊天记录
3. 使用浏览器控制台调试
4. 查看后端Flask日志

---

**祝开发顺利！** 🚀

---

**文档结束**
