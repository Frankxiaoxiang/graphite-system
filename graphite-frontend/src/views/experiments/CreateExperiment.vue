<template>
  <div class="create-experiment">
    <!-- 页面头部 -->
    <div class="header">
      <h1>创建新实验</h1>
      <div class="header-actions">
        <el-button @click="handleBack">返回</el-button>
        <el-button type="primary" @click="previewExperimentCode">
          <el-icon><View /></el-icon>
          预览实验编码
        </el-button>
      </div>
    </div>

    <!-- 实验编码预览 -->
    <div v-if="experimentCode" class="code-preview">
      <el-alert
        :title="`实验编码: ${experimentCode}`"
        type="success"
        :closable="false"
        show-icon
      />
    </div>

    <!-- 表单内容 -->
    <div class="form-container">
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="200px"
        size="default"
      >
        <!-- 标签页导航 -->
        <el-tabs v-model="activeTab" type="card" @tab-change="handleTabChange">

          <!-- 1. 实验设计参数 -->
          <el-tab-pane label="实验设计参数" name="basic">
            <div class="module-section">
              <h3 class="module-title">实验设计参数 (1/7)</h3>
              <div class="form-grid">
                <el-form-item label="PI膜厚度(μm)" prop="pi_film_thickness" required>
                  <SearchableSelect
                    v-model="formData.pi_film_thickness"
                    placeholder="输入或选择PI膜厚度"
                    :options="dropdownOptions.pi_film_thickness"
                    @search="handleSearch('pi_film_thickness', $event)"
                    type="number"
                  />
                </el-form-item>

                <!-- 客户类型 -->
                <el-form-item label="客户类型" prop="customer_type" required>
                  <el-select v-model="formData.customer_type" placeholder="请选择客户类型">
                    <el-option
                      v-for="option in dropdownOptions.customer_type"
                      :key="option.value"
                      :label="option.label"
                      :value="option.value"
                    />
                  </el-select>
                </el-form-item>

                <el-form-item label="客户名称" prop="customer_name" required>
                  <SearchableSelect
                    v-model="formData.customer_name"
                    placeholder="输入或选择客户名称"
                    :options="dropdownOptions.customer_name"
                    @search="handleSearch('customer_name', $event)"
                    @add-new="handleAddNewOption('customer_name', $event)"
                    :can-add="true"
                  />
                </el-form-item>

                <el-form-item label="PI膜型号" prop="pi_film_model" required>
                  <SearchableSelect
                    v-model="formData.pi_film_model"
                    placeholder="输入或选择PI膜型号"
                    :options="dropdownOptions.pi_film_model"
                    @search="handleSearch('pi_film_model', $event)"
                    @add-new="handleAddNewOption('pi_film_model', $event)"
                    :can-add="true"
                  />
                </el-form-item>

                <el-form-item label="实验申请日期" prop="experiment_date" required>
                  <el-date-picker
                    v-model="formData.experiment_date"
                    type="date"
                    placeholder="选择实验申请日期"
                    format="YYYY-MM-DD"
                    value-format="YYYY-MM-DD"
                  />
                </el-form-item>

                <el-form-item label="烧制地点" prop="sintering_location" required>
                  <SearchableSelect
                    v-model="formData.sintering_location"
                    placeholder="选择烧制地点"
                    :options="dropdownOptions.sintering_location"
                    @search="handleSearch('sintering_location', $event)"
                    @add-new="handleAddNewOption('sintering_location', $event)"
                    :can-add="false"
                  />
                </el-form-item>

                <el-form-item label="透烧材料类型" prop="material_type_for_firing" required>
                  <el-select v-model="formData.material_type_for_firing" placeholder="请选择透烧材料类型">
                    <el-option
                      v-for="option in dropdownOptions.material_type_for_firing"
                      :key="option.value"
                      :label="option.label"
                      :value="option.value"
                    />
                    </el-select>
                </el-form-item>

                <!-- 压延方式 -->
                <el-form-item label="压延方式" prop="rolling_method" required>
                  <el-select v-model="formData.rolling_method" placeholder="请选择压延方式">
                    <el-option
                    v-for="option in dropdownOptions.rolling_method"
                    :key="option.value"
                    :label="option.label"
                    :value="option.value"
                  />
                  </el-select>
                </el-form-item>

                <el-form-item label="实验编组" prop="experiment_group" required>
                  <el-input-number
                    v-model="formData.experiment_group"
                    :min="1"
                    :max="99"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="实验目的" prop="experiment_purpose" required style="grid-column: 1 / -1;">
                  <el-input
                    v-model="formData.experiment_purpose"
                    type="textarea"
                    :rows="3"
                    placeholder="请描述实验目的"
                  />
                </el-form-item>
              </div>
            </div>
          </el-tab-pane>

          <!-- 2. PI膜参数 -->
          <el-tab-pane label="PI膜参数" name="pi">
            <div class="module-section">
              <h3 class="module-title">PI膜参数 (2/7)</h3>
              <div class="form-grid">
                <el-form-item label="PI膜厂商" prop="pi_manufacturer" required>
                  <SearchableSelect
                    v-model="formData.pi_manufacturer"
                    placeholder="输入或选择PI膜厂商"
                    :options="dropdownOptions.pi_manufacturer"
                    @search="handleSearch('pi_manufacturer', $event)"
                    @add-new="handleAddNewOption('pi_manufacturer', $event)"
                    :can-add="true"
                  />
                </el-form-item>

                <el-form-item label="PI膜初始厚度(μm)" prop="pi_thickness_detail" required>
                  <SearchableSelect
                    v-model="formData.pi_thickness_detail"
                    placeholder="输入或选择PI膜厚度"
                    :options="dropdownOptions.pi_film_thickness"
                    @search="handleSearch('pi_film_thickness', $event)"
                    type="number"
                  />
                </el-form-item>

                <el-form-item label="PI膜型号" prop="pi_model_detail" required>
                  <SearchableSelect
                    v-model="formData.pi_model_detail"
                    placeholder="输入或选择PI膜型号"
                    :options="dropdownOptions.pi_film_model"
                    @search="handleSearch('pi_film_model', $event)"
                  />
                </el-form-item>

                <el-form-item label="PI膜宽幅(mm)" prop="pi_width">
                  <el-input-number
                    v-model="formData.pi_width"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="批次号" prop="batch_number">
                  <el-input v-model="formData.batch_number" placeholder="请输入批次号" />
                </el-form-item>

                <el-form-item label="PI重量(kg)" prop="pi_weight" required>
                  <el-input-number
                    v-model="formData.pi_weight"
                    :min="0"
                    :precision="3"
                    controls-position="right"
                  />
                </el-form-item>

                <!-- ✅ 新增：烧制卷数 -->
                <el-form-item label="烧制卷数" prop="firing_rolls">
                  <el-input-number
                    v-model="formData.firing_rolls"
                    :min="1"
                    :max="100"
                    :precision="0"
                    placeholder="请输入烧制卷数（非必填）"
                  />
                  <span style="color: #909399; font-size: 12px; margin-left: 10px;">非必填</span>
                </el-form-item>

                <!-- ✅ 新增：PI膜补充说明 -->
                <el-form-item label="PI膜补充说明" prop="pi_notes">
                  <el-input
                    v-model="formData.pi_notes"
                    type="textarea"
                    :rows="3"
                    placeholder="请输入PI膜补充说明（非必填）"
                    maxlength="500"
                    show-word-limit
                  />
                </el-form-item>
              </div>
            </div>
          </el-tab-pane>

          <!-- 3. 松卷参数 -->
          <el-tab-pane label="松卷参数" name="loose">
            <div class="module-section">
              <h3 class="module-title">松卷参数 (3/7)</h3>
              <div class="form-grid">
                <el-form-item label="卷芯筒类型" prop="core_tube_type">
                  <el-input v-model="formData.core_tube_type" placeholder="请输入卷芯筒类型" />
                </el-form-item>

                <el-form-item label="松卷间隙卷内(μm)" prop="loose_gap_inner">
                  <el-input-number
                    v-model="formData.loose_gap_inner"
                    :min="0"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="松卷间隙卷中(μm)" prop="loose_gap_middle">
                  <el-input-number
                    v-model="formData.loose_gap_middle"
                    :min="0"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="松卷间隙卷外(μm)" prop="loose_gap_outer">
                  <el-input-number
                    v-model="formData.loose_gap_outer"
                    :min="0"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>
              </div>
            </div>
          </el-tab-pane>

          <!-- 4. 碳化参数 -->
          <el-tab-pane label="碳化参数" name="carbon">
            <div class="module-section">
              <h3 class="module-title">碳化参数 (4/7)</h3>
              <div class="form-grid">
                <el-form-item label="碳化炉编号" prop="carbon_furnace_num" required>
                  <el-input v-model="formData.carbon_furnace_num" placeholder="请输入碳化炉编号" />
                </el-form-item>

                <el-form-item label="碳化炉次" prop="carbon_batch_num" required>
                  <el-input-number
                    v-model="formData.carbon_batch_num"
                    :min="1"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="舟皿型号" prop="boat_model">
                  <el-input v-model="formData.boat_model" placeholder="请输入舟皿型号" />
                </el-form-item>

                <el-form-item label="包裹形式" prop="wrap_type">
                  <el-input v-model="formData.wrap_type" placeholder="套筒/碳纸" />
                </el-form-item>

                <el-form-item label="真空度" prop="vacuum_degree">
                  <el-input-number
                    v-model="formData.vacuum_degree"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="电量" prop="carbon_power">
                  <el-input-number
                    v-model="formData.carbon_power"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="开机时间" prop="carbon_start_time">
                  <el-date-picker
                    v-model="formData.carbon_start_time"
                    type="datetime"
                    placeholder="选择开机时间"
                    format="YYYY-MM-DD HH:mm:ss"
                    value-format="YYYY-MM-DD HH:mm:ss"
                  />
                </el-form-item>

                <el-form-item label="关机时间" prop="carbon_end_time">
                  <el-date-picker
                    v-model="formData.carbon_end_time"
                    type="datetime"
                    placeholder="选择关机时间"
                    format="YYYY-MM-DD HH:mm:ss"
                    value-format="YYYY-MM-DD HH:mm:ss"
                  />
                </el-form-item>

                <el-form-item label="碳化温度1(℃)" prop="carbon_temp1">
                  <el-input-number
                    v-model="formData.carbon_temp1"
                    :min="0"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="碳化厚度1(μm)" prop="carbon_thickness1">
                  <el-input-number
                    v-model="formData.carbon_thickness1"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="碳化温度2(℃)" prop="carbon_temp2">
                  <el-input-number
                    v-model="formData.carbon_temp2"
                    :min="0"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="碳化厚度2(μm)" prop="carbon_thickness2">
                  <el-input-number
                    v-model="formData.carbon_thickness2"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="碳化最高温度(℃)" prop="carbon_max_temp" required>
                  <el-input-number
                    v-model="formData.carbon_max_temp"
                    :min="0"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <!-- ✅ 修改：碳化膜厚度 - 改为非必填 -->
                <el-form-item label="碳化膜厚度(μm)" prop="carbon_film_thickness">
                  <el-input-number
                    v-model="formData.carbon_film_thickness"
                    :min="1"
                    :precision="2"
                    placeholder="请输入碳化膜厚度（非必填）"
                  />
                  <span style="color: #909399; font-size: 12px; margin-left: 10px;">非必填</span>
                </el-form-item>

                <el-form-item label="碳化总时长(min)" prop="carbon_total_time" required>
                  <el-input-number
                    v-model="formData.carbon_total_time"
                    :min="0"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <!-- ✅ 修改：碳化后重量 - 改为非必填 -->
                <el-form-item label="碳化后重量(kg)" prop="carbon_weight">
                  <el-input-number
                    v-model="formData.carbon_weight"
                    :min="0"
                    :precision="3"
                    placeholder="请输入碳化后重量（非必填）"
                  />
                  <span style="color: #909399; font-size: 12px; margin-left: 10px;">非必填</span>
                </el-form-item>

                <!-- ✅ 修改：成碳率 - 改为非必填 -->
                <el-form-item label="成碳率%" prop="carbon_yield_rate">
                  <el-input-number
                    v-model="formData.carbon_yield_rate"
                    :min="0"
                    :max="100"
                    :precision="2"
                    placeholder="请输入成碳率（非必填）"
                  />
                  <span style="color: #909399; font-size: 12px; margin-left: 10px;">非必填</span>
                </el-form-item>

                <!-- 文件上传 -->
                <el-form-item label="碳化装载方式照片" prop="carbon_loading_photo">
                  <FileUpload
                    v-model="formData.carbon_loading_photo"
                    accept="image/*"
                    :max-size="10"
                  />
                </el-form-item>

                <el-form-item label="碳化样品照片" prop="carbon_sample_photo">
                  <FileUpload
                    v-model="formData.carbon_sample_photo"
                    accept="image/*"
                    :max-size="10"
                  />
                </el-form-item>

                <el-form-item label="碳化其它参数" prop="carbon_other_params">
                  <FileUpload
                    v-model="formData.carbon_other_params"
                    accept=".pdf,.jpg,.png"
                    :max-size="10"
                  />
                </el-form-item>

                <!-- ✅ 新增：碳化补充说明 -->
                <el-form-item label="碳化补充说明" prop="carbon_notes">
                  <el-input
                    v-model="formData.carbon_notes"
                    type="textarea"
                    :rows="3"
                    placeholder="请输入碳化补充说明（非必填）"
                    maxlength="500"
                    show-word-limit
                  />
                </el-form-item>
              </div>
            </div>
          </el-tab-pane>

          <!-- 5. 石墨化参数 -->
          <el-tab-pane label="石墨化参数" name="graphite">
            <div class="module-section">
              <h3 class="module-title">石墨化参数 (5/7)</h3>
              <div class="form-grid">
                <el-form-item label="石墨炉编号" prop="graphite_furnace_num" required>
                  <el-input v-model="formData.graphite_furnace_num" placeholder="请输入石墨炉编号" />
                </el-form-item>

                <el-form-item label="石墨化炉次" prop="graphite_batch_num">
                  <el-input-number
                    v-model="formData.graphite_batch_num"
                    :min="1"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="开机时间点" prop="graphite_start_time">
                  <el-date-picker
                    v-model="formData.graphite_start_time"
                    type="datetime"
                    placeholder="选择开机时间"
                    format="YYYY-MM-DD HH:mm:ss"
                    value-format="YYYY-MM-DD HH:mm:ss"
                  />
                </el-form-item>

                <el-form-item label="关机时间点" prop="graphite_end_time">
                  <el-date-picker
                    v-model="formData.graphite_end_time"
                    type="datetime"
                    placeholder="选择关机时间"
                    format="YYYY-MM-DD HH:mm:ss"
                    value-format="YYYY-MM-DD HH:mm:ss"
                  />
                </el-form-item>

                <!-- ✅ 修改：气压值 - 改为非必填 -->
                <el-form-item label="气压值" prop="pressure_value">
                  <el-input-number
                    v-model="formData.pressure_value"
                    :min="0"
                    :precision="4"
                    placeholder="请输入气压值（非必填）"
                  />
                  <span style="color: #909399; font-size: 12px; margin-left: 10px;">非必填</span>
                </el-form-item>

                <el-form-item label="电量" prop="graphite_power">
                  <el-input-number
                    v-model="formData.graphite_power"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <!-- 6个温度厚度对 -->
                <template v-for="i in 6" :key="i">
                  <el-form-item :label="`石墨化温度${i}(℃)`" :prop="`graphite_temp${i}`">
                    <el-input-number
                      v-model="formData[`graphite_temp${i}`]"
                      :min="0"
                      :precision="0"
                      controls-position="right"
                    />
                  </el-form-item>

                  <el-form-item :label="`石墨化厚度${i}(μm)`" :prop="`graphite_thickness${i}`">
                    <el-input-number
                      v-model="formData[`graphite_thickness${i}`]"
                      :min="0"
                      :precision="2"
                      controls-position="right"
                    />
                  </el-form-item>
                </template>

                <el-form-item label="石墨化最高温度(℃)" prop="graphite_max_temp" required>
                  <el-input-number
                    v-model="formData.graphite_max_temp"
                    :min="0"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="发泡厚度(μm)" prop="foam_thickness" required>
                  <el-input-number
                    v-model="formData.foam_thickness"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="石墨宽幅(mm)" prop="graphite_width" required>
                  <el-input-number
                    v-model="formData.graphite_width"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="收缩比" prop="shrinkage_ratio" required>
                  <el-input-number
                    v-model="formData.shrinkage_ratio"
                    :min="0"
                    :precision="4"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="石墨化总时长(min)" prop="graphite_total_time" required>
                  <el-input-number
                    v-model="formData.graphite_total_time"
                    :min="0"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="石墨化后重量(kg)" prop="graphite_weight" required>
                  <el-input-number
                    v-model="formData.graphite_weight"
                    :min="0"
                    :precision="3"
                    controls-position="right"
                  />
                </el-form-item>

                <!-- ✅ 修改：成碳率 - 改为非必填 -->
                <el-form-item label="成碳率%" prop="graphite_yield_rate">
                  <el-input-number
                    v-model="formData.graphite_yield_rate"
                    :min="0"
                    :max="100"
                    :precision="2"
                    placeholder="请输入成碳率（非必填）"
                  />
                  <span style="color: #909399; font-size: 12px; margin-left: 10px;">非必填</span>
                </el-form-item>

                <el-form-item label="石墨压延最薄极限" prop="graphite_min_thickness">
                  <el-input-number
                    v-model="formData.graphite_min_thickness"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <!-- 文件上传 -->
                <el-form-item label="石墨化装载方式照片" prop="graphite_loading_photo">
                  <FileUpload
                    v-model="formData.graphite_loading_photo"
                    accept="image/*"
                    :max-size="10"
                  />
                </el-form-item>

                <el-form-item label="石墨化样品照片" prop="graphite_sample_photo">
                  <FileUpload
                    v-model="formData.graphite_sample_photo"
                    accept="image/*"
                    :max-size="10"
                  />
                </el-form-item>

                <el-form-item label="石墨化其它参数" prop="graphite_other_params">
                  <FileUpload
                    v-model="formData.graphite_other_params"
                    accept=".pdf,.jpg,.png"
                    :max-size="10"
                  />
                </el-form-item>

                <!-- ✅ 新增：石墨化补充说明 -->
                <el-form-item label="石墨化补充说明" prop="graphite_notes">
                  <el-input
                    v-model="formData.graphite_notes"
                    type="textarea"
                    :rows="3"
                    placeholder="请输入石墨化补充说明（非必填）"
                    maxlength="500"
                    show-word-limit
                  />
                </el-form-item>
              </div>
            </div>
          </el-tab-pane>

          <!-- 6. 压延参数 -->
          <el-tab-pane label="压延参数" name="rolling">
            <div class="module-section">
              <h3 class="module-title">压延参数 (6/7)</h3>
              <div class="form-grid">
                <el-form-item label="压延机台编号" prop="rolling_machine_num">
                  <el-input v-model="formData.rolling_machine_num" placeholder="请输入压延机台编号" />
                </el-form-item>

                <el-form-item label="压延压力(MPa)" prop="rolling_pressure">
                  <el-input-number
                    v-model="formData.rolling_pressure"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="压延张力" prop="rolling_tension">
                  <el-input-number
                    v-model="formData.rolling_tension"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="压延速度(m/s)" prop="rolling_speed">
                  <el-input-number
                    v-model="formData.rolling_speed"
                    :min="0"
                    :precision="3"
                    controls-position="right"
                  />
                </el-form-item>

                <!-- ✅ 新增：压延补充说明 -->
                <el-form-item label="压延补充说明" prop="rolling_notes">
                  <el-input
                    v-model="formData.rolling_notes"
                    type="textarea"
                    :rows="3"
                    placeholder="请输入压延补充说明（非必填）"
                    maxlength="500"
                    show-word-limit
                  />
                </el-form-item>
              </div>
            </div>
          </el-tab-pane>

          <!-- 7. 成品参数 -->
          <el-tab-pane label="成品参数" name="product">
            <div class="module-section">
              <h3 class="module-title">成品参数 (7/7)</h3>
              <div class="form-grid">
                <el-form-item label="成品编码" prop="product_code">
                  <el-input v-model="formData.product_code" placeholder="请输入成品编码" />
                </el-form-item>

                <el-form-item label="样品平均厚度(μm)" prop="product_avg_thickness" required>
                  <el-input-number
                    v-model="formData.product_avg_thickness"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="规格(宽幅mm×长m)" prop="product_spec" required>
                  <el-input v-model="formData.product_spec" placeholder="例: 100×50" />
                </el-form-item>

                <el-form-item label="平均密度(g/cm³)" prop="product_avg_density" required>
                  <el-input-number
                    v-model="formData.product_avg_density"
                    :min="0"
                    :precision="3"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="热扩散系数(mm²/s)" prop="thermal_diffusivity" required>
                  <el-input-number
                    v-model="formData.thermal_diffusivity"
                    :min="0"
                    :precision="3"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="导热系数(W/m*K)" prop="thermal_conductivity" required>
                  <el-input-number
                    v-model="formData.thermal_conductivity"
                    :min="0"
                    :precision="3"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="比热(J/g/K)" prop="specific_heat" required>
                  <el-input-number
                    v-model="formData.specific_heat"
                    :min="0"
                    :precision="3"
                    controls-position="right"
                  />
                </el-form-item>

                <!-- ✅ 修改：内聚力 - 改为非必填 -->
                <el-form-item label="内聚力(gf)" prop="cohesion">
                  <el-input-number
                    v-model="formData.cohesion"
                    :min="0"
                    :precision="2"
                    placeholder="请输入内聚力（非必填）"
                  />
                  <span style="color: #909399; font-size: 12px; margin-left: 10px;">非必填</span>
                </el-form-item>

                <!-- ✅ 修改：剥离力 - 改为非必填 -->
                <el-form-item label="剥离力(gf)" prop="peel_strength">
                  <el-input-number
                    v-model="formData.peel_strength"
                    :min="0"
                    :precision="2"
                    placeholder="请输入剥离力（非必填）"
                  />
                  <span style="color: #909399; font-size: 12px; margin-left: 10px;">非必填</span>
                </el-form-item>

                <!-- ✅ 修改：粗糙度 - 改为非必填 -->
                <el-form-item label="粗糙度" prop="roughness">
                  <el-input
                    v-model="formData.roughness"
                    placeholder="请输入粗糙度（非必填）"
                  />
                  <span style="color: #909399; font-size: 12px; margin-left: 10px;">非必填</span>
                </el-form-item>

                <!-- ✅ 新增：结合力 -->
                <el-form-item label="结合力" prop="bond_strength">
                  <el-input-number
                    v-model="formData.bond_strength"
                    :min="0"
                    :precision="2"
                    placeholder="请输入结合力（非必填）"
                  />
                  <span style="color: #909399; font-size: 12px; margin-left: 10px;">非必填</span>
                </el-form-item>

                <el-form-item label="外观及不良情况描述" prop="appearance_description" required>
                  <el-input
                    v-model="formData.appearance_description"
                    type="textarea"
                    :rows="5"
                    placeholder="请描述外观及不良情况"
                  />
                </el-form-item>

                <el-form-item label="备注" prop="remarks">
                  <el-input
                    v-model="formData.remarks"
                    type="textarea"
                    :rows="5"
                    placeholder="请输入备注信息"
                  />
                </el-form-item>

                <el-form-item label="实验总结" prop="experiment_summary" required style="grid-column: 1 / -1;">
                  <el-input
                    v-model="formData.experiment_summary"
                    type="textarea"
                    :rows="5"
                    placeholder="请输入实验总结"
                  />
                </el-form-item>

                <!-- 文件上传 -->
                <el-form-item label="外观不良照片" prop="defect_photo">
                  <FileUpload
                    v-model="formData.defect_photo"
                    accept="image/*"
                    :max-size="10"
                  />
                </el-form-item>

                <el-form-item label="样品照片" prop="sample_photo">
                  <FileUpload
                    v-model="formData.sample_photo"
                    accept="image/*"
                    :max-size="10"
                  />
                </el-form-item>

                <el-form-item label="其它文件" prop="other_files">
                  <FileUpload
                    v-model="formData.other_files"
                    accept=".pdf,.jpg,.png,.doc,.docx,.xls,.xlsx"
                    :max-size="10"
                  />
                </el-form-item>
              </div>
            </div>
          </el-tab-pane>
        </el-tabs>

        <!-- 底部操作按钮 -->
        <div class="form-actions">
          <el-button @click="handleBack">取消</el-button>
          <el-button type="info" @click="handleSaveDraft" :loading="loading.draft">
            <el-icon><DocumentAdd /></el-icon>
            保存草稿
          </el-button>
          <el-button type="primary" @click="handleSubmit" :loading="loading.submit">
            <el-icon><Check /></el-icon>
            提交实验
          </el-button>
        </div>
      </el-form>
    </div>

    <!-- 新增选项对话框 -->
    <AddOptionDialog
      v-model="addOptionDialog.visible"
      :field-name="addOptionDialog.fieldName"
      :field-label="addOptionDialog.fieldLabel"
      @confirm="handleConfirmAddOption"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch, onMounted } from 'vue'
