<template>
  <ToolLayout title="🚀 启动图生成工具" description="一键生成 iOS 和 Android 各机型启动图，支持图片居中、不变形、背景填充">
    <div class="form-section">
      <h2>📸 上传图片</h2>
      <div 
        class="file-upload-area" 
        :class="{ dragover: isDragging }"
        @click="fileInput?.click()"
        @dragover.prevent="isDragging = true"
        @dragleave.prevent="isDragging = false"
        @drop.prevent="handleDrop"
        v-if="!originalImage"
      >
        <div class="file-upload-icon">📁</div>
        <div class="file-upload-text">点击或拖拽图片到此处</div>
        <div class="file-upload-hint">支持 JPG、PNG、WEBP 格式</div>
        <input ref="fileInput" type="file" accept="image/*" @change="handleFileSelect" style="display:none">
      </div>
      <div v-if="originalImage" class="image-preview-container">
        <img :src="previewImageSrc" class="preview-image" alt="预览">
        <button class="delete-btn" @click="resetImage" title="删除图片">×</button>
      </div>
    </div>

    <div class="form-section">
      <h2>📱 选择平台</h2>
      <div class="platform-tabs">
        <div 
          class="platform-tab" 
          :class="{ active: currentPlatform === 'ios' }"
          @click="currentPlatform = 'ios'; updateSizes()"
        >
          iOS
        </div>
        <div 
          class="platform-tab" 
          :class="{ active: currentPlatform === 'android' }"
          @click="currentPlatform = 'android'; updateSizes()"
        >
          Android
        </div>
      </div>
    </div>

    <div class="form-section">
      <h2>🎨 填充说明</h2>
      <div class="form-group">
        <small style="color: var(--color-text-secondary);">工具会自动检测图片边缘的主要颜色，并使用该颜色填充空白区域，确保图片内容居中且不变形。</small>
      </div>
    </div>

    <div class="form-section">
      <h2>📐 选择尺寸（单选）</h2>
      <div class="sizes-grid">
        <div 
          v-for="(size, index) in platformSizes[currentPlatform]" 
          :key="index"
          class="size-item"
          :class="{ selected: selectedSize === `${size.width}x${size.height}` }"
          @click="selectSize(size)"
        >
          <div class="size-label">{{ size.name }}</div>
          <div class="size-dimensions">{{ size.width}} × {{ size.height }}</div>
          <input 
            type="radio" 
            class="size-radio" 
            :name="`size-radio-${currentPlatform}`"
            :id="`size-${currentPlatform}-${index}`"
            :checked="selectedSize === `${size.width}x${size.height}`"
            @change="selectSize(size)"
          >
          <label :for="`size-${currentPlatform}-${index}`" style="cursor: pointer; margin-left: 5px;">选择</label>
        </div>
      </div>
    </div>

    <div v-if="currentPlatform === 'android'" class="form-section">
      <h2>
        <span class="format-icon">🧩</span>
        输出格式（Android）
      </h2>
      <div class="output-format-container">
        <div class="format-option" :class="{ 'format-selected': outputFormat === 'png' }">
          <input type="radio" name="output-format" id="outputFormatPng" class="format-radio" value="png" v-model="outputFormat">
          <label for="outputFormatPng" class="format-label">
            <div class="format-icon-wrapper">
              <svg class="format-svg" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="3" y="3" width="18" height="18" rx="2" stroke="currentColor" stroke-width="2" fill="none" />
                <path d="M9 9h6v6H9z" stroke="currentColor" stroke-width="1.5" fill="none" />
              </svg>
            </div>
            <div class="format-content">
              <div class="format-title">普通 PNG</div>
              <div class="format-desc">标准图片格式，适用于普通场景</div>
            </div>
            <div class="format-check">
              <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="12" cy="12" r="10" fill="currentColor" />
                <path d="M8 12l2 2 4-4" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
              </svg>
            </div>
          </label>
        </div>
        <div class="format-option" :class="{ 'format-selected': outputFormat === 'nine' }">
          <input type="radio" name="output-format" id="outputFormatNine" class="format-radio" value="nine" v-model="outputFormat">
          <label for="outputFormatNine" class="format-label">
            <div class="format-icon-wrapper">
              <svg class="format-svg" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="2" y="2" width="20" height="20" rx="2" stroke="currentColor" stroke-width="2" fill="none" />
                <path d="M2 2h4v4H2z" fill="currentColor" opacity="0.6" />
                <path d="M18 2h4v4h-4z" fill="currentColor" opacity="0.6" />
                <path d="M2 18h4v4H2z" fill="currentColor" opacity="0.6" />
                <path d="M18 18h4v4h-4z" fill="currentColor" opacity="0.6" />
                <rect x="9" y="9" width="6" height="6" stroke="currentColor" stroke-width="1.5" fill="none" />
              </svg>
            </div>
            <div class="format-content">
              <div class="format-title">.9.png（Nine‑Patch）</div>
              <div class="format-desc">Android 九宫格图片，支持智能拉伸</div>
            </div>
            <div class="format-check">
              <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <circle cx="12" cy="12" r="10" fill="currentColor" />
                <path d="M8 12l2 2 4-4" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
              </svg>
            </div>
          </label>
        </div>
      </div>
    </div>

    <ButtonGroup class="form-section">
      <AppButton variant="primary" icon="🚀" :disabled="!canGenerate" @click="generateImage">生成启动图</AppButton>
      <AppButton variant="success" icon="⬇️" :disabled="!generatedImage" @click="downloadImage">下载图片</AppButton>
    </ButtonGroup>

    <div v-if="statusMessage" class="status-message" :class="statusType">
      {{ statusMessage }}
    </div>

    <div v-if="loading" class="loading active">
      <div class="spinner"></div>
      <div>正在生成启动图...</div>
    </div>

    <div v-if="generatedImage" class="form-section preview-section">
      <h2>👀 预览（点击图片可全屏查看）</h2>
      <div class="preview-container">
        <div class="preview-item">
          <canvas ref="previewCanvas" @click="showFullscreen"></canvas>
          <div class="preview-item-label">{{ generatedImage.name }} ({{ generatedImage.width}}×{{ generatedImage.height }})</div>
        </div>
      </div>
    </div>

    <div v-if="showFullscreenModal" class="fullscreen-modal active" @click="closeFullscreen">
      <button class="close-btn" @click.stop="closeFullscreen">×</button>
      <div ref="fullscreenContent"></div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { computed, nextTick, onMounted, ref, watch } from 'vue'

