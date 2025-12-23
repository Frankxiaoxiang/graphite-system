<template>
  <div class="regression-chart">
    <div ref="chartRef" class="chart-container"></div>
    
    <div class="chart-actions">
      <el-button size="small" @click="handleExportPNG">
        <el-icon><Picture /></el-icon>
        导出PNG
      </el-button>
      <el-button size="small" @click="handleReset">
        <el-icon><RefreshRight /></el-icon>
        重置缩放
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Picture, RefreshRight } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import type { ECharts, EChartsOption } from 'echarts'
import type { RegressionResult, FieldMetadata } from '@/types/analysis'

// Props
interface Props {
  data: Array<{ x: number; y: number; experiment_code?: string }>
  regression: RegressionResult
  metadata?: FieldMetadata
}

const props = defineProps<Props>()

// 图表实例
const chartRef = ref<HTMLElement>()
let chartInstance: ECharts | null = null

// 初始化图表
onMounted(() => {
  if (chartRef.value) {
    chartInstance = echarts.init(chartRef.value)
    updateChart()
    
    // 监听窗口大小变化
    window.addEventListener('resize', handleResize)
  }
})

// 清理
onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  if (chartInstance) {
    chartInstance.dispose()
    chartInstance = null
  }
})

// 监听数据变化
watch(() => [props.data, props.regression], () => {
  updateChart()
}, { deep: true })

// 更新图表
const updateChart = () => {
  if (!chartInstance) return

  // 准备数据点 - 保留 experiment_code 作为第三个维度
  const scatterData = props.data.map(d => [d.x, d.y, d.experiment_code || '未知'])
  
  // 准备回归线数据
  const regressionLine = props.regression.predictions.map(p => [p.x, p.y])

  // 构建图表配置
  const option: EChartsOption = {
    title: {
      text: props.metadata 
        ? `${props.metadata.y_label} vs ${props.metadata.x_label}`
        : '回归分析图',
      left: 'center',
      top: 10,
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold'
      }
    },
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'cross'
      },
      formatter: (params: any) => {
        if (Array.isArray(params) && params.length > 0) {
          const dataPoint = params.find((p: any) => p.seriesName === '数据点')
          const regressionPoint = params.find((p: any) => p.seriesName === '回归线')
          
          let html = ''
          
          if (dataPoint) {
            const [x, y, code] = dataPoint.value  // ✅ 获取实验编码
            html += `
              <div style="font-weight: bold; margin-bottom: 5px;">实验: ${code}</div>
              <div>X: ${x.toFixed(2)} ${props.metadata?.x_unit || ''}</div>
              <div>Y: ${y.toFixed(2)} ${props.metadata?.y_unit || ''}</div>
            `
          }
          
          if (regressionPoint) {
            const [x, y] = regressionPoint.value
            html += `
              <div style="font-weight: bold; margin-top: 10px; margin-bottom: 5px;">预测值</div>
              <div>X: ${x.toFixed(2)} ${props.metadata?.x_unit || ''}</div>
              <div>Y: ${y.toFixed(2)} ${props.metadata?.y_unit || ''}</div>
            `
          }
          
          return html
        }
        return ''
      }
    },
    legend: {
      data: ['数据点', '回归线'],
      top: 40,
      left: 'center'
    },
    grid: {
      left: '10%',
      right: '10%',
      top: 100,
      bottom: 80,
      containLabel: true
    },
    xAxis: {
      type: 'value',
      name: props.metadata?.x_label || 'X',
      nameLocation: 'middle',
      nameGap: 30,
      nameTextStyle: {
        fontSize: 14,
        fontWeight: 'bold'
      },
      axisLabel: {
        formatter: (value: number) => {
          return `${value.toFixed(0)} ${props.metadata?.x_unit || ''}`
        }
      },
      splitLine: {
        lineStyle: {
          type: 'dashed',
          color: '#e4e7ed'
        }
      }
    },
    yAxis: {
      type: 'value',
      name: props.metadata?.y_label || 'Y',
      nameLocation: 'middle',
      nameGap: 50,
      nameTextStyle: {
        fontSize: 14,
        fontWeight: 'bold'
      },
      axisLabel: {
        formatter: (value: number) => {
          return `${value.toFixed(0)} ${props.metadata?.y_unit || ''}`
        }
      },
      splitLine: {
        lineStyle: {
          type: 'dashed',
          color: '#e4e7ed'
        }
      }
    },
    series: [
      {
        name: '数据点',
        type: 'scatter',
        data: scatterData,
        symbolSize: 10,
        itemStyle: {
          color: '#409eff',
          opacity: 0.7
        },
        emphasis: {
          itemStyle: {
            color: '#409eff',
            opacity: 1,
            borderColor: '#409eff',
            borderWidth: 2
          }
        }
      },
      {
        name: '回归线',
        type: 'line',
        data: regressionLine,
        smooth: false,
        showSymbol: false,
        lineStyle: {
          color: '#f56c6c',
          width: 3
        },
        emphasis: {
          lineStyle: {
            width: 4
          }
        }
      }
    ],
    graphic: [
      {
        type: 'text',
        left: 'center',
        bottom: 20,
        style: {
          text: `${props.regression.equation}    R² = ${props.regression.r_squared.toFixed(4)}`,
          fontSize: 14,
          fontWeight: 'bold',
          fill: '#303133'
        }
      }
    ],
    toolbox: {
      show: true,
      feature: {
        dataZoom: {
          yAxisIndex: 'none',
          title: {
            zoom: '区域缩放',
            back: '还原'
          }
        },
        restore: {
          title: '还原'
        },
        saveAsImage: {
          title: '保存图片',
          name: `regression_chart_${Date.now()}`
        }
      },
      right: 20,
      top: 10
    },
    dataZoom: [
      {
        type: 'inside',
        xAxisIndex: 0,
        filterMode: 'none'
      },
      {
        type: 'inside',
        yAxisIndex: 0,
        filterMode: 'none'
      }
    ]
  }

  chartInstance.setOption(option)
}

// 窗口大小调整
const handleResize = () => {
  if (chartInstance) {
    chartInstance.resize()
  }
}

// 导出PNG
const handleExportPNG = () => {
  if (!chartInstance) return
  
  try {
    const url = chartInstance.getDataURL({
      type: 'png',
      pixelRatio: 2,
      backgroundColor: '#fff'
    })
    
    const link = document.createElement('a')
    link.href = url
    link.download = `regression_chart_${Date.now()}.png`
    link.click()
    
    ElMessage.success('图表已导出')
  } catch (error) {
    ElMessage.error('导出失败')
  }
}

// 重置缩放
const handleReset = () => {
  if (chartInstance) {
    chartInstance.dispatchAction({
      type: 'restore'
    })
    ElMessage.success('已重置缩放')
  }
}
</script>

<style scoped lang="scss">
.regression-chart {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.chart-container {
  width: 100%;
  height: 500px;
  min-height: 400px;
}

.chart-actions {
  display: flex;
  justify-content: center;
  gap: 10px;
}
</style>