// 添加一个逗号和 useRoute
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ElMessage, ElMessageBox, ElForm } from 'element-plus'
import {
  View, DocumentAdd, Check, Upload, Plus, Delete
} from '@element-plus/icons-vue'
import SearchableSelect from '@/components/SearchableSelect.vue'
import FileUpload from '@/components/FileUpload.vue'
import AddOptionDialog from '@/components/AddOptionDialog.vue'
import { experimentApi } from '@/api/experiments'
import { dropdownApi } from '@/api/dropdown'

const router = useRouter()
const route = useRoute()  // ✅ 添加这行
const authStore = useAuthStore()
const formRef = ref<InstanceType<typeof ElForm>>()

// 当前激活的标签页
const activeTab = ref('basic')

// 加载状态
const loading = reactive({
  draft: false,
  submit: false
})

// 实验编码
const experimentCode = ref('')
// ✅ 新增：实验 ID（用于草稿更新）
const experimentId = ref<number | null>(null)

// 表单数据
const formData = reactive({
  // 1. 实验设计参数
  pi_film_thickness: null,
  customer_type: '',
  customer_name: '',
  pi_film_model: '',
  experiment_date: '',
  sintering_location: '',
  material_type_for_firing: '',
  rolling_method: '',
  experiment_group: 1,
  experiment_purpose: '',

  // 2. PI膜参数
  pi_manufacturer: '',
  pi_thickness_detail: null,
  pi_model_detail: '',
  pi_width: null,
  batch_number: '',
  pi_weight: null,
  // ✅ 新增字段
  firing_rolls: null,        // 烧制卷数
  pi_notes: '',              // PI膜补充说明

  // 3. 松卷参数
  core_tube_type: '',
  loose_gap_inner: null,
  loose_gap_middle: null,
  loose_gap_outer: null,

  // 4. 碳化参数
  carbon_furnace_num: '',
  carbon_batch_num: null,
  boat_model: '',
  wrap_type: '',
  vacuum_degree: null,
  carbon_power: null,
  carbon_start_time: '',
  carbon_end_time: '',
  carbon_temp1: null,
  carbon_thickness1: null,
  carbon_temp2: null,
  carbon_thickness2: null,
  carbon_max_temp: null,
  carbon_film_thickness: null,
  carbon_total_time: null,
  carbon_weight: null,
  carbon_yield_rate: null,
  carbon_loading_photo: null,
  carbon_sample_photo: null,
  carbon_other_params: null,
  // ✅ 新增字段
  carbon_notes: '',          // 碳化补充说明

  // 5. 石墨化参数
  graphite_furnace_num: '',
  graphite_batch_num: null,
  graphite_start_time: '',
  graphite_end_time: '',
  pressure_value: null,
  graphite_power: null,
  graphite_temp1: null,
  graphite_thickness1: null,
  graphite_temp2: null,
  graphite_thickness2: null,
  graphite_temp3: null,
  graphite_thickness3: null,
  graphite_temp4: null,
  graphite_thickness4: null,
  graphite_temp5: null,
  graphite_thickness5: null,
  graphite_temp6: null,
  graphite_thickness6: null,
  graphite_max_temp: null,
  foam_thickness: null,
  graphite_width: null,
  shrinkage_ratio: null,
  graphite_total_time: null,
  graphite_weight: null,
  graphite_yield_rate: null,
  graphite_min_thickness: null,
  graphite_loading_photo: null,
  graphite_sample_photo: null,
  graphite_other_params: null,
  // ✅ 新增字段
  graphite_notes: '',        // 石墨化补充说明

  // 6. 压延参数
  rolling_machine_num: '',
  rolling_pressure: null,
  rolling_tension: null,
  rolling_speed: null,
  rolling_notes: '',         // 压延补充说明

  // 7. 成品参数
  product_code: '',
  product_avg_thickness: null,
  product_spec: '',
  product_avg_density: null,
  thermal_diffusivity: null,
  thermal_conductivity: null,
  specific_heat: null,
  cohesion: null,
  peel_strength: null,
  roughness: '',
  appearance_description: '',
  experiment_summary: '',
  remarks: '',
  defect_photo: null,
  sample_photo: null,
  other_files: null,
  bond_strength: null,       // 结合力
})

