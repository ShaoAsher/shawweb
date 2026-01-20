<template>
  <ToolLayout
    icon="✍️"
    title="文字图片生成工具"
    description="输入文字和背景颜色，生成 1024×1024 纯文字图片（低于 50KB）"
  >
    <div class="form-section">
      <h2>输入配置</h2>
      <div class="form-group">
        <label for="textInput">文字内容 *</label>
        <input
          v-model="textInput"
          type="text"
          id="textInput"
          placeholder="输入1-4个字符"
          maxlength="4"
          required
          @keypress.enter="generateImage"
        />
        <small>最多输入4个字符，文字将居中显示</small>
      </div>
      <div class="form-group">
        <label>背景类型</label>
        <div class="color-options">
          <div class="color-option">
            <label>
              <input type="radio" v-model="bgType" value="solid" />
              <span>单色</span>
            </label>
          </div>
          <div class="color-option">
            <label>
              <input type="radio" v-model="bgType" value="gradient" />
              <span>渐变色</span>
            </label>
          </div>
        </div>
      </div>
      <div class="form-group">
        <div class="color-picker-group">
          <div v-if="bgType === 'solid'" class="color-picker-wrapper">
            <label for="solidColor">单色选择</label>
            <input v-model="solidColor" type="color" id="solidColor" class="color-picker-input" />
          </div>
          <div v-if="bgType === 'gradient'" class="color-picker-wrapper">
            <label for="gradientColor1">渐变色 - 起始颜色</label>
            <input v-model="gradientColor1" type="color" id="gradientColor1" class="color-picker-input" />
          </div>
          <div v-if="bgType === 'gradient'" class="color-picker-wrapper">
            <label for="gradientColor2">渐变色 - 结束颜色</label>
            <input v-model="gradientColor2" type="color" id="gradientColor2" class="color-picker-input" />
          </div>
        </div>
      </div>
      <div class="form-group">
        <label>单色预设</label>
        <div class="preset-grid">
          <div
            v-for="preset in solidBgPresets"
            :key="preset.id"
            class="preset-card"
            :class="{ selected: bgType === 'solid' && currentBgPresetId === preset.id }"
            @click="selectSolidPreset(preset)"
          >
            <div class="preset-canvas" :style="{ background: preset.color }"></div>
            <div class="preset-label">{{ preset.label }}</div>
          </div>
        </div>
      </div>
      <div class="form-group">
        <label>渐变预设</label>
        <div class="preset-grid">
          <div
            v-for="preset in gradientBgPresets"
            :key="preset.id"
            class="preset-card"
            :class="{ selected: bgType === 'gradient' && currentBgPresetId === preset.id }"
            @click="selectGradientPreset(preset)"
          >
            <div
              class="preset-canvas"
              :style="{
                background: `linear-gradient(135deg, ${preset.c1} 0%, ${preset.c2} 100%)`
              }"
            ></div>
            <div class="preset-label">{{ preset.label }}</div>
          </div>
        </div>
      </div>
    </div>

    <div class="form-section">
      <h2>风格预设</h2>
      <div class="preset-grid">
        <div
          v-for="preset in allPresets"
          :key="preset"
          class="preset-card"
          :class="{ selected: currentPreset === preset }"
          @click="currentPreset = preset"
        >
          <canvas
            :ref="el => { if (el) presetCanvasRefs[preset] = el }"
            class="preset-canvas"
            width="100"
            height="100"
          ></canvas>
          <div class="preset-label">{{ getPresetLabel(preset) }}</div>
        </div>
      </div>
    </div>

    <AppButton 
      variant="primary" 
      icon="🖼️" 
      :loading="generating"
      :disabled="generating"
      @click="generateImage"
    >
      生成图片
    </AppButton>

    <div v-if="generating" class="loading show">
      <div class="spinner"></div>
      <div>正在生成图片...</div>
    </div>

    <div v-if="errorMessage" class="error show">
      {{ errorMessage }}
    </div>
    <div v-if="successMessage" class="success show">
      {{ successMessage }}
    </div>

    <div v-if="showPreview" class="preview-section">
      <h2>预览与下载</h2>
      <div class="preview-info">
        <strong>图片信息：</strong>
        <span>{{ imageInfo }}</span>
      </div>
      <div class="preview-canvas-wrapper">
        <canvas ref="previewCanvas" width="1024" height="1024"></canvas>
      </div>
      <button class="download-btn" @click="downloadImage">下载图片</button>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { nextTick, onMounted, ref, watch } from 'vue'

