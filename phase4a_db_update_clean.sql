-- ========================================
-- Phase 4A Task 2: Database Configuration Update
-- Simplified Dropdown Field Functionality
-- ========================================

USE graphite_db;

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ==========================================
-- Step 1: Update field_type in dropdown_fields
-- ==========================================

-- 1.1 Convert 'expandable' to 'searchable'
UPDATE dropdown_fields 
SET field_type = 'searchable' 
WHERE field_type = 'expandable';

-- 1.2 Set fixed dropdown fields (4 fields)
UPDATE dropdown_fields 
SET field_type = 'fixed' 
WHERE field_name IN (
    'customer_type',
    'sintering_location',
    'material_type_for_firing',
    'rolling_method'
);

-- 1.3 Set searchable dropdown fields (5 fields)
UPDATE dropdown_fields 
SET field_type = 'searchable' 
WHERE field_name IN (
    'customer_name',
    'pi_film_thickness',
    'pi_film_model',
    'pi_manufacturer',
    'pi_thickness_detail'
);

-- ==========================================
-- Step 2: Simplify permission control
-- ==========================================

-- 2.1 All searchable fields: all users can add
UPDATE dropdown_fields 
SET 
    allow_user_add = 1,
    allow_engineer_add = 1,
    allow_admin_add = 1,
    require_approval = 0
WHERE field_type = 'searchable';

-- 2.2 All fixed fields: no one can add
UPDATE dropdown_fields 
SET 
    allow_user_add = 0,
    allow_engineer_add = 0,
    allow_admin_add = 0,
    require_approval = 0
WHERE field_type = 'fixed';

-- ==========================================
-- Step 3: Insert missing field configurations
-- ==========================================

INSERT INTO dropdown_fields (field_name, field_label, field_type, allow_user_add, allow_engineer_add, allow_admin_add, require_approval, description)
SELECT * FROM (
    SELECT 'customer_type' as field_name, 'Customer Type' as field_label, 'fixed' as field_type, 0 as allow_user_add, 0 as allow_engineer_add, 0 as allow_admin_add, 0 as require_approval, 'Fixed options' as description
    UNION ALL
    SELECT 'sintering_location', 'Sintering Location', 'fixed', 0, 0, 0, 0, 'Fixed options'
    UNION ALL
    SELECT 'material_type_for_firing', 'Material Type', 'fixed', 0, 0, 0, 0, 'Fixed options'
    UNION ALL
    SELECT 'rolling_method', 'Rolling Method', 'fixed', 0, 0, 0, 0, 'Fixed options'
    UNION ALL
    SELECT 'customer_name', 'Customer Name', 'searchable', 1, 1, 1, 0, 'Searchable and can add new'
    UNION ALL
    SELECT 'pi_film_thickness', 'PI Film Thickness', 'searchable', 1, 1, 1, 0, 'Searchable and can add new'
    UNION ALL
    SELECT 'pi_film_model', 'PI Film Model', 'searchable', 1, 1, 1, 0, 'Searchable and can add new'
    UNION ALL
    SELECT 'pi_manufacturer', 'PI Manufacturer', 'searchable', 1, 1, 1, 0, 'Searchable and can add new'
    UNION ALL
    SELECT 'pi_thickness_detail', 'PI Thickness Detail', 'searchable', 1, 1, 1, 0, 'Searchable and can add new'
) AS new_fields
WHERE NOT EXISTS (
    SELECT 1 FROM dropdown_fields WHERE dropdown_fields.field_name = new_fields.field_name
);

-- ==========================================
-- Step 4: Verify configuration
-- ==========================================

SELECT 
    field_name AS 'Field Name',
    field_label AS 'Label',
    field_type AS 'Type',
    allow_user_add AS 'User Can Add',
    require_approval AS 'Need Approval'
FROM dropdown_fields
ORDER BY field_type, field_name;

SELECT 
    field_type AS 'Field Type',
    COUNT(*) AS 'Count'
FROM dropdown_fields
GROUP BY field_type;

-- ==========================================
-- Step 5: Check approval table
-- ==========================================

SELECT COUNT(*) as 'Pending Approval Count' 
FROM dropdown_approvals 
WHERE status = 'pending';

-- ==========================================
-- Completion Message
-- ==========================================

SELECT 
    'Phase 4A Task 2 Database Update Completed!' AS 'Status',
    CONCAT(
        'Fixed fields: ', (SELECT COUNT(*) FROM dropdown_fields WHERE field_type = 'fixed'), ', ',
        'Searchable fields: ', (SELECT COUNT(*) FROM dropdown_fields WHERE field_type = 'searchable')
    ) AS 'Summary';