// 下拉选项数据
const dropdownOptions = reactive({
  pi_film_thickness: [],
  customer_type: [],
  customer_name: [],
  pi_film_model: [],
  sintering_location: [],
  material_type_for_firing: [],
  rolling_method: [],
  pi_manufacturer: [],
  pi_thickness_detail: []
})

// 新增选项对话框
const addOptionDialog = reactive({
  visible: false,
  fieldName: '',
  fieldLabel: ''
})

// 表单验证规则
const formRules = {
  // 必填字段验证
  pi_film_thickness: [{ required: true, message: 'PI膜厚度不能为空', trigger: 'change' }],
  customer_type: [{ required: true, message: '客户类型不能为空', trigger: 'change' }],
  customer_name: [{ required: true, message: '客户名称不能为空', trigger: 'change' }],
  pi_film_model: [{ required: true, message: 'PI膜型号不能为空', trigger: 'change' }],
  experiment_date: [{ required: true, message: '实验申请日期不能为空', trigger: 'change' }],
  sintering_location: [{ required: true, message: '烧制地点不能为空', trigger: 'change' }],
  material_type_for_firing: [{ required: true, message: '透烧材料类型不能为空', trigger: 'change' }],
  rolling_method: [{ required: true, message: '压延方式不能为空', trigger: 'change' }],
  experiment_group: [{ required: true, message: '实验编组不能为空', trigger: 'change' }],
  experiment_purpose: [{ required: true, message: '实验目的不能为空', trigger: 'blur' }],

  pi_manufacturer: [{ required: true, message: 'PI膜厂商不能为空', trigger: 'change' }],
  pi_thickness_detail: [{ required: true, message: 'PI膜初始厚度不能为空', trigger: 'change' }],
  pi_model_detail: [{ required: true, message: 'PI膜型号不能为空', trigger: 'change' }],
  pi_weight: [{ required: true, message: 'PI重量不能为空', trigger: 'change' }],

  carbon_furnace_num: [{ required: true, message: '碳化炉编号不能为空', trigger: 'blur' }],
  carbon_batch_num: [{ required: true, message: '碳化炉次不能为空', trigger: 'change' }],
  carbon_max_temp: [{ required: true, message: '碳化最高温度不能为空', trigger: 'change' }],
  carbon_total_time: [{ required: true, message: '碳化总时长不能为空', trigger: 'change' }],

  // ✅ 改为非必填 - 碳化膜厚度
  carbon_film_thickness: [
    { type: 'number', message: '必须是数字', trigger: 'blur' }
  ],

  // ✅ 改为非必填 - 碳化后重量
  carbon_weight: [
    { type: 'number', message: '必须是数字', trigger: 'blur' }
  ],

  // ✅ 改为非必填 - 成碳率
  carbon_yield_rate: [
    { type: 'number', message: '必须是数字', trigger: 'blur' }
  ],

  graphite_furnace_num: [{ required: true, message: '石墨炉编号不能为空', trigger: 'blur' }],

  // ✅ 改为非必填 - 气压值
  pressure_value: [
    { type: 'number', message: '必须是数字', trigger: 'blur' }
  ],

  graphite_max_temp: [{ required: true, message: '石墨化最高温度不能为空', trigger: 'change' }],
  foam_thickness: [{ required: true, message: '发泡厚度不能为空', trigger: 'change' }],
  graphite_width: [{ required: true, message: '石墨宽幅不能为空', trigger: 'change' }],
  shrinkage_ratio: [{ required: true, message: '收缩比不能为空', trigger: 'change' }],
  graphite_total_time: [{ required: true, message: '石墨化总时长不能为空', trigger: 'change' }],
  graphite_weight: [{ required: true, message: '石墨化后重量不能为空', trigger: 'change' }],

  // ✅ 改为非必填 - 石墨化成碳率
  graphite_yield_rate: [
    { type: 'number', message: '必须是数字', trigger: 'blur' }
  ],

  product_avg_thickness: [{ required: true, message: '样品平均厚度不能为空', trigger: 'change' }],
  product_spec: [{ required: true, message: '规格不能为空', trigger: 'blur' }],
  product_avg_density: [{ required: true, message: '平均密度不能为空', trigger: 'change' }],
  thermal_diffusivity: [{ required: true, message: '热扩散系数不能为空', trigger: 'change' }],
  thermal_conductivity: [{ required: true, message: '导热系数不能为空', trigger: 'change' }],
  specific_heat: [{ required: true, message: '比热不能为空', trigger: 'change' }],

  // ✅ 改为非必填 - 内聚力
  cohesion: [
    { type: 'number', message: '必须是数字', trigger: 'blur' }
  ],

  // ✅ 改为非必填 - 剥离力
  peel_strength: [
    { type: 'number', message: '必须是数字', trigger: 'blur' }
  ],

  // ✅ 改为非必填 - 粗糙度
  roughness: [],

  appearance_description: [{ required: true, message: '外观描述不能为空', trigger: 'blur' }],
  experiment_summary: [{ required: true, message: '实验总结不能为空', trigger: 'blur' }],

  // ✅ 新增字段的验证规则（非必填）
  firing_rolls: [
    { type: 'number', message: '必须是数字', trigger: 'blur' }
  ],
  pi_notes: [
    { max: 500, message: '最多500个字符', trigger: 'blur' }
  ],
  carbon_notes: [
    { max: 500, message: '最多500个字符', trigger: 'blur' }
  ],
  graphite_notes: [
    { max: 500, message: '最多500个字符', trigger: 'blur' }
  ],
  rolling_notes: [
    { max: 500, message: '最多500个字符', trigger: 'blur' }
  ],
  bond_strength: [
    { type: 'number', message: '必须是数字', trigger: 'blur' }
  ]
}