const fileInput = ref(null)
const previewCanvas = ref(null)
const fullscreenContent = ref(null)
const isDragging = ref(false)
const originalImage = ref(null)
const previewImageSrc = ref('')
const currentPlatform = ref('ios')
const selectedSize = ref(null)
const outputFormat = ref('nine')
const loading = ref(false)
const generatedImage = ref(null)
const statusMessage = ref('')
const statusType = ref('success')
const showFullscreenModal = ref(false)

const platformSizes = {
  ios: [
    { name: 'iPhone 14 Pro Max', width: 1290, height: 2796, scale: 3 },
    { name: 'iPhone 14 Pro', width: 1179, height: 2556, scale: 3 },
    { name: 'iPhone 14 Plus', width: 1284, height: 2778, scale: 3 },
    { name: 'iPhone 14', width: 1170, height: 2532, scale: 3 },
    { name: 'iPhone 13 Pro Max', width: 1284, height: 2778, scale: 3 },
    { name: 'iPhone 13 Pro', width: 1170, height: 2532, scale: 3 },
    { name: 'iPhone 13', width: 1170, height: 2532, scale: 3 },
    { name: 'iPhone 13 mini', width: 1080, height: 2340, scale: 3 },
    { name: 'iPhone 12 Pro Max', width: 1284, height: 2778, scale: 3 },
    { name: 'iPhone 12 Pro', width: 1170, height: 2532, scale: 3 },
    { name: 'iPhone 12', width: 1170, height: 2532, scale: 3 },
    { name: 'iPhone 12 mini', width: 1080, height: 2340, scale: 3 },
    { name: 'iPhone 11 Pro Max', width: 1242, height: 2688, scale: 3 },
    { name: 'iPhone 11 Pro', width: 1125, height: 2436, scale: 3 },
    { name: 'iPhone 11', width: 828, height: 1792, scale: 2 },
    { name: 'iPhone XS Max', width: 1242, height: 2688, scale: 3 },
    { name: 'iPhone XS', width: 1125, height: 2436, scale: 3 },
    { name: 'iPhone XR', width: 828, height: 1792, scale: 2 },
    { name: 'iPhone X', width: 1125, height: 2436, scale: 3 },
    { name: 'iPhone 8 Plus', width: 1242, height: 2208, scale: 3 },
    { name: 'iPhone 8', width: 750, height: 1334, scale: 2 },
    { name: 'iPad Pro 12.9"', width: 2048, height: 2732, scale: 2 },
    { name: 'iPad Pro 11"', width: 1668, height: 2388, scale: 2 },
    { name: 'iPad Air', width: 1640, height: 2360, scale: 2 },
    { name: 'iPad', width: 1620, height: 2160, scale: 2 },
    { name: 'iPad mini', width: 1536, height: 2048, scale: 2 }
  ],
  android: [
    { name: 'Android 手机竖屏 (480x762)', width: 480, height: 762 },
    { name: 'Android 手机竖屏 (720x1242)', width: 720, height: 1242 },
    { name: 'Android 手机竖屏 (1080x1882)', width: 1080, height: 1882 },
    { name: 'Android 手机竖屏 (1080x1920)', width: 1080, height: 1920 },
    { name: 'Android 手机横屏 (1920x1080)', width: 1920, height: 1080 },
    { name: 'Android 平板竖屏 (1200x1920)', width: 1200, height: 1920 },
    { name: 'Android 平板横屏 (1920x1200)', width: 1920, height: 1200 }
  ]
}

