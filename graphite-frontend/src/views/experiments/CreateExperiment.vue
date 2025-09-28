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

                <el-form-item label="客户类型" prop="customer_type" required>
                  <el-select v-model="formData.customer_type" placeholder="请选择客户类型">
                    <el-option label="国际客户" value="I" />
                    <el-option label="国内客户" value="D" />
                    <el-option label="内部客户" value="N" />
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
                    :can-add="authStore.user?.role !== 'user'"
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
                    :can-add="authStore.user?.role === 'admin'"
                  />
                </el-form-item>

                <el-form-item label="送烧材料类型" prop="material_type_for_firing" required>
                  <el-select v-model="formData.material_type_for_firing" placeholder="请选择送烧材料类型">
                    <el-option label="卷材(Roll)" value="R" />
                    <el-option label="片材(Plate)" value="P" />
                  </el-select>
                </el-form-item>

                <el-form-item label="压延方式" prop="rolling_method" required>
                  <el-select v-model="formData.rolling_method" placeholder="请选择压延方式">
                    <el-option label="内部平压(IF)" value="IF" />
                    <el-option label="内部辊压(IR)" value="IR" />
                    <el-option label="外发平压(OF)" value="OF" />
                    <el-option label="外发辊压(OR)" value="OR" />
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
                    :can-add="authStore.user?.role !== 'user'"
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

                <el-form-item label="碳化膜厚度(μm)" prop="carbon_film_thickness" required>
                  <el-input-number
                    v-model="formData.carbon_film_thickness"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="碳化总时长(min)" prop="carbon_total_time" required>
                  <el-input-number
                    v-model="formData.carbon_total_time"
                    :min="0"
                    :precision="0"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="碳化后重量(kg)" prop="carbon_weight" required>
                  <el-input-number
                    v-model="formData.carbon_weight"
                    :min="0"
                    :precision="3"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="成碳率(%)" prop="carbon_yield_rate" required>
                  <el-input-number
                    v-model="formData.carbon_yield_rate"
                    :min="0"
                    :max="100"
                    :precision="2"
                    controls-position="right"
                  />
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

                <el-form-item label="气压值" prop="pressure_value" required>
                  <el-input-number
                    v-model="formData.pressure_value"
                    :precision="2"
                    controls-position="right"
                  />
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

                <el-form-item label="成碳率(%)" prop="graphite_yield_rate" required>
                  <el-input-number
                    v-model="formData.graphite_yield_rate"
                    :min="0"
                    :max="100"
                    :precision="2"
                    controls-position="right"
                  />
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

                <el-form-item label="内聚力(gf)" prop="cohesion" required>
                  <el-input-number
                    v-model="formData.cohesion"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="剥离力(gf)" prop="peel_strength" required>
                  <el-input-number
                    v-model="formData.peel_strength"
                    :min="0"
                    :precision="2"
                    controls-position="right"
                  />
                </el-form-item>

                <el-form-item label="粗糙度" prop="roughness" required>
                  <el-input v-model="formData.roughness" placeholder="请输入粗糙度" />
                </el-form-item>

                <el-form-item label="外观及不良情况描述" prop="appearance_description">
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
import { useRouter } from 'vue-router'
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

  // 6. 压延参数
  rolling_machine_num: '',
  rolling_pressure: null,
  rolling_tension: null,
  rolling_speed: null,

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
  other_files: null
})