const textInput = ref('')
const bgType = ref('solid')
const solidColor = ref('#ffff00')
const gradientColor1 = ref('#ff0000')
const gradientColor2 = ref('#ff8800')
const currentPreset = ref('neon')
const currentBgPresetId = ref(null)
const generating = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const showPreview = ref(false)
const imageInfo = ref('-')
const currentImageBlob = ref(null)
const currentImageFormat = ref('png')
const previewCanvas = ref(null)
const presetCanvasRefs = ref({})

const allPresets = ['neon', 'metal', 'glass', 'bold-stroke', 'retro', 'vivid', 'glow', 'plastic']

const solidBgPresets = [
  { id: 'soft-blue', label: '柔和蓝', color: '#4A90E2' },
  { id: 'mint', label: '薄荷绿', color: '#6FCF97' },
  { id: 'peach', label: '蜜桃橙', color: '#FF8A65' },
  { id: 'rose', label: '玫瑰粉', color: '#F06292' },
  { id: 'lavender', label: '薰衣草', color: '#9B90FF' },
  { id: 'teal', label: '青绿', color: '#00C2A8' },
  { id: 'amber', label: '琥珀', color: '#FFC857' },
  { id: 'slate', label: '石板灰', color: '#708090' },
  { id: 'sky', label: '天空蓝', color: '#87CEEB' },
  { id: 'apple-blue', label: 'Apple蓝', color: '#007AFF' },
  { id: 'google-blue', label: 'Google蓝', color: '#4285F4' },
  { id: 'whatsapp-green', label: '柔绿', color: '#25D366' },
  { id: 'twitter-blue', label: '推特蓝', color: '#1DA1F2' },
  { id: 'cool-gray', label: '冷灰', color: '#B0BEC5' },
  { id: 'warm-gray', label: '暖灰', color: '#BDBDBD' },
  { id: 'cream', label: '奶油白', color: '#FFF4E6' }
]

const gradientBgPresets = [
  { id: 'blue-purple', label: '蓝紫', c1: '#667eea', c2: '#764ba2' },
  { id: 'teal-blue', label: '青蓝', c1: '#00C2A8', c2: '#4A90E2' },
  { id: 'peach-pink', label: '蜜桃粉', c1: '#FF9A8B', c2: '#FF6A88' },
  { id: 'mint-lavender', label: '薄荷紫', c1: '#A8E6CF', c2: '#D3BDF0' },
  { id: 'sunset', label: '柔和夕阳', c1: '#FDB99B', c2: '#CF8BF3' },
  { id: 'sky', label: '清新天空', c1: '#A1C4FD', c2: '#C2E9FB' },
  { id: 'ocean', label: '海洋', c1: '#2E8BC0', c2: '#B1D4E0' },
  { id: 'pastel-rainbow', label: '粉彩彩虹', c1: '#FAD0C4', c2: '#FFD1FF' },
  { id: 'morning-sky', label: '清晨天空', c1: '#FDEB71', c2: '#F8D800' },
  { id: 'fresh-meadow', label: '清新草地', c1: '#A8E6CF', c2: '#81FBB8' },
  { id: 'violet-dusk', label: '暮紫', c1: '#B993D6', c2: '#8CA6DB' },
  { id: 'peach-sunrise', label: '桃色朝霞', c1: '#FFDEE9', c2: '#B5FFFC' }
]

function getPresetLabel(preset) {
  const labels = {
    neon: '霓虹灯',
    metal: '金属质感',
    glass: '玻璃态',
    'bold-stroke': '厚描边',
    retro: '复古印刷',
    vivid: '炫彩渐变',
    glow: '强发光',
    plastic: '立体塑料'
  }
  return labels[preset] || preset
}

function selectSolidPreset(preset) {
  bgType.value = 'solid'
  solidColor.value = preset.color
  currentBgPresetId.value = preset.id
}

