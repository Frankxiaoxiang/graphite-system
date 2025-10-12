# 石墨实验数据管理系统 - 立即行动指南

**目标**: 在3天内完成核心数据闭环  
**预计时间**: 第1天 6-8小时  
**日期**: 2025-10-12  

---

## 🎯 第1天任务：实验提交 + 列表查询

### 上午任务 (4小时): 实验正式提交API

#### Step 1: 定义必填字段 (30分钟)

**编辑文件**: `graphite-backend/app/utils/validation.py`

```python
# graphite-backend/app/utils/validation.py

"""
实验数据验证工具
"""

def get_required_fields_for_submission():
    """
    获取正式提交时的所有必填字段 (40个)
    
    返回: List[str] - 必填字段名称列表
    """
    required_fields = {
        # 基本参数 (10个) - experiment_basic表
        'pi_film_thickness': 'PI膜厚度',
        'customer_type': '客户类型',
        'customer_name': '客户名称',
        'pi_film_model': 'PI膜型号',
        'experiment_date': '实验日期',
        'sintering_location': '烧制地点',
        'material_type_for_firing': '送烧材料类型',
        'rolling_method': '压延方式',
        'experiment_group': '实验编组',
        'experiment_purpose': '实验目的',
        
        # PI膜参数 (4个) - experiment_pi表
        'pi_manufacturer': 'PI膜厂商',
        'pi_thickness_detail': 'PI膜初始厚度',
        'pi_model_detail': 'PI膜型号详情',
        'pi_weight': 'PI重量',
        
        # 碳化参数 (7个) - experiment_carbon表
        'carbon_furnace_num': '碳化炉编号',
        'carbon_batch_num': '碳化炉次',
        'carbon_max_temp': '碳化最高温度',
        'carbon_film_thickness': '碳化膜厚度',
        'carbon_total_time': '碳化总时长',
        'carbon_weight': '碳化后重量',
        'carbon_yield_rate': '碳化成碳率',
        
        # 石墨化参数 (9个) - experiment_graphite表
        'graphite_furnace_num': '石墨炉编号',
        'pressure_value': '气压值',
        'graphite_max_temp': '石墨化最高温度',
        'foam_thickness': '发泡厚度',
        'graphite_width': '石墨宽幅',
        'shrinkage_ratio': '收缩比',
        'graphite_total_time': '石墨化总时长',
        'graphite_weight': '石墨化后重量',
        'graphite_yield_rate': '石墨化成碳率',
        
        # 成品参数 (10个) - experiment_product表
        'product_avg_thickness': '样品平均厚度',
        'product_spec': '规格',
        'product_avg_density': '平均密度',
        'thermal_diffusivity': '热扩散系数',
        'thermal_conductivity': '导热系数',
        'specific_heat': '比热',
        'cohesion': '内聚力',
        'peel_strength': '剥离强度',
        'tensile_strength': '抗拉强度',
        'elongation': '延伸率'
    }
    
    return required_fields


def validate_required_fields(data: dict, required_fields: dict) -> tuple[bool, list]:
    """
    验证必填字段
    
    参数:
        data: 提交的数据字典
        required_fields: 必填字段字典 {field_name: field_label}
    
    返回:
        (is_valid, missing_fields)
        - is_valid: bool - 是否通过验证
        - missing_fields: list - 缺失的字段名称和标签
    """
    missing_fields = []
    
    for field_name, field_label in required_fields.items():
        value = data.get(field_name)
        
        # 检查字段是否存在且不为空
        if value is None or value == '' or value == []:
            missing_fields.append({
                'field': field_name,
                'label': field_label
            })
    
    return len(missing_fields) == 0, missing_fields
```

---

#### Step 2: 完善提交API (2小时)

**编辑文件**: `graphite-backend/app/routes/experiments.py`

在文件末尾找到 `create_experiment()` 函数，用以下代码替换：

