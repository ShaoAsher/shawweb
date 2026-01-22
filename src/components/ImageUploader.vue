<template>
  <div class="image-uploader">
    <!-- 未选择图片时显示上传区域 -->
    <div
      v-if="!modelValue"
      class="upload-area"
      :class="{ dragover: isDragging }"
      @click="triggerFileInput"
      @dragover.prevent="handleDragOver"
      @dragleave.prevent="handleDragLeave"
      @drop.prevent="handleDrop"
    >
      <div class="upload-icon">{{ icon }}</div>
      <div class="upload-text">{{ text }}</div>
      <div class="upload-hint">{{ hint }}</div>
      <input
        ref="fileInputRef"
        type="file"
        accept="image/*"
        style="display: none"
        @change="handleFileSelect"
      />
    </div>

    <!-- 已选择图片时显示预览 -->
    <div v-else class="image-preview">
      <div class="preview-card">
        <div class="preview-header">
          <div class="preview-title">{{ previewTitle }}</div>
          <AppButton 
            variant="danger" 
            icon="🗑️" 
            size="sm"
            @click="handleDelete"
          >
            删除
          </AppButton>
        </div>
        
        <div 
          class="preview-image-wrapper" 
          @click="openFullscreen"
        >
          <img 
            :src="previewUrl" 
            class="preview-image-thumb" 
            :alt="previewTitle" 
          />
          <div class="preview-overlay">
            <span class="preview-fullscreen-icon">🔍</span>
            <span class="preview-fullscreen-text">点击查看大图</span>
          </div>
        </div>
        
        <div v-if="imageInfo" class="preview-meta">
          {{ imageInfo }}
        </div>
      </div>
    </div>

    <!-- 全屏预览 -->
    <Teleport to="body">
      <transition name="fullscreen-fade">
        <div 
          v-if="showFullscreen" 
          class="fullscreen-modal"
          @click="closeFullscreen"
        >
          <div class="fullscreen-header">
            <div class="fullscreen-title">{{ previewTitle }}</div>
            <button 
              class="fullscreen-close" 
              @click="closeFullscreen"
              title="关闭（ESC）"
            >
              ×
            </button>
          </div>
          <div class="fullscreen-content" @click.stop>
            <div class="fullscreen-scroll">
              <img 
                :src="previewUrl" 
                :alt="previewTitle" 
                class="fullscreen-image" 
              />
            </div>
          </div>
        </div>
      </transition>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed, watch, onUnmounted } from 'vue'
import AppButton from './AppButton.vue'

const props = defineProps({
  modelValue: {
    type: [File, Image, null],
    default: null
  },
  icon: {
    type: String,
    default: '📁'
  },
  text: {
    type: String,
    default: '点击或拖拽图片到此处'
  },
  hint: {
    type: String,
    default: '支持 JPG、PNG、WEBP'
  },
  previewTitle: {
    type: String,
    default: '📷 已选择的图片'
  },
  showInfo: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:modelValue', 'change', 'delete'])

const fileInputRef = ref(null)
const isDragging = ref(false)
const previewUrl = ref(null)
const imageWidth = ref(0)
const imageHeight = ref(0)
const imageSize = ref(0)
const showFullscreen = ref(false)

// 计算图片信息
const imageInfo = computed(() => {
  if (!props.showInfo || !props.modelValue) return ''
  
  const parts = []
  
  if (imageWidth.value && imageHeight.value) {
    parts.push(`${imageWidth.value} × ${imageHeight.value}`)
  }
  
  if (imageSize.value) {
    parts.push(formatFileSize(imageSize.value))
  }
  
  return parts.join(' · ')
})

// 监听modelValue变化，生成预览
watch(() => props.modelValue, async (value) => {
  if (value) {
    if (value instanceof File) {
      // File对象
      previewUrl.value = URL.createObjectURL(value)
      imageSize.value = value.size
      
      // 加载图片获取尺寸
      const img = await loadImage(previewUrl.value)
      imageWidth.value = img.naturalWidth
      imageHeight.value = img.naturalHeight
    } else if (value instanceof Image || value?.src) {
      // Image对象
      previewUrl.value = value.src
      imageWidth.value = value.naturalWidth || value.width
      imageHeight.value = value.naturalHeight || value.height
      imageSize.value = 0
    }
  } else {
    // 清理预览URL
    if (previewUrl.value && previewUrl.value.startsWith('blob:')) {
      URL.revokeObjectURL(previewUrl.value)
    }
    previewUrl.value = null
    imageWidth.value = 0
    imageHeight.value = 0
    imageSize.value = 0
  }
}, { immediate: true })

// 组件卸载时清理
onUnmounted(() => {
  if (previewUrl.value && previewUrl.value.startsWith('blob:')) {
    URL.revokeObjectURL(previewUrl.value)
  }
  // 确保恢复 body 滚动
  if (showFullscreen.value) {
    document.body.style.overflow = ''
  }
})

function triggerFileInput() {
  fileInputRef.value?.click()
}

function handleDragOver() {
  isDragging.value = true
}

function handleDragLeave() {
  isDragging.value = false
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
    emit('error', '请选择图片文件')
    return
  }
  
  emit('update:modelValue', file)
  emit('change', file)
}

function handleDelete() {
  emit('update:modelValue', null)
  emit('delete')
  
  // 清空input
  if (fileInputRef.value) {
    fileInputRef.value.value = ''
  }
}

function openFullscreen() {
  showFullscreen.value = true
  document.body.style.overflow = 'hidden'
}

function closeFullscreen() {
  showFullscreen.value = false
  document.body.style.overflow = ''
}

function loadImage(src) {
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.onload = () => resolve(img)
    img.onerror = reject
    img.src = src
  })
}

