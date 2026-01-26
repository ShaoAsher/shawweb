<template>
  <ToolLayout
    icon="📝"
    title="HTML 富文本编辑器"
    description="支持 HTML 编辑、实时预览和 HTML 转字符串功能"
  >
    <div class="html-editor">
      <div class="action-bar">
        <div class="action-group">
          <span class="topbar-title"><span>📝</span><span>HTML 富文本编辑器</span></span>
        </div>
        <div class="action-group">
          <button class="toolbar-btn" @click="copyContent"><span>📋</span><span>复制</span></button>
          <button class="toolbar-btn" @click="copyPreview"><span>📄</span><span>复制预览</span></button>
          <button class="toolbar-btn" @click="htmlToString"><span>📝</span><span>HTML转字符串</span></button>
          <button class="toolbar-btn" @click="stringToHtml"><span>🔄</span><span>还原HTML</span></button>
          <button class="toolbar-btn" @click="clearContent"><span>🗑️</span><span>清空</span></button>
          <button class="toolbar-btn" @click="downloadHtml"><span>💾</span><span>导出 HTML</span></button>
        </div>
      </div>
      <div class="editor-preview-wrapper">
        <div class="editor-section">
          <div class="section-header">
            <span>编辑区</span>
            <span class="char-count">{{ charCountText }}</span>
          </div>
          <div class="editor-shortcuts-bar">
            <div class="editor-shortcuts">
              <button class="toolbar-btn tooltip" data-tooltip="一级标题" @click="insertTag('h1')">H1</button>
              <button class="toolbar-btn tooltip" data-tooltip="二级标题" @click="insertTag('h2')">H2</button>
              <button class="toolbar-btn tooltip" data-tooltip="三级标题" @click="insertTag('h3')">H3</button>
              <button class="toolbar-btn tooltip" data-tooltip="段落" @click="insertTag('p')">P</button>
              <button class="toolbar-btn tooltip" data-tooltip="粗体" @click="insertTag('strong')">𝐁</button>
              <button class="toolbar-btn tooltip" data-tooltip="斜体" @click="insertTag('em')">𝐼</button>
              <button class="toolbar-btn tooltip" data-tooltip="链接" @click="insertTag('a')">🔗</button>
              <button class="toolbar-btn tooltip" data-tooltip="插入图片（可选择文件）" @click="insertImage">🖼️</button>
              <input 
                ref="imageInputRef"
                type="file" 
                accept="image/*" 
                style="display: none"
                @change="handleImageSelect"
              />
              <button class="toolbar-btn tooltip" data-tooltip="行内代码" @click="insertTag('code')">ᐸᐳ</button>
              <button class="toolbar-btn tooltip" data-tooltip="无序列表" @click="insertTag('ul')">•</button>
              <button class="toolbar-btn tooltip" data-tooltip="有序列表" @click="insertTag('ol')">1.</button>
              <button class="toolbar-btn tooltip" data-tooltip="表格" @click="insertTag('table')">▦</button>
              <button class="toolbar-btn tooltip" data-tooltip="容器" @click="insertTag('div')">□</button>
              <button class="toolbar-btn tooltip" data-tooltip="换行" @click="insertTag('br')">↵</button>
            </div>
          </div>
          <textarea 
            ref="editorRef"
            v-model="editorContent"
            class="editor-textarea" 
            placeholder="在此输入 HTML 内容..."
            @input="handleInput"
            @keydown="handleKeydown"
          ></textarea>
        </div>
        <div class="preview-section">
          <div class="section-header">
            <span>预览区</span>
            <button class="preview-toggle-btn" @click="togglePreviewMode">
              {{ previewMode === 'iframe' ? '🔲' : '📄' }} {{ previewMode === 'iframe' ? '内联预览' : 'iframe预览' }}
            </button>
          </div>
          <div v-if="previewMode === 'iframe'" class="preview-iframe-wrapper">
            <iframe 
              ref="previewIframeRef"
              class="preview-iframe"
              sandbox="allow-same-origin"
            ></iframe>
          </div>
          <div v-else ref="previewRef" class="preview-content" v-html="previewHtml"></div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { computed, nextTick, onMounted, ref, watch } from 'vue'

