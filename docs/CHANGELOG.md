# 变更日志

## [1.1.0] - 2025-10-10

### Added
- 石墨化参数表新增12个字段：
  - `graphite_temp1` ~ `graphite_temp6` (温度)
  - `graphite_thickness1` ~ `graphite_thickness6` (厚度)
- 支持记录6个温度点的厚度变化

### Fixed
- 修复实验提交时的 TypeError 错误
- 修复 Flask 路由尾部斜杠导致的 CORS 错误

### Changed
- Python 模型 `ExperimentGraphite` 添加12个字段定义

---

## [1.0.0] - 2025-10-08

### Added
- 初始数据库结构
- 用户认证系统
- 实验管理核心功能