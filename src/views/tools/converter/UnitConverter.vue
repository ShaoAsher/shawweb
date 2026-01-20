<template>
  <ToolLayout
    icon="📐"
    title="单位转换工具"
    description="支持长度、重量、温度、面积、体积、时间、速度、数据、角度、压力等多种单位转换，界面美观，分组展示"
  >
    <div class="converter-grid">
      <div v-for="converter in unitConverters" :key="converter.title" class="converter-card">
        <div class="card-header">
          <div class="card-icon">{{ converter.icon }}</div>
          <div class="card-title">{{ converter.title }}</div>
        </div>
        <div class="converter-form">
          <div class="input-field">
            <label class="input-label">输入值</label>
            <div class="input-row">
              <div class="input-wrapper">
                <input
                  v-model.number="converter.inputValue"
                  type="number"
                  class="unit-input"
                  placeholder="0"
                  step="any"
                  @input="performConversion(converter)"
                />
                <select
                  v-model="converter.fromUnit"
                  class="unit-select"
                  @change="performConversion(converter)"
                >
                  <option v-for="unit in converter.units" :key="unit.value" :value="unit.value">
                    {{ unit.name }}
                  </option>
                </select>
              </div>
            </div>
          </div>
          <div class="arrow-divider">⇄</div>
          <div class="input-field">
            <label class="input-label">转换结果</label>
            <div class="input-row">
              <div class="input-wrapper">
                <input
                  :value="converter.outputValue"
                  type="text"
                  class="unit-input"
                  readonly
                  style="background: var(--color-surface);"
                />
                <select
                  v-model="converter.toUnit"
                  class="unit-select"
                  @change="performConversion(converter)"
                >
                  <option v-for="unit in converter.units" :key="unit.value" :value="unit.value">
                    {{ unit.name }}
                  </option>
                </select>
              </div>
            </div>
          </div>
          <div v-if="converter.resultText" class="result-display show">
            {{ converter.resultText }}
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'