const editorRef = ref(null)
const previewRef = ref(null)
const previewIframeRef = ref(null)
const imageInputRef = ref(null)
const editorContent = ref('')
const previewMode = ref('inline') // 'inline' 或 'iframe'
const originalHtml = ref('') // 保存原始 HTML，用于还原

// 撤销/重做历史记录
const history = ref([])
const historyIndex = ref(-1)
const maxHistorySize = 50

const charCountText = computed(() => {
  return `${editorContent.value.length.toLocaleString()} 字符`
})

const previewHtml = computed(() => {
  if (!editorContent.value.trim()) {
    return '<div style="color:var(--color-text-secondary);font-style:italic;padding:20px;">预览内容将显示在这里...</div>'
  }
  return editorContent.value
})

// 更新预览
function updatePreview() {
  if (previewMode.value === 'iframe' && previewIframeRef.value) {
    const iframe = previewIframeRef.value
    const doc = iframe.contentDocument || iframe.contentWindow.document
    doc.open()
    doc.write(`
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            padding: 20px;
            line-height: 1.6;
            color: #333;
            max-width: 100%;
            margin: 0;
          }
          img { max-width: 100%; height: auto; }
          table { border-collapse: collapse; width: 100%; }
          table th, table td { border: 1px solid #ddd; padding: 8px; }
          table th { background-color: #f2f2f2; }
          code { background: #f5f5f5; padding: 2px 6px; border-radius: 4px; }
          pre { background: #f5f5f5; padding: 15px; border-radius: 8px; overflow-x: auto; }
          pre code { background: transparent; padding: 0; }
        </style>
      </head>
      <body>
        ${editorContent.value}
      </body>
      </html>
    `)
    doc.close()
  }
}

watch([editorContent, previewMode], () => {
  updatePreview()
})

// 处理输入事件
function handleInput() {
  updatePreview()
  // 输入时延迟添加到历史记录
  if (handleInput.saveTimeout) {
    clearTimeout(handleInput.saveTimeout)
  }
  handleInput.saveTimeout = setTimeout(() => {
    addToHistory()
  }, 500)
}

// 插入图片（打开文件选择器）
function insertImage() {
  if (imageInputRef.value) {
    imageInputRef.value.click()
  }
}

// 处理图片文件选择
function handleImageSelect(event) {
  const file = event.target.files?.[0]
  if (!file) return
  
  // 检查文件类型
  if (!file.type.startsWith('image/')) {
    alert('请选择图片文件')
    return
  }
  
  // 添加到历史记录
  addToHistory()
  
  // 使用文件名作为图片路径（相对路径）
  const imagePath = `./images/${file.name}`
  const alt = file.name.replace(/\.[^/.]+$/, '') // 使用文件名（不含扩展名）作为 alt
  
  // 插入图片标签
  if (!editorRef.value) return
  
  const textarea = editorRef.value
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  
  const imgTag = `<img src="${imagePath}" alt="${alt}" />`
  const newText = editorContent.value.substring(0, start) + imgTag + editorContent.value.substring(end)
  editorContent.value = newText
  
  nextTick(() => {
    const newPos = start + imgTag.length
    textarea.setSelectionRange(newPos, newPos)
    textarea.focus()
  })
  
  // 清空 input，以便可以再次选择同一文件
  event.target.value = ''
}

// 插入 HTML 标签
function insertTag(tag) {
  if (!editorRef.value) return
  
  // 添加到历史记录
  addToHistory()
  
  const textarea = editorRef.value
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  const selected = editorContent.value.substring(start, end)
  
  let insert = ''
  const templates = {
    h1: '<h1>标题</h1>',
    h2: '<h2>标题</h2>',
    h3: '<h3>标题</h3>',
    p: '<p>段落内容</p>',
    strong: '<strong>粗体文本</strong>',
    em: '<em>斜体文本</em>',
    a: '<a href="https://example.com">链接文本</a>',
    img: '<img src="https://example.com/image.jpg" alt="图片描述" />',
    code: '<code>代码</code>',
    ul: '<ul>\n  <li>列表项</li>\n</ul>',
    ol: '<ol>\n  <li>列表项</li>\n</ol>',
    table: '<table>\n  <tr>\n    <th>表头</th>\n  </tr>\n  <tr>\n    <td>单元格</td>\n  </tr>\n</table>',
    div: '<div>内容</div>',
    br: '<br />'
  }
  
  insert = templates[tag] || `<${tag}></${tag}>`
  
  if (selected) {
    // 如果有选中文本，用标签包裹
    if (['strong', 'em', 'code'].includes(tag)) {
      insert = `<${tag}>${selected}</${tag}>`
    } else {
      insert = selected
    }
  }
  
  const newText = editorContent.value.substring(0, start) + insert + editorContent.value.substring(end)
  editorContent.value = newText
  
  nextTick(() => {
    const newPos = start + insert.length
    textarea.setSelectionRange(newPos, newPos)
    textarea.focus()
  })
}

