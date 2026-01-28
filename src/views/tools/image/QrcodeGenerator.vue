<template>
  <ToolLayout
    icon="📷"
    title="二维码/条形码生成工具"
    description="支持自定义样式、颜色和图标，生成高质量二维码和条形码"
  >
    <div class="tab-buttons">
      <button
        class="tab-btn"
        :class="{ active: activeTab === 'qrcode' }"
        @click="activeTab = 'qrcode'"
      >
        二维码
      </button>
      <button
        class="tab-btn"
        :class="{ active: activeTab === 'barcode' }"
        @click="activeTab = 'barcode'"
      >
        条形码
      </button>
    </div>

    <!-- 二维码标签页 -->
    <div v-if="activeTab === 'qrcode'" class="tab-content">
      <div class="form-section">
        <h2>内容输入</h2>
        <div class="form-group">
          <label for="qrcodeText">输入文本或链接</label>
          <textarea
            v-model="qrcodeText"
            id="qrcodeText"
            placeholder="请输入要生成二维码的内容，如：https://example.com 或 文本内容"
          ></textarea>
        </div>
      </div>

      <div class="form-section">
        <h2>样式设置</h2>
        <div class="controls-grid">
          <div class="form-group">
            <label for="qrcodeSize">尺寸</label>
            <select v-model.number="qrcodeSize" id="qrcodeSize">
              <option :value="200">200x200</option>
              <option :value="300">300x300</option>
              <option :value="400">400x400</option>
              <option :value="500">500x500</option>
            </select>
          </div>
          <div class="form-group">
            <label for="qrcodeErrorLevel">容错级别</label>
            <select v-model="qrcodeErrorLevel" id="qrcodeErrorLevel">
              <option value="L">L - 低 (约7%)</option>
              <option value="M">M - 中 (约15%)</option>
              <option value="Q">Q - 较高 (约25%)</option>
              <option value="H">H - 高 (约30%)</option>
            </select>
          </div>
        </div>
        <div class="form-group">
          <label>颜色设置</label>
          <div class="controls-grid">
            <div class="color-input-group">
              <label style="flex: 1;">前景色：</label>
              <input v-model="qrcodeColor" type="color" id="qrcodeColor" />
            </div>
            <div class="color-input-group">
              <label style="flex: 1;">背景色：</label>
              <input v-model="qrcodeBgColor" type="color" id="qrcodeBgColor" />
            </div>
          </div>
        </div>
        <div class="form-group">
          <label>预设样式</label>
          <div class="style-presets">
            <div
              v-for="(style, key) in stylePresets"
              :key="key"
              class="style-preset"
              :class="{ active: selectedStyle === key }"
              @click="applyStyle(key)"
            >
              {{ getStyleName(key) }}
            </div>
          </div>
        </div>
      </div>

      <ButtonGroup>
        <AppButton variant="primary" icon="📱" @click="generateQRCode">生成二维码</AppButton>
        <AppButton variant="secondary" icon="🗑️" @click="clearQRCode">清空</AppButton>
      </ButtonGroup>

      <div v-if="qrcodeGenerated" class="preview-section">
        <h3>二维码预览</h3>
        <div id="qrcode"></div>
        <ButtonGroup align="center" style="margin-top: 20px;">
          <AppButton variant="success" icon="⬇️" @click="downloadQRCode">下载二维码</AppButton>
        </ButtonGroup>
      </div>
    </div>

    <!-- 条形码标签页 -->
    <div v-if="activeTab === 'barcode'" class="tab-content">
      <div class="form-section">
        <h2>内容输入</h2>
        <div class="form-group">
          <label for="barcodeText">输入数字或文本</label>
          <input
            v-model="barcodeText"
            type="text"
            id="barcodeText"
            placeholder="请输入要生成条形码的内容"
          />
        </div>
      </div>

      <div class="form-section">
        <h2>条形码设置</h2>
        <div class="controls-grid">
          <div class="form-group">
            <label for="barcodeFormat">格式类型</label>
            <select v-model="barcodeFormat" id="barcodeFormat">
              <option value="CODE128">CODE128</option>
              <option value="CODE39">CODE39</option>
              <option value="EAN13">EAN13</option>
              <option value="EAN8">EAN8</option>
              <option value="UPC">UPC</option>
              <option value="ITF14">ITF14</option>
              <option value="MSI">MSI</option>
              <option value="pharmacode">Pharmacode</option>
              <option value="codabar">Codabar</option>
            </select>
          </div>
          <div class="form-group">
            <label for="barcodeWidth">宽度</label>
            <input v-model.number="barcodeWidth" type="number" id="barcodeWidth" min="1" max="5" step="0.5" />
          </div>
          <div class="form-group">
            <label for="barcodeHeight">高度</label>
            <input v-model.number="barcodeHeight" type="number" id="barcodeHeight" min="50" max="200" step="10" />
          </div>
          <div class="form-group">
            <label for="barcodeDisplayValue">显示文本</label>
            <select v-model="barcodeDisplayValue" id="barcodeDisplayValue">
              <option :value="true">显示</option>
              <option :value="false">隐藏</option>
            </select>
          </div>
        </div>
        <div class="form-group">
          <label>颜色设置</label>
          <div class="controls-grid">
            <div class="color-input-group">
              <label style="flex: 1;">线条颜色：</label>
              <input v-model="barcodeColor" type="color" id="barcodeColor" />
            </div>
            <div class="color-input-group">
              <label style="flex: 1;">背景色：</label>
              <input v-model="barcodeBgColor" type="color" id="barcodeBgColor" />
            </div>
          </div>
        </div>
      </div>

      <ButtonGroup>
        <AppButton variant="primary" icon="📊" @click="generateBarcode">生成条形码</AppButton>
        <AppButton variant="secondary" icon="🗑️" @click="clearBarcode">清空</AppButton>
      </ButtonGroup>

      <div v-if="barcodeGenerated" class="preview-section">
        <h3>条形码预览</h3>
        <svg id="barcode"></svg>
        <ButtonGroup align="center" style="margin-top: 20px;">
          <AppButton variant="success" icon="⬇️" @click="downloadBarcode">下载条形码</AppButton>
        </ButtonGroup>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'
