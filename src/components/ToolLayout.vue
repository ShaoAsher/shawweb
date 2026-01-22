<template>
  <div class="tool-container" ref="containerRef">
    <div class="header">
      <router-link 
        to="/" 
        ref="homeBtnRef"
        class="home-btn btn-ripple" 
        title="返回首页"
      >
        <span class="home-btn-icon">🏠</span>
      </router-link>
      <div class="header-content">
        <h1 
          ref="titleRef"
          class="header-title" 
          style="color: #FFFFFF !important;"
        >
          <span 
            ref="iconRef"
            class="header-icon" 
            style="color: #FFFFFF !important;"
          >
            {{ icon }}
          </span>
          <span style="color: #FFFFFF !important;">{{ title }}</span>
        </h1>
        <p 
          ref="descRef"
          class="header-desc" 
          v-if="description" 
          style="color: #FFFFFF !important;"
        >
          {{ description }}
        </p>
      </div>
    </div>
    <div class="content">
      <div ref="contentRef" class="content-inner" :key="title">
        <slot></slot>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { gsap } from 'gsap'

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
const homeBtnRef = ref(null)
const iconRef = ref(null)
const titleRef = ref(null)
const descRef = ref(null)
const contentRef = ref(null)

onMounted(() => {
  nextTick(() => {
    // 获取实际DOM元素
    const homeBtnEl = homeBtnRef.value?.$el || homeBtnRef.value
    
    // 确保所有元素初始状态正确
    if (homeBtnEl) {
      gsap.set(homeBtnEl, { opacity: 1, clearProps: 'all' })
    }
    
    // GSAP 动画时间线
    const tl = gsap.timeline()
    
    // 1. 容器淡入上滑
    tl.from(containerRef.value, {
      opacity: 0,
      y: 50,
      duration: 0.6,
      ease: 'power2.out'
    })
    
    // 2. 图标旋转进入
    if (iconRef.value) {
      tl.from(iconRef.value, {
        opacity: 0,
        rotation: -180,
        duration: 0.6,
        ease: 'back.out(1.7)'
      }, '-=0.5')
    }
    
    // 3. 标题淡入
    if (titleRef.value) {
      tl.from(titleRef.value, {
        opacity: 0,
        y: -20,
        duration: 0.5
      }, '-=0.5')
    }
    
    // 4. 描述淡入
    if (descRef.value) {
      tl.from(descRef.value, {
        opacity: 0,
        duration: 0.5
      }, '-=0.4')
    }
    
    // 5. 内容区域淡入
    if (contentRef.value) {
      tl.from(contentRef.value, {
        opacity: 0,
        y: 20,
        duration: 0.5
      }, '-=0.3')
    }
    
    // 添加悬停动画 - 使用实际DOM元素
    if (homeBtnEl) {
      homeBtnEl.addEventListener('mouseenter', () => {
        gsap.to(homeBtnEl, {
          y: -3,
          duration: 0.3,
          ease: 'power2.out'
        })
      })
      
      homeBtnEl.addEventListener('mouseleave', () => {
        gsap.to(homeBtnEl, {
          y: 0,
          duration: 0.3,
          ease: 'power2.out'
        })
      })
    }
    
    // 图标摇摆动画
    if (iconRef.value) {
      iconRef.value.addEventListener('mouseenter', () => {
        gsap.to(iconRef.value, {
          rotation: 10,
          duration: 0.2,
          yoyo: true,
          repeat: 3,
          ease: 'power2.inOut'
        })
      })
    }
  })
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
  color: #ffffff !important;
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
  color: #ffffff !important;
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
  width: 50px;
  height: 50px;
  background: #ffffff;
  border: none;
  border-radius: var(--radius-full);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #667eea;
  text-decoration: none;
  font-size: 24px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 10;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15), 0 0 0 0 rgba(102, 126, 234, 0.4);
  overflow: hidden;
  animation: homeBtnPulse 2s ease-in-out infinite;
}

@keyframes homeBtnPulse {
  0%, 100% {
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15), 0 0 0 0 rgba(102, 126, 234, 0.4);
  }
  50% {
    box-shadow: 0 4px 25px rgba(0, 0, 0, 0.2), 0 0 0 8px rgba(102, 126, 234, 0.2);
  }
}

.home-btn::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: var(--radius-full);
  padding: 2px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask-composite: exclude;
  opacity: 0;
  transition: opacity 0.3s;
}

.home-btn-icon {
  transition: transform 0.3s;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
}

.home-btn:hover {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
  transform: scale(1.15) rotate(-5deg);
  box-shadow: 0 6px 30px rgba(102, 126, 234, 0.4);
  animation: none;
}

.home-btn:hover::before {
  opacity: 1;
}

.home-btn:hover .home-btn-icon {
  animation: homeIconBounce 0.6s ease;
}

@keyframes homeIconBounce {
  0%, 100% { transform: scale(1) rotate(0deg); }
  25% { transform: scale(1.2) rotate(-10deg); }
  75% { transform: scale(1.2) rotate(10deg); }
}

.home-btn:active {
  transform: scale(1.05) rotate(-5deg);
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