function selectGradientPreset(preset) {
  bgType.value = 'gradient'
  gradientColor1.value = preset.c1
  gradientColor2.value = preset.c2
  currentBgPresetId.value = preset.id
}

function getStyleConfig() {
  return getPresetStyleConfig(currentPreset.value)
}

function getPresetStyleConfig(preset) {
  const base = () => ({
    textGradient1: '#ffffff',
    textGradient2: '#999999',
    textGradientAngle: 45,
    strokeColor: '#000000',
    strokeWidth: 4,
    strokeEnabled: true,
    shadowColor: '#000000',
    shadowOpacity: 0.45,
    shadowBlur: 12,
    shadowOffsetX: 5,
    shadowOffsetY: 6,
    shadowEnabled: true,
    highlightColor: '#ffffff',
    highlightOpacity: 0.8,
    highlightBlur: 8,
    highlightOffsetX: -4,
    highlightOffsetY: -4,
    highlightEnabled: true,
    fontFamily: '"PingFang SC", "Microsoft YaHei", "SimHei", "Helvetica Neue", Arial, sans-serif',
    fontWeight: 'bold',
    lineHeightRatio: 1.3,
    charSpacingRatio: 0.15,
    canvasPadding: 50
  })

  const cfg = base()
  switch (preset) {
    case 'neon':
      cfg.textGradient1 = '#00ffff'
      cfg.textGradient2 = '#ff00ff'
      cfg.textGradientAngle = 0
      cfg.strokeColor = '#ffffff'
      cfg.strokeWidth = 2
      cfg.shadowOpacity = 0.6
      cfg.shadowBlur = 20
      cfg.shadowOffsetX = 3
      cfg.shadowOffsetY = 4
      cfg.highlightOpacity = 0.9
      cfg.highlightBlur = 16
      cfg.highlightOffsetX = -3
      cfg.highlightOffsetY = -3
      cfg.fontWeight = '900'
      break
    case 'metal':
      cfg.textGradient1 = '#f0f0f0'
      cfg.textGradient2 = '#7f7f7f'
      cfg.textGradientAngle = 45
      cfg.strokeColor = '#333333'
      cfg.strokeWidth = 4
      cfg.shadowOpacity = 0.35
      cfg.shadowBlur = 14
      cfg.highlightOpacity = 0.6
      cfg.highlightBlur = 10
      break
    case 'glass':
      cfg.textGradient1 = '#ffffff'
      cfg.textGradient2 = '#e0f7ff'
      cfg.textGradientAngle = 90
      cfg.strokeEnabled = false
      cfg.strokeWidth = 0
      cfg.shadowOpacity = 0.25
      cfg.shadowBlur = 20
      cfg.shadowOffsetX = 0
      cfg.shadowOffsetY = 0
      cfg.highlightOpacity = 0.9
      cfg.highlightBlur = 18
      break
    case 'bold-stroke':
      cfg.textGradient1 = '#ffffff'
      cfg.textGradient2 = '#eeeeee'
      cfg.strokeColor = '#000000'
      cfg.strokeWidth = 8
      cfg.highlightEnabled = false
      cfg.shadowOpacity = 0.3
      cfg.shadowBlur = 10
      break
    case 'retro':
      cfg.textGradient1 = '#d4a373'
      cfg.textGradient2 = '#8a5a3b'
      cfg.textGradientAngle = 45
      cfg.strokeColor = '#5a3a2a'
      cfg.strokeWidth = 3
      cfg.shadowOpacity = 0.3
      cfg.shadowBlur = 10
      cfg.highlightEnabled = false
      cfg.fontWeight = 'normal'
      cfg.charSpacingRatio = 0.12
      break
    case 'vivid':
      cfg.textGradient1 = '#ff0000'
      cfg.textGradient2 = '#00eaff'
      cfg.textGradientAngle = 90
      cfg.strokeEnabled = false
      cfg.strokeWidth = 0
      cfg.shadowOpacity = 0.35
      cfg.shadowBlur = 12
      cfg.highlightEnabled = false
      cfg.fontWeight = '900'
      break
    case 'glow':
      cfg.textGradient1 = '#ffffcc'
      cfg.textGradient2 = '#ffd966'
      cfg.textGradientAngle = 45
      cfg.strokeEnabled = false
      cfg.strokeWidth = 0
      cfg.shadowEnabled = false
      cfg.highlightColor = '#ffffcc'
      cfg.highlightOpacity = 1.0
      cfg.highlightBlur = 24
      cfg.highlightOffsetX = -4
      cfg.highlightOffsetY = -4
      cfg.fontWeight = '900'
      break
    case 'plastic':
      cfg.textGradient1 = '#ffd1d1'
      cfg.textGradient2 = '#ff7f7f'
      cfg.textGradientAngle = 45
      cfg.strokeColor = '#b33a3a'
      cfg.strokeWidth = 4
      cfg.shadowOpacity = 0.5
      cfg.shadowBlur = 16
      cfg.shadowOffsetX = 6
      cfg.shadowOffsetY = 8
      cfg.highlightOpacity = 0.7
      cfg.highlightBlur = 10
      cfg.highlightOffsetX = -3
      cfg.highlightOffsetY = -3
      break
  }
  return cfg
}

