<template>
  <div
    class="file-uploader"
    :class="{ 'has-file': modelValue, dragover: isDragging }"
  >
    <!-- 上传区域 -->
    <div
      v-if="!modelValue"
      class="upload-area"
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
        :accept="accept"
        :multiple="multiple"
        style="display: none"
        @change="handleFileSelect"
      />
    </div>

    <!-- 文件预览区域 -->
    <div v-else class="file-preview">
      <slot name="preview" :file="modelValue" :clear="clearFile">
        <!-- 默认预览 -->
        <div class="preview-card">
          <div class="preview-header">
            <div class="preview-title">
              <span class="preview-icon">📄</span>
              <span>{{ modelValue.name }}</span>
            </div>
            <button class="preview-close" @click="clearFile" title="删除">×</button>
          </div>
          <div v-if="previewUrl && isImage" class="preview-image">
            <img :src="previewUrl" :alt="modelValue.name" />
          </div>
          <div class="preview-info">
            <span>大小: {{ formatFileSize(modelValue.size) }}</span>
            <span v-if="modelValue.type">类型: {{ modelValue.type }}</span>
          </div>
        </div>
      </slot>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: [File, null],
    default: null
  },
  accept: {
    type: String,
    default: '*/*'
  },
  multiple: {
    type: Boolean,
    default: false
  },
  icon: {
    type: String,
    default: '📁'
  },
  text: {
    type: String,
    default: '点击或拖拽文件到此处'
  },
  hint: {
    type: String,
    default: '支持所有文件格式'
  },
  maxSize: {
    type: Number,
    default: 10 * 1024 * 1024 // 10MB
  }
})

const emit = defineEmits(['update:modelValue', 'change', 'error'])

const fileInputRef = ref(null)
const isDragging = ref(false)
const previewUrl = ref(null)

const isImage = computed(() => {
  return props.modelValue?.type?.startsWith('image/')
})

// 监听文件变化，生成预览URL
watch(() => props.modelValue, (file) => {
  if (file && isImage.value) {
    previewUrl.value = URL.createObjectURL(file)
  } else {
    if (previewUrl.value) {
      URL.revokeObjectURL(previewUrl.value)
    }
    previewUrl.value = null
  }
}, { immediate: true })

function triggerFileInput() {
  fileInputRef.value?.click()
}

function handleFileSelect(event) {
  const files = event.target.files
  if (files.length > 0) {
    handleFiles(files)
  }
}

function handleDragOver() {
  isDragging.value = true
}

function handleDragLeave() {
  isDragging.value = false
}

function handleDrop(event) {
  isDragging.value = false
  const files = event.dataTransfer.files
  if (files.length > 0) {
    handleFiles(files)
  }
}

function handleFiles(files) {
  const file = files[0]
  
  // 验证文件大小
  if (file.size > props.maxSize) {
    emit('error', {
      type: 'size',
      message: `文件大小不能超过 ${formatFileSize(props.maxSize)}`
    })
    return
  }
  
  // 验证文件类型
  if (props.accept !== '*/*' && !validateFileType(file)) {
    emit('error', {
      type: 'type',
      message: '不支持的文件类型'
    })
    return
  }
  
  emit('update:modelValue', file)
  emit('change', file)
}

function validateFileType(file) {
  const acceptTypes = props.accept.split(',').map(t => t.trim())
  return acceptTypes.some(type => {
    if (type.startsWith('.')) {
      return file.name.endsWith(type)
    }
    if (type.endsWith('/*')) {
      return file.type.startsWith(type.replace('/*', ''))
    }
    return file.type === type
  })
}

function clearFile() {
  if (previewUrl.value) {
    URL.revokeObjectURL(previewUrl.value)
    previewUrl.value = null
  }
  if (fileInputRef.value) {
    fileInputRef.value.value = ''
  }
  emit('update:modelValue', null)
  emit('change', null)
}

function formatFileSize(bytes) {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}
</script>

<style scoped>
.file-uploader {
  width: 100%;
}

.upload-area {
  border: 2px dashed var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--spacing-xl);
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  background: var(--color-surface-alt);
}

.upload-area:hover,
.upload-area.dragover {
  border-color: var(--color-primary);
  background: var(--color-hover);
}

.upload-icon {
  font-size: 48px;
  margin-bottom: var(--spacing-md);
}

.upload-text {
  font-size: var(--font-size-base);
  color: var(--color-text);
  margin-bottom: var(--spacing-xs);
}

.upload-hint {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}

.file-preview {
  width: 100%;
}

.preview-card {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--spacing-md);
  background: var(--color-surface);
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-md);
}

.preview-title {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text);
}

.preview-icon {
  font-size: 20px;
}

.preview-close {
  background: var(--color-error);
  color: white;
  border: none;
  width: 28px;
  height: 28px;
  border-radius: var(--radius-full);
  cursor: pointer;
  font-size: 20px;
  line-height: 1;
  transition: all 0.3s;
}

.preview-close:hover {
  transform: scale(1.1);
}

.preview-image {
  margin-bottom: var(--spacing-md);
  border-radius: var(--radius-sm);
  overflow: hidden;
}

.preview-image img {
  width: 100%;
  height: auto;
  max-height: 300px;
  object-fit: contain;
}

.preview-info {
  display: flex;
  gap: var(--spacing-md);
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}
</style>