// 下拉选项数据
const dropdownOptions = reactive({
  pi_film_thickness: [],
  customer_name: [],
  pi_film_model: [],
  sintering_location: [],
  pi_manufacturer: []
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
  material_type_for_firing: [{ required: true, message: '送烧材料类型不能为空', trigger: 'change' }],
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
  carbon_film_thickness: [{ required: true, message: '碳化膜厚度不能为空', trigger: 'change' }],
  carbon_total_time: [{ required: true, message: '碳化总时长不能为空', trigger: 'change' }],
  carbon_weight: [{ required: true, message: '碳化后重量不能为空', trigger: 'change' }],
  carbon_yield_rate: [{ required: true, message: '成碳率不能为空', trigger: 'change' }],

  graphite_furnace_num: [{ required: true, message: '石墨炉编号不能为空', trigger: 'blur' }],
  pressure_value: [{ required: true, message: '气压值不能为空', trigger: 'change' }],
  graphite_max_temp: [{ required: true, message: '石墨化最高温度不能为空', trigger: 'change' }],
  foam_thickness: [{ required: true, message: '发泡厚度不能为空', trigger: 'change' }],
  graphite_width: [{ required: true, message: '石墨宽幅不能为空', trigger: 'change' }],
  shrinkage_ratio: [{ required: true, message: '收缩比不能为空', trigger: 'change' }],
  graphite_total_time: [{ required: true, message: '石墨化总时长不能为空', trigger: 'change' }],
  graphite_weight: [{ required: true, message: '石墨化后重量不能为空', trigger: 'change' }],
  graphite_yield_rate: [{ required: true, message: '成碳率不能为空', trigger: 'change' }],

  product_avg_thickness: [{ required: true, message: '样品平均厚度不能为空', trigger: 'change' }],
  product_spec: [{ required: true, message: '规格不能为空', trigger: 'blur' }],
  product_avg_density: [{ required: true, message: '平均密度不能为空', trigger: 'change' }],
  thermal_diffusivity: [{ required: true, message: '热扩散系数不能为空', trigger: 'change' }],
  thermal_conductivity: [{ required: true, message: '导热系数不能为空', trigger: 'change' }],
  specific_heat: [{ required: true, message: '比热不能为空', trigger: 'change' }],
  cohesion: [{ required: true, message: '内聚力不能为空', trigger: 'change' }],
  peel_strength: [{ required: true, message: '剥离力不能为空', trigger: 'change' }],
  roughness: [{ required: true, message: '粗糙度不能为空', trigger: 'blur' }],
  experiment_summary: [{ required: true, message: '实验总结不能为空', trigger: 'blur' }]
}

// 监听关键字段变化，自动生成实验编码
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

// 页面初始化
onMounted(() => {
  loadDropdownOptions()
  // 设置默认实验申请日期为今天
  formData.experiment_date = new Date().toISOString().split('T')[0]
})

// 生成实验编码
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

    // 生成编码: PI膜厚度 + 客户类型 + 客户代码 + "-" + PI膜型号 + "-" + 日期 + 烧制地点 + "-" + 材料类型 + 压延方式 + 编组
    experimentCode.value = `${pi_film_thickness}${customer_type}${customerCode}-${pi_film_model}-${dateStr}${sintering_location}-${material_type_for_firing}${rolling_method}${groupStr}`
  } catch (error) {
    console.error('生成实验编码失败:', error)
    experimentCode.value = ''
  }
}

// 预览实验编码
function previewExperimentCode() {
  generateExperimentCode()
  if (experimentCode.value) {
    ElMessage.success(`实验编码: ${experimentCode.value}`)
  } else {
    ElMessage.warning('请先填写实验设计参数中的必填字段')
  }
}

// 加载下拉选项数据
async function loadDropdownOptions() {
  try {
    const fields = ['pi_film_thickness', 'customer_name', 'pi_film_model', 'sintering_location', 'pi_manufacturer']

    for (const field of fields) {
      const options = await dropdownApi.getOptions(field)
      dropdownOptions[field] = options
    }
  } catch (error) {
    console.error('加载下拉选项失败:', error)
    ElMessage.error('加载下拉选项失败')
  }
}

// 处理搜索
async function handleSearch(fieldName: string, keyword: string) {
  if (keyword.length < 2) return

  try {
    const options = await dropdownApi.searchOptions(fieldName, keyword)
    dropdownOptions[fieldName] = options
  } catch (error) {
    console.error('搜索失败:', error)
  }
}

// 处理新增选项
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

// 确认新增选项
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

// 处理标签页切换
function handleTabChange(tabName: string) {
  activeTab.value = tabName
}

// 保存草稿
async function handleSaveDraft() {
  // 草稿只验证基本参数
  const basicFields = [
    'pi_film_thickness', 'customer_type', 'customer_name', 'pi_film_model',
    'experiment_date', 'sintering_location', 'material_type_for_firing',
    'rolling_method', 'experiment_group', 'experiment_purpose'
  ]

  // 检查基本字段是否填写完整
  const missingFields = basicFields.filter(field => !formData[field])
  if (missingFields.length > 0) {
    ElMessage.warning('请先完善实验设计参数中的必填字段')
    activeTab.value = 'basic'
    return
  }

  loading.draft = true

  try {
    generateExperimentCode()
    const draftData = {
      ...formData,
      experiment_code: experimentCode.value,
      status: 'draft'
    }

    await experimentApi.saveDraft(draftData)
    ElMessage.success('草稿保存成功')
  } catch (error) {
    console.error('保存草稿失败:', error)
    ElMessage.error('保存草稿失败')
  } finally {
    loading.draft = false
  }
}

// 提交实验
async function handleSubmit() {
  if (!formRef.value) return

  try {
    // 验证所有必填字段
    await formRef.value.validate()

    const result = await ElMessageBox.confirm(
      '确认提交实验数据吗？提交后将无法修改。',
      '确认提交',
      {
        confirmButtonText: '确认提交',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    if (result !== 'confirm') return

    loading.submit = true

    generateExperimentCode()
    const submitData = {
      ...formData,
      experiment_code: experimentCode.value,
      status: 'submitted'
    }

    await experimentApi.submitExperiment(submitData)

    ElMessage.success('实验提交成功')
    router.push('/experiments/database')

  } catch (error) {
    if (error === 'cancel') return

    console.error('提交实验失败:', error)
    ElMessage.error('提交实验失败')
  } finally {
    loading.submit = false
  }
}

// 返回
function handleBack() {
  router.go(-1)
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