```python
@experiments_bp.route('', methods=['POST', 'OPTIONS'])
def create_experiment():
    """
    正式提交实验 - 验证所有必填字段
    前端已生成实验编码，后端负责验证和存储
    """
    # 🔧 第一步：处理 OPTIONS 预检请求
    if request.method == 'OPTIONS':
        response = make_response('', 200)
        response.headers['Access-Control-Allow-Origin'] = request.headers.get('Origin', 'http://localhost:5173')
        response.headers['Access-Control-Allow-Methods'] = 'POST, OPTIONS'
        response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
        response.headers['Access-Control-Max-Age'] = '3600'
        return response
    
    # 🔧 第二步：验证 JWT
    print("\n" + "="*60)
    print("📥 收到实验提交请求")
    print("="*60)
    
    try:
        auth_header = request.headers.get('Authorization')
        print(f"🔑 Authorization 头: {auth_header[:50] if auth_header else 'None'}...")
        
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': '缺少认证令牌'}), 401
        
        verify_jwt_in_request()
        current_user_id = int(get_jwt_identity())
        print(f"✅ JWT 验证成功！用户 ID: {current_user_id}")
        
    except Exception as e:
        print(f"❌ JWT 验证失败：{str(e)}")
        return jsonify({'error': f'认证失败: {str(e)}'}), 401
    
    # 🔧 第三步：提交实验逻辑
    try:
        data = request.get_json()
        experiment_code = data.get('experiment_code')
        
        print(f"\n📦 收到数据：")
        print(f"   - 实验编码: {experiment_code}")
        print(f"   - 客户名称: {data.get('customer_name', 'N/A')}")
        
        # 1. 验证实验编码格式
        print("\n🔖 验证实验编码格式...")
        is_valid, error_msg = validate_experiment_code_format(experiment_code)
        if not is_valid:
            print(f"❌ 编码格式错误: {error_msg}")
            return jsonify({'error': error_msg}), 400
        print(f"✅ 编码格式验证通过")
        
        # 2. 验证实验编码唯一性
        print("\n🔍 检查实验编码唯一性...")
        existing = Experiment.query.filter_by(experiment_code=experiment_code).first()
        if existing:
            error_msg = f'实验编码 {experiment_code} 已存在'
            print(f"❌ {error_msg}")
            return jsonify({'error': error_msg}), 400
        print(f"✅ 实验编码唯一")
        
        # 3. 验证所有必填字段
        print("\n📋 验证必填字段...")
        required_fields = get_required_fields_for_submission()
        is_valid, missing_fields = validate_required_fields(data, required_fields)
        
        if not is_valid:
            print(f"❌ 缺少 {len(missing_fields)} 个必填字段")
            for field_info in missing_fields[:5]:  # 只打印前5个
                print(f"   - {field_info['label']} ({field_info['field']})")
            
            return jsonify({
                'error': '缺少必填字段',
                'missing_fields': [f['label'] for f in missing_fields]
            }), 400
        
        print(f"✅ 所有必填字段验证通过")
        
        # 4. 创建实验记录
        print("\n💾 创建实验记录...")
        experiment = Experiment(
            experiment_code=experiment_code,
            creator_id=current_user_id,
            status='submitted',  # ← 关键：状态为submitted
            submitted_at=datetime.now()  # ← 关键：记录提交时间
        )
        db.session.add(experiment)
        db.session.flush()  # 获取experiment.id
        
        print(f"✅ 实验记录创建成功，ID: {experiment.id}")
        
        # 5. 保存所有模块数据
        print("\n📦 保存各模块数据...")
        _save_basic_params(experiment.id, data)
        print("   ✓ 基本参数")
        
        _save_pi_params(experiment.id, data)
        print("   ✓ PI膜参数")
        
        _save_loose_params(experiment.id, data)
        print("   ✓ 松卷参数")
        
        _save_carbon_params(experiment.id, data)
        print("   ✓ 碳化参数")
        
        _save_graphite_params(experiment.id, data)
        print("   ✓ 石墨化参数")
        
        _save_rolling_params(experiment.id, data)
        print("   ✓ 压延参数")
        
        _save_product_params(experiment.id, data)
        print("   ✓ 成品参数")
        
        # 6. 提交数据库事务
        db.session.commit()
        
        print(f"\n✅ 实验提交成功！")
        print(f"   - 实验 ID: {experiment.id}")
        print(f"   - 实验编码: {experiment_code}")
        print(f"   - 状态: submitted")
        print("="*60 + "\n")
        
        # 7. 记录操作日志
        SystemLog.log_action(
            user_id=current_user_id,
            action='submit_experiment',
            target_type='experiment',
            target_id=experiment.id,
            description=f'提交实验 {experiment_code}',
            ip_address=request.remote_addr
        )
        
        return jsonify({
            'message': '实验提交成功',
            'id': experiment.id,
            'experiment_code': experiment_code
        }), 201
        
    except Exception as e:
        db.session.rollback()
        print(f"\n❌ 提交实验失败：{type(e).__name__}")
        print(f"   错误详情：{str(e)}")
        traceback.print_exc()
        print("="*60 + "\n")
        return jsonify({'error': f'提交实验失败: {str(e)}'}), 500
```