const canGenerate = computed(() => !!originalImage.value && !!selectedSize.value)

watch(currentPlatform, () => {
  selectedSize.value = null
  generatedImage.value = null
  outputFormat.value = currentPlatform.value === 'android' ? 'nine' : 'png'
})

function updateSizes() {
  selectedSize.value = null
  generatedImage.value = null
}

function handleFileSelect(e) {
  const file = e.target.files[0]
  if (file) handleFile(file)
}

function handleDrop(e) {
  isDragging.value = false
  const files = e.dataTransfer.files
  if (files.length > 0) handleFile(files[0])
}

function handleFile(file) {
  if (!file.type.startsWith('image/')) {
    showStatus('请选择图片文件', 'error')
    return
  }
  const reader = new FileReader()
  reader.onload = (e) => {
    const img = new Image()
    img.onload = () => {
      originalImage.value = img
      previewImageSrc.value = e.target.result
      showStatus('图片加载成功', 'success')
    }
    img.src = e.target.result
  }
  reader.readAsDataURL(file)
}

function resetImage() {
  originalImage.value = null
  previewImageSrc.value = ''
  selectedSize.value = null
  generatedImage.value = null
  if (fileInput.value) fileInput.value.value = ''
  showStatus('已清除图片', 'info')
}

function selectSize(size) {
  selectedSize.value = `${size.width}x${size.height}`
}

function showStatus(message, type) {
  statusMessage.value = message
  statusType.value = type || 'success'
  setTimeout(() => {
    statusMessage.value = ''
  }, 5000)
}