function hexToRgba(hex, opacity) {
  let c = hex.replace('#', '')
  if (c.length === 3) {
    c = c.split('').map(s => s + s).join('')
  }
  const r = parseInt(c.substring(0, 2), 16)
  const g = parseInt(c.substring(2, 4), 16)
  const b = parseInt(c.substring(4, 6), 16)
  const a = Math.max(0, Math.min(1, opacity))
  return `rgba(${r}, ${g}, ${b}, ${a})`
}

function calculateOptimalFontSize(ctx, chars, availableWidth, availableHeight, maxCharsPerRow, rowCount, styleConfig) {
  let minFontSize = 30
  let maxFontSize = 600

  while (maxFontSize - minFontSize > 1) {
    const fontSize = Math.floor((minFontSize + maxFontSize) / 2)
    ctx.font = `${styleConfig.fontWeight} ${fontSize}px ${styleConfig.fontFamily}`

    const maxCharWidth = Math.max(...chars.map(char => ctx.measureText(char).width))
    const charSpacing = fontSize * styleConfig.charSpacingRatio
    const rowWidth = maxCharsPerRow * maxCharWidth + (maxCharsPerRow - 1) * charSpacing
    const rowHeight = fontSize * styleConfig.lineHeightRatio
    const totalHeight = (rowCount - 1) * rowHeight + fontSize

    if (rowWidth <= availableWidth && totalHeight <= availableHeight) {
      minFontSize = fontSize
    } else {
      maxFontSize = fontSize
    }
  }

  return Math.floor(minFontSize)
}

function calculateCharSpacing(ctx, chars, availableWidth, fontSize, styleConfig) {
  const totalCharWidth = chars.reduce((sum, char) => sum + ctx.measureText(char).width, 0)
  const remainingSpace = availableWidth - totalCharWidth
  const spacing = remainingSpace / (chars.length - 1)
  const minSpacing = fontSize * 0.1
  const maxSpacing = fontSize * 0.25
  const preferred = fontSize * styleConfig.charSpacingRatio
  return Math.max(minSpacing, Math.min(maxSpacing, Math.min(spacing, preferred)))
}

