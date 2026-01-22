<template>
  <ToolLayout
    icon="🗜️"
    title="图片压缩工具"
    description="智能压缩图片，保持比例与清晰度，支持预览对比与多格式导出"
  >
    <div class="form-section">
      <h2>上传图片</h2>
      
      <!-- 未选择图片时显示上传区域 -->
      <div
        v-if="!originalImage"
        class="file-upload-area"
        :class="{ dragover: isDragging }"
        @click="triggerFileInput"
        @dragover.prevent="isDragging = true"
        @dragleave.prevent="isDragging = false"
        @drop.prevent="handleDrop"
      >
        <div class="file-upload-icon">📁</div>
        <div class="file-upload-text">点击或拖拽图片到此处</div>
        <div class="file-upload-hint">支持 JPG、PNG、WEBP</div>
        <input
          ref="fileInput"
          type="file"
          accept="image/*"
          style="display: none"
          @change="handleFileSelect"
        />
      </div>

      <!-- 已选择图片时显示预览 -->
      <div v-else class="selected-image-preview">
        <div class="preview-card">
          <div class="preview-header">
            <div class="preview-title">📷 已选择的图片</div>
            <AppButton 
              variant="danger" 
              icon="🗑️" 
              size="sm"
              @click="resetState"
            >
              删除
            </AppButton>
          </div>
          <div class="preview-image-wrapper" @click="openFullscreen(originalPreviewUrl)">
            <img :src="originalPreviewUrl" class="preview-image-thumb" alt="原图预览" />
            <div class="preview-overlay">
              <span class="preview-fullscreen-icon">🔍</span>
              <span class="preview-fullscreen-text">点击查看大图</span>
            </div>
          </div>
          <div class="meta">{{ originalMeta }}</div>
        </div>
      </div>

      <div v-if="statusMessage" class="status-message" :class="statusType">
        {{ statusMessage }}
      </div>
    </div>

    <div v-if="originalImage" class="form-section">
      <h2>压缩设置</h2>
      <div class="info-box">
        默认仅在超过限制时缩小尺寸，始终保持原始宽高比例。
      </div>
      <div class="controls-grid">
        <div class="form-group">
          <label for="maxWidth">最大宽度（像素，可选）</label>
          <input
            v-model.number="maxWidth"
            type="number"
            id="maxWidth"
            placeholder="如 1920"
            min="1"
          />
        </div>
        <div class="form-group">
          <label for="maxHeight">最大高度（像素，可选）</label>
          <input
            v-model.number="maxHeight"
            type="number"
            id="maxHeight"
            placeholder="如 1080"
            min="1"
          />
        </div>
        <div class="form-group">
          <label for="targetSizeKB">目标大小（KB，可选）</label>
          <input
            v-model.number="targetSizeKB"
            type="number"
            id="targetSizeKB"
            placeholder="如 300"
            min="1"
          />
        </div>
        <div class="form-group">
          <label for="formatSelect">输出格式</label>
          <select v-model="formatSelect" id="formatSelect">
            <option value="auto">自动</option>
            <option value="jpeg">JPEG（有损）</option>
            <option value="png">PNG（无损）</option>
            <option value="webp">WEBP（有损）</option>
          </select>
        </div>
        <div class="form-group">
          <label>质量</label>
          <div class="range-wrapper">
            <input
              v-model.number="quality"
              type="range"
              id="qualityRange"
              min="50"
              max="100"
              :disabled="!isLossyFormat"
            />
            <span :style="{ opacity: isLossyFormat ? 1 : 0.5 }">{{ quality }}</span>
          </div>
        </div>
      </div>
      <div class="form-group">
        <label>
          <input v-model="avoidUpscale" type="checkbox" />
          禁止放大（仅缩小）
        </label>
      </div>
      <AppButton 
        variant="primary" 
        icon="🗜️" 
        :loading="compressing" 
        :disabled="compressing"
        @click="compressImage"
      >
        {{ compressing ? '压缩中...' : '开始压缩' }}
      </AppButton>
    </div>

    <div v-if="showPreview" class="form-section preview-section">
      <h2>预览与对比</h2>
      <div class="preview-grid">
        <div class="preview-card">
          <div class="preview-title">原图</div>
          <div class="preview-image-wrapper" @click="openFullscreen(originalPreviewUrl)">
            <img :src="originalPreviewUrl" class="preview-image-thumb" alt="原图预览" />
            <div class="preview-overlay">
              <span class="preview-fullscreen-icon">🔍</span>
            </div>
          </div>
          <div class="meta">{{ originalMeta }}</div>
        </div>
        <div class="preview-card">
          <div class="preview-title">压缩后</div>
          <div class="preview-image-wrapper" @click="openFullscreen(compressedPreviewUrl)">
            <img :src="compressedPreviewUrl" class="preview-image-thumb" alt="压缩预览" />
            <div class="preview-overlay">
              <span class="preview-fullscreen-icon">🔍</span>
            </div>
          </div>
          <div class="meta">{{ compressedMeta }}</div>
        </div>
      </div>
      <ButtonGroup style="margin-top: 15px;">
        <AppButton variant="success" icon="⬇️" @click="downloadCompressed">下载压缩图片</AppButton>
        <AppButton variant="secondary" icon="🔄" @click="resetState">重新选择图片</AppButton>
      </ButtonGroup>
    </div>

    <!-- 全屏预览模态框 -->
    <transition name="modal-fade">
      <div v-if="showFullscreen" class="fullscreen-modal" @click="closeFullscreen">
        <div class="fullscreen-content-wrapper">
          <button class="fullscreen-close" @click="closeFullscreen">✕</button>
          <div class="fullscreen-scroll-container" @click.stop>
            <img :src="fullscreenImageUrl" class="fullscreen-image" alt="全屏预览" />
          </div>
          <div class="fullscreen-hint">滚动查看完整图片 / 点击背景关闭</div>
        </div>
      </div>
    </transition>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import AppButton from '@/components/AppButton.vue'