const unitConverters = ref([
  {
    icon: '📏',
    title: '长度单位',
    isTemperature: false,
    inputValue: null,
    fromUnit: 1,
    toUnit: 100,
    outputValue: '',
    resultText: '',
    units: [
      { name: '米 (m)', value: 1 },
      { name: '千米 (km)', value: 0.001 },
      { name: '厘米 (cm)', value: 100 },
      { name: '毫米 (mm)', value: 1000 },
      { name: '微米 (μm)', value: 1000000 },
      { name: '纳米 (nm)', value: 1000000000 },
      { name: '英寸 (in)', value: 39.3701 },
      { name: '英尺 (ft)', value: 3.28084 },
      { name: '码 (yd)', value: 1.09361 },
      { name: '英里 (mi)', value: 0.000621371 },
      { name: '海里 (nmi)', value: 0.000539957 },
      { name: '光年 (ly)', value: 1.057e-16 }
    ]
  },
  {
    icon: '⚖️',
    title: '重量单位',
    isTemperature: false,
    inputValue: null,
    fromUnit: 1,
    toUnit: 1000,
    outputValue: '',
    resultText: '',
    units: [
      { name: '千克 (kg)', value: 1 },
      { name: '克 (g)', value: 1000 },
      { name: '毫克 (mg)', value: 1000000 },
      { name: '吨 (t)', value: 0.001 },
      { name: '磅 (lb)', value: 2.20462 },
      { name: '盎司 (oz)', value: 35.274 },
      { name: '英石 (st)', value: 0.157473 },
      { name: '克拉 (ct)', value: 5000 }
    ]
  },
  {
    icon: '🌡️',
    title: '温度单位',
    isTemperature: true,
    inputValue: null,
    fromUnit: 'celsius',
    toUnit: 'fahrenheit',
    outputValue: '',
    resultText: '',
    units: [
      { name: '摄氏度 (°C)', value: 'celsius' },
      { name: '华氏度 (°F)', value: 'fahrenheit' },
      { name: '开尔文 (K)', value: 'kelvin' }
    ]
  },
  {
    icon: '📐',
    title: '面积单位',
    isTemperature: false,
    inputValue: null,
    fromUnit: 1,
    toUnit: 10000,
    outputValue: '',
    resultText: '',
    units: [
      { name: '平方米 (m²)', value: 1 },
      { name: '平方千米 (km²)', value: 0.000001 },
      { name: '公顷 (ha)', value: 0.0001 },
      { name: '平方厘米 (cm²)', value: 10000 },
      { name: '平方毫米 (mm²)', value: 1000000 },
      { name: '平方英寸 (in²)', value: 1550.0031 },
      { name: '平方英尺 (ft²)', value: 10.7639 },
      { name: '平方码 (yd²)', value: 1.19599 },
      { name: '英亩 (acre)', value: 0.000247105 },
      { name: '平方英里 (mi²)', value: 3.861e-7 }
    ]
  },
  {
    icon: '🧪',
    title: '体积单位',
    isTemperature: false,
    inputValue: null,
    fromUnit: 1,
    toUnit: 1000,
    outputValue: '',
    resultText: '',
    units: [
      { name: '升 (L)', value: 1 },
      { name: '毫升 (mL)', value: 1000 },
      { name: '立方米 (m³)', value: 0.001 },
      { name: '立方厘米 (cm³)', value: 1000 },
      { name: '立方英寸 (in³)', value: 61.0237 },
      { name: '立方英尺 (ft³)', value: 0.0353147 },
      { name: '加仑 (gal)', value: 0.264172 },
      { name: '美制加仑 (US gal)', value: 0.264172 },
      { name: '英制加仑 (UK gal)', value: 0.219969 },
      { name: '品脱 (pt)', value: 2.11338 },
      { name: '夸脱 (qt)', value: 1.05669 },
      { name: '液盎司 (fl oz)', value: 33.814 }
    ]
  },
  {
    icon: '⏰',
    title: '时间单位',
    isTemperature: false,
    inputValue: null,
    fromUnit: 1,
    toUnit: 1000,
    outputValue: '',
    resultText: '',
    units: [
      { name: '秒 (s)', value: 1 },
      { name: '毫秒 (ms)', value: 1000 },
      { name: '微秒 (μs)', value: 1000000 },
      { name: '纳秒 (ns)', value: 1000000000 },
      { name: '分钟 (min)', value: 1 / 60 },
      { name: '小时 (h)', value: 1 / 3600 },
      { name: '天 (d)', value: 1 / 86400 },
      { name: '周 (week)', value: 1 / 604800 },
      { name: '月 (month)', value: 1 / 2592000 },
      { name: '年 (year)', value: 1 / 31536000 }
    ]
  },
  {
    icon: '🚀',
    title: '速度单位',
    isTemperature: false,
    inputValue: null,
    fromUnit: 1,
    toUnit: 3.6,
    outputValue: '',
    resultText: '',
    units: [
      { name: '米/秒 (m/s)', value: 1 },
      { name: '千米/小时 (km/h)', value: 3.6 },
      { name: '英里/小时 (mph)', value: 2.23694 },
      { name: '节 (kn)', value: 1.94384 },
      { name: '英尺/秒 (ft/s)', value: 3.28084 },
      { name: '光速 (c)', value: 3.33564e-9 }
    ]
  },
  {
    icon: '💾',
    title: '数据单位',
    isTemperature: false,
    inputValue: null,
    fromUnit: 1,
    toUnit: 1 / 1024,
    outputValue: '',
    resultText: '',
    units: [
      { name: '字节 (B)', value: 1 },
      { name: '千字节 (KB)', value: 1 / 1024 },
      { name: '兆字节 (MB)', value: 1 / 1048576 },
      { name: '吉字节 (GB)', value: 1 / 1073741824 },
      { name: '太字节 (TB)', value: 1 / 1099511627776 },
      { name: '拍字节 (PB)', value: 1 / 1125899906842624 },
      { name: '位 (bit)', value: 8 }
    ]
  },
  {
    icon: '🔄',
    title: '角度单位',
    isTemperature: false,
    inputValue: null,
    fromUnit: 1,
    toUnit: Math.PI / 180,
    outputValue: '',
    resultText: '',
    units: [
      { name: '度 (°)', value: 1 },
      { name: '弧度 (rad)', value: Math.PI / 180 },
      { name: '梯度 (grad)', value: 200 / 180 },
      { name: '转 (rev)', value: 1 / 360 }
    ]
  },
  {
    icon: '💨',
    title: '压力单位',
    isTemperature: false,
    inputValue: null,
    fromUnit: 1,
    toUnit: 0.001,
    outputValue: '',
    resultText: '',
    units: [
      { name: '帕斯卡 (Pa)', value: 1 },
      { name: '千帕 (kPa)', value: 0.001 },
      { name: '兆帕 (MPa)', value: 0.000001 },
      { name: '巴 (bar)', value: 0.00001 },
      { name: '大气压 (atm)', value: 9.86923e-6 },
      { name: 'PSI (psi)', value: 0.000145038 },
      { name: '毫米汞柱 (mmHg)', value: 0.00750062 },
      { name: '托 (Torr)', value: 0.00750062 }
    ]
  }
])

