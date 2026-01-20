<template>
  <ToolLayout
    icon="📋"
    title="JSON 格式化工具"
    description="JSON 格式化、压缩、验证和可视化预览，支持语法高亮和实时验证。"
  >
    <ButtonGroup>
      <AppButton variant="primary" icon="✨" @click="formatJSON">格式化</AppButton>
      <AppButton variant="secondary" icon="✓" @click="validateJSON">验证</AppButton>
      <AppButton variant="info" icon="📋" @click="copyJSON">复制结果</AppButton>
      <AppButton variant="danger" icon="🗑️" @click="clearJSON">清空</AppButton>
    </ButtonGroup>

    <div class="editor-container">
      <div class="editor-section">
        <h2>
          <span>编辑区域</span>
          <span class="status" :class="{ valid: isValid }">{{ editStatus }}</span>
        </h2>
        <textarea
          v-model="jsonInput"
          placeholder='请输入 JSON 内容，例如：&#10;{&#10;  "name": "示例",&#10;  "age": 25,&#10;  "items": [1, 2, 3]&#10;}'
          @input="handleInput"
        ></textarea>
        <div class="stats" v-if="inputStats">
          <div class="stat-item">
            <strong>字符数:</strong> {{ inputStats.chars }}
          </div>
          <div class="stat-item">
            <strong>行数:</strong> {{ inputStats.lines }}
          </div>
        </div>
      </div>

      <div class="editor-section">
        <h2>
          <span>预览区域</span>
          <span class="status valid">{{ previewStatus }}</span>
        </h2>
        <div class="preview-section" v-html="jsonPreview"></div>
        <div class="stats" v-if="outputStats">
          <div class="stat-item">
            <strong>字符数:</strong> {{ outputStats.chars }}
          </div>
          <div class="stat-item">
            <strong>行数:</strong> {{ outputStats.lines }}
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import ToolLayout from '@/components/ToolLayout.vue'
import { useToast } from '@/composables/useToast'

const toast = useToast()

const jsonInput = ref('')
const jsonPreview = ref('<div style="color: var(--color-text-secondary); text-align: center; padding: var(--spacing-xl);">格式化后的 JSON 将显示在这里</div>')
const editStatus = ref('未验证')
const previewStatus = ref('就绪')
const isValid = ref(false)
const inputStats = ref(null)
const outputStats = ref(null)
let validateTimer = null

const exampleJSON = {
  "name": "JSON 格式化工具",
  "version": "1.0.0",
  "features": ["格式化", "验证", "预览"],
  "author": {
    "name": "开发者",
    "email": "dev@example.com"
  },
  "numbers": [1, 2, 3, 4, 5],
  "active": true,
  "metadata": null
}

function formatJSON() {
  const input = jsonInput.value.trim()
  if (!input) {
    toast.warning('请输入 JSON 内容')
    return
  }

  try {
    const parsed = JSON.parse(input)
    const formatted = JSON.stringify(parsed, null, 2)
    jsonInput.value = formatted
    displayPreview(parsed)
    updateStatus(true)
    updateStats(input, formatted)
    toast.success('JSON 格式化成功！')
  } catch (e) {
    showError(e.message)
    updateStatus(false)
    toast.error('JSON 格式错误', e.message)
  }
}

function validateJSON() {
  const input = jsonInput.value.trim()
  if (!input) {
    toast.warning('请输入 JSON 内容')
    return
  }

  try {
    const parsed = JSON.parse(input)
    displayPreview(parsed)
    updateStatus(true)
    toast.success('JSON 格式正确！')
  } catch (e) {
    showError(e.message)
    updateStatus(false)
    toast.error('JSON 格式错误', e.message)
  }
}

function displayPreview(parsedObj) {
  const html = renderJSON(parsedObj, 0)
  jsonPreview.value = html
  previewStatus.value = '已格式化'

  setTimeout(() => {
    bindCollapseEvents()
  }, 0)
}