// ✅ 保留：监听关键字段变化,自动生成实验编码
watch([
  () => formData.pi_film_thickness,
  () => formData.customer_type,
  () => formData.customer_name,
  () => formData.pi_film_model,
  () => formData.experiment_date,
  () => formData.sintering_location,
  () => formData.material_type_for_firing,
  () => formData.rolling_method,
  () => formData.experiment_group
], generateExperimentCode)

/**
 * 加载草稿数据并填充到表单
 * @param expId 实验ID（使用不同的参数名避免与 ref 变量冲突）
 */
async function loadDraftData(expId: number) {
  try {
    console.log('📖 加载草稿数据，ID:', expId)

    // 调用API获取实验详情
    const response = await experimentApi.getExperiment(expId)
    const data = response.experiment

    console.log('✅ 草稿数据加载成功:', data)

    // 1. 填充基本参数
    if (data.basic) {
      formData.pi_film_thickness = data.basic.pi_film_thickness
      formData.customer_type = data.basic.customer_type
      formData.customer_name = data.basic.customer_name
      formData.pi_film_model = data.basic.pi_film_model
      formData.experiment_date = data.basic.experiment_date
      formData.sintering_location = data.basic.sintering_location
      formData.material_type_for_firing = data.basic.material_type_for_firing
      formData.rolling_method = data.basic.rolling_method
      formData.experiment_group = data.basic.experiment_group
      formData.experiment_purpose = data.basic.experiment_purpose
    }

    // 2. 填充PI膜参数
    if (data.pi) {
      formData.pi_manufacturer = data.pi.pi_manufacturer
      formData.pi_thickness_detail = data.pi.pi_thickness_detail
      formData.pi_model_detail = data.pi.pi_model_detail
      formData.pi_width = data.pi.pi_width
      formData.batch_number = data.pi.batch_number
      formData.pi_weight = data.pi.pi_weight
    }

    // 3. 填充松卷参数
    if (data.loose) {
      formData.core_tube_type = data.loose.core_tube_type
      formData.loose_gap_inner = data.loose.loose_gap_inner
      formData.loose_gap_middle = data.loose.loose_gap_middle
      formData.loose_gap_outer = data.loose.loose_gap_outer
    }

    // 4. 填充碳化参数
    if (data.carbon) {
      formData.carbon_furnace_num = data.carbon.carbon_furnace_number
      formData.carbon_batch_num = data.carbon.carbon_furnace_batch
      formData.boat_model = data.carbon.boat_model
      formData.wrap_type = data.carbon.wrapping_method
      formData.vacuum_degree = data.carbon.vacuum_degree
      formData.carbon_power = data.carbon.power_consumption
      formData.carbon_start_time = data.carbon.start_time
      formData.carbon_end_time = data.carbon.end_time

      // ✅ 温度/厚度字段
      formData.carbon_temp1 = data.carbon.carbon_temp1
      formData.carbon_thickness1 = data.carbon.carbon_thickness1
      formData.carbon_temp2 = data.carbon.carbon_temp2
      formData.carbon_thickness2 = data.carbon.carbon_thickness2

      formData.carbon_max_temp = data.carbon.carbon_max_temp
      formData.carbon_film_thickness = data.carbon.carbon_film_thickness
      formData.carbon_total_time = data.carbon.carbon_total_time
      formData.carbon_weight = data.carbon.carbon_after_weight
      formData.carbon_yield_rate = data.carbon.carbon_yield_rate
      formData.carbon_loading_photo = data.carbon.carbon_loading_photo
      formData.carbon_sample_photo = data.carbon.carbon_sample_photo
      formData.carbon_other_params = data.carbon.carbon_other_params
    }

    // 5. 填充石墨化参数
    if (data.graphite) {
      formData.graphite_furnace_num = data.graphite.graphite_furnace_number
      formData.graphite_batch_num = data.graphite.graphite_furnace_batch
      formData.graphite_start_time = data.graphite.graphite_start_time
      formData.graphite_end_time = data.graphite.graphite_end_time
      formData.pressure_value = data.graphite.gas_pressure
      formData.graphite_power = data.graphite.graphite_power

      // ✅ 温度/厚度字段
      formData.graphite_temp1 = data.graphite.graphite_temp1
      formData.graphite_thickness1 = data.graphite.graphite_thickness1
      formData.graphite_temp2 = data.graphite.graphite_temp2
      formData.graphite_thickness2 = data.graphite.graphite_thickness2
      formData.graphite_temp3 = data.graphite.graphite_temp3
      formData.graphite_thickness3 = data.graphite.graphite_thickness3
      formData.graphite_temp4 = data.graphite.graphite_temp4
      formData.graphite_thickness4 = data.graphite.graphite_thickness4
      formData.graphite_temp5 = data.graphite.graphite_temp5
      formData.graphite_thickness5 = data.graphite.graphite_thickness5
      formData.graphite_temp6 = data.graphite.graphite_temp6
      formData.graphite_thickness6 = data.graphite.graphite_thickness6

      formData.graphite_max_temp = data.graphite.graphite_max_temp
      formData.foam_thickness = data.graphite.foam_thickness
      formData.graphite_width = data.graphite.graphite_width
      formData.shrinkage_ratio = data.graphite.shrinkage_ratio
      formData.graphite_total_time = data.graphite.graphite_total_time
      formData.graphite_weight = data.graphite.graphite_after_weight
      formData.graphite_yield_rate = data.graphite.graphite_yield_rate
      formData.graphite_min_thickness = data.graphite.graphite_min_thickness
      formData.graphite_loading_photo = data.graphite.graphite_loading_photo
      formData.graphite_sample_photo = data.graphite.graphite_sample_photo
      formData.graphite_other_params = data.graphite.graphite_other_params
    }

    // 6. 填充压延参数
    if (data.rolling) {
      formData.rolling_machine_num = data.rolling.rolling_machine
      formData.rolling_pressure = data.rolling.rolling_pressure
      formData.rolling_tension = data.rolling.rolling_tension
      formData.rolling_speed = data.rolling.rolling_speed
    }

    // 7. 填充成品参数
    if (data.product) {
      formData.product_code = data.product.product_code
      formData.product_avg_thickness = data.product.avg_thickness
      formData.product_spec = data.product.specification
      formData.product_avg_density = data.product.avg_density
      formData.thermal_diffusivity = data.product.thermal_diffusivity
      formData.thermal_conductivity = data.product.thermal_conductivity
      formData.specific_heat = data.product.specific_heat
      formData.cohesion = data.product.cohesion
      formData.peel_strength = data.product.peel_strength
      formData.roughness = data.product.roughness
      formData.appearance_description = data.product.appearance_desc
      formData.experiment_summary = data.product.experiment_summary
      formData.remarks = data.product.remarks
      formData.defect_photo = data.product.appearance_defect_photo
      formData.sample_photo = data.product.sample_photo
      formData.other_files = data.product.other_files
    }

    // ✅ 关键修复：设置实验ID和编码（用于后续更新）
    experimentId.value = data.id  // ← 现在访问的是外部的 ref 变量
    experimentCode.value = data.experiment_code

    console.log('✅ 实验ID已设置:', experimentId.value)
    console.log('✅ 实验编码已设置:', experimentCode.value)

    ElMessage.success('草稿数据加载成功')

  } catch (error: any) {
    console.error('❌ 加载草稿数据失败:', error)
    ElMessage.error('加载草稿数据失败：' + (error.message || '未知错误'))
  }
}

