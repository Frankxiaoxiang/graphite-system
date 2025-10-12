# 石墨实验数据管理系统 - 数据库结构文档

**最后更新**: 2025-10-10  
**版本**: v1.1  
**数据库**: graphite_db (MySQL 8.0+)

---

## 📊 数据库概览

### 表结构总览

| 表名 | 中文名 | 字段数 | 说明 |
|------|--------|--------|------|
| `users` | 用户表 | 10 | 用户认证和权限管理 |
| `experiments` | 实验主表 | 9 | 实验基本信息和状态 |
| `experiment_basic` | 实验设计参数表 | 13 | 10个必填参数 |
| `experiment_pi` | PI膜参数表 | 8 | PI膜相关参数 |
| `experiment_loose` | 松卷参数表 | 6 | 松卷工艺参数 |
| `experiment_carbon` | 碳化参数表 | 20 | 碳化工艺参数 |
| `experiment_graphite` | 石墨化参数表 | 33 | 石墨化工艺参数 ⭐ |
| `experiment_rolling` | 压延参数表 | 6 | 压延工艺参数 |
| `experiment_product` | 成品参数表 | 18 | 成品检测参数 |
| `dropdown_options` | 下拉选项表 | 8 | 下拉字段选项配置 |
| `system_logs` | 系统日志表 | 10 | 操作日志记录 |

**总表数**: 11  
**总字段数**: 约150+

---

## 🔑 核心表结构

### 1. experiments（实验主表）

```sql
CREATE TABLE experiments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    experiment_code VARCHAR(50) UNIQUE NOT NULL COMMENT '实验编码',
    status ENUM('draft', 'submitted', 'completed') DEFAULT 'draft',
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    submitted_at TIMESTAMP NULL,
    version INT DEFAULT 1,
    notes TEXT,
    FOREIGN KEY (created_by) REFERENCES users(id)
);
```

**关系**:
- 一对一关联 7 个子表（basic, pi, loose, carbon, graphite, rolling, product）
- 多对一关联 users 表

---

### 2. experiment_graphite（石墨化参数表）⭐

**最近更新**: 2025-10-10 添加温度/厚度配对字段

```sql
CREATE TABLE experiment_graphite (
    id INT PRIMARY KEY AUTO_INCREMENT,
    experiment_id INT UNIQUE NOT NULL,
    
    -- 基础参数
    graphite_furnace_number VARCHAR(50) COMMENT '石墨化炉编号',
    graphite_furnace_batch INT COMMENT '石墨化炉次',
    graphite_start_time DATETIME COMMENT '开始时间',
    graphite_end_time DATETIME COMMENT '结束时间',
    gas_pressure DECIMAL(10,4) COMMENT '气体压力',
    graphite_power DECIMAL(10,2) COMMENT '功率',
    
    -- ⭐ 温度/厚度配对字段（2025-10-10新增）
    graphite_temp1 DECIMAL(8,2) COMMENT '石墨化温度1(℃)',
    graphite_thickness1 DECIMAL(8,2) COMMENT '石墨化厚度1(μm)',
    graphite_temp2 DECIMAL(8,2) COMMENT '石墨化温度2(℃)',
    graphite_thickness2 DECIMAL(8,2) COMMENT '石墨化厚度2(μm)',
    graphite_temp3 DECIMAL(8,2) COMMENT '石墨化温度3(℃)',
    graphite_thickness3 DECIMAL(8,2) COMMENT '石墨化厚度3(μm)',
    graphite_temp4 DECIMAL(8,2) COMMENT '石墨化温度4(℃)',
    graphite_thickness4 DECIMAL(8,2) COMMENT '石墨化厚度4(μm)',
    graphite_temp5 DECIMAL(8,2) COMMENT '石墨化温度5(℃)',
    graphite_thickness5 DECIMAL(8,2) COMMENT '石墨化厚度5(μm)',
    graphite_temp6 DECIMAL(8,2) COMMENT '石墨化温度6(℃)',
    graphite_thickness6 DECIMAL(8,2) COMMENT '石墨化厚度6(μm)',
    
    -- 其他参数
    foam_thickness DECIMAL(8,2) COMMENT '泡沫厚度',
    graphite_max_temp DECIMAL(8,2) COMMENT '最高温度',
    graphite_width DECIMAL(10,2) COMMENT '宽度',
    shrinkage_ratio DECIMAL(5,4) COMMENT '收缩率',
    graphite_total_time INT COMMENT '总时长(min)',
    graphite_after_weight DECIMAL(10,3) COMMENT '石墨化后重量',
    graphite_yield_rate DECIMAL(5,2) COMMENT '产率(%)',
    graphite_min_thickness DECIMAL(8,2) COMMENT '最小厚度',
    
    -- 文件字段
    graphite_loading_photo VARCHAR(255) COMMENT '装炉照片',
    graphite_sample_photo VARCHAR(255) COMMENT '样品照片',
    graphite_other_params VARCHAR(255) COMMENT '其他参数文件',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (experiment_id) REFERENCES experiments(id) ON DELETE CASCADE
);
```