---

#### Step 3: 完善前端提交逻辑 (1小时)

**编辑文件**: `graphite-frontend/src/views/experiments/CreateExperiment.vue`

找到 `handleSubmit()` 函数，用以下代码替换：

```typescript
/**
 * 提交实验 - 验证所有必填字段并提交
 */
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

    console.log('📤 准备提交实验数据：', submitData.experiment_code)

    // 5. 调用API提交实验
    const response = await experimentApi.submitExperiment(submitData)

    console.log('✅ 实验提交成功：', response.experiment_code)

    // 6. 提交成功提示
    ElMessage.success({
      message: `实验提交成功！实验编码：${response.experiment_code}`,
      duration: 3000,
      showClose: true
    })

    // 7. 跳转到数据库页面
    setTimeout(() => {
      router.push({
        name: 'ExperimentDatabase',
        query: { highlight: response.id }
      })
    }, 1000)

  } catch (error: any) {
    if (error !== 'cancel') {
      console.error('❌ 提交实验失败:', error)
      
      // 显示详细错误信息
      if (error.response?.data?.missing_fields) {
        const fields = error.response.data.missing_fields
        const fieldList = fields.slice(0, 5).join('、')
        const moreText = fields.length > 5 ? `等${fields.length}个字段` : ''
        
        ElMessage.error({
          message: `缺少必填字段：${fieldList}${moreText}`,
          duration: 5000,
          showClose: true
        })
      } else if (error.response?.data?.error) {
        ElMessage.error({
          message: error.response.data.error,
          duration: 5000,
          showClose: true
        })
      } else {
        ElMessage.error({
          message: error.message || '提交失败，请重试',
          duration: 3000,
          showClose: true
        })
      }
    }
  } finally {
    loading.submit = false
  }
}
```

---

#### Step 4: 更新API接口 (30分钟)

**编辑文件**: `graphite-frontend/src/api/experiments.ts`

确保有 `submitExperiment` 函数：

```typescript
/**
 * 提交实验（正式提交）
 */
export async function submitExperiment(data: any) {
  return request.post('/experiments', data)
}
```

---

#### Step 5: 测试提交功能 (1小时)

```bash
# 1. 启动后端
cd graphite-backend
source venv/bin/activate  # Windows: venv\Scripts\activate
python run.py

# 2. 启动前端
cd graphite-frontend
npm run dev

# 3. 测试流程
# ✓ 登录系统
# ✓ 填写基本参数（10个必填字段）
# ✓ 生成实验编码
# ✓ 填写其他模块的必填字段
# ✓ 点击"提交实验"
# ✓ 确认提交
# ✓ 验证提交成功提示
```

