<template>
  <ToolLayout title="🎨 图标工厂" description="上传一个图标，生成 iOS 与 Android 标准尺寸与文件夹结构">
    <div class="form-section">
      <h2>上传图标</h2>
      <div 
        class="file-upload-area" 
        :class="{ dragover: isDragging }"
        @click="fileInput?.click()"
        @dragover.prevent="isDragging = true"
        @dragleave.prevent="isDragging = false"
        @drop.prevent="handleDrop"
      >
        <div style="font-size:42px;color:var(--color-primary);margin-bottom:10px">📁</div>
        <div style="color:var(--color-text);font-size:var(--font-size-base);margin-bottom:6px">点击或拖拽图标到此处</div>
        <div style="color:var(--color-text-secondary);font-size:var(--font-size-small)">建议上传正方形 PNG，尺寸≥1024×1024</div>
        <input ref="fileInput" type="file" accept="image/*" @change="handleFileSelect" style="display:none">
      </div>
      <div v-if="statusMessage" :class="['status', 'show', statusType]">
        {{ statusMessage }}
      </div>
    </div>

    <div class="form-section">
      <h2>生成设置</h2>
      <div class="controls-grid">
        <div class="form-group">
          <label for="bgColor">背景颜色（用于非正方形图标补边）</label>
          <input type="color" id="bgColor" v-model="bgColor">
        </div>
        <div class="form-group">
          <label for="padding">内边距（百分比，0-30）</label>
          <input type="number" id="padding" v-model.number="padding" min="0" max="30">
        </div>
        <div class="form-group">
          <label>
            <input type="checkbox" v-model="generateRound">
            生成圆形图标（ic_launcher_round）
          </label>
        </div>
        <div class="form-group">
          <label for="platformSelect">平台</label>
          <select id="platformSelect" v-model="platform">
            <option value="both">iOS + Android</option>
            <option value="ios">仅 iOS</option>
            <option value="android">仅 Android</option>
          </select>
        </div>
      </div>
      <AppButton variant="primary" icon="📦" :disabled="!canGenerate" @click="generate">生成并下载 ZIP</AppButton>
    </div>

    <div v-if="loading" class="loading show">
      <div class="spinner"></div>
      <div>正在生成图标及目录结构...</div>
    </div>

    <div class="form-section">
      <h2>预览（部分尺寸）</h2>
      <div class="preview-grid" ref="previewGrid"></div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { computed, nextTick, onMounted, ref } from 'vue'
import { loadScript } from '@/utils/cdn-loader.js'

const fileInput = ref(null)
const previewGrid = ref(null)
const isDragging = ref(false)
const baseImage = ref(null)
const bgColor = ref('#FFFFFF')
const padding = ref(0)
const generateRound = ref(false)
const platform = ref('both')
const loading = ref(false)
const statusMessage = ref('')
const statusType = ref('success')
let JSZip = null

const canGenerate = computed(() => !!baseImage.value)

onMounted(async () => {
  // 加载 JSZip 库
  try {
    await loadScript('https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js')
    JSZip = window.JSZip
  } catch (err) {
    console.error('Failed to load JSZip:', err)
    showStatus('加载 JSZip 库失败', 'error')
  }
})

function showStatus(text, type) {
  statusMessage.value = text
  statusType.value = type || 'success'
  setTimeout(() => {
    statusMessage.value = ''
  }, 3000)
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
      baseImage.value = img
      showStatus('图标加载成功', 'success')
      renderPreview()
    }
    img.src = e.target.result
  }
  reader.readAsDataURL(file)
}

function drawIconToCanvas(size, bgColor, padding) {
  const c = document.createElement('canvas')
  c.width = size
  c.height = size
  const ctx = c.getContext('2d')
  ctx.fillStyle = bgColor
  ctx.fillRect(0, 0, size, size)
  const iw = baseImage.value.naturalWidth || baseImage.value.width
  const ih = baseImage.value.naturalHeight || baseImage.value.height
  const inset = size * (padding / 100)
  const target = size - 2 * inset
  const scale = Math.min(Math.min(target / iw, target / ih), 1)
  const dw = iw * scale
  const dh = ih * scale
  const dx = (size - dw) / 2
  const dy = (size - dh) / 2
  ctx.imageSmoothingEnabled = true
  ctx.imageSmoothingQuality = 'high'
  ctx.drawImage(baseImage.value, dx, dy, dw, dh)
  return c
}