async function generateImage() {
  if (!originalImage.value || !selectedSize.value) {
    showStatus('请先上传图片并选择尺寸', 'error')
    return
  }
  loading.value = true
  try {
    const sizes = platformSizes[currentPlatform.value]
    const size = sizes.find(s => `${s.width}x${s.height}` === selectedSize.value)
    if (!size) {
      showStatus('选择的尺寸无效', 'error')
      return
    }
    const { canvas, contentRect } = await generateLaunchImage(originalImage.value, size.width, size.height)
    if (canvas.width !== size.width || canvas.height !== size.height) {
      throw new Error(`图片尺寸不匹配: 期望 ${size.width}x${size.height}, 实际 ${canvas.width}x${canvas.height}`)
    }
    generatedImage.value = {
      canvas,
      name: size.name,
      width: size.width,
      height: size.height,
      contentRect
    }
    await nextTick()
    renderPreview(canvas, size)
    showStatus(`成功生成启动图: ${size.name}`, 'success')
  } catch (error) {
    console.error('生成失败:', error)
    showStatus('生成失败: ' + error.message, 'error')
  } finally {
    loading.value = false
  }
}

function generateLaunchImage(image, targetWidth, targetHeight) {
  return new Promise((resolve) => {
    const finalWidth = Math.floor(targetWidth)
    const finalHeight = Math.floor(targetHeight)
    const canvas = document.createElement('canvas')
    canvas.width = finalWidth
    canvas.height = finalHeight
    const ctx = canvas.getContext('2d')
    const originalWidth = image.naturalWidth || image.width
    const originalHeight = image.naturalHeight || image.height
    const originalAspect = originalWidth / originalHeight
    const widthScale = finalWidth / originalWidth
    const heightScale = finalHeight / originalHeight
    const scale = Math.min(widthScale, heightScale)
    const scaledWidth = originalWidth * scale
    const scaledHeight = originalHeight * scale
    const drawX = (finalWidth - scaledWidth) / 2
    const drawY = (finalHeight - scaledHeight) / 2
    const edgeColor = detectEdgeColorFromOriginalImage(image)
    ctx.fillStyle = `rgb(${edgeColor.r}, ${edgeColor.g}, ${edgeColor.b})`
    ctx.fillRect(0, 0, finalWidth, finalHeight)
    ctx.imageSmoothingEnabled = true
    ctx.imageSmoothingQuality = 'high'
    ctx.drawImage(image, 0, 0, originalWidth, originalHeight, drawX, drawY, scaledWidth, scaledHeight)
    const contentRect = {
      x: Math.round(drawX),
      y: Math.round(drawY),
      width: Math.round(scaledWidth),
      height: Math.round(scaledHeight)
    }
    resolve({ canvas, contentRect })
  })
}

function detectEdgeColorFromOriginalImage(image) {
  const tempCanvas = document.createElement('canvas')
  tempCanvas.width = image.width
  tempCanvas.height = image.height
  const tempCtx = tempCanvas.getContext('2d')
  tempCtx.drawImage(image, 0, 0)
  const imageData = tempCtx.getImageData(0, 0, image.width, image.height)
  const data = imageData.data
  let rSum = 0, gSum = 0, bSum = 0, count = 0
  const edgeWidth = Math.max(1, Math.floor(Math.min(image.width, image.height) * 0.05))
  for (let x = 0; x < edgeWidth && x < image.width; x++) {
    for (let y = 0; y < image.height; y++) {
      const index = (y * image.width + x) * 4
      if (data[index + 3] > 0) {
        rSum += data[index]
        gSum += data[index + 1]
        bSum += data[index + 2]
        count++
      }
    }
  }
  for (let x = Math.max(0, image.width - edgeWidth); x < image.width; x++) {
    for (let y = 0; y < image.height; y++) {
      const index = (y * image.width + x) * 4
      if (data[index + 3] > 0) {
        rSum += data[index]
        gSum += data[index + 1]
        bSum += data[index + 2]
        count++
      }
    }
  }
  for (let y = 0; y < edgeWidth && y < image.height; y++) {
    for (let x = edgeWidth; x < image.width - edgeWidth; x++) {
      const index = (y * image.width + x) * 4
      if (data[index + 3] > 0) {
        rSum += data[index]
        gSum += data[index + 1]
        bSum += data[index + 2]
        count++
      }
    }
  }
  for (let y = Math.max(0, image.height - edgeWidth); y < image.height; y++) {
    for (let x = edgeWidth; x < image.width - edgeWidth; x++) {
      const index = (y * image.width + x) * 4
      if (data[index + 3] > 0) {
        rSum += data[index]
        gSum += data[index + 1]
        bSum += data[index + 2]
        count++
      }
    }
  }
  if (count > 0) {
    return {
      r: Math.round(rSum / count),
      g: Math.round(gSum / count),
      b: Math.round(bSum / count)
    }
  }
  return { r: 255, g: 255, b: 255 }
}