import AppButton from '@/components/AppButton.vue'
import ButtonGroup from '@/components/ButtonGroup.vue'
import { loadScript } from '@/utils/cdn-loader.js'

const activeTab = ref('qrcode')
const qrcodeText = ref('')
const qrcodeSize = ref(300)
const qrcodeErrorLevel = ref('M')
const qrcodeColor = ref('#000000')
const qrcodeBgColor = ref('#ffffff')
const selectedStyle = ref('default')
const qrcodeGenerated = ref(false)
let qrcodeInstance = null

const barcodeText = ref('')
const barcodeFormat = ref('CODE128')
const barcodeWidth = ref(2)
const barcodeHeight = ref(100)
const barcodeDisplayValue = ref(true)
const barcodeColor = ref('#000000')
const barcodeBgColor = ref('#ffffff')
const barcodeGenerated = ref(false)

const stylePresets = {
  default: { color: '#000000', bgColor: '#ffffff' },
  blue: { color: '#1677FF', bgColor: '#ffffff' },
  green: { color: '#07C160', bgColor: '#ffffff' },
  red: { color: '#FF0050', bgColor: '#ffffff' },
  purple: { color: '#764ba2', bgColor: '#ffffff' },
  gradient: { color: '#667eea', bgColor: '#f8f9fa' }
}

function getStyleName(key) {
  const names = {
    default: '默认',
    blue: '蓝色',
    green: '绿色',
    red: '红色',
    purple: '紫色',
    gradient: '渐变'
  }
  return names[key] || key
}

function applyStyle(key) {
  selectedStyle.value = key
  const style = stylePresets[key]
  qrcodeColor.value = style.color
  qrcodeBgColor.value = style.bgColor
}

async function generateQRCode() {
  if (!qrcodeText.value.trim()) {
    alert('请输入要生成二维码的内容')
    return
  }

  // 确保库已加载
  if (typeof QRCode === 'undefined') {
    try {
      await loadScript('https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js')
    } catch (e) {
      alert('加载二维码库失败，请检查网络')
      return
    }
  }

  // 等待库完全加载（双重保险）
  if (typeof QRCode === 'undefined') {
    alert('二维码库加载失败，请重试')
    return
  }

  qrcodeGenerated.value = true

  await nextTick()

  const qrcodeDiv = document.getElementById('qrcode')
  if (qrcodeDiv) {
    qrcodeDiv.innerHTML = ''

    qrcodeInstance = new QRCode(qrcodeDiv, {
      text: qrcodeText.value,
      width: qrcodeSize.value,
      height: qrcodeSize.value,
      colorDark: qrcodeColor.value,
      colorLight: qrcodeBgColor.value,
      correctLevel: QRCode.CorrectLevel[qrcodeErrorLevel.value]
    })
  } else {
    console.error('QR code container not found')
    alert('生成失败：未找到二维码容器')
  }
}