import ButtonGroup from '@/components/ButtonGroup.vue'
import { computed, ref } from 'vue'

const fileInput = ref(null)
const isDragging = ref(false)
const originalImage = ref(null)
const originalBlob = ref(null)
const originalPreviewUrl = ref('')
const originalMeta = ref('-')
const compressedBlob = ref(null)
const compressedPreviewUrl = ref('')
const compressedMeta = ref('-')
const compressedExt = ref('jpg')
const showPreview = ref(false)
const compressing = ref(false)
const statusMessage = ref('')
const statusType = ref('success')
const showFullscreen = ref(false)
const fullscreenImageUrl = ref('')

const maxWidth = ref(null)
const maxHeight = ref(null)
const targetSizeKB = ref(300)
const formatSelect = ref('auto')
const quality = ref(92)
const avoidUpscale = ref(true)

const isLossyFormat = computed(() => {
  return formatSelect.value === 'jpeg' || formatSelect.value === 'webp' || formatSelect.value === 'auto'
})

function triggerFileInput() {
  fileInput.value?.click()
}

function handleFileSelect(event) {
  const file = event.target.files[0]
  if (file) {
    handleFile(file)
  }
}

function handleDrop(event) {
  isDragging.value = false
  const files = event.dataTransfer.files
  if (files.length > 0) {
    handleFile(files[0])
  }
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
      originalBlob.value = file
      originalPreviewUrl.value = e.target.result
      const sizeKB = (file.size / 1024).toFixed(2)
      originalMeta.value = `尺寸: ${img.naturalWidth || img.width}×${img.naturalHeight || img.height} | 大小: ${sizeKB} KB`
      showPreview.value = false
      showStatus('图片加载成功', 'success')
    }
    img.src = e.target.result
  }
  reader.readAsDataURL(file)
}

function showStatus(text, type) {
  statusMessage.value = text
  statusType.value = type || 'success'
  setTimeout(() => {
    statusMessage.value = ''
  }, 3000)
}

