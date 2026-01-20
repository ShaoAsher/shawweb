<template>
  <button
    ref="btnRef"
    :class="buttonClasses"
    :disabled="disabled || loading"
    :type="type"
    @click="handleClick"
  >
    <!-- 入场光效 -->
    <span class="btn-shine"></span>
    <span v-if="loading" class="btn-loader">
      <span class="btn-spinner"></span>
    </span>
    <span v-if="icon && !loading" class="btn-icon">{{ icon }}</span>
    <span v-if="$slots.default" class="btn-text"><slot /></span>
  </button>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'

const btnRef = ref(null)
const hasPlayedShine = ref(false)

const props = defineProps({
  variant: {
    type: String,
    default: 'primary'
  },
  size: {
    type: String,
    default: 'md'
  },
  disabled: {
    type: Boolean,
    default: false
  },
  loading: {
    type: Boolean,
    default: false
  },
  icon: {
    type: String,
    default: ''
  },
  block: {
    type: Boolean,
    default: false
  },
  rounded: {
    type: Boolean,
    default: false
  },
  iconOnly: {
    type: Boolean,
    default: false
  },
  type: {
    type: String,
    default: 'button'
  }
})

const emit = defineEmits(['click'])

const buttonClasses = computed(() => [
  'app-btn',
  `app-btn--${props.variant}`,
  `app-btn--${props.size}`,
  {
    'app-btn--block': props.block,
    'app-btn--rounded': props.rounded,
    'app-btn--icon-only': props.iconOnly,
    'app-btn--loading': props.loading,
    'app-btn--disabled': props.disabled
  }
])

function handleClick(event) {
  if (!props.disabled && !props.loading) {
    emit('click', event)
  }
}

// 入场光效 - 只播放一次
onMounted(() => {
  if (btnRef.value && !hasPlayedShine.value) {
    hasPlayedShine.value = true
    btnRef.value.classList.add('btn-mounted')
  }
})
</script>

<style scoped>
/* ========== 基础样式 ========== */
.app-btn {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  font-family: inherit;
  font-weight: 500;
  text-decoration: none;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  overflow: hidden;
  white-space: nowrap;
  user-select: none;
  -webkit-tap-highlight-color: transparent;
  /* 禁用所有变换和过渡，避免点击变大 */
  transform: none !important;
  transition: none;
}

/* ========== 尺寸 ========== */
.app-btn--sm {
  padding: 6px 14px;
  font-size: 13px;
  min-height: 32px;
  border-radius: 6px;
}

.app-btn--md {
  padding: 10px 20px;
  font-size: 14px;
  min-height: 40px;
}

.app-btn--lg {
  padding: 14px 28px;
  font-size: 16px;
  min-height: 48px;
}