function drawRoundIconToCanvas(size, bgColor, padding) {
  const c = document.createElement('canvas')
  c.width = size
  c.height = size
  const ctx = c.getContext('2d')
  ctx.fillStyle = bgColor
  ctx.fillRect(0, 0, size, size)
  ctx.save()
  ctx.beginPath()
  ctx.arc(size / 2, size / 2, size / 2, 0, Math.PI * 2)
  ctx.closePath()
  ctx.clip()
  const iw = baseImage.value.naturalWidth || baseImage.value.width
  const ih = baseImage.value.naturalHeight || baseImage.value.height
  const inset = size * (padding / 100)
  const target = size - 2 * inset
  const scale = Math.min(Math.min(target / iw, target / ih), 1)
  const dw = iw * scale
  const dh = ih * scale
  const dx = (size - dw) / 2
  const dy = (size - dh) / 2
  ctx.imageSmoothingEnabled = true
  ctx.imageSmoothingQuality = 'high'
  ctx.drawImage(baseImage.value, dx, dy, dw, dh)
  ctx.restore()
  return c
}

function canvasToBlob(canvas, mime = 'image/png', quality = 1) {
  return new Promise(res => canvas.toBlob(b => res(b), mime, quality))
}

async function encodePngNative(canvas) {
  return canvasToBlob(canvas, 'image/png', 1)
}

function renderPreview() {
  nextTick(() => {
    if (!previewGrid.value) return
    previewGrid.value.innerHTML = ''
    if (!baseImage.value) return
    const bg = bgColor.value
    const pad = padding.value || 0
    const previewSizes = [1024, 180, 120, 80, 60, 48, 192]
    previewSizes.forEach(s => {
      const card = document.createElement('div')
      card.className = 'preview-card'
      const title = document.createElement('div')
      title.className = 'preview-title'
      title.textContent = `${s}×${s}`
      const imgEl = document.createElement('img')
      imgEl.className = 'preview-image'
      const c = drawIconToCanvas(s, bg, pad)
      imgEl.src = c.toDataURL('image/png')
      card.appendChild(title)
      card.appendChild(imgEl)
      previewGrid.value.appendChild(card)
    })
  })
}

const iosSpecs = [
  { size: 40, name: 'icon-20@2x.png', idiom: 'iphone', scale: '2x', pt: '20x20' },
  { size: 60, name: 'icon-20@3x.png', idiom: 'iphone', scale: '3x', pt: '20x20' },
  { size: 58, name: 'icon-29@2x.png', idiom: 'iphone', scale: '2x', pt: '29x29' },
  { size: 87, name: 'icon-29@3x.png', idiom: 'iphone', scale: '3x', pt: '29x29' },
  { size: 80, name: 'icon-40@2x.png', idiom: 'iphone', scale: '2x', pt: '40x40' },
  { size: 120, name: 'icon-40@3x.png', idiom: 'iphone', scale: '3x', pt: '40x40' },
  { size: 120, name: 'icon-60@2x.png', idiom: 'iphone', scale: '2x', pt: '60x60' },
  { size: 180, name: 'icon-60@3x.png', idiom: 'iphone', scale: '3x', pt: '60x60' },
  { size: 20, name: 'icon-20-ipad.png', idiom: 'ipad', scale: '1x', pt: '20x20' },
  { size: 40, name: 'icon-20-ipad@2x.png', idiom: 'ipad', scale: '2x', pt: '20x20' },
  { size: 29, name: 'icon-29-ipad.png', idiom: 'ipad', scale: '1x', pt: '29x29' },
  { size: 58, name: 'icon-29-ipad@2x.png', idiom: 'ipad', scale: '2x', pt: '29x29' },
  { size: 40, name: 'icon-40-ipad.png', idiom: 'ipad', scale: '1x', pt: '40x40' },
  { size: 80, name: 'icon-40-ipad@2x.png', idiom: 'ipad', scale: '2x', pt: '40x40' },
  { size: 76, name: 'icon-76.png', idiom: 'ipad', scale: '1x', pt: '76x76' },
  { size: 152, name: 'icon-76@2x.png', idiom: 'ipad', scale: '2x', pt: '76x76' },
  { size: 167, name: 'icon-83.5@2x.png', idiom: 'ipad', scale: '2x', pt: '83.5x83.5' },
  { size: 1024, name: 'icon-1024.png', idiom: 'ios-marketing', scale: '1x', pt: '1024x1024' }
]