function formatFileSize(bytes) {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

// 监听ESC键关闭全屏
if (typeof window !== 'undefined') {
  const handleKeydown = (e) => {
    if (e.key === 'Escape' && showFullscreen.value) {
      closeFullscreen()
    }
  }
  window.addEventListener('keydown', handleKeydown)
  onUnmounted(() => {
    window.removeEventListener('keydown', handleKeydown)
  })
}
</script>

<style scoped>
.image-uploader {
  width: 100%;
}

/* 上传区域 */
.upload-area {
  border: 2px dashed var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--spacing-xxl);
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  background: var(--color-surface-alt);
}

.upload-area:hover,
.upload-area.dragover {
  border-color: var(--color-primary);
  background: var(--color-hover);
  transform: translateY(-2px);
}

.upload-icon {
  font-size: 48px;
  margin-bottom: var(--spacing-md);
  color: var(--color-primary);
}

.upload-text {
  font-size: var(--font-size-base);
  color: var(--color-text);
  margin-bottom: var(--spacing-xs);
  font-weight: var(--font-weight-medium);
}

.upload-hint {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}

/* 预览区域 */
.image-preview {
  width: 100%;
}

.preview-card {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  background: var(--color-surface);
  box-shadow: var(--shadow-sm);
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-md);
}

.preview-title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
}

.preview-image-wrapper {
  position: relative;
  border-radius: var(--radius-sm);
  overflow: hidden;
  cursor: pointer;
  background: var(--color-surface-alt);
  margin-bottom: var(--spacing-md);
}

.preview-image-thumb {
  width: 100%;
  height: auto;
  max-height: 400px;
  object-fit: contain;
  display: block;
  transition: transform 0.3s ease;
}

.preview-image-wrapper:hover .preview-image-thumb {
  transform: scale(1.02);
}

.preview-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s ease;
  color: white;
  gap: var(--spacing-sm);
}

.preview-image-wrapper:hover .preview-overlay {
  opacity: 1;
}

.preview-fullscreen-icon {
  font-size: 32px;
}

.preview-fullscreen-text {
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-medium);
}

.preview-meta {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  text-align: center;
  padding: var(--spacing-xs);
  background: var(--color-surface-alt);
  border-radius: var(--radius-sm);
}

/* 全屏预览 */
.fullscreen-modal {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.95);
  z-index: 9999;
  display: flex;
  flex-direction: column;
}

.fullscreen-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-lg);
  background: rgba(0, 0, 0, 0.8);
  color: white;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  flex-shrink: 0;
}

.fullscreen-title {
  font-size: var(--font-size-large);
  font-weight: var(--font-weight-semibold);
}

.fullscreen-close {
  width: 44px;
  height: 44px;
  border: none;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  font-size: 32px;
  cursor: pointer;
  border-radius: var(--radius-full);
  transition: all 0.3s ease;
  line-height: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

.fullscreen-close:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.1);
}

.fullscreen-content {
  flex: 1;
  overflow: auto;
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding: var(--spacing-lg);
  min-height: 0;
}

.fullscreen-scroll {
  width: 100%;
  max-width: 100%;
  display: flex;
  justify-content: center;
}

.fullscreen-image {
  max-width: 100%;
  height: auto;
  display: block;
  border-radius: var(--radius-sm);
}

/* 过渡动画 */
.fullscreen-fade-enter-active,
.fullscreen-fade-leave-active {
  transition: opacity 0.3s ease;
}

.fullscreen-fade-enter-from,
.fullscreen-fade-leave-to {
  opacity: 0;
}

/* 响应式 */
@media (max-width: 768px) {
  .upload-area {
    padding: var(--spacing-lg);
  }
  
  .upload-icon {
    font-size: 36px;
  }
  
  .preview-card {
    padding: var(--spacing-md);
  }
  
  .fullscreen-header {
    padding: var(--spacing-md);
  }
  
  .fullscreen-title {
    font-size: var(--font-size-base);
  }
  
  .fullscreen-close {
    width: 36px;
    height: 36px;
    font-size: 24px;
  }
  
  .fullscreen-content {
    padding: var(--spacing-md);
  }
}
</style>