function convertTemperature(value, fromUnit, toUnit) {
  let celsius

  if (fromUnit === 'celsius') {
    celsius = parseFloat(value) || 0
  } else if (fromUnit === 'fahrenheit') {
    celsius = (parseFloat(value) - 32) * 5 / 9
  } else if (fromUnit === 'kelvin') {
    celsius = parseFloat(value) - 273.15
  }

  if (toUnit === 'celsius') {
    return celsius.toFixed(2)
  } else if (toUnit === 'fahrenheit') {
    return (celsius * 9 / 5 + 32).toFixed(2)
  } else if (toUnit === 'kelvin') {
    return (celsius + 273.15).toFixed(2)
  }
  return '0'
}

function formatResult(result) {
  if (Math.abs(result) < 0.000001) {
    return result.toExponential(6)
  } else if (Math.abs(result) < 1) {
    return result.toFixed(8).replace(/\.?0+$/, '')
  } else if (Math.abs(result) < 1000000) {
    return result.toFixed(6).replace(/\.?0+$/, '')
  } else {
    return result.toExponential(6)
  }
}

function performConversion(converter) {
  const value = converter.inputValue
  if (value === null || value === '' || isNaN(value)) {
    converter.outputValue = ''
    converter.resultText = ''
    return
  }

  const fromValue = converter.fromUnit
  const toValue = converter.toUnit

  let result
  if (converter.isTemperature) {
    result = convertTemperature(value, fromValue, toValue)
  } else {
    const baseValue = value / parseFloat(fromValue)
    result = baseValue * parseFloat(toValue)
    result = formatResult(result)
  }

  converter.outputValue = result

  const fromUnitName = converter.units.find(u => u.value == fromValue)?.name || ''
  const toUnitName = converter.units.find(u => u.value == toValue)?.name || ''
  converter.resultText = `${value} ${fromUnitName} = ${result} ${toUnitName}`
}
</script>

<style scoped>
.converter-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
  gap: 24px;
}

.converter-card {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: var(--spacing-lg);
  border: 1px solid var(--color-border);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: var(--shadow-sm);
}

.converter-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-md);
  border-color: var(--color-primary);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 2px solid var(--color-border);
}

.card-icon {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-md);
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  flex-shrink: 0;
  box-shadow: 0 4px 12px var(--color-shadow-primary);
}

.card-title {
  font-size: var(--font-size-large);
  font-weight: 700;
  color: var(--color-text);
  flex: 1;
}

.converter-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.input-field {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.input-label {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.input-row {
  display: flex;
  gap: 12px;
  align-items: stretch;
}

.input-wrapper {
  flex: 1;
  display: flex;
  gap: 8px;
  min-width: 0;
}

.unit-input {
  flex: 1;
  min-width: 0;
  padding: 12px 16px;
  border: 2px solid var(--color-border);
  border-radius: 10px;
  font-size: 15px;
  transition: all 0.3s;
  background: var(--color-surface-alt);
  font-weight: 500;
  color: var(--color-text);
}

.unit-input:focus {
  outline: none;
  border-color: var(--color-primary);
  background: var(--color-surface);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.unit-select {
  min-width: 140px;
  max-width: 180px;
  padding: 12px 16px;
  border: 2px solid var(--color-border);
  border-radius: 10px;
  font-size: var(--font-size-small);
  background: var(--color-surface);
  cursor: pointer;
  transition: all 0.3s;
  flex-shrink: 0;
  font-weight: 500;
  color: var(--color-text);
}

.unit-select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.arrow-divider {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 8px;
  color: var(--color-primary);
  font-size: 20px;
  flex-shrink: 0;
}

.result-display {
  margin-top: 16px;
  padding: 16px;
  background: linear-gradient(135deg, var(--color-background-alt) 0%, var(--color-surface-alt) 100%);
  border-radius: var(--radius-md);
  font-family: 'SF Mono', 'Monaco', 'Courier New', monospace;
  font-size: var(--font-size-small);
  color: var(--color-text);
  min-height: 50px;
  display: none;
  align-items: center;
  word-break: break-all;
  border: 1px solid var(--color-border);
}

.result-display.show {
  display: flex;
}

@media (max-width: 1200px) {
  .converter-grid {
    grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
    gap: 20px;
  }
}

@media (max-width: 768px) {
  .converter-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }

  .converter-card {
    padding: 20px;
  }

  .input-row {
    flex-direction: column;
    gap: 12px;
  }

  .arrow-divider {
    transform: rotate(90deg);
    padding: 8px 0;
  }

  .unit-select {
    min-width: 100%;
    max-width: 100%;
  }
}
</style>