**测试清单**：
- [ ] 缺少必填字段时，是否显示错误提示？
- [ ] 填写所有必填字段后，能否成功提交？
- [ ] 提交成功后，是否跳转到数据库页面？
- [ ] 后端日志是否显示"实验提交成功"？

---

### 下午任务 (4小时): 实验列表查询API + 前端页面

#### Step 6: 创建列表查询API (1.5小时)

**编辑文件**: `graphite-backend/app/routes/experiments.py`

在文件末尾添加以下代码：

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
    print("\n" + "="*60)
    print("📥 收到实验列表查询请求")
    print("="*60)
    
    try:
        # 1. JWT验证
        verify_jwt_in_request()
        current_user_id = int(get_jwt_identity())
        current_user = User.query.get(current_user_id)
        
        print(f"✅ JWT 验证成功！用户 ID: {current_user_id}, 角色: {current_user.role}")
        
        # 2. 获取查询参数
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        status = request.args.get('status', None)
        search = request.args.get('search', None)
        customer_name = request.args.get('customer_name', None)
        date_from = request.args.get('date_from', None)
        date_to = request.args.get('date_to', None)
        
        print(f"\n📊 查询参数：")
        print(f"   - 页码: {page}")
        print(f"   - 每页: {per_page}")
        print(f"   - 状态: {status or '全部'}")
        print(f"   - 搜索: {search or '无'}")
        
        # 3. 构建查询
        query = Experiment.query
        
        # 权限控制：普通用户只能看自己的数据
        if current_user.role == 'user':
            query = query.filter_by(creator_id=current_user_id)
            print(f"   - 权限: 仅显示用户自己的数据")
        else:
            print(f"   - 权限: 显示所有数据")
        
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
        
        print(f"\n📋 查询结果：共 {pagination.total} 条记录")
        
        # 5. 格式化响应
        experiments = []
        for exp in pagination.items:
            basic = ExperimentBasic.query.filter_by(experiment_id=exp.id).first()
            experiments.append({
                'id': exp.id,
                'experiment_code': exp.experiment_code,
                'customer_name': basic.customer_name if basic else None,
                'pi_film_thickness': basic.pi_film_thickness if basic else None,
                'experiment_date': basic.experiment_date.isoformat() if basic and basic.experiment_date else None,
                'status': exp.status,
                'status_display': '草稿' if exp.status == 'draft' else '已提交',
                'created_at': exp.created_at.isoformat() if exp.created_at else None,
                'submitted_at': exp.submitted_at.isoformat() if exp.submitted_at else None,
                'creator_name': exp.creator.real_name if exp.creator else None
            })
        
        print("="*60 + "\n")
        
        return jsonify({
            'experiments': experiments,
            'total': pagination.total,
            'page': page,
            'per_page': per_page,
            'pages': pagination.pages
        }), 200
        
    except Exception as e:
        print(f"❌ 查询实验列表失败：{type(e).__name__}")
        print(f"   错误详情：{str(e)}")
        traceback.print_exc()
        print("="*60 + "\n")
        return jsonify({'error': f'查询失败: {str(e)}'}), 500
