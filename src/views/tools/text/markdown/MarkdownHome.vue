<template>
  <ToolLayout
    icon="📖"
    title="Markdown 编辑器"
    description="导入或粘贴 Markdown，支持编辑、预览、历史与导出"
  >
    <div class="markdown-home">
      <section class="hero">
        <div class="hero-main">
          <div class="hero-title">markdown 编辑器</div>
          <div class="hero-subtitle">一站式导入、编辑、预览和管理 Markdown 文档</div>
          <div class="hero-tags">
            <span class="hero-tag">📁 导入文件</span>
            <span class="hero-tag">📋 导入文字</span>
            <span class="hero-tag">🕒 历史记录</span>
            <span class="hero-tag">🛠️ 编译模式</span>
            <span class="hero-tag">👁️ 预览模式</span>
          </div>
        </div>
      </section>

      <div class="home-layout">
        <div class="panel">
          <div class="panel-header">
            <div class="panel-title">
              <div class="panel-title-main"><span>📥 导入文件与文字</span></div>
              <div class="panel-title-sub">支持拖拽上传 .md/.markdown 文件，或直接粘贴 Markdown 文本</div>
            </div>
            <div class="panel-header-extra">保存后可进入编译/预览模式</div>
          </div>
          <div class="panel-body">
            <div class="import-grid">
              <div>
                <div 
                  class="upload-card" 
                  :class="{ dragover: isDragging }"
                  @click="triggerFileInput"
                  @dragover.prevent="handleDragOver"
                  @dragleave.prevent="handleDragLeave"
                  @drop.prevent="handleDrop"
                >
                  <div class="upload-card-icon">📄</div>
                  <div class="upload-card-title">拖拽 Markdown 文件到此处</div>
                  <div class="upload-card-text">或点击选择本地文件</div>
                  <div class="upload-card-hint">支持 .md /.markdown /.txt</div>
                  <input 
                    ref="fileInput" 
                    type="file" 
                    class="file-input" 
                    accept=".md,.markdown,.txt,text/markdown,text/plain"
                    @change="handleFileSelect"
                  />
                </div>
              </div>
              <div>
                <div style="display:flex;justify-content:space-between;align-items:center;">
                  <span style="font-size:var(--font-size-base);font-weight:var(--font-weight-semibold);">📝 粘贴或输入 Markdown 文本</span>
                  <span class="char-count">{{ charCountText }}</span>
                </div>
                <textarea 
                  v-model="textInput" 
                  class="editor-textarea" 
                  placeholder="在此粘贴或输入 Markdown 文本，将自动保存到历史记录中。"
                  @input="updateCharCount"
                  @paste="handlePaste"
                ></textarea>
                <ButtonGroup gap="sm" class="action-buttons">
                  <AppButton variant="primary" size="sm" icon="⚡" @click="goToCompile">编译模式</AppButton>
                  <AppButton variant="secondary" size="sm" icon="👁️" @click="goToPreview">预览模式</AppButton>
                  <AppButton variant="secondary" size="sm" icon="💾" @click="saveToHistory">保存</AppButton>
                </ButtonGroup>
              </div>
            </div>
          </div>
        </div>

        <div class="panel">
          <div class="panel-header">
            <div class="panel-title">
              <div class="panel-title-main"><span>🕒 历史记录</span></div>
              <div class="panel-title-sub">最近打开的文件与粘贴内容自动保存在本地浏览器</div>
            </div>
            <div class="panel-header-extra">
              <AppButton variant="danger" size="sm" icon="🗑️" @click="clearHistory">清空历史</AppButton>
            </div>
          </div>
          <div class="panel-body">
            <div class="history-list">
              <div v-if="markdownHistory.length === 0" class="history-empty">
                暂无历史记录，导入文件或粘贴文本后将自动出现在这里。
              </div>
              <div 
                v-for="item in markdownHistory" 
                :key="item.id"
                class="history-item"
                @click="openHistoryItem(item, 'preview')"
              >
                <div class="history-main">
                  <div class="history-title-row">
                    <span :class="['history-type', item.type === 'file' ? 'history-type-file' : 'history-type-paste']">
                      {{ item.type === 'file' ? '文件' : '粘贴' }}
                    </span>
                    <span class="history-filename">{{ item.title }}</span>
                  </div>
                  <div class="history-meta">
                    <span>📅 {{ formatDate(item.timestamp) }}</span>
                    <span>📏 {{ formatFileSize(item.size || 0) }}</span>
                  </div>
                </div>
                <div class="history-actions" @click.stop>
                  <button class="history-btn primary" @click="openHistoryItem(item, 'compile')">编译模式</button>
                  <button class="history-btn" @click="openHistoryItem(item, 'preview')">预览模式</button>
                  <button class="history-btn" @click="deleteHistoryItem(item.id)">删除</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const fileInput = ref(null)
