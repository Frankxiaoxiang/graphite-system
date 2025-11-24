-- ============================================================
-- 石墨实验数据管理系统 - 数据库更新脚本 v1.1
-- 更新日期: 2025-11-23
-- 说明: 新增5个字段，修改8个字段为非必填
-- 执行前请务必备份数据库！
-- ============================================================

USE graphite_db;

-- ============================================================
-- 1. PI膜参数表（experiment_pi）新增字段
-- ============================================================

-- 2.7 烧制卷数
ALTER TABLE experiment_pi 
ADD COLUMN firing_rolls INT DEFAULT NULL 
COMMENT '烧制卷数' 
AFTER pi_weight;

-- 2.8 PI膜补充说明
ALTER TABLE experiment_pi 
ADD COLUMN pi_notes TEXT DEFAULT NULL 
COMMENT 'PI膜补充说明' 
AFTER firing_rolls;

-- ============================================================
-- 2. 碳化参数表（experiment_carbon）新增字段
-- ============================================================

-- 4.21 碳化补充说明
ALTER TABLE experiment_carbon 
ADD COLUMN carbon_notes TEXT DEFAULT NULL 
COMMENT '碳化补充说明' 
AFTER carbon_other_params;

-- ============================================================
-- 3. 石墨化参数表（experiment_graphite）新增字段
-- ============================================================

-- 5.30 石墨化补充说明
ALTER TABLE experiment_graphite 
ADD COLUMN graphite_notes TEXT DEFAULT NULL 
COMMENT '石墨化补充说明' 
AFTER graphite_other_params;

-- ============================================================
-- 4. 压延参数表（experiment_rolling）新增字段
-- ============================================================

-- 6.5 压延补充说明
ALTER TABLE experiment_rolling 
ADD COLUMN rolling_notes TEXT DEFAULT NULL 
COMMENT '压延补充说明' 
AFTER rolling_speed;

-- ============================================================
-- 5. 成品参数表（experiment_product）新增字段
-- ============================================================

-- 7.17 结合力
ALTER TABLE experiment_product 
ADD COLUMN bond_strength DECIMAL(8,2) DEFAULT NULL 
COMMENT '结合力（数值单位待确认）' 
AFTER remarks;

-- ============================================================
-- 6. 修改必填字段为非必填（通过修改字段为允许NULL）
-- ============================================================

-- 6.1 碳化参数表 - 3个字段改为非必填
ALTER TABLE experiment_carbon 
MODIFY COLUMN carbon_film_thickness DECIMAL(8,2) DEFAULT NULL 
COMMENT '碳化膜厚度(μm) - 非必填';

ALTER TABLE experiment_carbon 
MODIFY COLUMN carbon_after_weight DECIMAL(10,3) DEFAULT NULL 
COMMENT '碳化后重量（kg）- 非必填';

ALTER TABLE experiment_carbon 
MODIFY COLUMN carbon_yield_rate DECIMAL(5,2) DEFAULT NULL 
COMMENT '碳化成碳率% - 非必填';

-- 6.2 石墨化参数表 - 2个字段改为非必填
ALTER TABLE experiment_graphite 
MODIFY COLUMN graphite_yield_rate DECIMAL(5,2) DEFAULT NULL 
COMMENT '石墨化成碳率% - 非必填';

ALTER TABLE experiment_graphite 
MODIFY COLUMN gas_pressure DECIMAL(10,4) DEFAULT NULL 
COMMENT '气压值 - 非必填';

-- 6.3 成品参数表 - 3个字段改为非必填
ALTER TABLE experiment_product 
MODIFY COLUMN cohesion DECIMAL(8,2) DEFAULT NULL 
COMMENT '内聚力（gf）- 非必填';

ALTER TABLE experiment_product 
MODIFY COLUMN peel_strength DECIMAL(8,2) DEFAULT NULL 
COMMENT '剥离力（gf）- 非必填';

ALTER TABLE experiment_product 
MODIFY COLUMN roughness VARCHAR(50) DEFAULT NULL 
COMMENT '粗糙度 - 非必填';

-- ============================================================
-- 7. 验证更新结果
-- ============================================================

-- 检查新增字段
SELECT 
    '新增字段验证' AS check_type,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_COMMENT
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_SCHEMA = 'graphite_db'
    AND COLUMN_NAME IN (
        'firing_rolls', 'pi_notes', 'carbon_notes', 
        'graphite_notes', 'rolling_notes', 'bond_strength'
    )
ORDER BY TABLE_NAME, COLUMN_NAME;

-- 检查必填改为非必填的字段
SELECT 
    '必填改为非必填验证' AS check_type,
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_COMMENT
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_SCHEMA = 'graphite_db'
    AND COLUMN_NAME IN (
        'carbon_film_thickness', 'carbon_after_weight', 'carbon_yield_rate',
        'graphite_yield_rate', 'gas_pressure',
        'cohesion', 'peel_strength', 'roughness'
    )
ORDER BY TABLE_NAME, COLUMN_NAME;

-- ============================================================
-- 8. 更新成功确认
-- ============================================================
SELECT 
    '✅ 数据库更新成功！' AS status,
    '新增字段：5个' AS new_fields,
    '必填改为非必填：8个' AS modified_fields,
    NOW() AS update_time;
