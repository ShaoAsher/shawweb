<template>
  <ThemeToggle />
  <router-view v-slot="{ Component, route }">
    <transition 
      :name="route.meta.transition || 'page'" 
      mode="out-in"
      @before-enter="onBeforeEnter"
      @after-leave="onAfterLeave"
    >
      <component :is="Component" :key="route.path" />
    </transition>
  </router-view>
</template>

<script setup>
import { initTheme } from './utils/themes.js'
import './assets/css/theme.css'
import './assets/css/animations.css'
import ThemeToggle from './components/ThemeToggle.vue'

// 初始化主题
initTheme()

// 页面过渡钩子
function onBeforeEnter(el) {
  el.style.willChange = 'opacity, transform'
}

function onAfterLeave(el) {
  el.style.willChange = 'auto'
}
</script>

<style>
/* ========== 基础重置 ========== */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* ========== 全局主题过渡 ========== */
*,
*::before,
*::after {
  transition-property: background-color, border-color, color, fill, stroke, box-shadow;
  transition-duration: 0.2s;
  transition-timing-function: ease-out;
}

/* 排除需要精确控制的元素 */
input,
textarea,
select,
button,
a,
.no-transition {
  transition-property: none;
}

/* 为交互元素恢复特定过渡 */
input,
textarea,
select {
  transition: border-color 0.2s, box-shadow 0.2s;
}

button,
a {
  transition: transform 0.2s, box-shadow 0.2s, background-color 0.2s, color 0.2s, border-color 0.2s;
}

/* ========== Body 基础样式 ========== */
body {
  font-family: var(--font-family);
  background: var(--color-background);
  color: var(--color-text);
  min-height: 100vh;
  padding: 20px;
  overflow-x: hidden;
  font-size: var(--font-size-base);
  line-height: var(--line-height);
}

/* ========== 页面切换动画 ========== */

/* 默认页面过渡 - 淡入淡出 + 滑动 */
.page-enter-active,
.page-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.page-enter-from {
  opacity: 0;
  transform: translateY(20px);
}

.page-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* 淡入淡出过渡 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.25s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* 滑动过渡 - 从右进入 */
.slide-right-enter-active,
.slide-right-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.slide-right-enter-from {
  opacity: 0;
  transform: translateX(30px);
}

.slide-right-leave-to {
  opacity: 0;
  transform: translateX(-30px);
}

/* 滑动过渡 - 从左进入 */
.slide-left-enter-active,
.slide-left-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.slide-left-enter-from {
  opacity: 0;
  transform: translateX(-30px);
}

.slide-left-leave-to {
  opacity: 0;
  transform: translateX(30px);
}

/* 缩放过渡 */
.scale-enter-active,
.scale-leave-active {
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.scale-enter-from,
.scale-leave-to {
  opacity: 0;
  transform: scale(0.95);
}

/* ========== 滚动条美化 ========== */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: var(--color-surface-alt);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb {
  background: var(--color-border);
  border-radius: 4px;
  transition: background 0.2s;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--color-text-light);
}

/* Firefox 滚动条 */
* {
  scrollbar-width: thin;
  scrollbar-color: var(--color-border) var(--color-surface-alt);
}

/* ========== 选中文本样式 ========== */
::selection {
  background: var(--color-primary);
  color: var(--color-text-on-primary);
}

::-moz-selection {
  background: var(--color-primary);
  color: var(--color-text-on-primary);
}

/* ========== 焦点轮廓优化 ========== */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}

:focus:not(:focus-visible) {
  outline: none;
}

/* ========== 无障碍：减少动画 ========== */
@media (prefers-reduced-motion: reduce) {
  .page-enter-active,
  .page-leave-active,
  .fade-enter-active,
  .fade-leave-active,
  .slide-right-enter-active,
  .slide-right-leave-active,
  .slide-left-enter-active,
  .slide-left-leave-active,
  .scale-enter-active,
  .scale-leave-active {
    transition-duration: 0.01ms !important;
  }
}
</style>