function drawCharWithStyle(ctx, char, x, y, fontSize, styleConfig) {
  ctx.save()
  const rad = (styleConfig.textGradientAngle % 360) * Math.PI / 180
  const gx = Math.cos(rad) * fontSize
  const gy = Math.sin(rad) * fontSize
  const grad = ctx.createLinearGradient(x - gx, y - gy, x + gx, y + gy)
  grad.addColorStop(0, styleConfig.textGradient1)
  grad.addColorStop(1, styleConfig.textGradient2)
  ctx.fillStyle = grad

  if (styleConfig.shadowEnabled) {
    ctx.shadowColor = hexToRgba(styleConfig.shadowColor, styleConfig.shadowOpacity)
    ctx.shadowBlur = fontSize * (styleConfig.shadowBlur / 100)
    ctx.shadowOffsetX = fontSize * (styleConfig.shadowOffsetX / 100)
    ctx.shadowOffsetY = fontSize * (styleConfig.shadowOffsetY / 100)
    ctx.fillText(char, x, y)
  } else {
    ctx.fillText(char, x, y)
  }

  if (styleConfig.highlightEnabled) {
    ctx.shadowColor = hexToRgba(styleConfig.highlightColor, styleConfig.highlightOpacity)
    ctx.shadowBlur = fontSize * (styleConfig.highlightBlur / 100)
    ctx.shadowOffsetX = fontSize * (styleConfig.highlightOffsetX / 100)
    ctx.shadowOffsetY = fontSize * (styleConfig.highlightOffsetY / 100)
    ctx.fillText(char, x, y)
  }

  ctx.shadowColor = 'transparent'
  ctx.shadowBlur = 0

  if (styleConfig.strokeEnabled && styleConfig.strokeWidth > 0) {
    ctx.lineWidth = Math.max(0, styleConfig.strokeWidth)
    ctx.strokeStyle = styleConfig.strokeColor
    ctx.strokeText(char, x, y)
  }

  ctx.restore()
}

function drawTextWithLayout(ctx, text, canvasSize, styleConfig) {
  const padding = styleConfig.canvasPadding
  const availableWidth = canvasSize - padding * 2
  const availableHeight = canvasSize - padding * 2
  const chars = text.split('')
  const charCount = chars.length

  let layout
  if (charCount === 1) {
    layout = { rows: [[chars[0]]] }
  } else if (charCount === 2) {
    layout = { rows: [[chars[0], chars[1]]] }
  } else if (charCount === 3) {
    layout = { rows: [[chars[0]], [chars[1], chars[2]]] }
  } else if (charCount === 4) {
    layout = { rows: [[chars[0], chars[1]], [chars[2], chars[3]]] }
  }

  const maxCharsPerRow = Math.max(...layout.rows.map(row => row.length))
  const rowCount = layout.rows.length

  const fontSize = calculateOptimalFontSize(ctx, chars, availableWidth, availableHeight, maxCharsPerRow, rowCount, styleConfig)

  ctx.font = `${styleConfig.fontWeight} ${fontSize}px ${styleConfig.fontFamily}`
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'

  const lineHeight = fontSize * styleConfig.lineHeightRatio
  const totalTextHeight = (rowCount - 1) * lineHeight + fontSize
  const startY = (canvasSize - totalTextHeight) / 2 + fontSize / 2

  layout.rows.forEach((row, rowIndex) => {
    const charsInRow = row.length
    const rowY = startY + rowIndex * lineHeight

    if (charsInRow === 1) {
      drawCharWithStyle(ctx, row[0], canvasSize / 2, rowY, fontSize, styleConfig)
    } else {
      const charSpacing = calculateCharSpacing(ctx, row, availableWidth, fontSize, styleConfig)
      const rowWidth = row.reduce((sum, char) => sum + ctx.measureText(char).width, 0) + charSpacing * (charsInRow - 1)
      const startX = (canvasSize - rowWidth) / 2

      let currentX = startX
      row.forEach((char) => {
        const metrics = ctx.measureText(char)
        const charX = currentX + metrics.width / 2
        drawCharWithStyle(ctx, char, charX, rowY, fontSize, styleConfig)
        currentX += metrics.width + charSpacing
      })
    }
  })
}

function compressImage(canvas) {
  return new Promise((resolve, reject) => {
    const targetSizeKB = 50
    const targetSizeBytes = targetSizeKB * 1024

    canvas.toBlob((pngBlob) => {
      if (!pngBlob) {
        reject(new Error('无法生成图片'))
        return
      }

      if (pngBlob.size <= targetSizeBytes) {
        resolve({ blob: pngBlob, format: 'png' })
        return
      }

      const jpegCanvas = document.createElement('canvas')
      jpegCanvas.width = canvas.width
      jpegCanvas.height = canvas.height
      const jpegCtx = jpegCanvas.getContext('2d')
      jpegCtx.drawImage(canvas, 0, 0)

      let quality = 0.9
      const minQuality = 0.3
      const step = 0.05

      function tryJPEG() {
        jpegCanvas.toBlob((jpegBlob) => {
          if (!jpegBlob) {
            resolve({ blob: pngBlob, format: 'png' })
            return
          }

          if (jpegBlob.size <= targetSizeBytes || quality <= minQuality) {
            resolve({ blob: jpegBlob, format: 'jpeg' })
            return
          }

          quality -= step
          tryJPEG()
        }, 'image/jpeg', quality)
      }

      tryJPEG()
    }, 'image/png')
  })
}