function createNinePatchFromCanvas(imageCanvas, contentRect) {
  const w = imageCanvas.width
  const h = imageCanvas.height
  const nineCanvas = document.createElement('canvas')
  nineCanvas.width = w + 2
  nineCanvas.height = h + 2
  const ctx = nineCanvas.getContext('2d')
  ctx.imageSmoothingEnabled = true
  ctx.imageSmoothingQuality = 'high'
  ctx.clearRect(0, 0, nineCanvas.width, nineCanvas.height)
  ctx.drawImage(imageCanvas, 1, 1)
  ctx.fillStyle = '#000'
  const buffer = 2
  const cx = Math.max(0, Math.min(w, Math.round(contentRect.x)))
  const cy = Math.max(0, Math.min(h, Math.round(contentRect.y)))
  const cw = Math.max(0, Math.min(w - cx, Math.round(contentRect.width)))
  const ch = Math.max(0, Math.min(h - cy, Math.round(contentRect.height)))
  const leftMargin = cx
  const rightMargin = Math.max(0, w - (cx + cw))
  const topMargin = cy
  const bottomMargin = Math.max(0, h - (cy + ch))
  if (leftMargin > buffer) {
    ctx.fillRect(1, 0, leftMargin - buffer, 1)
  } else if (leftMargin > 0) {
    ctx.fillRect(1, 0, leftMargin, 1)
  }
  if (rightMargin > buffer) {
    ctx.fillRect(1 + cx + cw + buffer, 0, rightMargin - buffer, 1)
  } else if (rightMargin > 0) {
    ctx.fillRect(1 + cx + cw, 0, rightMargin, 1)
  }
  if (leftMargin <= buffer && rightMargin <= buffer) {
    ctx.fillRect(1, 0, 1, 1)
  }
  if (topMargin > buffer) {
    ctx.fillRect(0, 1, topMargin - buffer, 1)
  } else if (topMargin > 0) {
    ctx.fillRect(0, 1, topMargin, 1)
  }
  if (bottomMargin > buffer) {
    ctx.fillRect(0, 1 + cy + ch + buffer, 1, bottomMargin - buffer)
  } else if (bottomMargin > 0) {
    ctx.fillRect(0, 1 + cy + ch, 1, bottomMargin)
  }
  if (topMargin <= buffer && bottomMargin <= buffer) {
    ctx.fillRect(0, 1, 1, 1)
  }
  ctx.fillRect(1, h + 1, w, 1)
  ctx.fillRect(w + 1, 1, 1, h)
  return nineCanvas
}

function renderPreview(canvas, size) {
  nextTick(() => {
    if (!previewCanvas.value) return
    const phoneCanvas = createPhonePreview(canvas, size, 300)
    previewCanvas.value.width = phoneCanvas.width
    previewCanvas.value.height = phoneCanvas.height
    const ctx = previewCanvas.value.getContext('2d')
    ctx.drawImage(phoneCanvas, 0, 0)
  })
}