```

---

#### Step 7: 创建实验列表页面 (2小时)

**创建文件**: `graphite-frontend/src/views/experiments/ExperimentDatabase.vue`

```vue
<template>
  <div class="experiment-database">
    <!-- 页面头部 -->
    <div class="header">
      <h1>📊 实验数据库</h1>
      <el-button type="primary" @click="router.push('/experiments/create')">
        <el-icon><Plus /></el-icon>
        创建新实验
      </el-button>
    </div>

    <!-- 搜索筛选区 -->
    <div class="search-section">
      <el-form :inline="true">
        <el-form-item label="搜索">
          <el-input 
            v-model="searchForm.search" 
            placeholder="实验编码或客户名称"
            clearable
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" clearable placeholder="全部">
            <el-option label="草稿" value="draft" />
            <el-option label="已提交" value="submitted" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="实验日期">
          <el-date-picker
            v-model="searchForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            clearable
          />
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="handleSearch">
            <el-icon><Search /></el-icon>
            搜索
          </el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <!-- 数据表格 -->
    <div class="table-section">
      <el-table 
        v-loading="loading"
        :data="tableData" 
        stripe
        :row-class-name="getRowClassName"
      >
        <el-table-column prop="experiment_code" label="实验编码" width="220" />
        <el-table-column prop="customer_name" label="客户名称" width="120" />
        <el-table-column prop="pi_film_thickness" label="PI膜厚度" width="100" />
        <el-table-column prop="experiment_date" label="实验日期" width="120" />
        <el-table-column prop="status_display" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'draft' ? 'warning' : 'success'">
              {{ row.status_display }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="creator_name" label="创建人" width="100" />
        <el-table-column prop="created_at" label="创建时间" width="180" />
        
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button 
              type="primary" 
              size="small" 
              @click="handleView(row.id)"
            >
              查看
            </el-button>
            <el-button 
              v-if="row.status === 'draft'" 
              type="warning" 
              size="small" 
              @click="handleEdit(row.id)"
            >
              编辑
            </el-button>
            <el-button 
              v-if="canDelete(row)" 
              type="danger" 
              size="small" 
              @click="handleDelete(row.id)"
            >
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.per_page"
          :page-sizes="[10, 20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="loadData"
          @current-change="loadData"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Search } from '@element-plus/icons-vue'
import * as experimentApi from '@/api/experiments'

const router = useRouter()

// 搜索表单
const searchForm = reactive({
  search: '',
  status: '',
  dateRange: []
})

// 分页
const pagination = reactive({
  page: 1,
  per_page: 20,
  total: 0,
  pages: 0
})

// 表格数据
const tableData = ref([])
const loading = ref(false)

/**
 * 加载数据
 */
async function loadData() {
  loading.value = true
  
  try {
    const params: any = {
      page: pagination.page,
      per_page: pagination.per_page
    }
    
    if (searchForm.search) {
      params.search = searchForm.search
    }
    
    if (searchForm.status) {
      params.status = searchForm.status
    }
    
    if (searchForm.dateRange && searchForm.dateRange.length === 2) {
      params.date_from = searchForm.dateRange[0]
      params.date_to = searchForm.dateRange[1]
    }
    
    const response = await experimentApi.getExperiments(params)
    
    tableData.value = response.experiments
    pagination.total = response.total
    pagination.pages = response.pages
    
    console.log('✅ 数据加载成功，共', response.total, '条记录')
    
  } catch (error: any) {
    console.error('❌ 加载数据失败:', error)
    ElMessage.error(error.message || '加载数据失败')
  } finally {
    loading.value = false
  }
}

/**
 * 搜索
 */
function handleSearch() {
  pagination.page = 1  // 重置到第一页
  loadData()
}

/**
 * 重置搜索
 */
function handleReset() {
  searchForm.search = ''
  searchForm.status = ''
  searchForm.dateRange = []
  pagination.page = 1
  loadData()
}

/**
 * 查看详情
 */
function handleView(id: number) {
  router.push(`/experiments/${id}`)
}

/**
 * 编辑实验
 */
function handleEdit(id: number) {
  router.push(`/experiments/edit/${id}`)
}

/**
 * 删除实验
 */