**字段总数**: 33  
**必填字段**: 8个（graphite_furnace_num, graphite_batch_num, graphite_start_time, graphite_end_time, pressure_value, graphite_max_temp, foam_thickness, graphite_width）

---

## 📈 变更历史

### v1.1 (2025-10-10)

**变更内容**:
- ✅ 添加 `experiment_graphite` 表的 12 个字段
  - `graphite_temp1` ~ `graphite_temp6` (6个温度字段)
  - `graphite_thickness1` ~ `graphite_thickness6` (6个厚度字段)

**变更原因**:
- 修复提交实验时的 TypeError
- 支持记录6个温度点及对应的厚度变化

**迁移脚本**: `database/migrations/2025-10-10_add_graphite_temp_fields.sql`

### v1.0 (2025-10-08)

**初始版本**:
- ✅ 创建所有基础表结构
- ✅ 建立表关系和外键约束
- ✅ 添加索引优化查询性能

---

## 🔗 表关系图

```
users (1) ──────────┐
                    │
                    ├──> (N) experiments (主表)
                    │         │
                    │         ├──> (1:1) experiment_basic
                    │         ├──> (1:1) experiment_pi
                    │         ├──> (1:1) experiment_loose
                    │         ├──> (1:1) experiment_carbon
                    │         ├──> (1:1) experiment_graphite ⭐
                    │         ├──> (1:1) experiment_rolling
                    │         └──> (1:1) experiment_product
                    │
                    └──> (N) system_logs
```

---

## 📝 字段命名规范

| 前缀/后缀 | 含义 | 示例 |
|-----------|------|------|
| `_id` | 主键或外键 | `experiment_id` |
| `_num` / `_number` | 编号 | `furnace_num` |
| `_code` | 编码 | `experiment_code` |
| `_temp` | 温度 | `graphite_temp1` |
| `_time` | 时间 | `start_time` |
| `_date` | 日期 | `experiment_date` |
| `_at` | 时间戳 | `created_at` |
| `_photo` | 照片文件 | `loading_photo` |
| `_params` | 参数 | `other_params` |

---

## 🔍 常用查询示例

### 查询实验完整信息

```sql
SELECT 
    e.*,
    b.customer_name,
    b.experiment_date,
    g.graphite_max_temp,
    g.graphite_temp1,
    g.graphite_thickness1,
    p.thermal_conductivity
FROM experiments e
LEFT JOIN experiment_basic b ON e.id = b.experiment_id
LEFT JOIN experiment_graphite g ON e.id = g.experiment_id
LEFT JOIN experiment_product p ON e.id = p.experiment_id
WHERE e.status = 'submitted'
ORDER BY e.created_at DESC;
```

### 查询最近提交的实验

```sql
SELECT 
    id, 
    experiment_code, 
    status, 
    created_at 
FROM experiments 
WHERE status = 'submitted'
ORDER BY submitted_at DESC 
LIMIT 10;
```

---

## 📊 索引说明

| 表名 | 索引字段 | 类型 | 说明 |
|------|---------|------|------|
| experiments | experiment_code | UNIQUE | 实验编码唯一性 |
| experiments | created_by | INDEX | 用户查询优化 |
| experiments | status | INDEX | 状态筛选优化 |
| experiment_graphite | graphite_furnace_number | INDEX | 炉号查询优化 |
| experiment_graphite | graphite_max_temp | INDEX | 温度范围查询 |

---

## 🔒 权限和安全

- 外键约束: `ON DELETE CASCADE` - 删除实验时级联删除所有子表数据
- 唯一约束: `experiment_code` 确保实验编码唯一性
- 时间戳: 自动记录 `created_at` 和 `updated_at`

---

**文档版本**: v1.1  
**维护者**: 项目团队  
**最后更新**: 2025-10-10