function createPhonePreview(imageCanvas, size, maxWidth) {
  const canvasAspect = imageCanvas.width / imageCanvas.height
  const borderWidth = maxWidth * 0.08
  const screenWidth = maxWidth - borderWidth * 2
  const screenHeight = screenWidth / canvasAspect
  const phoneWidth = screenWidth + borderWidth * 2
  const phoneHeight = screenHeight + borderWidth * 2
  const phoneCanvas = document.createElement('canvas')
  phoneCanvas.width = phoneWidth
  phoneCanvas.height = phoneHeight
  const ctx = phoneCanvas.getContext('2d')
  ctx.imageSmoothingEnabled = true
  ctx.imageSmoothingQuality = 'high'
  ctx.fillStyle = '#1a1a1a'
  ctx.fillRect(0, 0, phoneWidth, phoneHeight)
  ctx.strokeStyle = '#333'
  ctx.lineWidth = borderWidth * 0.3
  ctx.strokeRect(borderWidth * 0.5, borderWidth * 0.5, phoneWidth - borderWidth, phoneHeight - borderWidth)
  const cornerRadius = borderWidth * 0.3
  ctx.fillStyle = '#000'
  if (ctx.roundRect) {
    ctx.beginPath()
    ctx.roundRect(borderWidth, borderWidth, screenWidth, screenHeight, cornerRadius)
    ctx.fill()
  } else {
    ctx.fillRect(borderWidth, borderWidth, screenWidth, screenHeight)
  }
  ctx.save()
  if (ctx.roundRect) {
    ctx.beginPath()
    ctx.roundRect(borderWidth, borderWidth, screenWidth, screenHeight, cornerRadius)
    ctx.clip()
  }
  ctx.drawImage(imageCanvas, 0, 0, imageCanvas.width, imageCanvas.height, borderWidth, borderWidth, screenWidth, screenHeight)
  ctx.restore()
  return phoneCanvas
}

function showFullscreen() {
  if (!generatedImage.value) return
  showFullscreenModal.value = true
  nextTick(() => {
    if (!fullscreenContent.value) return
    const size = platformSizes[currentPlatform.value].find(s => `${s.width}x${s.height}` === selectedSize.value)
    const maxWidth = Math.min(window.innerWidth * 0.9, 600)
    const displayCanvas = createPhonePreview(generatedImage.value.canvas, size, maxWidth)
    fullscreenContent.value.innerHTML = ''
    fullscreenContent.value.appendChild(displayCanvas)
  })
}

function closeFullscreen() {
  showFullscreenModal.value = false
}

function downloadImage() {
  if (!generatedImage.value) {
    showStatus('没有可下载的图片', 'error')
    return
  }
  const platformName = currentPlatform.value === 'ios' ? 'iOS' : 'Android'
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, -5)
  const link = document.createElement('a')
  if (currentPlatform.value === 'android' && outputFormat.value === 'nine') {
    const ninePatchCanvas = createNinePatchFromCanvas(generatedImage.value.canvas, generatedImage.value.contentRect || { x: 0, y: 0, width: generatedImage.value.width, height: generatedImage.value.height })
    link.download = `${platformName}_${generatedImage.value.name.replace(/\s+/g, '_')}_${generatedImage.value.width}x${generatedImage.value.height}_${timestamp}.9.png`
    link.href = ninePatchCanvas.toDataURL('image/png')
  } else {
    link.download = `${platformName}_${generatedImage.value.name.replace(/\s+/g, '_')}_${generatedImage.value.width}x${generatedImage.value.height}_${timestamp}.png`
    link.href = generatedImage.value.canvas.toDataURL('image/png')
  }
  link.click()
  showStatus('图片下载已开始', 'success')
}