function resetState() {
  // 释放原图预览 URL
  if (originalPreviewUrl.value) {
    URL.revokeObjectURL(originalPreviewUrl.value)
  }
  // 释放压缩图预览 URL
  if (compressedPreviewUrl.value) {
    URL.revokeObjectURL(compressedPreviewUrl.value)
  }
  
  originalImage.value = null
  originalBlob.value = null
  originalPreviewUrl.value = ''
  originalMeta.value = '-'
  compressedBlob.value = null
  compressedPreviewUrl.value = ''
  compressedMeta.value = '-'
  compressedExt.value = 'jpg'
  showPreview.value = false
  statusMessage.value = ''
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

function getAutoFormat(img, originalType) {
  const hasAlpha = detectAlpha(img)
  if (hasAlpha) return 'png'
  if (originalType && originalType.includes('png')) return 'png'
  return 'jpeg'
}

function detectAlpha(img) {
  const c = document.createElement('canvas')
  c.width = img.naturalWidth || img.width
  c.height = img.naturalHeight || img.height
  const ctx = c.getContext('2d')
  ctx.drawImage(img, 0, 0)
  const data = ctx.getImageData(0, 0, c.width, c.height).data
  for (let i = 3; i < data.length; i += 4) {
    if (data[i] !== 255) return true
  }
  return false
}

function computeTargetSize(w, h) {
  const mw = maxWidth.value || 0
  const mh = maxHeight.value || 0
  let tw = w, th = h

  if (mw > 0 || mh > 0) {
    const sw = mw > 0 ? mw / w : Infinity
    const sh = mh > 0 ? mh / h : Infinity
    let scale = Math.min(sw, sh)
    if (scale === Infinity) scale = 1
    if (avoidUpscale.value) scale = Math.min(scale, 1)
    tw = Math.max(1, Math.floor(w * scale))
    th = Math.max(1, Math.floor(h * scale))
  }

  return { tw, th }
}

function toBlobAsync(canvas, mime, quality) {
  return new Promise(res => canvas.toBlob(b => res(b), mime, quality))
}

async function tryBinary(canvas, mime, ext) {
  const targetBytes = targetSizeKB.value > 0 ? targetSizeKB.value * 1024 : 0
  const maxQ = quality.value / 100
  const minQ = 0.7

  let low = minQ, high = maxQ, best = null

  for (let i = 0; i < 8; i++) {
    const mid = (low + high) / 2
    const blob = await toBlobAsync(canvas, mime, mid)
    if (!blob) break

    if (targetBytes > 0 && blob.size > targetBytes) {
      high = mid
    } else {
      best = blob
      low = mid
    }
  }

  if (best) return { blob: best, ext }

  const final = await toBlobAsync(canvas, mime, Math.max(minQ, Math.min(maxQ, high)))
  return { blob: final, ext }
}

async function compressImage() {
  if (!originalImage.value) return

  compressing.value = true
  try {
    const img = originalImage.value
    const ow = img.naturalWidth || img.width
    const oh = img.naturalHeight || img.height
    const { tw, th } = computeTargetSize(ow, oh)

    const c = document.createElement('canvas')
    c.width = tw
    c.height = th
    const ctx = c.getContext('2d')
    ctx.imageSmoothingEnabled = true
    ctx.imageSmoothingQuality = 'high'
    ctx.drawImage(img, 0, 0, ow, oh, 0, 0, tw, th)

    let fmt = formatSelect.value
    if (fmt === 'auto') {
      fmt = getAutoFormat(img, originalBlob.value ? originalBlob.value.type : null)
    }

    const targetBytes = targetSizeKB.value > 0 ? targetSizeKB.value * 1024 : 0
    let result

    if (fmt === 'png') {
      const pngBlob = await toBlobAsync(c, 'image/png')
      if (!pngBlob) throw new Error('生成图片失败')

      if (targetBytes > 0 && pngBlob.size > targetBytes) {
        const hasAlpha = detectAlpha(img)
        const webpRes = await tryBinary(c, 'image/webp', 'webp')
        if (targetBytes > 0 && webpRes.blob.size > targetBytes) {
          showStatus('已尽力压缩，未完全达到目标大小', 'error')
        } else {
          if (hasAlpha) showStatus('为达到目标大小，已切换为 WEBP（保留透明）', 'success')
        }
        result = { blob: webpRes.blob, ext: webpRes.ext, width: tw, height: th }
      } else {
        result = { blob: pngBlob, ext: 'png', width: tw, height: th }
      }
    } else if (fmt === 'jpeg') {
      const jpgRes = await tryBinary(c, 'image/jpeg', 'jpg')
      if (targetBytes > 0 && jpgRes.blob.size > targetBytes) {
        const webpRes = await tryBinary(c, 'image/webp', 'webp')
        if (webpRes.blob.size < jpgRes.blob.size) {
          showStatus('为达到目标大小，已切换为 WEBP', 'success')
          result = { blob: webpRes.blob, ext: webpRes.ext, width: tw, height: th }
        } else {
          showStatus('已尽力压缩，未完全达到目标大小', 'error')
          result = { blob: jpgRes.blob, ext: jpgRes.ext, width: tw, height: th }
        }
      } else {
        result = { blob: jpgRes.blob, ext: jpgRes.ext, width: tw, height: th }
      }
    } else if (fmt === 'webp') {
      const webpRes = await tryBinary(c, 'image/webp', 'webp')
      if (targetBytes > 0 && webpRes.blob.size > targetBytes) {
        showStatus('已尽力压缩，未完全达到目标大小', 'error')
      }
      result = { blob: webpRes.blob, ext: webpRes.ext, width: tw, height: th }
    } else {
      const defaultRes = await tryBinary(c, 'image/jpeg', 'jpg')
      result = { blob: defaultRes.blob, ext: defaultRes.ext, width: tw, height: th }
    }

    compressedBlob.value = result.blob
    compressedExt.value = result.ext
    compressedPreviewUrl.value = URL.createObjectURL(result.blob)
    const sizeKB = (result.blob.size / 1024).toFixed(2)
    compressedMeta.value = `尺寸: ${result.width}×${result.height} | 大小: ${sizeKB} KB | 格式: ${result.ext.toUpperCase()}`
    showPreview.value = true
  } catch (err) {
    showStatus('压缩失败: ' + err.message, 'error')
  } finally {
    compressing.value = false
  }
}

function downloadCompressed() {
  if (!compressedBlob.value) return

  const url = URL.createObjectURL(compressedBlob.value)
  const name = `compressed_${Date.now()}.${compressedExt.value}`
  const a = document.createElement('a')
  a.href = url
  a.download = name
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

function openFullscreen(imageUrl) {
  fullscreenImageUrl.value = imageUrl
  showFullscreen.value = true
  document.body.style.overflow = 'hidden'
}

function closeFullscreen() {
  showFullscreen.value = false
  fullscreenImageUrl.value = ''
  document.body.style.overflow = ''
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

.file-upload-icon {
  font-size: 48px;
  color: var(--color-primary);
  margin-bottom: var(--spacing-md);
}

.file-upload-text {
  color: var(--color-text-secondary);
  font-size: var(--font-size-base);
  margin-bottom: 10px;
}

.file-upload-hint {
  color: var(--color-text-secondary);
  font-size: 12px;
}

.selected-image-preview {
  margin-bottom: var(--spacing-md);
}

.selected-image-preview .preview-card {
  background: var(--color-surface);
  border: 2px solid var(--color-primary);
  border-radius: var(--radius-md);
  padding: var(--spacing-md);
  box-shadow: 0 4px 12px var(--color-shadow-primary);
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-md);
  padding-bottom: var(--spacing-sm);
  border-bottom: 2px solid var(--color-border);
}

.preview-header .preview-title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: 0;
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
}

.btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px var(--color-shadow-primary);
}

