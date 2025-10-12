-- ==========================================
-- 迁移脚本：添加石墨化温度字段
-- 日期：2025-10-10
-- 描述：为 experiment_graphite 表添加 6 对温度/厚度字段
-- ==========================================

USE graphite_db;

-- 添加石墨化温度1和厚度1
ALTER TABLE experiment_graphite 
ADD COLUMN graphite_temp1 INT COMMENT '石墨化温度1(℃)' AFTER graphite_power;

ALTER TABLE experiment_graphite 
ADD COLUMN graphite_thickness1 DECIMAL(10,2) COMMENT '石墨化厚度1(μm)' AFTER graphite_temp1;

-- 添加石墨化温度2和厚度2
ALTER TABLE experiment_graphite 
ADD COLUMN graphite_temp2 INT COMMENT '石墨化温度2(℃)' AFTER graphite_thickness1;

ALTER TABLE experiment_graphite 
ADD COLUMN graphite_thickness2 DECIMAL(10,2) COMMENT '石墨化厚度2(μm)' AFTER graphite_temp2;

-- 添加石墨化温度3和厚度3
ALTER TABLE experiment_graphite 
ADD COLUMN graphite_temp3 INT COMMENT '石墨化温度3(℃)' AFTER graphite_thickness2;

ALTER TABLE experiment_graphite 
ADD COLUMN graphite_thickness3 DECIMAL(10,2) COMMENT '石墨化厚度3(μm)' AFTER graphite_temp3;

-- 添加石墨化温度4和厚度4
ALTER TABLE experiment_graphite 
ADD COLUMN graphite_temp4 INT COMMENT '石墨化温度4(℃)' AFTER graphite_thickness3;

ALTER TABLE experiment_graphite 
ADD COLUMN graphite_thickness4 DECIMAL(10,2) COMMENT '石墨化厚度4(μm)' AFTER graphite_temp4;

-- 添加石墨化温度5和厚度5
ALTER TABLE experiment_graphite 
ADD COLUMN graphite_temp5 INT COMMENT '石墨化温度5(℃)' AFTER graphite_thickness4;

ALTER TABLE experiment_graphite 
ADD COLUMN graphite_thickness5 DECIMAL(10,2) COMMENT '石墨化厚度5(μm)' AFTER graphite_temp5;

-- 添加石墨化温度6和厚度6
ALTER TABLE experiment_graphite 
ADD COLUMN graphite_temp6 INT COMMENT '石墨化温度6(℃)' AFTER graphite_thickness5;

ALTER TABLE experiment_graphite 
ADD COLUMN graphite_thickness6 DECIMAL(10,2) COMMENT '石墨化厚度6(μm)' AFTER graphite_temp6;

-- 验证字段添加成功
DESCRIBE experiment_graphite;

-- 输出确认信息
SELECT '✅ 石墨化温度字段添加完成！共添加 12 个字段。' AS status;