const textInput = ref('')
const isDragging = ref(false)
const markdownHistory = ref([])

const charCountText = computed(() => {
  return `${textInput.value.length.toLocaleString()} 字符`
})

function formatFileSize(bytes) {
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
}

function formatDate(timestamp) {
  const date = new Date(timestamp)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function getMarkdownTitle(content) {
  const lines = content.split('\n')
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()
    if (line.startsWith('# ')) return line.substring(2).trim()
    if (line.startsWith('## ')) return line.substring(3).trim()
  }
  return null
}

function updateCharCount() {
  // 字符数通过computed自动更新
}

function handlePaste() {
  setTimeout(() => {
    updateCharCount()
  }, 10)
}

function loadHistory() {
  const saved = localStorage.getItem('markdownHistory')
  if (saved) {
    try {
      const parsed = JSON.parse(saved)
      markdownHistory.value = Array.isArray(parsed) ? parsed : []
    } catch (e) {
      markdownHistory.value = []
    }
  } else {
    markdownHistory.value = []
  }
}

function saveHistory() {
  try {
    if (markdownHistory.value.length > 100) {
      markdownHistory.value = markdownHistory.value.slice(0, 100)
    }
    localStorage.setItem('markdownHistory', JSON.stringify(markdownHistory.value))
  } catch (e) {}
}

function addToHistory(content, fileName, type) {
  if (!content || !content.trim()) return null
  const title = getMarkdownTitle(content) || fileName || '未命名文档'
  const item = {
    id: Date.now(),
    title: title,
    content: content,
    fileName: fileName || null,
    type: type || 'paste',
    timestamp: new Date().toISOString(),
    size: content.length
  }
  markdownHistory.value = markdownHistory.value.filter(h => !(h.content === content && h.fileName === fileName))
  markdownHistory.value.unshift(item)
  saveHistory()
  return item
}

function deleteHistoryItem(id) {
  markdownHistory.value = markdownHistory.value.filter(h => h.id !== id)
  saveHistory()
}

function clearHistory() {
  if (!markdownHistory.value.length) return
  if (!confirm('确定要清空所有历史记录吗？此操作不可恢复！')) return
  markdownHistory.value = []
  saveHistory()
}

function goToMode(mode, content, title) {
  if (!content || !content.trim()) {
    alert('没有可处理的内容')
    return
  }
  const finalTitle = title || getMarkdownTitle(content) || '未命名文档'
  try {
    sessionStorage.setItem('markdownContent', content)
    sessionStorage.setItem('markdownTitle', finalTitle)
    sessionStorage.setItem('markdownMode', mode)
  } catch (e) {}
  if (mode === 'compile') {
    router.push('/tools/text/markdown/compile')
  } else {
    router.push('/tools/text/markdown/preview')
  }
}

function goToCompile() {
  if (!textInput.value || !textInput.value.trim()) {
    alert('请先粘贴或输入 Markdown 内容')
    return
  }
  const item = addToHistory(textInput.value, null, 'paste')
  const title = (item && item.title) || getMarkdownTitle(textInput.value) || '未命名文档'
  goToMode('compile', textInput.value, title)
}