// HTML 转字符串（去除 HTML 标签，只保留文本内容）
function htmlToString() {
  if (!editorContent.value.trim()) {
    alert('内容为空')
    return
  }
  
  // 添加到历史记录
  addToHistory()
  
  // 保存原始 HTML，以便后续还原
  originalHtml.value = editorContent.value
  
  // 创建一个临时的 DOM 元素来解析 HTML
  const tempDiv = document.createElement('div')
  tempDiv.innerHTML = editorContent.value
  
  // 获取纯文本内容
  let textContent = tempDiv.textContent || tempDiv.innerText || ''
  
  // 清理多余的空格和换行
  textContent = textContent
    .replace(/\n\s*\n/g, '\n') // 多个连续换行合并为一个
    .replace(/[ \t]+/g, ' ') // 多个空格合并为一个
    .trim()
  
  editorContent.value = textContent
}

// 还原 HTML（将纯文本转换回 HTML 格式）
function stringToHtml() {
  if (!editorContent.value.trim()) {
    alert('内容为空')
    return
  }
  
  // 添加到历史记录
  addToHistory()
  
  // 如果保存了原始 HTML，优先还原原始 HTML
  if (originalHtml.value) {
    editorContent.value = originalHtml.value
    originalHtml.value = '' // 清空保存的原始 HTML
    return
  }
  
  // 如果没有原始 HTML，将纯文本智能转换为 HTML
  let text = editorContent.value
  
  // 按行分割
  const lines = text.split('\n')
  const htmlLines = []
  let inUnorderedList = false
  let inOrderedList = false
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()
    const prevLine = i > 0 ? lines[i - 1].trim() : ''
    const nextLine = i < lines.length - 1 ? lines[i + 1].trim() : ''
    
    if (!line) {
      // 空行，关闭当前列表或段落
      if (inUnorderedList) {
        htmlLines.push('</ul>')
        inUnorderedList = false
      }
      if (inOrderedList) {
        htmlLines.push('</ol>')
        inOrderedList = false
      }
      continue
    }
    
    // 检测标题（以 # 开头）
    if (line.startsWith('# ')) {
      if (inUnorderedList) { htmlLines.push('</ul>'); inUnorderedList = false }
      if (inOrderedList) { htmlLines.push('</ol>'); inOrderedList = false }
      htmlLines.push(`<h1>${escapeHtmlChars(line.substring(2))}</h1>`)
    } else if (line.startsWith('## ')) {
      if (inUnorderedList) { htmlLines.push('</ul>'); inUnorderedList = false }
      if (inOrderedList) { htmlLines.push('</ol>'); inOrderedList = false }
      htmlLines.push(`<h2>${escapeHtmlChars(line.substring(3))}</h2>`)
    } else if (line.startsWith('### ')) {
      if (inUnorderedList) { htmlLines.push('</ul>'); inUnorderedList = false }
      if (inOrderedList) { htmlLines.push('</ol>'); inOrderedList = false }
      htmlLines.push(`<h3>${escapeHtmlChars(line.substring(4))}</h3>`)
    } else if (line.startsWith('#### ')) {
      if (inUnorderedList) { htmlLines.push('</ul>'); inUnorderedList = false }
      if (inOrderedList) { htmlLines.push('</ol>'); inOrderedList = false }
      htmlLines.push(`<h4>${escapeHtmlChars(line.substring(5))}</h4>`)
    } else if (line.startsWith('##### ')) {
      if (inUnorderedList) { htmlLines.push('</ul>'); inUnorderedList = false }
      if (inOrderedList) { htmlLines.push('</ol>'); inOrderedList = false }
      htmlLines.push(`<h5>${escapeHtmlChars(line.substring(6))}</h5>`)
    } else if (line.startsWith('###### ')) {
      if (inUnorderedList) { htmlLines.push('</ul>'); inUnorderedList = false }
      if (inOrderedList) { htmlLines.push('</ol>'); inOrderedList = false }
      htmlLines.push(`<h6>${escapeHtmlChars(line.substring(7))}</h6>`)
    } else if (line.startsWith('- ') || line.startsWith('* ')) {
      // 无序列表项
      if (inOrderedList) {
        htmlLines.push('</ol>')
        inOrderedList = false
      }
      if (!inUnorderedList) {
        htmlLines.push('<ul>')
        inUnorderedList = true
      }
      htmlLines.push(`  <li>${escapeHtmlChars(line.substring(2))}</li>`)
      if (!nextLine || (!nextLine.startsWith('- ') && !nextLine.startsWith('* '))) {
        htmlLines.push('</ul>')
        inUnorderedList = false
      }
    } else if (/^\d+\.\s/.test(line)) {
      // 有序列表项
      if (inUnorderedList) {
        htmlLines.push('</ul>')
        inUnorderedList = false
      }
      if (!inOrderedList) {
        htmlLines.push('<ol>')
        inOrderedList = true
      }
      htmlLines.push(`  <li>${escapeHtmlChars(line.replace(/^\d+\.\s/, ''))}</li>`)
      if (!nextLine || !/^\d+\.\s/.test(nextLine)) {
        htmlLines.push('</ol>')
        inOrderedList = false
      }
    } else {
      // 普通段落
      if (inUnorderedList) {
        htmlLines.push('</ul>')
        inUnorderedList = false
      }
      if (inOrderedList) {
        htmlLines.push('</ol>')
        inOrderedList = false
      }
      htmlLines.push(`<p>${escapeHtmlChars(line)}</p>`)
    }
  }
  
  // 确保关闭所有未关闭的列表
  if (inUnorderedList) {
    htmlLines.push('</ul>')
  }
  if (inOrderedList) {
    htmlLines.push('</ol>')
  }
  
  editorContent.value = htmlLines.join('\n')
}