const androidSquareSpecs = [
  { size: 48, dir: 'mipmap-mdpi', name: 'ic_launcher.png' },
  { size: 72, dir: 'mipmap-hdpi', name: 'ic_launcher.png' },
  { size: 96, dir: 'mipmap-xhdpi', name: 'ic_launcher.png' },
  { size: 144, dir: 'mipmap-xxhdpi', name: 'ic_launcher.png' },
  { size: 192, dir: 'mipmap-xxxhdpi', name: 'ic_launcher.png' }
]

const androidRoundSpecs = [
  { size: 48, dir: 'mipmap-mdpi', name: 'ic_launcher_round.png' },
  { size: 72, dir: 'mipmap-hdpi', name: 'ic_launcher_round.png' },
  { size: 96, dir: 'mipmap-xhdpi', name: 'ic_launcher_round.png' },
  { size: 144, dir: 'mipmap-xxhdpi', name: 'ic_launcher_round.png' },
  { size: 192, dir: 'mipmap-xxxhdpi', name: 'ic_launcher_round.png' }
]

function buildIosContentsJson(images) {
  return JSON.stringify({
    images: images.map(img => ({
      size: img.pt,
      idiom: img.idiom,
      filename: img.name,
      scale: img.scale
    })),
    info: { version: 1, author: 'icon-factory' }
  }, null, 2)
}

async function generate() {
  if (!baseImage.value || !JSZip) return
  const bg = bgColor.value
  const pad = padding.value || 0
  const platformValue = platform.value
  loading.value = true
  try {
    const zip = new JSZip()
    if (platformValue === 'both' || platformValue === 'ios') {
      const iosFolder = zip.folder('iOS').folder('AppIcon.appiconset')
      const iosImages = []
      for (const spec of iosSpecs) {
        const c = drawIconToCanvas(spec.size, bg, pad)
        const blob = await encodePngNative(c)
        iosFolder.file(spec.name, blob)
        iosImages.push(spec)
      }
      iosFolder.file('Contents.json', buildIosContentsJson(iosImages))
    }
    if (platformValue === 'both' || platformValue === 'android') {
      const andFolder = zip.folder('Android')
      for (const spec of androidSquareSpecs) {
        const c = drawIconToCanvas(spec.size, bg, pad)
        const blob = await encodePngNative(c)
        andFolder.folder(spec.dir).file(spec.name, blob)
      }
      if (generateRound.value) {
        for (const spec of androidRoundSpecs) {
          const c = drawRoundIconToCanvas(spec.size, bg, pad)
          const blob = await encodePngNative(c)
          andFolder.folder(spec.dir).file(spec.name, blob)
        }
      }
    }
    const blob = await zip.generateAsync({ type: 'blob' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `icon_factory_${Date.now()}.zip`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    showStatus('生成完成，已下载 ZIP 包', 'success')
  } catch (err) {
    console.error(err)
    showStatus('生成失败：' + err.message, 'error')
  } finally {
    loading.value = false
  }
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

.file-upload-area {
  border: 3px dashed var(--color-primary);
  border-radius: var(--radius-md);
  padding: var(--spacing-xxl);
  text-align: center;
  background: var(--color-hover);
  cursor: pointer;
  transition: all .3s;
}

.file-upload-area:hover {
  background: var(--color-surface-alt);
  border-color: var(--color-primary-dark);
}

.file-upload-area.dragover {
  background: var(--color-hover);
  border-color: var(--color-primary);
}

.controls-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 15px;
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
  transition: border-color .3s;
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
  padding: 14px 35px;
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
  0% { transform: rotate(0); }
  100% { transform: rotate(360deg); }
}

.preview-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
  gap: 12px;
}

.preview-card {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 12px;
  text-align: center;
}

.preview-title {
  font-size: 13px;
  color: var(--color-text-secondary);
  margin-bottom: 8px;
}

.preview-image {
  width: 96px;
  height: 96px;
  border-radius: var(--radius-lg);
  object-fit: contain;
  background: var(--color-surface-alt);
  border: 1px dashed var(--color-border);
}

.status {
  display: none;
  margin-top: 12px;
  padding: 10px;
  border-radius: 8px;
}

.status.show {
  display: block;
}

.status.success {
  background: var(--color-surface-alt);
  color: var(--color-success);
  border: 1px solid #c3e6cb;
}

.status.error {
  background: var(--color-surface-alt);
  color: var(--color-error);
  border: 1px solid #f5c6cb;
}
</style>
