<template>
  <ToolLayout
    icon="🎨"
    title="RGB 颜色互转工具"
    description="支持 RGB、HEX、HSL 颜色格式互转，提供主流颜色预设卡片，条状展示。"
  >
    <div class="form-section">
      <h2>颜色输入</h2>
      <div class="controls-grid">
        <div class="form-group">
          <label for="hexInput">HEX 颜色值</label>
          <input
            v-model="hexInput"
            type="text"
            id="hexInput"
            placeholder="#FF5733 或 FF5733"
            @input="handleHexInput"
          />
        </div>
        <div class="form-group">
          <label for="rInput">R (0-255)</label>
          <input
            v-model.number="rInput"
            type="number"
            id="rInput"
            min="0"
            max="255"
            @input="handleRgbInput"
          />
        </div>
        <div class="form-group">
          <label for="gInput">G (0-255)</label>
          <input
            v-model.number="gInput"
            type="number"
            id="gInput"
            min="0"
            max="255"
            @input="handleRgbInput"
          />
        </div>
        <div class="form-group">
          <label for="bInput">B (0-255)</label>
          <input
            v-model.number="bInput"
            type="number"
            id="bInput"
            min="0"
            max="255"
            @input="handleRgbInput"
          />
        </div>
      </div>
      <div class="form-group">
        <label>颜色预览</label>
        <div class="color-preview" :style="{ backgroundColor: previewColor }"></div>
      </div>
      <ButtonGroup style="margin-top: 15px;">
        <AppButton variant="primary" icon="🔄" @click="convert">转换</AppButton>
        <AppButton variant="secondary" icon="🗑️" @click="clear">清空</AppButton>
      </ButtonGroup>
    </div>

    <div class="form-section">
      <h2>转换结果</h2>
      <div class="result-display" v-if="result">
        <div style="line-height:1.8">
          <strong>HEX:</strong> {{ result.hex }}<br>
          <strong>RGB:</strong> {{ result.rgb }}<br>
          <strong>RGBA:</strong> {{ result.rgba }}<br>
          <strong>HSL:</strong> {{ result.hsl }}<br>
          <strong>HSLA:</strong> {{ result.hsla }}
        </div>
      </div>
    </div>

    <div class="form-section">
      <h2>颜色预设</h2>
      <div
        v-for="group in presetColorsGroups"
        :key="group.title"
        class="color-presets-group"
      >
        <div class="color-presets-group-title">{{ group.title }}</div>
        <div class="color-presets">
          <div
            v-for="color in group.colors"
            :key="color.hex"
            class="color-card"
            :class="{ expanded: expandedCard === color.hex }"
            @click="selectPresetColor(color)"
          >
            <div class="color-card-square" :style="{ background: color.hex }"></div>
            <div class="color-card-info">
              <div class="color-card-name">{{ color.name }}</div>
              <div class="color-card-values">{{ color.hex }} {{ color.rgb }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'

const hexInput = ref('#667eea')
const rInput = ref(102)
const gInput = ref(126)
const bInput = ref(234)
const expandedCard = ref('')
const result = ref(null)

const presetColorsGroups = [
  {
    title: '基础颜色',
    colors: [
      { name: '红色', hex: '#FF0000', rgb: 'rgb(255, 0, 0)' },
      { name: '绿色', hex: '#00FF00', rgb: 'rgb(0, 255, 0)' },
      { name: '蓝色', hex: '#0000FF', rgb: 'rgb(0, 0, 255)' },
      { name: '黄色', hex: '#FFFF00', rgb: 'rgb(255, 255, 0)' },
      { name: '紫色', hex: '#800080', rgb: 'rgb(128, 0, 128)' },
      { name: '青色', hex: '#00FFFF', rgb: 'rgb(0, 255, 255)' },
      { name: '橙色', hex: '#FFA500', rgb: 'rgb(255, 165, 0)' },
      { name: '粉色', hex: '#FFC0CB', rgb: 'rgb(255, 192, 203)' },
      { name: '黑色', hex: '#000000', rgb: 'rgb(0, 0, 0)' },
      { name: '白色', hex: '#FFFFFF', rgb: 'rgb(255, 255, 255)' },
      { name: '灰色', hex: '#808080', rgb: 'rgb(128, 128, 128)' }
    ]
  },
  {
    title: '主流 App 颜色',
    colors: [
      { name: '微信绿', hex: '#07C160', rgb: 'rgb(7, 193, 96)' },
      { name: '支付宝蓝', hex: '#1677FF', rgb: 'rgb(22, 119, 255)' },
      { name: '抖音红', hex: '#FF0050', rgb: 'rgb(255, 0, 80)' },
      { name: '微博橙', hex: '#FF6600', rgb: 'rgb(255, 102, 0)' },
      { name: 'QQ蓝', hex: '#12B7F5', rgb: 'rgb(18, 183, 245)' },
      { name: '淘宝橙', hex: '#FF5000', rgb: 'rgb(255, 80, 0)' },
      { name: '京东红', hex: '#E1251B', rgb: 'rgb(225, 37, 27)' },
      { name: '美团黄', hex: '#FFC300', rgb: 'rgb(255, 195, 0)' },
      { name: '饿了么蓝', hex: '#0096FF', rgb: 'rgb(0, 150, 255)' },
      { name: '小红书红', hex: '#FF2442', rgb: 'rgb(255, 36, 66)' },
      { name: 'B站粉', hex: '#FB7299', rgb: 'rgb(251, 114, 153)' },
      { name: '知乎蓝', hex: '#0084FF', rgb: 'rgb(0, 132, 255)' },
      { name: '豆瓣绿', hex: '#42BD56', rgb: 'rgb(66, 189, 86)' },
      { name: '网易云红', hex: '#E83C3C', rgb: 'rgb(232, 60, 60)' },
      { name: 'QQ音乐绿', hex: '#31C27C', rgb: 'rgb(49, 194, 124)' },
      { name: '酷狗蓝', hex: '#00A0E9', rgb: 'rgb(0, 160, 233)' },
      { name: '爱奇艺粉', hex: '#FF6B9D', rgb: 'rgb(255, 107, 157)' },
      { name: '腾讯视频蓝', hex: '#002FA7', rgb: 'rgb(0, 47, 167)' },
      { name: '优酷蓝', hex: '#00A8E6', rgb: 'rgb(0, 168, 230)' },
      { name: '百度红', hex: '#2932E1', rgb: 'rgb(41, 50, 225)' },
      { name: '高德蓝', hex: '#0091FF', rgb: 'rgb(0, 145, 255)' },
      { name: '滴滴橙', hex: '#FF6600', rgb: 'rgb(255, 102, 0)' },
      { name: '携程蓝', hex: '#1BA9BA', rgb: 'rgb(27, 169, 186)' },
      { name: '飞猪橙', hex: '#FF6A00', rgb: 'rgb(255, 106, 0)' }
    ]
  },
  {
    title: '国际品牌色',
    colors: [
      { name: '苹果黑', hex: '#000000', rgb: 'rgb(0, 0, 0)' },
      { name: '苹果灰', hex: '#86868B', rgb: 'rgb(134, 134, 139)' },
      { name: '谷歌蓝', hex: '#4285F4', rgb: 'rgb(66, 133, 244)' },
      { name: '谷歌红', hex: '#EA4335', rgb: 'rgb(234, 67, 53)' },
      { name: '谷歌黄', hex: '#FBBC05', rgb: 'rgb(251, 188, 5)' },
      { name: '谷歌绿', hex: '#34A853', rgb: 'rgb(52, 168, 83)' },
      { name: 'Facebook蓝', hex: '#1877F2', rgb: 'rgb(24, 119, 242)' },
      { name: 'Twitter蓝', hex: '#1DA1F2', rgb: 'rgb(29, 161, 242)' },
      { name: 'Instagram紫', hex: '#E4405F', rgb: 'rgb(228, 64, 95)' },
      { name: 'YouTube红', hex: '#FF0000', rgb: 'rgb(255, 0, 0)' },
      { name: 'LinkedIn蓝', hex: '#0077B5', rgb: 'rgb(0, 119, 181)' },
      { name: 'GitHub黑', hex: '#24292E', rgb: 'rgb(36, 41, 46)' },
      { name: 'GitHub紫', hex: '#6F42C1', rgb: 'rgb(111, 66, 193)' },
      { name: 'Spotify绿', hex: '#1DB954', rgb: 'rgb(29, 185, 84)' },
      { name: 'Netflix红', hex: '#E50914', rgb: 'rgb(229, 9, 20)' },
      { name: 'Amazon橙', hex: '#FF9900', rgb: 'rgb(255, 153, 0)' },
      { name: 'Microsoft蓝', hex: '#0078D4', rgb: 'rgb(0, 120, 212)' },
      { name: 'Adobe红', hex: '#FF0000', rgb: 'rgb(255, 0, 0)' },
      { name: 'PayPal蓝', hex: '#003087', rgb: 'rgb(0, 48, 135)' },
      { name: 'Stripe蓝', hex: '#635BFF', rgb: 'rgb(99, 91, 255)' },
      { name: 'Airbnb红', hex: '#FF5A5F', rgb: 'rgb(255, 90, 95)' },
      { name: 'Uber黑', hex: '#000000', rgb: 'rgb(0, 0, 0)' },
      { name: 'Tesla红', hex: '#E31937', rgb: 'rgb(227, 25, 55)' },
      { name: 'Nike黑', hex: '#000000', rgb: 'rgb(0, 0, 0)' },
      { name: 'Coca-Cola红', hex: '#F40009', rgb: 'rgb(244, 0, 9)' },
      { name: 'Pepsi蓝', hex: '#004B93', rgb: 'rgb(0, 75, 147)' },
      { name: 'Starbucks绿', hex: '#00704A', rgb: 'rgb(0, 112, 74)' },
      { name: 'McDonald\'s金', hex: '#FFC72C', rgb: 'rgb(255, 199, 44)' },
      { name: 'McDonald\'s红', hex: '#DA291C', rgb: 'rgb(218, 41, 28)' }
    ]
  },
  {
    title: '其他常用颜色',
    colors: [
      { name: '深红', hex: '#8B0000', rgb: 'rgb(139, 0, 0)' },
      { name: '深绿', hex: '#006400', rgb: 'rgb(0, 100, 0)' },
      { name: '深蓝', hex: '#00008B', rgb: 'rgb(0, 0, 139)' },
      { name: '浅蓝', hex: '#87CEEB', rgb: 'rgb(135, 206, 235)' },
      { name: '浅绿', hex: '#90EE90', rgb: 'rgb(144, 238, 144)' },
      { name: '浅红', hex: '#FFB6C1', rgb: 'rgb(255, 182, 193)' },
      { name: '金色', hex: '#FFD700', rgb: 'rgb(255, 215, 0)' },
      { name: '银色', hex: '#C0C0C0', rgb: 'rgb(192, 192, 192)' },
      { name: '棕色', hex: '#A52A2A', rgb: 'rgb(165, 42, 42)' },
      { name: '橄榄色', hex: '#808000', rgb: 'rgb(128, 128, 0)' },
      { name: '海军蓝', hex: '#000080', rgb: 'rgb(0, 0, 128)' },
      { name: '青绿色', hex: '#40E0D0', rgb: 'rgb(64, 224, 208)' },
      { name: '珊瑚色', hex: '#FF7F50', rgb: 'rgb(255, 127, 80)' },
      { name: '番茄色', hex: '#FF6347', rgb: 'rgb(255, 99, 71)' },
      { name: '天蓝色', hex: '#87CEEB', rgb: 'rgb(135, 206, 235)' },
      { name: '紫罗兰', hex: '#8A2BE2', rgb: 'rgb(138, 43, 226)' },
      { name: '深紫色', hex: '#4B0082', rgb: 'rgb(75, 0, 130)' },
      { name: '深粉色', hex: '#FF1493', rgb: 'rgb(255, 20, 147)' },
      { name: '薄荷绿', hex: '#00CED1', rgb: 'rgb(0, 206, 209)' }
    ]
  }
]

const previewColor = computed(() => {
  if (result.value) {
    return result.value.hex
  }
  return '#f0f0f0'
})

function hexToRgb(hex) {
  hex = hex.replace('#', '')
  if (hex.length === 3) hex = hex.split('').map(c => c + c).join('')
  const r = parseInt(hex.substr(0, 2), 16)
  const g = parseInt(hex.substr(2, 2), 16)
  const b = parseInt(hex.substr(4, 2), 16)
  return { r, g, b }
}

function rgbToHex(r, g, b) {
  return '#' + [r, g, b].map(x => {
    const hex = x.toString(16)
    return hex.length === 1 ? '0' + hex : hex
  }).join('').toUpperCase()
}

function rgbToHsl(r, g, b) {
  r /= 255
  g /= 255
  b /= 255
  const max = Math.max(r, g, b)
  const min = Math.min(r, g, b)
  let h, s, l = (max + min) / 2

  if (max === min) {
    h = s = 0
  } else {
    const d = max - min
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
    switch (max) {
      case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6; break
      case g: h = ((b - r) / d + 2) / 6; break
      case b: h = ((r - g) / d + 4) / 6; break
    }
  }

  return {
    h: Math.round(h * 360),
    s: Math.round(s * 100),
    l: Math.round(l * 100)
  }
}

function updateResult(r, g, b) {
  const hex = rgbToHex(r, g, b)
  const hsl = rgbToHsl(r, g, b)

  result.value = {
    hex,
    rgb: `rgb(${r}, ${g}, ${b})`,
    rgba: `rgba(${r}, ${g}, ${b}, 1)`,
    hsl: `hsl(${hsl.h}, ${hsl.s}%, ${hsl.l}%)`,
    hsla: `hsla(${hsl.h}, ${hsl.s}%, ${hsl.l}%, 1)`
  }
}

function convert() {
  let r, g, b

  if (hexInput.value.trim()) {
    try {
      const rgb = hexToRgb(hexInput.value.trim())
      r = rgb.r
      g = rgb.g
      b = rgb.b
      rInput.value = r
      gInput.value = g
      bInput.value = b
    } catch (e) {
      alert('HEX格式错误')
      return
    }
  } else {
    r = Math.max(0, Math.min(255, rInput.value || 0))
    g = Math.max(0, Math.min(255, gInput.value || 0))
    b = Math.max(0, Math.min(255, bInput.value || 0))
    rInput.value = r
    gInput.value = g
    bInput.value = b
    hexInput.value = rgbToHex(r, g, b)
  }

  updateResult(r, g, b)
}

function handleHexInput() {
  if (hexInput.value.trim()) {
    convert()
  }
}

function handleRgbInput() {
  convert()
}

function selectPresetColor(color) {
  const rgb = hexToRgb(color.hex)
  hexInput.value = color.hex
  rInput.value = rgb.r
  gInput.value = rgb.g
  bInput.value = rgb.b
  expandedCard.value = expandedCard.value === color.hex ? '' : color.hex
  convert()
}

function clear() {
  hexInput.value = ''
  rInput.value = 0
  gInput.value = 0
  bInput.value = 0
  result.value = null
  expandedCard.value = ''
}

// 初始化
convert()
</script>

<style scoped>
.form-section {
  background: var(--color-background-alt);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  margin-bottom: var(--spacing-lg);
}

.form-section h2 {
  font-size: var(--font-size-large);
  color: var(--color-text);
  margin-bottom: var(--spacing-lg);
  border-bottom: 2px solid var(--color-primary);
  padding-bottom: var(--spacing-sm);
}

.controls-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 15px;
}