/* ========== Primary 变体 ========== */
.app-btn--primary {
  background: linear-gradient(135deg, var(--color-primary, #667eea) 0%, var(--color-primary-dark, #5a67d8) 100%);
  color: #fff !important;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.app-btn--primary:hover:not(:disabled) {
  filter: brightness(1.05);
}

.app-btn--primary:active:not(:disabled) {
  filter: brightness(0.95);
}

.app-btn--primary * {
  color: #fff !important;
}

/* ========== Secondary 变体 ========== */
.app-btn--secondary {
  background: var(--color-surface-alt, #f5f5f5);
  color: var(--color-text, #333);
  border: 1px solid var(--color-border, #e0e0e0);
}

.app-btn--secondary:hover:not(:disabled) {
  background: var(--color-hover, #ebebeb);
  border-color: var(--color-primary, #667eea);
  color: var(--color-primary, #667eea);
}

/* ========== Success 变体 ========== */
.app-btn--success {
  background: linear-gradient(135deg, var(--color-success, #10b981) 0%, #059669 100%);
  color: #fff !important;
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
}

.app-btn--success:hover:not(:disabled) {
  filter: brightness(1.05);
}

.app-btn--success:active:not(:disabled) {
  filter: brightness(0.95);
}

.app-btn--success * {
  color: #fff !important;
}

/* ========== Danger 变体 ========== */
.app-btn--danger {
  background: linear-gradient(135deg, var(--color-error, #ef4444) 0%, #dc2626 100%);
  color: #fff !important;
  box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3);
}

.app-btn--danger:hover:not(:disabled) {
  filter: brightness(1.05);
}

.app-btn--danger:active:not(:disabled) {
  filter: brightness(0.95);
}

.app-btn--danger * {
  color: #fff !important;
}

/* ========== Warning 变体 ========== */
.app-btn--warning {
  background: linear-gradient(135deg, var(--color-warning, #f59e0b) 0%, #d97706 100%);
  color: #fff !important;
  box-shadow: 0 2px 8px rgba(245, 158, 11, 0.3);
}

.app-btn--warning:hover:not(:disabled) {
  filter: brightness(1.05);
}

.app-btn--warning:active:not(:disabled) {
  filter: brightness(0.95);
}

.app-btn--warning * {
  color: #fff !important;
}

/* ========== Info 变体 ========== */
.app-btn--info {
  background: linear-gradient(135deg, var(--color-info, #3b82f6) 0%, #2563eb 100%);
  color: #fff !important;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
}

.app-btn--info:hover:not(:disabled) {
  filter: brightness(1.05);
}

.app-btn--info:active:not(:disabled) {
  filter: brightness(0.95);
}

.app-btn--info * {
  color: #fff !important;
}

/* ========== Ghost 变体 ========== */
.app-btn--ghost {
  background: transparent;
  color: var(--color-primary, #667eea);
  border: 1px solid var(--color-primary, #667eea);
  box-shadow: none;
}

.app-btn--ghost:hover:not(:disabled) {
  background: var(--color-primary, #667eea);
  color: #fff !important;
}

/* ========== Link 变体 ========== */
.app-btn--link {
  background: transparent;
  color: var(--color-primary, #667eea);
  padding-left: 0;
  padding-right: 0;
  box-shadow: none;
}

.app-btn--link:hover:not(:disabled) {
  color: var(--color-primary-dark, #5a67d8);
  text-decoration: underline;
}

/* ========== 状态 ========== */
.app-btn--disabled,
.app-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.app-btn--block {
  width: 100%;
}

.app-btn--rounded {
  border-radius: 50px;
}

.app-btn--icon-only {
  padding: 0;
  width: 36px;
  height: 36px;
}

.app-btn--icon-only.app-btn--sm {
  width: 30px;
  height: 30px;
}

.app-btn--icon-only.app-btn--lg {
  width: 44px;
  height: 44px;
}

/* ========== 子元素 ========== */
.btn-icon {
  display: inline-flex;
  font-size: 1em;
  line-height: 1;
}

.btn-text {
  line-height: 1.2;
}

/* ========== 加载状态 ========== */
.app-btn--loading {
  pointer-events: none;
}

.app-btn--loading .btn-text {
  opacity: 0.7;
}

.btn-loader {
  display: inline-flex;
  margin-right: 4px;
}

.btn-spinner {
  width: 14px;
  height: 14px;
  border: 2px solid currentColor;
  border-top-color: transparent;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* ========== 入场光效 - 只在初次渲染时播放一次 ========== */
.btn-shine {
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(255, 255, 255, 0.4) 50%,
    transparent 100%
  );
  transform: skewX(-25deg);
  pointer-events: none;
  opacity: 0;
}

.btn-mounted .btn-shine {
  animation: shine 0.6s ease-out forwards;
}

@keyframes shine {
  0% {
    left: -100%;
    opacity: 1;
  }
  100% {
    left: 100%;
    opacity: 0;
  }
}

/* secondary/ghost/link 不显示光效 */
.app-btn--secondary .btn-shine,
.app-btn--ghost .btn-shine,
.app-btn--link .btn-shine {
  display: none;
}

/* ========== 主题适配 ========== */
:global(body[data-theme="cyberpunk"]) .app-btn--primary {
  box-shadow: 0 0 12px var(--color-shadow-primary, rgba(102, 126, 234, 0.5));
}

:global(body[data-theme="minimal"]) .app-btn--primary {
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}

/* ========== 响应式 ========== */
@media (max-width: 640px) {
  .app-btn--md {
    padding: 8px 16px;
  }
  
  .app-btn--lg {
    padding: 12px 24px;
  }
}

/* ========== 减少动画 ========== */
@media (prefers-reduced-motion: reduce) {
  .btn-spinner {
    animation: none;
  }
  
  .btn-shine {
    display: none;
  }
}
</style>