async function generateImage() {
  const text = textInput.value.trim()

  if (!text || text.length === 0) {
    errorMessage.value = '请输入文字内容'
    setTimeout(() => { errorMessage.value = '' }, 3000)
    return
  }

  if (text.length > 4) {
    errorMessage.value = '文字内容不能超过4个字符'
    setTimeout(() => { errorMessage.value = '' }, 3000)
    return
  }

  generating.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    await nextTick()
    const canvas = document.createElement('canvas')
    const ctx = canvas.getContext('2d')
    const size = 1024
    canvas.width = size
    canvas.height = size

    ctx.clearRect(0, 0, size, size)

    if (bgType.value === 'solid') {
      ctx.fillStyle = solidColor.value
      ctx.fillRect(0, 0, size, size)
    } else {
      const gradient = ctx.createLinearGradient(0, 0, size, size)
      gradient.addColorStop(0, gradientColor1.value)
      gradient.addColorStop(1, gradientColor2.value)
      ctx.fillStyle = gradient
      ctx.fillRect(0, 0, size, size)
    }

    const styleConfig = getStyleConfig()
    drawTextWithLayout(ctx, text, size, styleConfig)

    const result = await compressImage(canvas)
    currentImageBlob.value = result.blob
    currentImageFormat.value = result.format || 'png'

    const img = new Image()
    img.onload = () => {
      if (previewCanvas.value) {
        const previewCtx = previewCanvas.value.getContext('2d')
        previewCtx.clearRect(0, 0, 1024, 1024)
        previewCtx.drawImage(img, 0, 0, 1024, 1024)
      }

      const fileSizeKB = (result.blob.size / 1024).toFixed(2)
      const formatUpper = currentImageFormat.value.toUpperCase()
      imageInfo.value = `尺寸: 1024×1024 像素 | 文件大小: ${fileSizeKB} KB | 格式: ${formatUpper}`

      showPreview.value = true
      generating.value = false
      successMessage.value = `图片生成成功！文件大小: ${fileSizeKB} KB`
      setTimeout(() => { successMessage.value = '' }, 3000)
    }
    img.src = URL.createObjectURL(result.blob)
  } catch (err) {
    console.error('生成失败:', err)
    errorMessage.value = '生成失败: ' + err.message
    generating.value = false
    setTimeout(() => { errorMessage.value = '' }, 3000)
  }
}

function downloadImage() {
  if (!currentImageBlob.value) {
    errorMessage.value = '请先生成图片'
    setTimeout(() => { errorMessage.value = '' }, 3000)
    return
  }

  const text = textInput.value.trim() || 'text'
  const url = URL.createObjectURL(currentImageBlob.value)
  const a = document.createElement('a')
  a.href = url
  const extension = currentImageFormat.value === 'jpeg' ? 'jpg' : 'png'
  a.download = `${text}_${Date.now()}.${extension}`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)

  successMessage.value = '图片下载成功！'
  setTimeout(() => { successMessage.value = '' }, 3000)
}

function renderPresetCanvas(canvas, preset) {
  if (!canvas) return
  const ctx = canvas.getContext('2d')
  const size = Math.min(canvas.width, canvas.height)
  const cfg = getPresetStyleConfig(preset)
  const previewCfg = Object.assign({}, cfg, { canvasPadding: 16 })
  ctx.clearRect(0, 0, canvas.width, canvas.height)
  const bg = ctx.createLinearGradient(0, 0, size, size)
  bg.addColorStop(0, '#f7f7f7')
  bg.addColorStop(1, '#e9ecef')
  ctx.fillStyle = bg
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  const sampleText = 'Aa'
  drawTextWithLayout(ctx, sampleText, size, previewCfg)
}