.form-group {
  margin-bottom: 18px;
}

.form-group label {
  display: block;
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--spacing-sm);
  font-size: var(--font-size-small);
}

.form-group input {
  width: 100%;
  padding: var(--spacing-sm);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  background: var(--color-surface);
  color: var(--color-text);
}

.form-group input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.color-preview {
  width: 100%;
  height: 120px;
  border-radius: var(--radius-sm);
  border: 2px solid var(--color-border);
  margin-top: 10px;
  background: var(--color-surface-alt);
  transition: background-color 0.3s;
}

.btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border: none;
  padding: 12px 24px;
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  font-weight: 600;
  cursor: pointer;
  transition: transform .2s;
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px var(--color-shadow-primary);
}

.btn-secondary {
  background: linear-gradient(135deg, var(--color-text-secondary) 0%, var(--color-text-light) 100%);
  margin-left: 10px;
}

.result-display {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: var(--spacing-md);
  margin-top: 15px;
  font-family: 'Courier New', monospace;
  font-size: var(--font-size-small);
  word-break: break-all;
  color: var(--color-text);
}

.color-presets-group {
  margin-bottom: 25px;
}

.color-presets-group:last-child {
  margin-bottom: 0;
}

.color-presets-group-title {
  font-size: var(--font-size-base);
  font-weight: 600;
  color: var(--color-text-secondary);
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 2px solid var(--color-primary);
}

.color-presets {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 10px;
  margin-top: 0;
}

.color-card {
  display: flex;
  align-items: center;
  gap: 10px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 6px;
  padding: 8px;
  cursor: pointer;
  transition: all .3s ease;
  position: relative;
  overflow: visible;
}

.color-card:hover,
.color-card.expanded {
  transform: scale(1.1);
  z-index: 10;
  box-shadow: 0 4px 16px rgba(0, 0, 0, .2);
  border-color: var(--color-primary);
}

.color-card-square {
  width: 36px;
  height: 36px;
  border-radius: 4px;
  border: 1px solid rgba(0, 0, 0, .1);
  flex-shrink: 0;
  transition: all .3s ease;
}

.color-card:hover .color-card-square,
.color-card.expanded .color-card-square {
  width: 44px;
  height: 44px;
}

.color-card-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.color-card-name {
  font-weight: 600;
  color: var(--color-text-secondary);
  font-size: 13px;
  white-space: normal;
  word-break: break-word;
  line-height: 1.3;
}

.color-card-values {
  font-size: 10px;
  color: var(--color-text-secondary);
  line-height: 1.4;
  white-space: normal;
  word-break: break-word;
}
</style>