// 页面初始化
onMounted(async () => {
  // 1. 加载下拉选项
  loadDropdownOptions()

  // 2. 检查是否是编辑模式（从路由获取experiment_id）
  const experimentIdFromRoute = route.params.id

  if (experimentIdFromRoute) {
    // 编辑模式：加载草稿数据
    console.log('📝 编辑模式，实验ID:', experimentIdFromRoute)
    await loadDraftData(Number(experimentIdFromRoute))
  } else {
    // 创建模式：设置默认日期
    console.log('✨ 创建模式')
    formData.experiment_date = new Date().toISOString().split('T')[0]
  }
})

// ✅ 修复后的生成实验编码函数
function generateExperimentCode() {
  const {
    pi_film_thickness,
    customer_type,
    customer_name,
    pi_film_model,
    experiment_date,
    sintering_location,
    material_type_for_firing,
    rolling_method,
    experiment_group
  } = formData

  if (!pi_film_thickness || !customer_type || !customer_name || !pi_film_model ||
      !experiment_date || !sintering_location || !material_type_for_firing ||
      !rolling_method || !experiment_group) {
    experimentCode.value = ''
    return
  }

  try {
    // 提取客户代码 (如 "SA/三星" -> "SA")
    const customerCode = customer_name.split('/')[0] || customer_name.substring(0, 2)

    // 格式化日期 (如 "2025-09-01" -> "250901")
    const dateStr = experiment_date.replace(/-/g, '').substring(2)

    // 格式化编组 (如 1 -> "01")
    const groupStr = experiment_group.toString().padStart(2, '0')

    // ✅ 修复：去除PI膜型号中的所有连字符和空格
    // 例如：TH5-100 -> TH5100, GP-65 -> GP65
    const cleanedPiModel = pi_film_model.replace(/-/g, '').replace(/\s/g, '')

    // 生成编码: PI膜厚度 + 客户类型 + 客户代码 + "-" + PI膜型号(已清理) + "-" + 日期 + 烧制地点 + "-" + 材料类型 + 压延方式 + 编组
    // 示例：100ISA-TH5100-251008DG-RIF01 (3个连字符 ✅)
    experimentCode.value = `${pi_film_thickness}${customer_type}${customerCode}-${cleanedPiModel}-${dateStr}${sintering_location}-${material_type_for_firing}${rolling_method}${groupStr}`
  } catch (error) {
    console.error('生成实验编码失败:', error)
    experimentCode.value = ''
  }
}

