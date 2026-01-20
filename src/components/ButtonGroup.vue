<template>
  <div :class="groupClasses">
    <slot />
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  // 方向：horizontal, vertical
  direction: {
    type: String,
    default: 'horizontal'
  },
  // 间距：sm, md, lg
  gap: {
    type: String,
    default: 'md'
  },
  // 对齐：start, center, end, between, around
  align: {
    type: String,
    default: 'start'
  },
  // 是否换行
  wrap: {
    type: Boolean,
    default: true
  }
})

const groupClasses = computed(() => [
  'btn-group-wrapper',
  `btn-group--${props.direction}`,
  `btn-group--gap-${props.gap}`,
  `btn-group--align-${props.align}`,
  {
    'btn-group--wrap': props.wrap
  }
])
</script>

<style scoped>
.btn-group-wrapper {
  display: flex;
}

.btn-group--horizontal {
  flex-direction: row;
}

.btn-group--vertical {
  flex-direction: column;
}

.btn-group--gap-sm {
  gap: 8px;
}

.btn-group--gap-md {
  gap: 12px;
}

.btn-group--gap-lg {
  gap: 16px;
}

.btn-group--align-start {
  justify-content: flex-start;
}

.btn-group--align-center {
  justify-content: center;
}

.btn-group--align-end {
  justify-content: flex-end;
}

.btn-group--align-between {
  justify-content: space-between;
}

.btn-group--align-around {
  justify-content: space-around;
}

.btn-group--wrap {
  flex-wrap: wrap;
}

@media (max-width: 640px) {
  .btn-group--horizontal {
    flex-direction: column;
  }
  
  .btn-group--horizontal :deep(.app-btn) {
    width: 100%;
  }
}
</style>