function renderJSON(obj, indent = 0) {
  const indentStr = '&nbsp;'.repeat(indent * 2)
  const nextIndent = indent + 1
  const nextIndentStr = '&nbsp;'.repeat(nextIndent * 2)

  if (obj === null) {
    return `<span class="json-null">null</span>`
  }

  if (typeof obj === 'string') {
    return `<span class="json-string">"${escapeHtml(obj)}"</span>`
  }

  if (typeof obj === 'number') {
    return `<span class="json-number">${obj}</span>`
  }

  if (typeof obj === 'boolean') {
    return `<span class="json-boolean">${obj}</span>`
  }

  if (Array.isArray(obj)) {
    if (obj.length === 0) {
      return `[]`
    }
    const id = 'arr_' + Math.random().toString(36).substr(2, 9)
    let html = `<div>${indentStr}<span class="json-collapsible collapsed" data-id="${id}">[<span class="json-count">${obj.length} items</span>]</span>`
    html += `<div class="json-children" id="${id}" style="display: none;">`
    obj.forEach((item, index) => {
      html += `${nextIndentStr}${renderJSON(item, nextIndent)}`
      if (index < obj.length - 1) html += ','
      html += '<br>'
    })
    html += `${indentStr}]</div></div>`
    return html
  }

  if (typeof obj === 'object') {
    const keys = Object.keys(obj)
    if (keys.length === 0) {
      return `{}`
    }
    const id = 'obj_' + Math.random().toString(36).substr(2, 9)
    let html = `<div>${indentStr}<span class="json-collapsible collapsed" data-id="${id}">{<span class="json-count">${keys.length} keys</span>}</span>`
    html += `<div class="json-children" id="${id}" style="display: none;">`
    keys.forEach((key, index) => {
      html += `${nextIndentStr}<span class="json-key">"${escapeHtml(key)}"</span>: ${renderJSON(obj[key], nextIndent)}`
      if (index < keys.length - 1) html += ','
      html += '<br>'
    })
    html += `${indentStr}}</div></div>`
    return html
  }

  return escapeHtml(String(obj))
}

function bindCollapseEvents() {
  document.querySelectorAll('.json-collapsible').forEach(el => {
    el.addEventListener('click', function () {
      const id = this.dataset.id
      const children = document.getElementById(id)
      if (children) {
        if (this.classList.contains('collapsed')) {
          this.classList.remove('collapsed')
          this.classList.add('expanded')
          children.style.display = 'block'
        } else {
          this.classList.remove('expanded')
          this.classList.add('collapsed')
          children.style.display = 'none'
        }
      }
    })
  })
}

function escapeHtml(text) {
  const div = document.createElement('div')
  div.textContent = text
  return div.innerHTML
}

function showError(message) {
  jsonPreview.value = `<div class="json-error">JSON 格式错误：${escapeHtml(message)}</div>`
  previewStatus.value = '格式错误'
}

function updateStatus(isValidStatus) {
  isValid.value = isValidStatus
  if (isValidStatus) {
    editStatus.value = '格式正确'
  } else {
    editStatus.value = '格式错误'
  }
}

function updateStats(input, output) {
  const inputLength = input.length
  const outputLength = output.length
  const inputLines = input.split('\n').length
  const outputLines = output.split('\n').length

  inputStats.value = {
    chars: inputLength.toLocaleString(),
    lines: inputLines
  }

  outputStats.value = {
    chars: outputLength.toLocaleString(),
    lines: outputLines
  }
}

function copyJSON() {
  const text = jsonInput.value
  if (!text.trim()) {
    toast.warning('没有内容可复制')
    return
  }

  navigator.clipboard.writeText(text).then(() => {
    toast.success('已复制到剪贴板！')
  }).catch(() => {
    const textarea = document.createElement('textarea')
    textarea.value = text
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand('copy')
    document.body.removeChild(textarea)
    toast.success('已复制到剪贴板！')
  })
}

function clearJSON() {
  jsonInput.value = ''
  jsonPreview.value = '<div style="color: var(--color-text-secondary); text-align: center; padding: var(--spacing-xl);">格式化后的 JSON 将显示在这里</div>'
  editStatus.value = '未验证'
  isValid.value = false
  previewStatus.value = '就绪'
  inputStats.value = null
  outputStats.value = null
  toast.info('已清空所有内容')
}