// HTML 字符转义辅助函数
function escapeHtmlChars(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
}

// 复制内容
async function copyContent() {
  try {
    await navigator.clipboard.writeText(editorContent.value)
    alert('已复制到剪贴板')
  } catch (err) {
    // 降级方案
    const textarea = document.createElement('textarea')
    textarea.value = editorContent.value
    textarea.style.position = 'fixed'
    textarea.style.opacity = '0'
    document.body.appendChild(textarea)
    textarea.select()
    try {
      document.execCommand('copy')
      alert('已复制到剪贴板')
    } catch (e) {
      alert('复制失败，请手动复制')
    }
    document.body.removeChild(textarea)
  }
}

// 复制预览 HTML
async function copyPreview() {
  const html = previewHtml.value
  try {
    await navigator.clipboard.writeText(html)
    alert('预览内容已复制到剪贴板')
  } catch (err) {
    const textarea = document.createElement('textarea')
    textarea.value = html
    textarea.style.position = 'fixed'
    textarea.style.opacity = '0'
    document.body.appendChild(textarea)
    textarea.select()
    try {
      document.execCommand('copy')
      alert('预览内容已复制到剪贴板')
    } catch (e) {
      alert('复制失败，请手动复制')
    }
    document.body.removeChild(textarea)
  }
}

// 清空内容
function clearContent() {
  if (confirm('确定要清空所有内容吗？')) {
    editorContent.value = ''
  }
}