function goToPreview() {
  if (!textInput.value || !textInput.value.trim()) {
    alert('请先粘贴或输入 Markdown 内容')
    return
  }
  const item = addToHistory(textInput.value, null, 'paste')
  const title = (item && item.title) || getMarkdownTitle(textInput.value) || '未命名文档'
  goToMode('preview', textInput.value, title)
}

function saveToHistory() {
  if (!textInput.value || !textInput.value.trim()) {
    alert('没有可保存的内容')
    return
  }
  addToHistory(textInput.value, null, 'paste')
  alert('已保存到历史记录')
}

function openHistoryItem(item, mode) {
  goToMode(mode, item.content, item.title)
}

function triggerFileInput() {
  fileInput.value?.click()
}

function handleDragOver() {
  isDragging.value = true
}

function handleDragLeave() {
  isDragging.value = false
}

function handleDrop(e) {
  isDragging.value = false
  const file = e.dataTransfer?.files?.[0]
  if (file) {
    handleFile(file)
  }
}

function handleFileSelect(e) {
  const file = e.target.files?.[0]
  if (file) {
    handleFile(file)
  }
}

function handleFile(file) {
  if (!file) {
    alert('没有选择文件')
    return
  }
  const fileName = file.name || ''
  const validExt = fileName.match(/\.(md|markdown|txt)$/i)
  if (!validExt) {
    alert('请上传 .md、.markdown 或 .txt 文件')
    return
  }
  const reader = new FileReader()
  reader.onload = function(e) {
    const content = e.target.result || ''
    if (!content.trim()) {
      alert('文件内容为空')
      return
    }
    textInput.value = content
    updateCharCount()
    const item = addToHistory(content, fileName, 'file')
    const title = (item && item.title) || fileName || '未命名文档'
    goToMode('preview', content, title)
  }
  reader.onerror = function() {
    alert('文件读取失败，请重试')
  }
  reader.readAsText(file, 'UTF-8')
}

onMounted(() => {
  loadHistory()
  updateCharCount()
})
</script>

<style scoped>
.markdown-home {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xl);
  min-height: calc(100vh - 40px);
}

.hero {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--spacing-xl);
  padding: var(--spacing-lg) var(--spacing-xl);
  border-radius: var(--radius-lg);
  background: radial-gradient(circle at top left, rgba(102,126,234,0.28), transparent 55%), radial-gradient(circle at bottom right, rgba(118,75,162,0.24), transparent 55%), var(--color-surface);
  border: 1px solid var(--color-border);
}

.hero-main {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-sm);
}

.hero-title {
  font-size: var(--font-size-xlarge);
  font-weight: var(--font-weight-bold);
}

.hero-subtitle {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}

.hero-tags {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-xs);
  margin-top: var(--spacing-sm);
}

.hero-tag {
  padding: 4px 10px;
  border-radius: 999px;
  font-size: var(--font-size-small);
  background: var(--color-surface-alt);
  color: var(--color-text-secondary);
  border: 1px solid rgba(255,255,255,0.04);
}

.home-layout {
  display: grid;
  grid-template-columns: minmax(0, 2fr) minmax(0, 1.4fr);
  gap: var(--spacing-xl);
  align-items: flex-start;
}

@media (max-width: 1024px) {
  .hero {
    flex-direction: column;
    align-items: flex-start;
  }
  .home-layout {
    grid-template-columns: 1fr;
  }
}

.panel {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  border: 1px solid var(--color-border);
  box-shadow: var(--shadow-sm);
  display: flex;
  flex-direction: column;
  min-height: 0;
  overflow: hidden;
}

.panel-header {
  padding: var(--spacing-md) var(--spacing-lg);
  border-bottom: 1px solid var(--color-border);
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--spacing-md);
}

.panel-title {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.panel-title-main {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
}

.panel-title-sub {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}

.panel-header-extra {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  white-space: nowrap;
}

.panel-body {
  padding: var(--spacing-lg);
  display: flex;
  flex-direction: column;
  gap: var(--spacing-lg);
}

.import-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.1fr) minmax(0, 1.4fr);
  gap: var(--spacing-lg);
  align-items: stretch;
}