watch(allPresets, async () => {
  await nextTick()
  allPresets.forEach(preset => {
    const canvas = presetCanvasRefs.value[preset]
    if (canvas) {
      renderPresetCanvas(canvas, preset)
    }
  })
}, { immediate: true })

onMounted(async () => {
  await nextTick()
  allPresets.forEach(preset => {
    const canvas = presetCanvasRefs.value[preset]
    if (canvas) {
      renderPresetCanvas(canvas, preset)
    }
  })
})
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

.form-group input[type="text"] {
  width: 100%;
  padding: var(--spacing-sm);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  transition: border-color 0.3s;
  background: var(--color-surface);
  color: var(--color-text);
}

.form-group input[type="text"]:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.form-group small {
  display: block;
  color: var(--color-text-secondary);
  margin-top: var(--spacing-xs);
  font-size: var(--font-size-small);
}

.color-options {
  display: flex;
  gap: var(--spacing-md);
  margin-bottom: var(--spacing-md);
  flex-wrap: wrap;
}

.color-option {
  flex: 1;
  min-width: 120px;
}

.color-option label {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  cursor: pointer;
}

.color-option input[type="radio"] {
  width: auto;
  margin: 0;
}

.color-picker-group {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.color-picker-wrapper {
  flex: 1;
  min-width: 150px;
}

.color-picker-wrapper label {
  display: block;
  margin-bottom: 8px;
}

.color-picker-input {
  width: 100%;
  height: 50px;
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  cursor: pointer;
  padding: 0;
}

.btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border: none;
  padding: var(--spacing-sm) var(--spacing-xl);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  cursor: pointer;
  transition: transform 0.2s;
  width: 100%;
}

.btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.loading {
  text-align: center;
  padding: 20px;
  display: none;
}

.loading.show {
  display: block;
}

.spinner {
  border: 4px solid var(--color-border);
  border-top: 4px solid var(--color-primary);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto 15px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error {
  background: var(--color-surface-alt);
  border-left: 4px solid var(--color-error);
  color: var(--color-error);
  padding: var(--spacing-md);
  border-radius: var(--radius-sm);
  margin-top: 20px;
  display: none;
}

.error.show {
  display: block;
}

.success {
  background: var(--color-surface-alt);
  border-left: 4px solid var(--color-success);
  color: var(--color-success);
  padding: var(--spacing-md);
  border-radius: var(--radius-sm);
  margin-top: 20px;
  display: none;
}

.success.show {
  display: block;
}

.preview-section {
  margin-top: var(--spacing-xl);
  text-align: center;
}

.preview-section h2 {
  font-size: var(--font-size-large);
  color: var(--color-text);
  margin-bottom: 20px;
  border-bottom: 2px solid var(--color-primary);
  padding-bottom: 10px;
  text-align: left;
}

.preview-canvas-wrapper {
  display: inline-block;
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: 10px;
  background: var(--color-surface-alt);
  margin-bottom: 20px;
}

.preview-info {
  background: var(--color-surface-alt);
  border-left: 4px solid var(--color-info);
  padding: var(--spacing-md);
  border-radius: var(--radius-sm);
  margin-bottom: 20px;
  font-size: 13px;
  color: var(--color-text);
  text-align: left;
}

.download-btn {
  background: var(--color-success);
  color: var(--color-text-on-primary);
  border: none;
  padding: 12px 24px;
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  margin-top: 15px;
  width: 100%;
}

.download-btn:hover {
  transform: translateY(-2px);
}

.preset-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
  gap: 8px;
}

.preset-card {
  border: 2px solid var(--color-border);
  border-radius: 10px;
  padding: 6px;
  background: var(--color-surface);
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
  text-align: center;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.preset-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

.preset-card.selected {
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px var(--color-shadow-primary);
}

.preset-label {
  margin-top: 6px;
  font-size: 10px;
  color: var(--color-text-secondary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.preset-canvas {
  width: 100%;
  height: auto;
  aspect-ratio: 1 / 1;
  display: block;
}

#previewCanvas {
  display: block;
  max-width: 100%;
  height: auto;
}
</style>
