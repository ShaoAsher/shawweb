<template>
  <ToolLayout title="🔄 SVG 互转 PNG/JPG/JPEG" description="支持上传 SVG 或 PNG/JPG/JPEG，进行相互转换与下载">
    <div class="form-section">
      <h2>上传文件</h2>
      <!-- 使用统一的 FileUploader 组件 -->
      <FileUploader
        v-model="inputFile"
        accept=".svg,image/*"
        icon="🔄"
        text="点击或拖拽文件到此处"
        hint="支持 SVG、PNG、JPG、JPEG"
        @change="handleFile"
        @delete="resetFile"
      />
    </div>

    <div class="form-section">
      <h2>转换设置</h2>
      <div class="controls-grid">
        <div class="form-group">
          <label for="targetFormat">目标格式</label>
          <select id="targetFormat" v-model="targetFormat">
            <option value="png">PNG</option>
            <option value="jpg">JPG</option>
            <option value="jpeg">JPEG</option>
            <option value="svg">SVG</option>
          </select>
        </div>
        <div class="form-group">
          <label for="targetWidth">宽度（像素）</label>
          <input type="number" id="targetWidth" v-model.number="targetWidth" placeholder="如 1024">
        </div>
        <div class="form-group">
          <label for="targetHeight">高度（像素）</label>
          <input type="number" id="targetHeight" v-model.number="targetHeight" placeholder="如 1024">
        </div>
        <div class="form-group">
          <label>
            <input type="checkbox" v-model="keepAspect" checked>
            保持原始比例（仅栅格化时生效）
          </label>
        </div>
        <div class="form-group">
          <label for="bgColor">背景颜色（PNG 支持透明，JPG/JPEG会使用该颜色）</label>
          <input type="color" id="bgColor" v-model="bgColor">
        </div>
      </div>
      <AppButton variant="primary" icon="🔄" :disabled="!canConvert" @click="convert">开始转换并下载</AppButton>
    </div>

    <div v-if="loading" class="loading show">
      <div class="spinner"></div>
      <div>正在转换...</div>
    </div>

    <div class="form-section">
      <h2>预览</h2>
      <div class="preview">
        <div class="card">
          <div style="font-weight:var(--font-weight-semibold);color:var(--color-text);margin-bottom:var(--spacing-sm)">
            输入文件预览
          </div>
          <div ref="inputPreview"></div>
        </div>
        <div class="card">
          <div style="font-weight:var(--font-weight-semibold);color:var(--color-text);margin-bottom:var(--spacing-sm)">
            输出结果预览
          </div>
          <img v-if="outputPreviewUrl" :src="outputPreviewUrl" class="preview-image" alt="">
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { computed, nextTick, ref } from 'vue'

const inputPreview = ref(null)
const inputFile = ref(null)
const inputType = ref(null) // 'svg' | 'raster'
const inputDataURL = ref(null)
const svgText = ref(null)
const targetFormat = ref('png')
const targetWidth = ref(0)
const targetHeight = ref(0)
const keepAspect = ref(true)
const bgColor = ref('#FFFFFF')
const loading = ref(false)
const outputPreviewUrl = ref('')

const canConvert = computed(() => !!inputFile.value)

function resetFile() {
  inputFile.value = null
  inputType.value = null
  inputDataURL.value = null
  svgText.value = null
  outputPreviewUrl.value = ''
  if (inputPreview.value) {
    inputPreview.value.innerHTML = ''
  }
}

function handleFile(file) {
  if (!file) return
  inputFile.value = file
  const name = file.name.toLowerCase()
  const isSvg = name.endsWith('.svg') || file.type === 'image/svg+xml'
  
  if (isSvg) {
    inputType.value = 'svg'
    const reader = new FileReader()
    reader.onload = (e) => {
      svgText.value = e.target.result
      inputDataURL.value = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svgText.value)
      renderInputPreview()
    }
    reader.readAsText(file)
  } else if (file.type.startsWith('image/')) {
    inputType.value = 'raster'
    const reader = new FileReader()
    reader.onload = (e) => {
      inputDataURL.value = e.target.result
      renderInputPreview()
    }
    reader.readAsDataURL(file)
  }
}

function renderInputPreview() {
  nextTick(() => {
    if (!inputPreview.value) return
    inputPreview.value.innerHTML = ''
    if (inputType.value === 'svg') {
      const iframe = document.createElement('iframe')
      iframe.style.width = '100%'
      iframe.style.height = '220px'
      iframe.style.border = '1px solid #e9ecef'
      iframe.srcdoc = svgText.value
      inputPreview.value.appendChild(iframe)
    } else {
      const img = new Image()
      img.src = inputDataURL.value
      img.style.maxWidth = '100%'
      img.style.borderRadius = '8px'
      img.style.background = 'transparent'
      inputPreview.value.appendChild(img)
    }
  })
}