@media (max-width: 1024px) {
  .import-grid {
    grid-template-columns: 1fr;
  }
}

.upload-card {
  border-radius: var(--radius-md);
  border: 1px dashed var(--color-border);
  padding: var(--spacing-xl);
  background: var(--color-surface-alt);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-sm);
  cursor: pointer;
  transition: all 0.25s;
  text-align: center;
  position: relative;
  overflow: hidden;
}

.upload-card:hover {
  border-color: var(--color-primary);
  background: var(--color-hover);
  transform: translateY(-1px);
  box-shadow: var(--shadow-md);
}

.upload-card.dragover {
  border-color: var(--color-primary);
  background: var(--color-hover);
}

.upload-card-icon {
  font-size: 40px;
  margin-bottom: var(--spacing-xs);
}

.upload-card-title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
}

.upload-card-text {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}

.upload-card-hint {
  margin-top: var(--spacing-xs);
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  opacity: 0.9;
}

.file-input {
  display: none;
}

.editor-textarea {
  width: 100%;
  min-height: 220px;
  padding: var(--spacing-md);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  font-family: 'Courier New', Consolas, monospace;
  font-size: var(--font-size-base);
  line-height: 1.6;
  background: var(--color-surface);
  color: var(--color-text);
  resize: vertical;
  transition: all 0.3s;
}

.editor-textarea:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.char-count {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}

.action-buttons {
  display: flex;
  gap: var(--spacing-md);
  margin-top: var(--spacing-md);
  flex-wrap: wrap;
}

.btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border: none;
  padding: var(--spacing-sm) var(--spacing-xl);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  cursor: pointer;
  transition: all 0.2s;
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.btn-secondary {
  background: var(--color-surface-alt);
  color: var(--color-text-on-surface-alt);
  border: 1px solid var(--color-border);
}

.btn-secondary:hover {
  background: var(--color-hover);
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-sm);
  max-height: 520px;
  overflow-y: auto;
}

.history-empty {
  padding: var(--spacing-lg);
  border-radius: var(--radius-md);
  background: var(--color-surface-alt);
  color: var(--color-text-secondary);
  font-size: var(--font-size-small);
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--spacing-md);
  padding: var(--spacing-md);
  border-radius: var(--radius-md);
  background: var(--color-surface-alt);
  border: 1px solid var(--color-border);
  cursor: pointer;
  transition: all 0.18s;
}

.history-item:hover {
  transform: translateY(-1px);
  border-color: var(--color-primary);
  box-shadow: var(--shadow-sm);
  background: var(--color-hover);
}

.history-main {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.history-title-row {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  font-size: var(--font-size-small);
}

.history-type {
  padding: 2px 6px;
  border-radius: 999px;
  font-size: 10px;
  font-weight: var(--font-weight-semibold);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.history-type-file {
  background: var(--color-primary);
  color: var(--color-text-on-primary);
}

.history-type-paste {
  background: var(--color-success);
  color: var(--color-text-on-primary);
}

.history-filename {
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.history-meta {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  display: flex;
  gap: var(--spacing-md);
  flex-wrap: wrap;
}

.history-actions {
  display: flex;
  gap: var(--spacing-xs);
  align-items: center;
}

.history-btn {
  position: relative;
  border: none;
  border-radius: var(--radius-sm);
  padding: 4px 10px;
  font-size: var(--font-size-small);
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  transition: all 0.18s;
  background: var(--color-surface);
  color: var(--color-text-secondary);
  overflow: hidden;
}

.history-btn.primary {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: #fff !important;
  box-shadow: 0 2px 8px var(--color-shadow-primary);
}

/* 入场光效 */
.history-btn.primary::before {
  content: '';
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
  animation: btn-shine 0.8s ease-out 0.2s forwards;
}

@keyframes btn-shine {
  0% { left: -100%; }
  100% { left: 100%; }
}

.history-btn:hover {
  background: var(--color-hover);
}

.history-btn.primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px var(--color-shadow-primary);
}
</style>