onMounted(() => {
  if (!CanvasRenderingContext2D.prototype.roundRect) {
    CanvasRenderingContext2D.prototype.roundRect = function (x, y, width, height, radius) {
      this.beginPath()
      this.moveTo(x + radius, y)
      this.lineTo(x + width - radius, y)
      this.quadraticCurveTo(x + width, y, x + width, y + radius)
      this.lineTo(x + width, y + height - radius)
      this.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
      this.lineTo(x + radius, y + height)
      this.quadraticCurveTo(x, y + height, x, y + height - radius)
      this.lineTo(x, y + radius)
      this.quadraticCurveTo(x, y, x + radius, y)
      this.closePath()
    }
  }
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && showFullscreenModal.value) {
      closeFullscreen()
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

.file-upload-area {
  border: 3px dashed var(--color-primary);
  border-radius: var(--radius-md);
  padding: var(--spacing-xxl);
  text-align: center;
  background: var(--color-hover);
  cursor: pointer;
  transition: all 0.3s;
}

.file-upload-area:hover {
  background: var(--color-surface-alt);
  border-color: var(--color-primary-dark);
}

.file-upload-area.dragover {
  background: var(--color-hover);
  border-color: var(--color-primary);
}

.file-upload-icon {
  font-size: 48px;
  color: var(--color-primary);
  margin-bottom: 15px;
}

.file-upload-text {
  color: var(--color-text-secondary);
  font-size: var(--font-size-base);
  margin-bottom: 10px;
}

.file-upload-hint {
  color: var(--color-text-secondary);
  font-size: var(--font-size-small);
}

.image-preview-container {
  position: relative;
  display: inline-block;
  width: 100%;
}

.preview-image {
  max-width: 100%;
  max-height: 400px;
  border-radius: var(--radius-sm);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  margin-bottom: 15px;
  display: block;
}

.delete-btn {
  position: absolute;
  top: 10px;
  right: 10px;
  background: rgba(220, 53, 69, 0.9);
  color: var(--color-text-on-primary);
  border: none;
  border-radius: 50%;
  width: 36px;
  height: 36px;
  font-size: var(--font-size-large);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.delete-btn:hover {
  background: rgba(220, 53, 69, 1);
  transform: scale(1.1);
}

.platform-tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.platform-tab {
  flex: 1;
  padding: 12px;
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  background: var(--color-surface);
  cursor: pointer;
  text-align: center;
  font-weight: 600;
  color: var(--color-text-secondary);
  transition: all 0.3s;
}

.platform-tab.active {
  background: var(--color-primary);
  color: var(--color-text-on-primary);
  border-color: var(--color-primary);
}

.platform-tab:hover {
  border-color: var(--color-primary);
}

.sizes-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 15px;
  margin-top: 20px;
}

.size-item {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: var(--spacing-md);
  text-align: center;
  transition: all 0.3s;
  cursor: pointer;
}

.size-item:hover {
  border-color: var(--color-primary);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.size-item.selected {
  border-color: var(--color-primary);
  background: var(--color-hover);
}

.size-label {
  font-weight: 600;
  color: var(--color-text-secondary);
  margin-bottom: 5px;
}

.size-dimensions {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  margin-bottom: 10px;
}

.size-radio {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
  display: inline-block;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: var(--color-text-on-primary);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.btn-secondary {
  background: var(--color-secondary);
  color: var(--color-text-on-primary);
}

.btn-secondary:hover {
  background: var(--color-primary-dark);
}

.btn-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.status-message {
  padding: 12px;
  border-radius: var(--radius-sm);
  margin-top: 15px;
  display: none;
}

.status-message.success {
  background: var(--color-surface-alt);
  color: var(--color-success);
  border: 1px solid #c3e6cb;
  display: block;
}

.status-message.error {
  background: var(--color-surface-alt);
  color: var(--color-error);
  border: 1px solid #f5c6cb;
  display: block;
}

.status-message.info {
  background: var(--color-surface-alt);
  color: var(--color-text);
  border: 1px solid #bee5eb;
  display: block;
}

.loading {
  display: none;
  text-align: center;
  padding: 20px;
}

.loading.active {
  display: block;
}

.spinner {
  border: 4px solid var(--color-border);
  border-top: 4px solid var(--color-primary);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto 10px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.preview-section {
  margin-top: var(--spacing-lg);
}

.preview-container {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
  margin-top: 20px;
}

.preview-item {
  text-align: center;
}

.preview-item canvas {
  border: none;
  border-radius: 0;
  max-width: 300px;
  max-height: 600px;
  width: auto !important;
  height: auto !important;
  display: block;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  image-rendering: -webkit-optimize-contrast;
  image-rendering: crisp-edges;
  cursor: pointer;
  transition: transform 0.2s;
}

.preview-item canvas:hover {
  transform: scale(1.05);
}

.preview-item-label {
  margin-top: 8px;
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}

.fullscreen-modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.95);
  z-index: 10000;
  cursor: pointer;
}

.fullscreen-modal.active {
  display: flex;
  align-items: center;
  justify-content: center;
}

.fullscreen-modal img,
.fullscreen-modal canvas {
  max-width: 90vw;
  max-height: 90vh;
  width: auto;
  height: auto;
  object-fit: contain;
  border-radius: 0;
  image-rendering: -webkit-optimize-contrast;
  image-rendering: crisp-edges;
  box-shadow: 0 8px 40px rgba(0, 0, 0, 0.5);
}

.close-btn {
  position: absolute;
  top: 20px;
  right: 20px;
  background: rgba(255, 255, 255, 0.2);
  color: var(--color-text-on-primary);
  border: 2px solid var(--color-border);
  border-radius: 50%;
  width: 50px;
  height: 50px;
  font-size: 24px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
}

.format-icon {
  display: inline-block;
  margin-right: 8px;
  font-size: 1.2em;
}

.output-format-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
  margin-top: 20px;
}

.format-option {
  position: relative;
}

.format-radio {
  position: absolute;
  opacity: 0;
  pointer-events: none;
}

.format-label {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.format-label::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
  opacity: 0;
  transition: opacity 0.3s;
}

.format-label:hover {
  border-color: var(--color-primary);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
}

.format-label:hover::before {
  opacity: 1;
}

.format-option.format-selected .format-label {
  border-color: var(--color-primary);
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.08) 100%);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.25);
  transform: translateY(-2px);
}