// ✅ 保留：预览实验编码
function previewExperimentCode() {
  generateExperimentCode()
  if (experimentCode.value) {
    ElMessage.success(`实验编码: ${experimentCode.value}`)
  } else {
    ElMessage.warning('请先填写实验设计参数中的必填字段')
  }
}

// ✅ 保留：加载下拉选项数据
async function loadDropdownOptions() {
  try {
    const fields = [
      'pi_film_thickness',
      'customer_type',
      'customer_name',
      'pi_film_model',
      'sintering_location',
      'material_type_for_firing',
      'rolling_method',
      'pi_manufacturer',
      'pi_thickness_detail'
    ]

    for (const field of fields) {
      const options = await dropdownApi.getOptions(field)
      dropdownOptions[field] = options
    }
  } catch (error) {
    console.error('加载下拉选项失败:', error)
    ElMessage.error('加载下拉选项失败')
  }
}

// ✅ 保留：处理搜索
async function handleSearch(fieldName: string, keyword: string) {
  if (keyword.length < 2) return

  try {
    const options = await dropdownApi.searchOptions(fieldName, keyword)
    dropdownOptions[fieldName] = options
  } catch (error) {
    console.error('搜索失败:', error)
  }
}

// ✅ 保留：处理新增选项
function handleAddNewOption(fieldName: string, value: string) {
  const fieldLabels = {
    customer_name: '客户名称',
    pi_film_model: 'PI膜型号',
    pi_manufacturer: 'PI膜厂商',
    sintering_location: '烧制地点'
  }

  addOptionDialog.fieldName = fieldName
  addOptionDialog.fieldLabel = fieldLabels[fieldName] || fieldName
  addOptionDialog.visible = true
}

