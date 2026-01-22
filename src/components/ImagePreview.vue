<template>
  <div class="image-preview" :class="{ fullscreen: isFullscreen }">
    <!-- 普通预览 -->
    <div v-if="!isFullscreen && !fullscreenOnly" class="preview-container">
      <div
        v-if="src"
        class="preview-wrapper"
        :class="{ clickable: allowFullscreen }"
        @click="openFullscreen"
      >
        <img :src="src" :alt="alt" class="preview-image" />
        <div v-if="allowFullscreen" class="preview-overlay">
          <span class="fullscreen-icon">🔍</span>
          <span class="fullscreen-text">点击查看大图</span>
        </div>
      </div>
      <div v-else class="preview-empty">
        <div class="empty-icon">🖼️</div>
        <div class="empty-text">暂无图片</div>
      </div>
      
      <!-- 图片信息 -->
      <div v-if="showInfo && src" class="preview-info">
        <slot name="info">
          <div v-if="width && height" class="info-item">
            <span class="info-label">尺寸:</span>
            <span class="info-value">{{ width }} × {{ height }}</span>
          </div>
          <div v-if="size" class="info-item">
            <span class="info-label">大小:</span>
            <span class="info-value">{{ formatSize(size) }}</span>
          </div>
        </slot>
      </div>
    </div>

    <!-- 全屏预览 -->
    <Teleport to="body">
      <transition name="fullscreen-fade">
        <div v-if="isFullscreen" class="fullscreen-modal" @click="closeFullscreen">
          <div class="fullscreen-header">
            <div class="fullscreen-title">{{ title || '图片预览' }}</div>
            <button class="fullscreen-close" @click="closeFullscreen" title="关闭">×</button>
          </div>
          <div class="fullscreen-content" @click.stop>
            <div class="fullscreen-scroll">
              <img :src="src" :alt="alt" class="fullscreen-image" />
            </div>
          </div>
        </div>
      </transition>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  src: {
    type: String,
    default: ''
  },
  alt: {
    type: String,
    default: '图片预览'
  },
  title: {
    type: String,
    default: ''
  },
  width: {
    type: [Number, String],
    default: null
  },
  height: {
    type: [Number, String],
    default: null
  },
  size: {
    type: Number,
    default: null
  },
  allowFullscreen: {
    type: Boolean,
    default: true
  },
  showInfo: {
    type: Boolean,
    default: true
  },
  fullscreenOnly: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['fullscreen-open', 'fullscreen-close'])

const isFullscreen = ref(false)

// 监听 show prop 的变化
watch(() => props.show, (newVal) => {
  if (newVal && props.fullscreenOnly) {
    isFullscreen.value = true
    document.body.style.overflow = 'hidden'
  } else if (!newVal) {
    isFullscreen.value = false
    document.body.style.overflow = ''
  }
})

function openFullscreen() {
  if (!props.allowFullscreen || !props.src) return
  isFullscreen.value = true
  document.body.style.overflow = 'hidden'
  emit('fullscreen-open')
}

function closeFullscreen() {
  isFullscreen.value = false
  document.body.style.overflow = ''
  emit('fullscreen-close')
}

function formatSize(bytes) {
  if (!bytes) return ''
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

// 监听ESC键关闭全屏
function handleKeydown(e) {
  if (e.key === 'Escape' && isFullscreen.value) {
    closeFullscreen()
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
  // 确保恢复 body 滚动
  if (isFullscreen.value) {
    document.body.style.overflow = ''
  }
})
</script>

<style scoped>
.image-preview {
  width: 100%;
}

.preview-container {
  width: 100%;
}

.preview-wrapper {
  position: relative;
  border-radius: var(--radius-md);
  overflow: hidden;
  background: var(--color-surface-alt);
  aspect-ratio: 16 / 9;
  display: flex;
  align-items: center;
  justify-content: center;
}

.preview-wrapper.clickable {
  cursor: pointer;
}

.preview-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  transition: transform 0.3s;
}

.preview-wrapper.clickable:hover .preview-image {
  transform: scale(1.02);
}

.preview-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
  color: white;
  gap: var(--spacing-sm);
}

.preview-wrapper.clickable:hover .preview-overlay {
  opacity: 1;
}

.fullscreen-icon {
  font-size: 32px;
}

.fullscreen-text {
  font-size: var(--font-size-small);
}

.preview-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-xxl);
  background: var(--color-surface-alt);
  border-radius: var(--radius-md);
  color: var(--color-text-light);
}

.empty-icon {
  font-size: 48px;
  margin-bottom: var(--spacing-md);
  opacity: 0.5;
}

.empty-text {
  font-size: var(--font-size-small);
}

.preview-info {
  display: flex;
  gap: var(--spacing-md);
  margin-top: var(--spacing-sm);
  padding: var(--spacing-sm) var(--spacing-md);
  background: var(--color-surface-alt);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
}

.info-item {
  display: flex;
  gap: var(--spacing-xs);
}

.info-label {
  color: var(--color-text-secondary);
}

.info-value {
  color: var(--color-text);
  font-weight: var(--font-weight-medium);
}

/* 全屏模态框 */
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
}

.fullscreen-title {
  font-size: var(--font-size-large);
  font-weight: var(--font-weight-medium);
}

.fullscreen-close {
  width: 40px;
  height: 40px;
  border: none;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  font-size: 28px;
  cursor: pointer;
  border-radius: var(--radius-full);
  transition: all 0.3s;
  line-height: 1;
}

.fullscreen-close:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.1);
}

.fullscreen-content {
  flex: 1;
  overflow: auto;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-lg);
}

.fullscreen-scroll {
  max-width: 100%;
  max-height: 100%;
}

.fullscreen-image {
  max-width: 100%;
  height: auto;
  display: block;
  margin: 0 auto;
}

/* 过渡动画 */
.fullscreen-fade-enter-active,
.fullscreen-fade-leave-active {
  transition: opacity 0.3s;
}

.fullscreen-fade-enter-from,
.fullscreen-fade-leave-to {
  opacity: 0;
}

/* 响应式 */
@media (max-width: 768px) {
  .fullscreen-header {
    padding: var(--spacing-md);
  }
  
  .fullscreen-content {
    padding: var(--spacing-md);
  }
  
  .fullscreen-title {
    font-size: var(--font-size-base);
  }
}
</style>