// 下载 HTML
function downloadHtml() {
  const html = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HTML 文档</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      padding: 40px 20px;
      line-height: 1.8;
      color: #333;
      max-width: 800px;
      margin: 0 auto;
    }
    img { max-width: 100%; height: auto; }
    table { border-collapse: collapse; width: 100%; margin: 20px 0; }
    table th, table td { border: 1px solid #ddd; padding: 8px; }
    table th { background-color: #f2f2f2; }
    code { background: #f5f5f5; padding: 2px 6px; border-radius: 4px; }
    pre { background: #f5f5f5; padding: 15px; border-radius: 8px; overflow-x: auto; }
    pre code { background: transparent; padding: 0; }
  </style>
</head>
<body>
${editorContent.value}
</body>
</html>`
  
  const blob = new Blob([html], { type: 'text/html;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = 'document.html'
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

// 切换预览模式
function togglePreviewMode() {
  previewMode.value = previewMode.value === 'inline' ? 'iframe' : 'inline'
  nextTick(() => {
    updatePreview()
  })
}

// 添加到历史记录
function addToHistory() {
  const currentContent = editorContent.value
  
  // 如果内容没有变化，不添加到历史记录
  if (history.value.length > 0 && history.value[historyIndex.value] === currentContent) {
    return
  }
  
  // 如果当前不在历史记录末尾，删除后面的记录
  if (historyIndex.value < history.value.length - 1) {
    history.value = history.value.slice(0, historyIndex.value + 1)
  }
  
  // 添加新记录
  history.value.push(currentContent)
  historyIndex.value = history.value.length - 1
  
  // 限制历史记录大小
  if (history.value.length > maxHistorySize) {
    history.value.shift()
    historyIndex.value = history.value.length - 1
  }
}

// 撤销
function undo() {
  if (historyIndex.value > 0) {
    historyIndex.value--
    editorContent.value = history.value[historyIndex.value]
  }
}

// 重做
function redo() {
  if (historyIndex.value < history.value.length - 1) {
    historyIndex.value++
    editorContent.value = history.value[historyIndex.value]
  }
}

// 保存到 localStorage
function saveToStorage() {
  try {
    localStorage.setItem('htmlEditorContent', editorContent.value)
    localStorage.setItem('htmlEditorHistory', JSON.stringify(history.value))
    localStorage.setItem('htmlEditorHistoryIndex', historyIndex.value.toString())
    alert('已保存')
  } catch (err) {
    alert('保存失败：' + err.message)
  }
}

// 处理键盘快捷键
function handleKeydown(e) {
  // Ctrl/Cmd + Z 撤销
  if ((e.ctrlKey || e.metaKey) && !e.shiftKey && e.key === 'z') {
    e.preventDefault()
    undo()
    return
  }
  
  // Ctrl/Cmd + Shift + Z 或 Ctrl/Cmd + Y 重做
  if ((e.ctrlKey || e.metaKey) && ((e.shiftKey && e.key === 'z') || e.key === 'y')) {
    e.preventDefault()
    redo()
    return
  }
  
  // Ctrl/Cmd + S 保存
  if ((e.ctrlKey || e.metaKey) && e.key === 's') {
    e.preventDefault()
    saveToStorage()
    return
  }
  
  // Ctrl/Cmd + K HTML转字符串
  if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
    e.preventDefault()
    htmlToString()
    return
  }
  
  // 其他输入操作时添加到历史记录（延迟添加，避免频繁记录）
  if (!e.ctrlKey && !e.metaKey && !e.altKey) {
    // 延迟添加到历史记录，避免每次输入都记录
    if (handleKeydown.saveTimeout) {
      clearTimeout(handleKeydown.saveTimeout)
    }
    handleKeydown.saveTimeout = setTimeout(() => {
      addToHistory()
    }, 500) // 500ms 后添加到历史记录
  }
}

onMounted(() => {
  // 从 localStorage 恢复内容和历史记录
  try {
    const stored = localStorage.getItem('htmlEditorContent')
    if (stored) {
      editorContent.value = stored
    }
    
    const storedHistory = localStorage.getItem('htmlEditorHistory')
    if (storedHistory) {
      history.value = JSON.parse(storedHistory)
      const storedIndex = localStorage.getItem('htmlEditorHistoryIndex')
      if (storedIndex) {
        historyIndex.value = parseInt(storedIndex, 10)
      } else {
        historyIndex.value = history.value.length - 1
      }
    } else {
      // 初始化历史记录
      history.value = [editorContent.value]
      historyIndex.value = 0
    }
  } catch (err) {
    console.error('恢复历史记录失败:', err)
    history.value = [editorContent.value]
    historyIndex.value = 0
  }
  
  // 监听内容变化，保存到 sessionStorage（用于临时保存）
  watch(editorContent, (newVal) => {
    sessionStorage.setItem('htmlEditorContent', newVal)
  })
  
  updatePreview()
})
</script>

<style scoped>
.html-editor {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-md);
  background: var(--color-background-alt);
  border-bottom: 2px solid var(--color-border);
  flex-wrap: wrap;
  gap: var(--spacing-sm);
}

.action-group {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  flex-wrap: wrap;
}

.topbar-title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
}

.toolbar-btn {
  padding: var(--spacing-xs) var(--spacing-md);
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  color: var(--color-text);
  font-size: var(--font-size-small);
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
}

.toolbar-btn:hover {
  background: var(--color-hover);
  border-color: var(--color-primary);
  transform: translateY(-2px);
}

.toolbar-btn:active {
  transform: translateY(0);
}

.editor-preview-wrapper {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-md);
  flex: 1;
  overflow: hidden;
  padding: var(--spacing-md);
}

.editor-section,
.preview-section {
  display: flex;
  flex-direction: column;
  background: var(--color-surface);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-md);
  overflow: hidden;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--spacing-sm) var(--spacing-md);
  background: var(--color-background-alt);
  border-bottom: 2px solid var(--color-border);
  font-weight: var(--font-weight-semibold);
  font-size: var(--font-size-small);
  color: var(--color-text);
}

.char-count {
  color: var(--color-text-secondary);
  font-size: var(--font-size-small);
}

.preview-toggle-btn {
  padding: var(--spacing-xs) var(--spacing-sm);
  background: transparent;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  color: var(--color-text);
  font-size: var(--font-size-small);
  cursor: pointer;
  transition: all 0.3s;
}

.preview-toggle-btn:hover {
  background: var(--color-hover);
  border-color: var(--color-primary);
}

.editor-shortcuts-bar {
  padding: var(--spacing-sm);
  background: var(--color-background-alt);
  border-bottom: 1px solid var(--color-border);
}

.editor-shortcuts {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-xs);
}

.editor-shortcuts .toolbar-btn {
  padding: var(--spacing-xs) var(--spacing-sm);
  font-size: var(--font-size-small);
  min-width: auto;
}

.editor-textarea {
  flex: 1;
  width: 100%;
  padding: var(--spacing-md);
  border: none;
  outline: none;
  resize: none;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', 'Consolas', monospace;
  font-size: var(--font-size-base);
  line-height: 1.6;
  color: var(--color-text);
  background: var(--color-surface);
  overflow-y: auto;
}

.preview-content {
  flex: 1;
  padding: var(--spacing-md);
  overflow-y: auto;
  color: var(--color-text);
  background: var(--color-surface);
}

.preview-iframe-wrapper {
  flex: 1;
  overflow: hidden;
  position: relative;
}

.preview-iframe {
  width: 100%;
  height: 100%;
  border: none;
  background: var(--color-surface);
}

/* 预览内容样式 */
.preview-content :deep(h1),
.preview-content :deep(h2),
.preview-content :deep(h3),
.preview-content :deep(h4),
.preview-content :deep(h5),
.preview-content :deep(h6) {
  margin-top: 1em;
  margin-bottom: 0.5em;
  font-weight: var(--font-weight-bold);
}

.preview-content :deep(p) {
  margin-bottom: 1em;
}

.preview-content :deep(img) {
  max-width: 100%;
  height: auto;
}

.preview-content :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 1em 0;
}

.preview-content :deep(table th),
.preview-content :deep(table td) {
  border: 1px solid var(--color-border);
  padding: 8px;
}

.preview-content :deep(table th) {
  background: var(--color-background-alt);
  font-weight: var(--font-weight-semibold);
}

.preview-content :deep(code) {
  background: var(--color-background-alt);
  padding: 2px 6px;
  border-radius: var(--radius-sm);
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', 'Consolas', monospace;
  font-size: 0.9em;
}

.preview-content :deep(pre) {
  background: var(--color-background-alt);
  padding: var(--spacing-md);
  border-radius: var(--radius-md);
  overflow-x: auto;
  margin: 1em 0;
}

.preview-content :deep(pre code) {
  background: transparent;
  padding: 0;
}

.preview-content :deep(ul),
.preview-content :deep(ol) {
  margin: 1em 0;
  padding-left: 2em;
}

.preview-content :deep(li) {
  margin: 0.5em 0;
}

.preview-content :deep(a) {
  color: var(--color-primary);
  text-decoration: none;
}

.preview-content :deep(a:hover) {
  text-decoration: underline;
}

@media (max-width: 1024px) {
  .editor-preview-wrapper {
    grid-template-columns: 1fr;
    grid-template-rows: 1fr 1fr;
  }
}
</style>