.format-option.format-selected .format-label::before {
  opacity: 1;
}

.format-icon-wrapper {
  flex-shrink: 0;
  width: 56px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  border-radius: var(--radius-md);
  transition: all 0.3s;
  position: relative;
  z-index: 1;
}

.format-option.format-selected .format-icon-wrapper {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.2) 0%, rgba(118, 75, 162, 0.2) 100%);
  transform: scale(1.05);
}

.format-svg {
  width: 32px;
  height: 32px;
  color: var(--color-primary);
  transition: all 0.3s;
}

.format-option.format-selected .format-svg {
  color: var(--color-primary-dark);
  transform: scale(1.1);
}

.format-content {
  flex: 1;
  min-width: 0;
  position: relative;
  z-index: 1;
}

.format-title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: 6px;
  transition: color 0.3s;
}

.format-option.format-selected .format-title {
  color: var(--color-primary-dark);
}

.format-desc {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  line-height: 1.4;
  transition: color 0.3s;
}

.format-check {
  flex-shrink: 0;
  width: 24px;
  height: 24px;
  color: var(--color-primary);
  opacity: 0;
  transform: scale(0.5);
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  position: relative;
  z-index: 1;
}

.format-option.format-selected .format-check {
  opacity: 1;
  transform: scale(1);
}

.format-check svg {
  width: 100%;
  height: 100%;
}

@media (max-width: 640px) {
  .output-format-container {
    grid-template-columns: 1fr;
  }

  .format-label {
    padding: 16px;
    gap: 12px;
  }

  .format-icon-wrapper {
    width: 48px;
    height: 48px;
  }

  .format-svg {
    width: 28px;
    height: 28px;
  }
}
</style>
