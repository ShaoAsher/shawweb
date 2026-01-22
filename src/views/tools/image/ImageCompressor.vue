<template>
  <ToolLayout
    icon="🗜️"
    title="图片压缩工具"
    description="智能压缩图片，保持比例与清晰度，支持预览对比与多格式导出"
  >
    <div class="form-section">
      <h2>上传图片</h2>
      
      <!-- 使用统一的 ImageUploader 组件 -->
      <ImageUploader
        v-model="originalFile"
        icon="🖼️"
        text="点击或拖拽图片到此处"
        hint="支持 JPG、PNG、WEBP"
        preview-title="📷 已选择的图片"
        @change="handleImageChange"
        @delete="handleImageDelete"
      />
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

    <!-- 使用统一的 ImagePreview 组件（仅全屏模式） -->
    <ImagePreview
      :show="showFullscreenModal"
      :src="fullscreenImageUrl"
      title="图片预览"
      fullscreen-only
      @close="closeFullscreen"
    />
  </ToolLayout>
</template>

<script setup>
import { computed, ref } from 'vue'
import { loadImage } from '@/utils/common'
import ToolLayout from '@/components/ToolLayout.vue'

const originalFile = ref(null)
const originalImage = ref(null)
const originalPreviewUrl = ref('')
const originalMeta = ref('-')
const compressedBlob = ref(null)
const compressedPreviewUrl = ref('')
const compressedMeta = ref('-')
const compressedExt = ref('jpg')
const showPreview = ref(false)
const compressing = ref(false)
const showFullscreenModal = ref(false)
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

async function handleImageChange(file) {
  if (!file) return
  
  try {
    const img = await loadImage(file)
    originalImage.value = img
    originalPreviewUrl.value = URL.createObjectURL(file)
    const sizeKB = (file.size / 1024).toFixed(2)
    originalMeta.value = `尺寸: ${img.width}×${img.height} | 大小: ${sizeKB} KB`
    showPreview.value = false
  } catch (err) {
    console.error('图片加载失败:', err)
  }
}

function handleImageDelete() {
  resetState()
}

function resetState() {
  if (originalPreviewUrl.value) {
    URL.revokeObjectURL(originalPreviewUrl.value)
  }
  if (compressedPreviewUrl.value) {
    URL.revokeObjectURL(compressedPreviewUrl.value)
  }
  
  originalFile.value = null
  originalImage.value = null
  originalPreviewUrl.value = ''
  originalMeta.value = '-'
  compressedBlob.value = null
  compressedPreviewUrl.value = ''
  compressedMeta.value = '-'
  compressedExt.value = 'jpg'
  showPreview.value = false
}

function getAutoFormat(img, originalType) {
  const hasAlpha = detectAlpha(img)
  if (hasAlpha) return 'png'
  if (originalType && originalType.includes('png')) return 'png'
  return 'jpeg'
}

function detectAlpha(img) {
  const c = document.createElement('canvas')
  c.width = img.width
  c.height = img.height
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
    const ow = img.width
    const oh = img.height
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
      fmt = getAutoFormat(img, originalFile.value ? originalFile.value.type : null)
    }

    const targetBytes = targetSizeKB.value > 0 ? targetSizeKB.value * 1024 : 0
    let result

    if (fmt === 'png') {
      const pngBlob = await toBlobAsync(c, 'image/png')
      if (!pngBlob) throw new Error('生成图片失败')

      if (targetBytes > 0 && pngBlob.size > targetBytes) {
        const webpRes = await tryBinary(c, 'image/webp', 'webp')
        result = { blob: webpRes.blob, ext: webpRes.ext, width: tw, height: th }
      } else {
        result = { blob: pngBlob, ext: 'png', width: tw, height: th }
      }
    } else if (fmt === 'jpeg') {
      const jpgRes = await tryBinary(c, 'image/jpeg', 'jpg')
      if (targetBytes > 0 && jpgRes.blob.size > targetBytes) {
        const webpRes = await tryBinary(c, 'image/webp', 'webp')
        if (webpRes.blob.size < jpgRes.blob.size) {
          result = { blob: webpRes.blob, ext: webpRes.ext, width: tw, height: th }
        } else {
          result = { blob: jpgRes.blob, ext: jpgRes.ext, width: tw, height: th }
        }
      } else {
        result = { blob: jpgRes.blob, ext: jpgRes.ext, width: tw, height: th }
      }
    } else if (fmt === 'webp') {
      const webpRes = await tryBinary(c, 'image/webp', 'webp')
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
    console.error('压缩失败:', err)
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
  showFullscreenModal.value = true
}

function closeFullscreen() {
  showFullscreenModal.value = false
  fullscreenImageUrl.value = ''
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
  font-weight: var(--font-weight-semibold);
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

.meta {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  margin-top: 8px;
}
</style>
