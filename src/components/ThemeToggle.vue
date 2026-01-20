<template>
  <div class="theme-toggle-wrapper">
    <button 
      class="theme-toggle-btn" 
      title="切换主题"
      @click="openThemeModal"
    >
      <span class="theme-toggle-icon">🎨</span>
    </button>

    <Teleport to="body">
      <transition name="modal">
        <div v-if="showModal" class="theme-modal-overlay" @click.self="closeThemeModal">
          <div class="theme-modal-content">
            <div class="theme-modal-header">
              <h2 class="theme-modal-title">🎨 选择主题</h2>
              <button class="theme-modal-close" @click="closeThemeModal">×</button>
            </div>
            <div class="theme-list">
              <div
                v-for="theme in themes"
                :key="theme.key"
                class="theme-item"
                :class="{ active: currentTheme === theme.key }"
                @click="selectTheme(theme.key)"
              >
                <div 
                  class="theme-item-preview"
                  :style="{ background: theme.data?.colors?.background }"
                >
                  <span v-if="currentTheme === theme.key" class="preview-check">✓</span>
                </div>
                <div class="theme-item-info">
                  <div class="theme-item-name">
                    {{ theme.name?.zh || theme.name?.en || theme.key }}
                  </div>
                  <div class="theme-item-desc">
                    {{ getThemeDescription(theme.key) }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </transition>
    </Teleport>
  </div>
</template>

<script setup>
import { getThemes, setTheme } from '@/utils/themes.js'
import { onMounted, onUnmounted, ref } from 'vue'

const showModal = ref(false)
const currentTheme = ref(localStorage.getItem('theme') || 'purple')
const themes = getThemes()

function getThemeDescription(key) {
  const descriptions = {
    purple: '优雅的紫色渐变',
    cyberpunk: '炫酷的霓虹风格',
    light: '清新明亮的浅色',
    modern: '简洁现代的设计',
    alipay: '支付宝经典蓝',
    wechat: '微信清新绿'
  }
  return descriptions[key] || ''
}

function openThemeModal() {
  showModal.value = true
  document.body.style.overflow = 'hidden'
}

function closeThemeModal() {
  showModal.value = false
  document.body.style.overflow = ''
}

function selectTheme(key) {
  currentTheme.value = key
  setTheme(key)
  closeThemeModal()
}

function handleKeydown(e) {
  if (e.key === 'Escape' && showModal.value) {
    closeThemeModal()
  }
}

onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
  document.body.style.overflow = ''
})
</script>

<style scoped>
.theme-toggle-wrapper {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 1000;
}

.theme-toggle-btn {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 20px var(--color-shadow-primary),
              0 2px 8px rgba(0, 0, 0, 0.1);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.theme-toggle-btn:hover {
  transform: scale(1.1) rotate(15deg);
  box-shadow: 0 6px 25px var(--color-shadow-primary),
              0 4px 12px rgba(0, 0, 0, 0.15);
}

.theme-toggle-btn:active {
  transform: scale(1) rotate(0deg);
}

.theme-toggle-icon {
  font-size: 22px;
  line-height: 1;
}

/* 弹窗遮罩 */
.theme-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 20px;
}

/* 弹窗内容 */
.theme-modal-content {
  background: var(--color-surface);
  border-radius: var(--radius-xl);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  width: 100%;
  max-width: 500px;
  max-height: 80vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.theme-modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px;
  border-bottom: 1px solid var(--color-border);
}

.theme-modal-title {
  font-size: 20px;
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin: 0;
}

.theme-modal-close {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: none;
  background: var(--color-surface-alt);
  color: var(--color-text-secondary);
  font-size: 24px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.theme-modal-close:hover {
  background: var(--color-error);
  color: #fff;
}

/* 主题列表 */
.theme-list {
  padding: 16px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.theme-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  border-radius: var(--radius-lg);
  border: 2px solid transparent;
  background: var(--color-surface-alt);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.theme-item:hover {
  background: var(--color-hover);
  transform: translateX(4px);
}

.theme-item.active {
  border-color: var(--color-primary);
  background: var(--color-hover);
}

.theme-item-preview {
  width: 48px;
  height: 48px;
  border-radius: var(--radius-md);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  flex-shrink: 0;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.preview-check {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.95);
  color: var(--color-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  font-size: 14px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
}

.theme-item-info {
  flex: 1;
}

.theme-item-name {
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: 4px;
}

.theme-item-desc {
  font-size: 13px;
  color: var(--color-text-secondary);
}

/* 弹窗动画 */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-active .theme-modal-content,
.modal-leave-active .theme-modal-content {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .theme-modal-content {
  transform: scale(0.9) translateY(20px);
  opacity: 0;
}

.modal-leave-to .theme-modal-content {
  transform: scale(0.9) translateY(-20px);
  opacity: 0;
}

/* 赛博朋克主题 */
:global(body[data-theme="cyberpunk"]) .theme-toggle-btn {
  box-shadow: 0 0 20px var(--color-shadow-primary),
              0 0 40px var(--color-shadow-primary);
}

:global(body[data-theme="cyberpunk"]) .theme-toggle-btn:hover {
  box-shadow: 0 0 30px var(--color-shadow-primary),
              0 0 60px var(--color-shadow-primary);
}

/* 响应式 */
@media (max-width: 640px) {
  .theme-toggle-wrapper {
    top: 12px;
    right: 12px;
  }
  
  .theme-toggle-btn {
    width: 42px;
    height: 42px;
  }
  
  .theme-toggle-icon {
    font-size: 18px;
  }
  
  .theme-modal-content {
    max-height: 90vh;
  }
}
</style>