.btn:disabled {
  opacity: .6;
  cursor: not-allowed;
  transform: none;
}

.btn-secondary {
  background: var(--color-secondary);
  color: var(--color-text-on-primary);
}

.btn-secondary:hover {
  background: var(--color-text-light);
}

.controls-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 15px;
}

.range-wrapper {
  display: flex;
  align-items: center;
  gap: 10px;
}

.range-wrapper input[type="range"] {
  flex: 1;
}

.info-box {
  background: var(--color-surface-alt);
  border-left: 4px solid var(--color-info);
  padding: var(--spacing-md);
  border-radius: var(--radius-sm);
  margin-bottom: 20px;
  font-size: 13px;
  color: var(--color-text);
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

.preview-section {
  margin-top: 20px;
}

.preview-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.preview-card {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: 12px;
}

.preview-title {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  margin-bottom: 8px;
}

.preview-image-wrapper {
  position: relative;
  width: 100%;
  max-height: 300px;
  overflow: hidden;
  border-radius: var(--radius-sm);
  cursor: pointer;
  background: var(--color-surface-alt);
}

.preview-image-thumb {
  width: 100%;
  height: 100%;
  object-fit: contain;
  max-height: 300px;
  border-radius: var(--radius-sm);
  box-shadow: 0 4px 12px rgba(0, 0, 0, .1);
  transition: transform 0.3s;
}

.preview-image-wrapper:hover .preview-image-thumb {
  transform: scale(1.05);
}

.preview-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  opacity: 0;
  transition: opacity 0.3s;
  border-radius: var(--radius-sm);
}