// ✅ 保留：确认新增选项
async function handleConfirmAddOption(data: any) {
  try {
    await dropdownApi.addOption(addOptionDialog.fieldName, data)
    ElMessage.success('选项添加成功')

    // 重新加载该字段的选项
    const options = await dropdownApi.getOptions(addOptionDialog.fieldName)
    dropdownOptions[addOptionDialog.fieldName] = options

    // 设置为新添加的选项
    formData[addOptionDialog.fieldName] = data.value
  } catch (error) {
    console.error('添加选项失败:', error)
    ElMessage.error('添加选项失败')
  }
}

// ✅ 保留：处理标签页切换
function handleTabChange(tabName: string) {
  activeTab.value = tabName
}

// ==========================================
// 🆕 新增：数据准备函数
// ==========================================
function prepareSubmitData() {
  return {
    // 实验编码（前端已生成）
    experiment_code: experimentCode.value,

    // 实验设计参数（基本参数）
    pi_film_thickness: formData.pi_film_thickness,
    customer_type: formData.customer_type,
    customer_name: formData.customer_name,
    pi_film_model: formData.pi_film_model,
    experiment_date: formData.experiment_date,
    sintering_location: formData.sintering_location,
    material_type_for_firing: formData.material_type_for_firing,
    rolling_method: formData.rolling_method,
    experiment_group: formData.experiment_group,
    experiment_purpose: formData.experiment_purpose,

    // PI膜参数
    pi_manufacturer: formData.pi_manufacturer,
    pi_thickness_detail: formData.pi_thickness_detail,
    pi_model_detail: formData.pi_model_detail,
    pi_width: formData.pi_width,
    batch_number: formData.batch_number,
    pi_weight: formData.pi_weight,
    firing_rolls: formData.firing_rolls,
    pi_notes: formData.pi_notes,

    // 松卷参数
    core_tube_type: formData.core_tube_type,
    loose_gap_inner: formData.loose_gap_inner,
    loose_gap_middle: formData.loose_gap_middle,
    loose_gap_outer: formData.loose_gap_outer,

    // 碳化参数
    carbon_furnace_num: formData.carbon_furnace_num,
    carbon_batch_num: formData.carbon_batch_num,
    boat_model: formData.boat_model,
    wrap_type: formData.wrap_type,
    vacuum_degree: formData.vacuum_degree,
    carbon_power: formData.carbon_power,
    carbon_start_time: formData.carbon_start_time,
    carbon_end_time: formData.carbon_end_time,
    carbon_temp1: formData.carbon_temp1,
    carbon_thickness1: formData.carbon_thickness1,
    carbon_temp2: formData.carbon_temp2,
    carbon_thickness2: formData.carbon_thickness2,
    carbon_max_temp: formData.carbon_max_temp,
    carbon_film_thickness: formData.carbon_film_thickness,
    carbon_total_time: formData.carbon_total_time,
    carbon_weight: formData.carbon_weight,
    carbon_yield_rate: formData.carbon_yield_rate,
    carbon_loading_photo: formData.carbon_loading_photo,
    carbon_sample_photo: formData.carbon_sample_photo,
    carbon_other_params: formData.carbon_other_params,
    carbon_notes: formData.carbon_notes,

    // 石墨化参数
    graphite_furnace_num: formData.graphite_furnace_num,
    graphite_batch_num: formData.graphite_batch_num,
    graphite_start_time: formData.graphite_start_time,
    graphite_end_time: formData.graphite_end_time,
    pressure_value: formData.pressure_value,
    graphite_power: formData.graphite_power,
    graphite_temp1: formData.graphite_temp1,
    graphite_thickness1: formData.graphite_thickness1,
    graphite_temp2: formData.graphite_temp2,
    graphite_thickness2: formData.graphite_thickness2,
    graphite_temp3: formData.graphite_temp3,
    graphite_thickness3: formData.graphite_thickness3,
    graphite_temp4: formData.graphite_temp4,
    graphite_thickness4: formData.graphite_thickness4,
    graphite_temp5: formData.graphite_temp5,
    graphite_thickness5: formData.graphite_thickness5,
    graphite_temp6: formData.graphite_temp6,
    graphite_thickness6: formData.graphite_thickness6,
    graphite_max_temp: formData.graphite_max_temp,
    foam_thickness: formData.foam_thickness,
    graphite_width: formData.graphite_width,
    shrinkage_ratio: formData.shrinkage_ratio,
    graphite_total_time: formData.graphite_total_time,
    graphite_weight: formData.graphite_weight,
    graphite_yield_rate: formData.graphite_yield_rate,
    graphite_min_thickness: formData.graphite_min_thickness,
    graphite_loading_photo: formData.graphite_loading_photo,
    graphite_sample_photo: formData.graphite_sample_photo,
    graphite_other_params: formData.graphite_other_params,
    graphite_notes: formData.graphite_notes,

    // 压延参数
    rolling_machine_num: formData.rolling_machine_num,
    rolling_pressure: formData.rolling_pressure,
    rolling_tension: formData.rolling_tension,
    rolling_speed: formData.rolling_speed,
    rolling_notes: formData.rolling_notes,

    // 产品参数
    product_code: formData.product_code,
    product_avg_thickness: formData.product_avg_thickness,
    product_spec: formData.product_spec,
    product_avg_density: formData.product_avg_density,
    thermal_diffusivity: formData.thermal_diffusivity,
    thermal_conductivity: formData.thermal_conductivity,
    specific_heat: formData.specific_heat,
    cohesion: formData.cohesion,
    peel_strength: formData.peel_strength,
    roughness: formData.roughness,
    appearance_description: formData.appearance_description,
    experiment_summary: formData.experiment_summary,
    remarks: formData.remarks,
    defect_photo: formData.defect_photo,
    sample_photo: formData.sample_photo,
    other_files: formData.other_files,
    bond_strength: formData.bond_strength,

    // 备注
    notes: formData.notes || ''
  }
}


