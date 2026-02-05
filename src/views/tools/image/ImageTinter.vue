<template>
  <ToolLayout
    icon="🎨"
    title="图片/图标变色工具"
    description="主要对纯色图标或图片进行着色（TintColor），支持自定义颜色与实时预览导出"
  >
    <div class="form-section">
      <h2>上传图片</h2>
      <ImageUploader
        v-model="originalFile"
        icon="🖼️"
        text="点击或拖拽图片到此处"
        hint="建议上传透明背景的 PNG 图标"
        preview-title="📷 原图预览"
        @change="handleImageChange"
        @delete="handleImageDelete"
      />
    </div>

    <div v-if="originalImage" class="form-section">
      <h2>变色设置</h2>
      <div class="controls-grid">
        <div class="form-group">
          <label for="colorPicker">选择颜色</label>
          <div class="color-picker-wrapper">
            <input
              type="color"
              id="colorPicker"
              v-model="tintColor"
              @input="applyTint"
            />
            <input
              type="text"
              v-model="tintColor"
              @input="applyTint"
              placeholder="#000000"
              class="hex-input"
            />
          </div>
        </div>
      </div>
    </div>

    <div v-if="processedPreviewUrl" class="form-section preview-section">
      <h2>预览与导出</h2>
      <div class="preview-grid">
        <div class="preview-card">
          <div class="preview-title">原图</div>
          <div class="preview-image-wrapper" @click="openFullscreen(originalPreviewUrl)">
            <img :src="originalPreviewUrl" class="preview-image-thumb" alt="原图预览" />
            <div class="preview-overlay">
              <span class="preview-fullscreen-icon">🔍</span>
            </div>
          </div>
        </div>
        <div class="preview-card">
          <div class="preview-title">变色后</div>
          <div class="preview-image-wrapper" @click="openFullscreen(processedPreviewUrl)">
            <img :src="processedPreviewUrl" class="preview-image-thumb" alt="变色预览" />
            <div class="preview-overlay">
              <span class="preview-fullscreen-icon">🔍</span>
            </div>
          </div>
        </div>
      </div>
      <ButtonGroup style="margin-top: 15px;">
        <AppButton variant="success" icon="⬇️" @click="downloadImage">下载图片</AppButton>
        <AppButton variant="secondary" icon="🔄" @click="resetState">重新选择</AppButton>
      </ButtonGroup>
    </div>

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
import { ref } from 'vue'
import { loadImage } from '@/utils/common'
import ToolLayout from '@/components/ToolLayout.vue'

const originalFile = ref(null)
const originalImage = ref(null)
const originalPreviewUrl = ref('')

const tintColor = ref('#FF0000')
const processedBlob = ref(null)
const processedPreviewUrl = ref('')

const showFullscreenModal = ref(false)
const fullscreenImageUrl = ref('')

async function handleImageChange(file) {
  if (!file) return
  try {
    const img = await loadImage(file)
    originalImage.value = img
    originalPreviewUrl.value = URL.createObjectURL(file)
    applyTint()
  } catch (err) {
    console.error('Image load failed:', err)
  }
}

function handleImageDelete() {
  resetState()
}

function resetState() {
  if (originalPreviewUrl.value) URL.revokeObjectURL(originalPreviewUrl.value)
  if (processedPreviewUrl.value) URL.revokeObjectURL(processedPreviewUrl.value)
  
  originalFile.value = null
  originalImage.value = null
  originalPreviewUrl.value = ''
  processedBlob.value = null
  processedPreviewUrl.value = ''
  // tintColor.value = '#FF0000' // keep color
}

function applyTint() {
  if (!originalImage.value) return

  const canvas = document.createElement('canvas')
  const ctx = canvas.getContext('2d')
  const img = originalImage.value

  canvas.width = img.width
  canvas.height = img.height

  // Draw original image
  ctx.drawImage(img, 0, 0)

  // Composite operation to tint non-transparent pixels
  ctx.globalCompositeOperation = 'source-in'
  ctx.fillStyle = tintColor.value
  ctx.fillRect(0, 0, canvas.width, canvas.height)

  canvas.toBlob(blob => {
    if (processedPreviewUrl.value) URL.revokeObjectURL(processedPreviewUrl.value)
    processedBlob.value = blob
    processedPreviewUrl.value = URL.createObjectURL(blob)
  }, 'image/png')
}

function downloadImage() {
  if (!processedBlob.value) return
  const url = URL.createObjectURL(processedBlob.value)
  const a = document.createElement('a')
  a.href = url
  a.download = `tinted_${Date.now()}.png`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

function openFullscreen(url) {
  fullscreenImageUrl.value = url
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

.controls-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 15px;
}

.color-picker-wrapper {
  display: flex;
  align-items: center;
  gap: 10px;
}

.color-picker-wrapper input[type="color"] {
  width: 50px;
  height: 40px;
  padding: 0;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  background: none;
}

.hex-input {
  flex: 1;
  padding: var(--spacing-sm);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  background: var(--color-surface);
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
  display: flex;
  align-items: center;
  justify-content: center;
}

.preview-image-thumb {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  border-radius: var(--radius-sm);
  transition: transform 0.3s;
}

.preview-image-wrapper:hover .preview-image-thumb {
  transform: scale(1.05);
}

.preview-overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
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
</style>