.preview-image-wrapper:hover .preview-overlay {
  opacity: 1;
}

.preview-fullscreen-icon {
  font-size: 32px;
  color: white;
}

.preview-fullscreen-text {
  color: white;
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-semibold);
}

.meta {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  margin-top: 8px;
}

/* 全屏预览模态框 */
.fullscreen-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.95);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  cursor: pointer;
}

.fullscreen-content-wrapper {
  position: relative;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px 20px;
}

.fullscreen-scroll-container {
  width: 100%;
  max-width: 95vw;
  max-height: calc(100vh - 100px);
  overflow: auto;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  cursor: default;
  /* 自定义滚动条 */
  scrollbar-width: thin;
  scrollbar-color: rgba(255, 255, 255, 0.3) transparent;
}

.fullscreen-scroll-container::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

.fullscreen-scroll-container::-webkit-scrollbar-track {
  background: transparent;
}

.fullscreen-scroll-container::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.3);
  border-radius: 4px;
}

.fullscreen-scroll-container::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.5);
}

.fullscreen-image {
  max-width: 100%;
  width: auto;
  height: auto;
  border-radius: var(--radius-md);
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
  margin: auto;
}

.fullscreen-close {
  position: absolute;
  top: 10px;
  right: 20px;
  width: 44px;
  height: 44px;
  background: rgba(255, 255, 255, 0.2);
  border: 2px solid rgba(255, 255, 255, 0.5);
  border-radius: var(--radius-full);
  color: white;
  font-size: 24px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s;
  backdrop-filter: blur(10px);
  z-index: 10;
}

.fullscreen-close:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
}

.fullscreen-hint {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  color: rgba(255, 255, 255, 0.7);
  font-size: var(--font-size-small);
  background: rgba(0, 0, 0, 0.5);
  padding: 8px 16px;
  border-radius: var(--radius-full);
  backdrop-filter: blur(10px);
  pointer-events: none;
  white-space: nowrap;
}

/* 模态框动画 */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-fade-enter-active .fullscreen-image,
.modal-fade-leave-active .fullscreen-image {
  transition: transform 0.3s ease;
}

.modal-fade-enter-from .fullscreen-image {
  transform: scale(0.9);
}

.modal-fade-leave-to .fullscreen-image {
  transform: scale(0.9);
}
</style>