// ==========================================
// 🔄 替换：保存草稿函数（支持创建和更新）
// ==========================================
async function handleSaveDraft() {
  // 1. 草稿只验证基本参数
  const basicFields = [
    'pi_film_thickness', 'customer_type', 'customer_name', 'pi_film_model',
    'experiment_date', 'sintering_location', 'material_type_for_firing',
    'rolling_method', 'experiment_group', 'experiment_purpose'
  ]

  // 检查基本字段是否填写完整
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
    // 准备提交数据（使用前端已生成的实验编码）
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

    // 处理错误信息
    let errorMsg = '保存草稿失败'

    if (error.response?.data?.error) {
      errorMsg = error.response.data.error

      // 如果有缺失字段信息
      if (error.response.data.missing_fields) {
        const fields = error.response.data.missing_fields.join(', ')
        errorMsg += `\n缺少字段：${fields}`
      }
    } else if (error.message) {
      errorMsg = error.message
    }

    ElMessage.error({
      message: errorMsg,
      duration: 5000
    })
  } finally {
    loading.draft = false
  }
}

// ✅ 修复后的提交实验函数
async function handleSubmit() {
  if (!formRef.value) return

  // 🔧 先检查实验编码
  if (!experimentCode.value) {
    ElMessage.error('实验编码未生成，请检查基本参数是否填写完整')
    activeTab.value = 'basic'
    return
  }

  loading.submit = true

  try {
    // 1. 验证所有必填字段
    await formRef.value.validate()

    // 2. 确认提交对话框
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

    // 3. 准备提交数据
    const submitData = prepareSubmitData()

    // 4. 调用API提交实验
    const response = await experimentApi.submitExperiment(submitData)

    // 5. 提交成功提示
    ElMessage.success({
      message: `实验提交成功！实验编码：${response.experiment_code}`,
      duration: 3000
    })

    // 6. 延迟跳转到实验数据库页面
    setTimeout(() => {
      router.push('/experiments/database')
    }, 1500)

  } catch (error: any) {
    console.error('提交实验失败:', error)

    // ✅ 关键修复：区分验证错误和网络错误

    // 1. 用户取消操作
    if (error === 'cancel' || error === 'close') {
      loading.submit = false
      return
    }

    // 2. Element Plus 表单验证错误（对象格式）
    if (error && typeof error === 'object' && !error.response) {
      // 提取验证失败的字段名
      const fieldNames = Object.keys(error)
      const fieldLabels: Record<string, string> = {
        'pi_manufacturer': 'PI膜厂商',
        'pi_thickness_detail': 'PI膜初始厚度',
        'pi_model_detail': 'PI膜型号',
        'pi_weight': 'PI重量',
        'carbon_furnace_num': '碳化炉编号',
        'carbon_batch_num': '碳化炉次',
        'carbon_max_temp': '碳化最高温度',
        'carbon_film_thickness': '碳化膜厚度',
        'carbon_total_time': '碳化总时长',
        'carbon_weight': '碳化后重量',
        'carbon_yield_rate': '碳化成碳率',
        'graphite_furnace_num': '石墨炉编号',
        'pressure_value': '气压值',
        'graphite_max_temp': '石墨化最高温度',
        'foam_thickness': '发泡厚度',
        'graphite_width': '石墨宽幅',
        'shrinkage_ratio': '收缩比',
        'graphite_total_time': '石墨化总时长',
        'graphite_weight': '石墨化后重量',
        'graphite_yield_rate': '石墨化成碳率',
        'product_avg_thickness': '样品平均厚度',
        'product_spec': '规格',
        'product_avg_density': '平均密度',
        'thermal_diffusivity': '热扩散系数',
        'thermal_conductivity': '导热系数',
        'specific_heat': '比热',
        'cohesion': '内聚力',
        'peel_strength': '剥离力',
        'roughness': '粗糙度',
        'appearance_description': '外观描述'
      }

      const missingLabels = fieldNames
        .map(field => fieldLabels[field] || field)
        .slice(0, 10) // 最多显示10个

      const moreCount = fieldNames.length > 10 ? ` 等${fieldNames.length}个` : ''

      ElMessage.error({
        message: `请完善以下必填字段：\n${missingLabels.join('、')}${moreCount}`,
        duration: 5000,
        showClose: true
      })

      loading.submit = false
      return
    }

    // 3. 网络错误或后端错误
    if (error.response?.data?.error) {
      let errorMsg = error.response.data.error

      if (error.response.data.missing_fields) {
        const fields = error.response.data.missing_fields.join('\n- ')
        ElMessage.error({
          message: `${errorMsg}\n\n缺少以下字段：\n- ${fields}`,
          duration: 8000,
          showClose: true
        })
      } else {
        ElMessage.error({
          message: errorMsg,
          duration: 5000
        })
      }
    } else if (error.message) {
      ElMessage.error({
        message: error.message,
        duration: 5000
      })
    } else {
      ElMessage.error('提交实验失败，请稍后重试')
    }

    loading.submit = false
  }
}

// ==========================================
// 🔄 替换：返回函数
// ==========================================
function handleBack() {
  // 检查是否有未保存的数据
  const hasData = formData.pi_film_thickness ||
                  formData.customer_name ||
                  formData.experiment_purpose

  if (hasData) {
    ElMessageBox.confirm(
      '确定要离开吗？未保存的数据将会丢失。',
      '确认离开',
      {
        confirmButtonText: '确定离开',
        cancelButtonText: '继续编辑',
        type: 'warning',
        distinguishCancelAndClose: true
      }
    ).then(() => {
      router.go(-1)
    }).catch(() => {
      // 用户取消，不做任何操作
    })
  } else {
    // 没有数据，直接返回
    router.go(-1)
  }
}
</script>

<style scoped>
.create-experiment {
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
  position: sticky;
  top: 0;
  z-index: 100;
}

.header h1 {
  margin: 0;
  color: #2c3e50;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.code-preview {
  margin: 20px 40px 0;
}

.form-container {
  padding: 20px 40px 40px;
  max-width: 1400px;
  margin: 0 auto;
}

.module-section {
  background: white;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
}

.module-title {
  color: #2c3e50;
  margin: 0 0 20px 0;
  padding-bottom: 10px;
  border-bottom: 2px solid #3498db;
  font-size: 18px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 20px;
  align-items: start;
}

.form-grid .el-form-item {
  margin-bottom: 0;
}

.form-actions {
  background: white;
  padding: 20px;
  border-radius: 8px;
  display: flex;
  justify-content: center;
  gap: 20px;
  position: sticky;
  bottom: 20px;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
}

.form-actions .el-button {
  min-width: 120px;
  height: 40px;
}

/* 标签页样式 */
:deep(.el-tabs__nav-wrap) {
  background: white;
  padding: 0 20px;
  border-radius: 8px 8px 0 0;
}

:deep(.el-tabs__content) {
  padding: 0;
}

:deep(.el-tabs__item) {
  font-weight: 500;
  font-size: 14px;
}

:deep(.el-tabs__item.is-active) {
  color: #3498db;
}

/* 表单项样式 */
:deep(.el-form-item__label) {
  font-weight: 500;
  color: #2c3e50;
}

:deep(.el-form-item.is-required .el-form-item__label::before) {
  content: '*';
  color: #f56c6c;
  margin-right: 4px;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .form-grid {
    grid-template-columns: 1fr;
  }

  .header {
    padding: 15px 20px;
  }

  .form-container {
    padding: 15px 20px 30px;
  }
}

@media (max-width: 768px) {
  .header {
    flex-direction: column;
    gap: 10px;
    align-items: stretch;
  }

  .header-actions {
    justify-content: center;
  }

  .form-actions {
    flex-direction: column;
    align-items: center;
  }
}
</style>