async function handleDelete(id: number) {
  try {
    await ElMessageBox.confirm(
      '确定要删除这条实验记录吗？删除后无法恢复。',
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await experimentApi.deleteExperiment(id)
    ElMessage.success('删除成功')
    loadData()
    
  } catch (error: any) {
    if (error !== 'cancel') {
      ElMessage.error(error.message || '删除失败')
    }
  }
}

/**
 * 判断是否可以删除
 */
function canDelete(row: any) {
  // 只有草稿状态才能删除
  // TODO: 添加权限判断（管理员可以删除所有，用户只能删除自己的）
  return row.status === 'draft'
}

/**
 * 行高亮
 */
function getRowClassName({ row }: { row: any }) {
  const query = router.currentRoute.value.query
  if (query.highlight && String(row.id) === String(query.highlight)) {
    return 'highlight-row'
  }
  return ''
}

// 页面加载时获取数据
onMounted(() => {
  loadData()
})
</script>

<style scoped>
.experiment-database {
  min-height: 100vh;
  background: #f5f7fa;
}

.header {
  background: white;
  padding: 20px 40px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header h1 {
  margin: 0;
  color: #2c3e50;
}

.search-section {
  background: white;
  padding: 20px 40px;
  margin: 20px 40px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.table-section {
  background: white;
  padding: 20px 40px;
  margin: 0 40px 40px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

/* 高亮行 */
:deep(.highlight-row) {
  background-color: #ecf5ff !important;
  animation: highlight 2s ease-in-out;
}

@keyframes highlight {
  0% {
    background-color: #409eff;
  }
  100% {
    background-color: #ecf5ff;
  }
}
</style>
```

---

#### Step 8: 更新API接口 (15分钟)

**编辑文件**: `graphite-frontend/src/api/experiments.ts`

添加以下函数：

```typescript
/**
 * 获取实验列表
 */
export async function getExperiments(params: any) {
  return request.get('/experiments', { params })
}

/**
 * 获取实验详情
 */
export async function getExperimentDetail(id: number) {
  return request.get(`/experiments/${id}`)
}

/**
 * 删除实验
 */
export async function deleteExperiment(id: number) {
  return request.delete(`/experiments/${id}`)
}
```

---

#### Step 9: 配置路由 (15分钟)

**编辑文件**: `graphite-frontend/src/router/index.ts`

添加以下路由：

```typescript
{
  path: '/experiments/database',
  name: 'ExperimentDatabase',
  component: () => import('@/views/experiments/ExperimentDatabase.vue'),
  meta: {
    title: '实验数据库',
    requiresAuth: true
  }
},
{
  path: '/experiments/:id',
  name: 'ExperimentDetail',
  component: () => import('@/views/experiments/ExperimentDetail.vue'),
  meta: {
    title: '实验详情',
    requiresAuth: true
  }
}
```

---

#### Step 10: 测试列表页面 (1小时)

```bash
# 访问页面
http://localhost:5173/experiments/database
```

**测试清单**：
- [ ] 页面是否正常加载？
- [ ] 数据表格是否显示？
- [ ] 搜索功能是否正常？
- [ ] 分页功能是否工作？
- [ ] 查看按钮是否可点击？
- [ ] 高亮显示是否正常？

---

## ✅ 第1天完成标志

完成以下内容后，第1天任务完成：

1. ✅ 实验提交API开发完成
2. ✅ 前端提交逻辑完善
3. ✅ 提交功能测试通过
4. ✅ 实验列表查询API完成
5. ✅ 实验列表页面创建完成
6. ✅ 列表页面测试通过

---

## 🎯 明天任务预告

### 第2天：实验详情 + 编辑删除

**上午 (4小时)**:
- 创建 ExperimentDetail.vue 页面
- 显示完整的7个模块数据
- 实现打印功能

**下午 (4小时)**:
- 开发编辑和删除API
- 实现编辑功能（复用CreateExperiment.vue）
- 实现删除功能
- 完整测试

---

## 💡 遇到问题？

### 常见问题

1. **Token过期**
   - 重新登录获取新Token

2. **CORS错误**
   - 检查后端CORS配置
   - 检查请求头是否正确

3. **数据不显示**
   - 检查后端日志
   - 检查浏览器控制台

4. **路由跳转失败**
   - 检查路由配置
   - 检查路由参数

---

**开始第1天的开发吧！** 💪🚀

---

**文档结束**