async function convert() {
  if (!inputFile.value) return
  loading.value = true
  try {
    const fmt = targetFormat.value
    if (inputType.value === 'svg') {
      if (fmt === 'svg') {
        const blob = new Blob([svgText.value], { type: 'image/svg+xml' })
        const url = URL.createObjectURL(blob)
        outputPreviewUrl.value = url
        triggerDownload(blob, rename(inputFile.value.name, 'svg'))
      } else {
        const canvas = await rasterizeSvg(svgText.value, getTargetSize())
        const mime = fmt === 'png' ? 'image/png' : 'image/jpeg'
        const useBg = mime === 'image/jpeg'
        const blob = await canvasToBlob(canvas, mime, 0.92, useBg ? bgColor.value : null)
        outputPreviewUrl.value = URL.createObjectURL(blob)
        triggerDownload(blob, rename(inputFile.value.name, fmt))
      }
    } else {
      if (fmt === 'svg') {
        const svgBlob = await wrapRasterInSvg(inputDataURL.value, getTargetSize())
        outputPreviewUrl.value = URL.createObjectURL(svgBlob)
        triggerDownload(svgBlob, rename(inputFile.value.name, 'svg'))
      } else {
        const canvas = await drawRasterToCanvas(inputDataURL.value, getTargetSize())
        const mime = fmt === 'png' ? 'image/png' : 'image/jpeg'
        const useBg = mime === 'image/jpeg'
        const blob = await canvasToBlob(canvas, mime, 0.92, useBg ? bgColor.value : null)
        outputPreviewUrl.value = URL.createObjectURL(blob)
        triggerDownload(blob, rename(inputFile.value.name, fmt))
      }
    }
    console.log('转换完成，已开始下载')
  } catch (err) {
    console.error('转换失败：', err)
  } finally {
    loading.value = false
  }
}

function getTargetSize() {
  const w = targetWidth.value || 0
  const h = targetHeight.value || 0
  return { w, h }
}

function rename(name, ext) {
  const base = name.replace(/\.[^.]+$/, '')
  return base + '.' + ext
}

function canvasToBlob(canvas, mime = 'image/png', quality = 0.92, bg = null) {
  return new Promise(res => {
    if (bg) {
      const ctx = canvas.getContext('2d')
      const imgData = ctx.getImageData(0, 0, canvas.width, canvas.height)
      ctx.fillStyle = bg
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.putImageData(imgData, 0, 0)
    }
    canvas.toBlob(b => res(b), mime, quality)
  })
}

async function rasterizeSvg(svgString, size) {
  const svgBlob = new Blob([svgString], { type: 'image/svg+xml' })
  const url = URL.createObjectURL(svgBlob)
  const img = await loadImage(url)
  const intrinsicW = img.naturalWidth || img.width
  const intrinsicH = img.naturalHeight || img.height
  let w = size.w || intrinsicW || 1024
  let h = size.h || intrinsicH || 1024
  if (keepAspect.value && size.w && !size.h) {
    h = Math.round(w * (intrinsicH / intrinsicW))
  } else if (keepAspect.value && size.h && !size.w) {
    w = Math.round(h * (intrinsicW / intrinsicH))
  }
  const canvas = document.createElement('canvas')
  canvas.width = w
  canvas.height = h
  const ctx = canvas.getContext('2d')
  ctx.imageSmoothingEnabled = true
  ctx.imageSmoothingQuality = 'high'
  ctx.clearRect(0, 0, w, h)
  ctx.drawImage(img, 0, 0, w, h)
  URL.revokeObjectURL(url)
  return canvas
}

async function drawRasterToCanvas(dataURL, size) {
  const img = await loadImage(dataURL)
  const iw = img.naturalWidth || img.width
  const ih = img.naturalHeight || img.height
  let w = size.w || iw
  let h = size.h || ih
  if (keepAspect.value && size.w && !size.h) {
    h = Math.round(w * (ih / iw))
  } else if (keepAspect.value && size.h && !size.w) {
    w = Math.round(h * (iw / ih))
  }
  const c = document.createElement('canvas')
  c.width = w
  c.height = h
  const ctx = c.getContext('2d')
  ctx.imageSmoothingEnabled = true
  ctx.imageSmoothingQuality = 'high'
  ctx.drawImage(img, 0, 0, w, h)
  return c
}

async function wrapRasterInSvg(dataURL, size) {
  const img = await loadImage(dataURL)
  const iw = img.naturalWidth || img.width
  const ih = img.naturalHeight || img.height
  const w = size.w || iw
  const h = size.h || ih
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">
    <rect width="100%" height="100%" fill="none"/>
    <image href="${dataURL}" x="0" y="0" width="${w}" height="${h}" preserveAspectRatio="${keepAspect.value ? 'xMidYMid meet' : 'none'}"/>
  </svg>`
  return new Blob([svg], { type: 'image/svg+xml' })
}

function loadImage(src) {
  return new Promise((res, rej) => {
    const img = new Image()
    img.onload = () => res(img)
    img.onerror = () => rej(new Error('图片加载失败'))
    img.src = src
  })
}

function triggerDownload(blob, filename) {
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  setTimeout(() => URL.revokeObjectURL(url), 100)
}
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
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: var(--spacing-md);
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
.form-group select {
  width: 100%;
  padding: var(--spacing-sm);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  background: var(--color-surface);
  color: var(--color-text);
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border: none;
  padding: var(--spacing-sm) var(--spacing-xl);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  font-weight: 600;
  cursor: pointer;
  transition: transform .2s;
  width: 100%;
  margin-top: var(--spacing-md);
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, .4);
}

.btn:disabled {
  opacity: .6;
  cursor: not-allowed;
}

.preview {
  display: flex;
  gap: var(--spacing-lg);
  flex-wrap: wrap;
}

.card {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--spacing-sm);
  text-align: center;
  flex: 1;
  min-width: 280px;
}

.loading {
  text-align: center;
  padding: var(--spacing-lg);
  display: none;
}

.loading.show {
  display: block;
}

.spinner {
  border: 4px solid var(--color-border-light);
  border-top: 4px solid var(--color-primary);
  border-radius: var(--radius-full);
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto var(--spacing-md);
}

@keyframes spin {
  0% { transform: rotate(0); }
  100% { transform: rotate(360deg); }
}

.preview-image {
  max-width: 100%;
  height: auto;
  border-radius: var(--radius-sm);
  background: var(--color-surface-alt);
}
</style>
