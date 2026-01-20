<template>
  <div class="tool-container" ref="containerRef">
    <div class="header">
      <router-link to="/" class="home-btn btn-ripple" title="返回首页">
        <span class="home-btn-icon">🏠</span>
      </router-link>
      <div class="header-content">
        <h1 class="header-title">
          <span class="header-icon">{{ icon }}</span>
          <span>{{ title }}</span>
        </h1>
        <p class="header-desc" v-if="description">{{ description }}</p>
      </div>
    </div>
    <div class="content">
      <transition name="content-fade" mode="out-in" appear>
        <div class="content-inner" :key="title">
          <slot></slot>
        </div>
      </transition>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

defineProps({
  icon: {
    type: String,
    default: '🔧'
  },
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    default: ''
  }
})

const containerRef = ref(null)

onMounted(() => {
  // 页面加载完成后添加入场动画类
  if (containerRef.value) {
    containerRef.value.classList.add('mounted')
  }
})
</script>

<style scoped>
/* ========== 容器入场动画 ========== */
.tool-container {
  max-width: 1400px;
  margin: 0 auto;
  background: var(--color-surface);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-xl);
  overflow: hidden;
  border: 1px solid var(--color-border);
  opacity: 0;
  transform: translateY(20px);
  animation: containerEnter 0.5s ease-out forwards;
}

@keyframes containerEnter {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ========== Header 样式和动画 ========== */
.header {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  padding: var(--spacing-xxl) var(--spacing-xl);
  text-align: center;
  position: relative;
  overflow: hidden;
}

/* Header 背景动画效果 */
.header::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 60%);
  animation: headerShine 10s ease-in-out infinite;
  pointer-events: none;
}

@keyframes headerShine {
  0%, 100% {
    transform: translate(0, 0);
  }
  50% {
    transform: translate(25%, 25%);
  }
}

.header-content {
  position: relative;
  z-index: 1;
}

.header-title {
  font-size: var(--font-size-xlarge);
  font-weight: var(--font-weight-bold);
  margin-bottom: var(--spacing-sm);
  text-shadow: 0 2px 10px rgba(0, 0, 0, .2);
  color: var(--color-text-on-primary);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-sm);
  animation: titleEnter 0.6s ease-out 0.1s both;
}

.header-icon {
  display: inline-block;
  animation: iconFloat 3s ease-in-out infinite;
}

@keyframes iconFloat {
  0%, 100% {
    transform: translateY(0) rotate(0deg);
  }
  50% {
    transform: translateY(-5px) rotate(5deg);
  }
}

.header-desc {
  opacity: 0;
  font-size: var(--font-size-small);
  color: var(--color-text-on-primary);
  animation: descEnter 0.6s ease-out 0.2s both;
}

@keyframes titleEnter {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes descEnter {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 0.95;
    transform: translateY(0);
  }
}

/* ========== 返回按钮 ========== */
.home-btn {
  position: absolute;
  top: var(--spacing-lg);
  left: var(--spacing-lg);
  width: 44px;
  height: 44px;
  background: rgba(255, 255, 255, 0.15);
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: var(--radius-full);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-text-on-primary);
  text-decoration: none;
  font-size: var(--font-size-large);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 10;
  backdrop-filter: blur(10px);
  overflow: hidden;
}

.home-btn-icon {
  transition: transform 0.3s;
}

.home-btn:hover {
  background: rgba(255, 255, 255, 0.25);
  border-color: rgba(255, 255, 255, 0.5);
  transform: scale(1.1);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.home-btn:hover .home-btn-icon {
  animation: homeIconPulse 0.5s ease;
}

@keyframes homeIconPulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
}

.home-btn:active {
  transform: scale(0.95);
}

/* ========== 内容区域 ========== */
.content {
  padding: var(--spacing-xl);
  background: var(--color-surface);
  color: var(--color-text);
  min-height: 300px;
}

.content-inner {
  animation: contentEnter 0.4s ease-out;
}

@keyframes contentEnter {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ========== 内容过渡动画 ========== */
.content-fade-enter-active,
.content-fade-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.content-fade-enter-from {
  opacity: 0;
  transform: translateY(15px);
}

.content-fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* ========== 主题特定效果 ========== */

/* 赛博朋克主题 */
:global(body[data-theme="cyberpunk"]) .tool-container,
:global(body.cyberpunk) .tool-container {
  box-shadow: var(--shadow-xl), 0 0 30px var(--color-shadow-primary);
}

:global(body[data-theme="cyberpunk"]) .header,
:global(body.cyberpunk) .header {
  text-shadow: 0 0 10px var(--color-shadow-primary);
}

:global(body[data-theme="cyberpunk"]) .home-btn:hover,
:global(body.cyberpunk) .home-btn:hover {
  box-shadow: 0 0 20px var(--color-shadow-primary);
}

/* 现代简约主题 */
:global(body[data-theme="modern"]) .header,
:global(body.modern) .header {
  text-shadow: 0 2px 15px rgba(0, 0, 0, 0.3);
}

/* ========== 响应式 ========== */
@media (max-width: 768px) {
  .header {
    padding: var(--spacing-xl) var(--spacing-lg);
  }

  .header-title {
    font-size: var(--font-size-large);
    flex-direction: column;
    gap: var(--spacing-xs);
  }

  .home-btn {
    width: 36px;
    height: 36px;
    font-size: var(--font-size-base);
    top: var(--spacing-md);
    left: var(--spacing-md);
  }

  .content {
    padding: var(--spacing-lg);
  }
}

/* ========== 无障碍：减少动画 ========== */
@media (prefers-reduced-motion: reduce) {
  .tool-container {
    animation: none;
    opacity: 1;
    transform: none;
  }

  .header::before {
    animation: none;
  }

  .header-icon {
    animation: none;
  }

  .header-title,
  .header-desc {
    animation: none;
    opacity: 1;
  }

  .content-inner {
    animation: none;
  }

  .home-btn:hover .home-btn-icon {
    animation: none;
  }
}
</style>