function clearQRCode() {
  qrcodeText.value = ''
  qrcodeGenerated.value = false
  if (qrcodeInstance) {
    qrcodeInstance.clear()
    qrcodeInstance = null
  }
  const qrcodeDiv = document.getElementById('qrcode')
  if (qrcodeDiv) {
    qrcodeDiv.innerHTML = ''
  }
}

function downloadQRCode() {
  const canvas = document.querySelector('#qrcode canvas')
  if (canvas) {
    const link = document.createElement('a')
    link.download = 'qrcode.png'
    link.href = canvas.toDataURL()
    link.click()
  }
}

async function generateBarcode() {
  if (!barcodeText.value.trim()) {
    alert('请输入要生成条形码的内容')
    return
  }

  // 确保库已加载
  if (typeof JsBarcode === 'undefined') {
    try {
      await loadScript('https://cdnjs.cloudflare.com/ajax/libs/jsbarcode/3.11.5/JsBarcode.all.min.js')
    } catch (e) {
      alert('加载条形码库失败，请检查网络')
      return
    }
  }

  // 等待库完全加载（双重保险）
  if (typeof JsBarcode === 'undefined') {
    alert('条形码库加载失败，请重试')
    return
  }

  barcodeGenerated.value = true

  await nextTick()

  try {
    JsBarcode('#barcode', barcodeText.value, {
      format: barcodeFormat.value,
      width: barcodeWidth.value,
      height: barcodeHeight.value,
      displayValue: barcodeDisplayValue.value,
      lineColor: barcodeColor.value,
      background: barcodeBgColor.value
    })
  } catch (e) {
    alert('生成条形码失败：' + e.message)
    barcodeGenerated.value = false
  }
}

function clearBarcode() {
  barcodeText.value = ''
  barcodeGenerated.value = false
  const barcodeSvg = document.getElementById('barcode')
  if (barcodeSvg) {
    barcodeSvg.innerHTML = ''
  }
}

function downloadBarcode() {
  const svg = document.querySelector('#barcode svg')
  if (svg) {
    const svgData = new XMLSerializer().serializeToString(svg)
    const canvas = document.createElement('canvas')
    const ctx = canvas.getContext('2d')
    const img = new Image()
    img.onload = () => {
      canvas.width = img.width
      canvas.height = img.height
      ctx.drawImage(img, 0, 0)
      const link = document.createElement('a')
      link.download = 'barcode.png'
      link.href = canvas.toDataURL()
      link.click()
    }
    img.src = 'data:image/svg+xml;base64,' + btoa(unescape(encodeURIComponent(svgData)))
  }
}

onMounted(() => {
  // 预加载库
  loadScript('https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js')
  loadScript('https://cdnjs.cloudflare.com/ajax/libs/jsbarcode/3.11.5/JsBarcode.all.min.js')
})
</script>

<style scoped>
.tab-buttons {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.tab-btn {
  flex: 1;
  padding: 12px;
  background: var(--color-surface-alt);
  border: none;
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  font-weight: 600;
  cursor: pointer;
  transition: all .3s;
  color: var(--color-text);
}

.tab-btn.active {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
}

.tab-content {
  display: block;
}

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

.form-group {
  margin-bottom: var(--spacing-lg);
}

.form-group label {
  display: block;
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--spacing-sm);
  font-size: var(--font-size-small);
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: var(--spacing-sm);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  transition: border-color .3s;
  background: var(--color-surface);
  color: var(--color-text);
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.form-group textarea {
  min-height: 100px;
  resize: vertical;
}

.controls-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: var(--spacing-md);
  margin-top: var(--spacing-md);
}

.color-input-group {
  display: flex;
  gap: var(--spacing-sm);
  align-items: center;
}

.color-input-group input[type="color"] {
  width: 60px;
  height: 40px;
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  cursor: pointer;
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

.btn-group {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.preview-section {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  text-align: center;
  margin-top: 25px;
}

.preview-section h3 {
  font-size: var(--font-size-large);
  color: var(--color-text-secondary);
  margin-bottom: 20px;
}

#qrcode,
#barcode {
  display: inline-block;
  padding: 20px;
  background: var(--color-surface);
  border-radius: var(--radius-sm);
  box-shadow: 0 2px 8px rgba(0, 0, 0, .1);
}

#barcode {
  padding: 15px 30px;
}

.style-presets {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  gap: 10px;
  margin-top: 15px;
}

.style-preset {
  padding: 10px;
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  cursor: pointer;
  text-align: center;
  transition: all .3s;
  font-size: 12px;
  color: var(--color-text);
}

.style-preset:hover {
  border-color: var(--color-primary);
  transform: translateY(-2px);
}

.style-preset.active {
  border-color: var(--color-primary);
  background: var(--color-hover);
}
</style>