function handleInput() {
  clearTimeout(validateTimer)
  validateTimer = setTimeout(() => {
    const input = jsonInput.value.trim()
    if (input) {
      try {
        JSON.parse(input)
        updateStatus(true)
      } catch (e) {
        updateStatus(false)
      }
    } else {
      editStatus.value = '未验证'
      isValid.value = false
    }
  }, 500)
}

onMounted(() => {
  jsonInput.value = JSON.stringify(exampleJSON, null, 2)
  formatJSON()
})
</script>

<style scoped>
.editor-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-lg);
  margin-bottom: var(--spacing-lg);
}

@media (max-width: 768px) {
  .editor-container {
    grid-template-columns: 1fr;
  }
}

.editor-section {
  background: var(--color-background-alt);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
}

.editor-section h2 {
  font-size: var(--font-size-large);
  color: var(--color-text);
  margin-bottom: var(--spacing-md);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.editor-section h2 .status {
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-normal);
  padding: var(--spacing-xs) var(--spacing-sm);
  border-radius: var(--radius-sm);
  background: var(--color-error);
  color: var(--color-text-on-primary);
}

.editor-section h2 .status.valid {
  background: var(--color-success);
}

textarea {
  width: 100%;
  min-height: 400px;
  padding: var(--spacing-md);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-family: 'Courier New', Consolas, monospace;
  font-size: var(--font-size-small);
  line-height: var(--line-height);
  resize: vertical;
  transition: border-color .3s;
  background: var(--color-surface);
  color: var(--color-text);
}

textarea:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.preview-section {
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  padding: var(--spacing-md);
  min-height: 400px;
  max-height: 600px;
  overflow: auto;
  font-family: 'Courier New', Consolas, monospace;
  font-size: var(--font-size-small);
  line-height: var(--line-height);
  color: var(--color-text);
}

:deep(.json-collapsible) {
  cursor: pointer;
  user-select: none;
}

:deep(.json-collapsible:hover) {
  background: var(--color-hover);
}

:deep(.json-collapsible::before) {
  content: '▶';
  display: inline-block;
  width: 12px;
  margin-right: var(--spacing-xs);
  transition: transform 0.2s;
  color: var(--color-text-secondary);
}

:deep(.json-collapsible.collapsed::before) {
  transform: rotate(0deg);
}

:deep(.json-collapsible.expanded::before) {
  transform: rotate(90deg);
}

:deep(.json-children) {
  margin-left: 20px;
  border-left: 1px solid var(--color-border);
  padding-left: var(--spacing-sm);
}

:deep(.json-collapsible.collapsed + .json-children) {
  display: none;
}

:deep(.json-count) {
  color: var(--color-text-secondary);
  font-size: var(--font-size-small);
  font-weight: normal;
  margin-left: 5px;
}

:deep(.json-key) {
  color: var(--color-primary);
  font-weight: 600;
}

:deep(.json-string) {
  color: var(--color-success);
}

:deep(.json-number) {
  color: var(--color-info);
}

:deep(.json-boolean) {
  color: var(--color-error);
}

:deep(.json-null) {
  color: var(--color-text-secondary);
}

:deep(.json-error) {
  color: var(--color-error);
  background: var(--color-surface-alt);
  padding: var(--spacing-sm);
  border-radius: var(--radius-sm);
  border-left: 3px solid var(--color-error);
}

.btn-group {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border: none;
  padding: 12px 24px;
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
  font-weight: 600;
  cursor: pointer;
  transition: transform .2s;
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 5px 15px var(--color-shadow-primary);
}

.btn-secondary {
  background: linear-gradient(135deg, var(--color-text-secondary) 0%, var(--color-text-light) 100%);
}

.btn-danger {
  background: linear-gradient(135deg, var(--color-error) 0%, var(--color-error) 100%);
}

.stats {
  display: flex;
  gap: 15px;
  margin-top: 15px;
  padding: 10px;
  background: var(--color-surface-alt);
  border-radius: 6px;
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}

.stat-item {
  display: flex;
  gap: 5px;
}

.stat-item strong {
  color: var(--color-text-secondary);
}
</style>
