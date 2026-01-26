<template>
  <ToolLayout
    icon="🛠️"
    title="Markdown 编译模式"
    description="提供编辑与实时编译预览，可保存历史并跳转预览模式"
  >
    <div class="markdown-compile">
      <div class="action-bar">
        <div class="action-group">
          <span class="topbar-title"><span>🛠️</span><span>Markdown 编译模式</span></span>
        </div>
        <div class="action-group">
          <button class="toolbar-btn" @click="goToHome"><span>📖</span><span>Markdown 首页</span></button>
          <button class="toolbar-btn" @click="saveHistory"><span>💾</span><span>保存历史</span></button>
          <button class="toolbar-btn" @click="goToPreview"><span>👁️</span><span>预览模式</span></button>
          <button class="toolbar-btn" @click="copyContent"><span>📋</span><span>复制</span></button>
          <button class="toolbar-btn" @click="downloadMd"><span>📄</span><span>导出 MD</span></button>
          <button class="toolbar-btn" @click="downloadHtml"><span>🌐</span><span>导出 HTML</span></button>
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
              <button class="toolbar-btn tooltip" data-tooltip="一级标题" data-i="h1" @click="insertText('h1')">H1</button>
              <button class="toolbar-btn tooltip" data-tooltip="二级标题" data-i="h2" @click="insertText('h2')">H2</button>
              <button class="toolbar-btn tooltip" data-tooltip="三级标题" data-i="h3" @click="insertText('h3')">H3</button>
              <button class="toolbar-btn tooltip" data-tooltip="粗体" data-i="bold" @click="insertText('bold')">𝐁</button>
              <button class="toolbar-btn tooltip" data-tooltip="斜体" data-i="italic" @click="insertText('italic')">𝐼</button>
              <button class="toolbar-btn tooltip" data-tooltip="链接" data-i="link" @click="insertText('link')">🔗</button>
              <button class="toolbar-btn tooltip" data-tooltip="插入图片（可选择文件）" data-i="image" @click="insertImage">🖼️</button>
              <input 
                ref="imageInputRef"
                type="file" 
                accept="image/*" 
                style="display: none"
                @change="handleImageSelect"
              />
              <button class="toolbar-btn tooltip" data-tooltip="行内代码" data-i="code" @click="insertText('code')">ᐸᐳ</button>
              <button class="toolbar-btn tooltip" data-tooltip="代码块" data-i="codeblock" @click="insertText('codeblock')">📦</button>
              <button class="toolbar-btn tooltip" data-tooltip="引用" data-i="quote" @click="insertText('quote')">❝</button>
              <button class="toolbar-btn tooltip" data-tooltip="无序列表" data-i="list" @click="insertText('list')">•</button>
              <button class="toolbar-btn tooltip" data-tooltip="有序列表" data-i="olist" @click="insertText('olist')">1.</button>
              <button class="toolbar-btn tooltip" data-tooltip="表格" data-i="table" @click="insertText('table')">▦</button>
              <button class="toolbar-btn tooltip" data-tooltip="分隔线" data-i="hr" @click="insertText('hr')">➖</button>
            </div>
          </div>
          <textarea 
            ref="editorRef"
            v-model="editorContent"
            class="editor-textarea" 
            placeholder="在此输入 Markdown 内容..."
            @input="handleInput"
            @scroll="handleEditorScroll"
            @click="handleEditorClick"
            @keyup="handleEditorKeyup"
            @keydown="handleEditorKeydown"
          ></textarea>
        </div>
        <div class="preview-section">
          <div class="section-header"><span>预览区</span></div>
          <div class="preview-offset-bar"></div>
          <div ref="previewRef" class="preview-content" v-html="previewHtml"></div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { loadScript, loadStyle } from '@/utils/cdn-loader'
import { computed, nextTick, onMounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const editorRef = ref(null)
const previewRef = ref(null)
const imageInputRef = ref(null)
const editorContent = ref('')
const marked = ref(null)
const hljs = ref(null)
const isSyncingScroll = ref(false)
const isUserScrolling = ref(false)
const lastScrollTop = ref(0)

// 撤销/重做历史记录
const history = ref([])
const historyIndex = ref(-1)
const maxHistorySize = 50

const charCountText = computed(() => {
  return `${editorContent.value.length.toLocaleString()} 字符`
})

const previewHtml = computed(() => {
  if (!marked.value || !editorContent.value.trim()) {
    return '<div style="color:var(--color-text-secondary);font-style:italic;">预览内容将显示在这里...</div>'
  }
  return marked.value.parse(editorContent.value)
})

function getMarkdownTitle(content) {
  const lines = content.split('\n')
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()
    if (line.startsWith('# ')) return line.substring(2).trim()
    if (line.startsWith('## ')) return line.substring(3).trim()
  }
  return null
}

function formatFileSize(bytes) {
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
}

async function loadLibraries() {
  try {
    // 加载 marked
    await loadScript('https://cdn.jsdelivr.net/npm/marked@11.1.1/marked.min.js')
    marked.value = window.marked
    if (marked.value) {
      marked.value.setOptions({ breaks: true, gfm: true, headerIds: true, mangle: false })
    }

    // 加载 highlight.js
    await loadStyle('https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css')
    await loadScript('https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js')
    hljs.value = window.hljs
  } catch (error) {
    console.error('Failed to load libraries:', error)
  }
}

function updatePreview() {
  if (isSyncingScroll.value) return
  nextTick(() => {
    if (previewRef.value && hljs.value) {
      previewRef.value.querySelectorAll('pre code').forEach((block) => {
        hljs.value.highlightElement(block)
      })
    }
    if (!isUserScrolling.value) {
      setTimeout(() => {
        syncPreviewToCaret()
      }, 200)
    }
  })
}

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

watch(previewHtml, () => {
  nextTick(() => {
    if (previewRef.value && hljs.value) {
      previewRef.value.querySelectorAll('pre code').forEach((block) => {
        hljs.value.highlightElement(block)
      })
    }
  })
})

// 添加到历史记录
function addToHistory() {
  if (!editorRef.value) return
  
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
    updatePreview()
  }
}

// 重做
function redo() {
  if (historyIndex.value < history.value.length - 1) {
    historyIndex.value++
    editorContent.value = history.value[historyIndex.value]
    updatePreview()
  }
}

// 保存到 localStorage
function saveToStorage() {
  try {
    localStorage.setItem('markdownEditorContent', editorContent.value)
    localStorage.setItem('markdownEditorHistory', JSON.stringify(history.value))
    localStorage.setItem('markdownEditorHistoryIndex', historyIndex.value.toString())
    alert('已保存')
  } catch (err) {
    alert('保存失败：' + err.message)
  }
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
  
  // 使用文件名作为图片路径（相对路径）
  const imagePath = `./images/${file.name}`
  const alt = file.name.replace(/\.[^/.]+$/, '') // 使用文件名（不含扩展名）作为 alt
  
  // 插入 Markdown 图片语法
  if (!editorRef.value) return
  
  const textarea = editorRef.value
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  
    addToHistory()
    
    const imageMarkdown = `![${alt}](${imagePath})`
  const newText = editorContent.value.substring(0, start) + imageMarkdown + editorContent.value.substring(end)
  editorContent.value = newText
  
  nextTick(() => {
    const newPos = start + imageMarkdown.length
    textarea.setSelectionRange(newPos, newPos)
    textarea.focus()
    updatePreview()
  })
  
  // 清空 input，以便可以再次选择同一文件
  event.target.value = ''
}

function insertText(type) {
  if (!editorRef.value) return
  const textarea = editorRef.value
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  const selected = editorContent.value.substring(start, end)
  let insert = ''
  
  addToHistory()
  
  if (type === 'h1') { insert = `# ${selected || '标题 1'}` }
  else if (type === 'h2') { insert = `## ${selected || '标题 2'}` }
  else if (type === 'h3') { insert = `### ${selected || '标题 3'}` }
  else if (type === 'bold') { insert = `**${selected || '粗体文本'}**` }
  else if (type === 'italic') { insert = `*${selected || '斜体文本'}*` }
  else if (type === 'link') { insert = `[${selected || '链接文本'}](https://example.com)` }
  else if (type === 'image') { insert = `![${selected || '图片描述'}](https://example.com/image.png)` }
  else if (type === 'code') { insert = `\`${selected || '代码'}\`` }
  else if (type === 'codeblock') { insert = `\`\`\`\n${selected || '代码块'}\n\`\`\`` }
  else if (type === 'quote') { insert = `> ${selected || '引用内容'}` }
  else if (type === 'list') { insert = `- ${selected || '列表项'}` }
  else if (type === 'olist') { insert = `1. ${selected || '列表项'}` }
  else if (type === 'table') { insert = `| 列1 | 列2 | 列3 |\n| --- | --- | --- |\n| 内容1 | 内容2 | 内容3 |` }
  else if (type === 'hr') { insert = `\n---\n` }
  
  textarea.focus()
  let newPos = start
  
  if (typeof textarea.setRangeText === 'function') {
    textarea.setRangeText(insert, start, end, 'end')
    newPos = textarea.selectionStart
  } else {
    const newText = editorContent.value.substring(0, start) + insert + editorContent.value.substring(end)
    editorContent.value = newText
    newPos = start + insert.length
    textarea.setSelectionRange(newPos, newPos)
  }
  
  updatePreview()
  setTimeout(() => {
    scrollToPosition(newPos)
  }, 150)
}

function getEditorCharIndexAtScrollTop() {
  if (!editorRef.value || !editorContent.value) return 0
  const scrollTop = editorRef.value.scrollTop
  const lineHeight = getEditorLineHeight()
  const lines = editorContent.value.split('\n')
  const visibleLineIndex = Math.floor(scrollTop / lineHeight)
  let charIndex = 0
  for (let i = 0; i < Math.min(visibleLineIndex, lines.length); i++) {
    charIndex += lines[i].length + 1
  }
  return Math.max(0, Math.min(editorContent.value.length - 1, charIndex))
}

function getEditorLineHeight() {
  if (!editorRef.value) return 20
  const style = window.getComputedStyle(editorRef.value)
  const lineHeight = parseFloat(style.lineHeight)
  if (isNaN(lineHeight)) {
    const fontSize = parseFloat(style.fontSize) || 16
    return fontSize * 1.6
  }
  return lineHeight
}

function getPreviewOffsetByCharIndex(charIndex) {
  if (!previewRef.value || !editorRef.value || !previewRef.value.children.length) return 0
  const text = editorContent.value || ''
  if (text.length === 0) return 0
  if (charIndex < 0) charIndex = 0
  if (charIndex >= text.length) charIndex = text.length - 1

  const lines = text.split('\n')
  let charCount = 0
  let targetLineIndex = -1
  for (let i = 0; i < lines.length; i++) {
    const lineLength = lines[i].length
    if (charIndex >= charCount && charIndex <= charCount + lineLength) {
      targetLineIndex = i
      break
    }
    charCount += lineLength + 1
  }

  if (targetLineIndex < 0 || targetLineIndex >= lines.length) {
    const maxScroll = previewRef.value.scrollHeight - previewRef.value.clientHeight
    return Math.max(0, maxScroll)
  }

  const targetLine = lines[targetLineIndex]
  const targetLineText = targetLine.trim()
  const previewRect = previewRef.value.getBoundingClientRect()
  const previewElements = Array.from(previewRef.value.querySelectorAll('h1, h2, h3, h4, h5, h6, p, li, pre, blockquote, table, hr'))
  let bestOffset = null
  let bestScore = 0

  for (let i = 0; i < previewElements.length; i++) {
    const element = previewElements[i]
    const elementText = element.textContent || ''
    const elementTextClean = elementText.trim().replace(/\s+/g, ' ')
    const targetLineClean = targetLineText.replace(/\s+/g, ' ')

    if (!targetLineClean || !elementTextClean) continue

    let score = 0
    if (elementTextClean === targetLineClean) {
      score = 1000
    } else if (elementTextClean.includes(targetLineClean)) {
      score = 800
    } else if (targetLineClean.includes(elementTextClean)) {
      score = 700
    } else {
      const minLen = Math.min(elementTextClean.length, targetLineClean.length, 30)
      if (minLen > 5) {
        let matchCount = 0
        for (let j = 0; j < minLen; j++) {
          if (elementTextClean[j] === targetLineClean[j]) matchCount++
          else break
        }
        if (matchCount > 10) score = 400 + matchCount
        if (elementTextClean.substring(0, 15) === targetLineClean.substring(0, 15)) {
          score = Math.max(score, 600)
        }
      }
    }

    if (score > bestScore) {
      try {
        const rect = element.getBoundingClientRect()
        if (rect.height > 0) {
          const offset = rect.top - previewRect.top + previewRef.value.scrollTop
          bestScore = score
          bestOffset = Math.max(0, offset - 50)
        }
      } catch (e) {}
    }
  }

  if (bestOffset !== null && bestScore > 300) {
    return bestOffset
  }

  const ratio = charIndex / Math.max(1, text.length)
  const maxScroll = previewRef.value.scrollHeight - previewRef.value.clientHeight
  return Math.max(0, ratio * maxScroll)
}

function syncScroll() {
  if (!editorRef.value || !previewRef.value || isSyncingScroll.value || !previewRef.value.children.length) return
  const currentScrollTop = editorRef.value.scrollTop
  if (Math.abs(currentScrollTop - lastScrollTop.value) < 1) return
  lastScrollTop.value = currentScrollTop
  isUserScrolling.value = true
  isSyncingScroll.value = true
  
  requestAnimationFrame(() => {
    const charIndex = getEditorCharIndexAtScrollTop()
    const previewOffset = getPreviewOffsetByCharIndex(charIndex)
    if (previewOffset !== null && previewOffset !== undefined) {
      previewRef.value.scrollTop = previewOffset
    }
    setTimeout(() => {
      isSyncingScroll.value = false
      isUserScrolling.value = false
    }, 50)
  })
}

function syncPreviewToCaret() {
  if (!editorRef.value || !previewRef.value || isSyncingScroll.value || isUserScrolling.value || !previewRef.value.children.length) return
  const caret = editorRef.value.selectionStart || 0
  
  setTimeout(() => {
    if (isSyncingScroll.value || isUserScrolling.value) return
    isSyncingScroll.value = true
    requestAnimationFrame(() => {
      const previewOffset = getPreviewOffsetByCharIndex(caret)
      if (previewOffset !== null && previewOffset !== undefined) {
        previewRef.value.scrollTop = previewOffset
      }
      setTimeout(() => { isSyncingScroll.value = false }, 50)
    })
  }, 150)
}

function scrollToPosition(charIndex) {
  if (!editorRef.value || !previewRef.value) return
  isSyncingScroll.value = true
  isUserScrolling.value = false
  const lineHeight = getEditorLineHeight()
  const lines = editorContent.value.split('\n')
  let charCount = 0
  let lineNum = 0
  for (let i = 0; i < lines.length; i++) {
    if (charIndex >= charCount && charIndex <= charCount + lines[i].length) {
      lineNum = i
      break
    }
    charCount += lines[i].length + 1
  }
  const editorScrollTop = Math.max(0, lineNum * lineHeight - 100)
  editorRef.value.scrollTop = editorScrollTop
  lastScrollTop.value = editorScrollTop
  setTimeout(() => {
    const previewOffset = getPreviewOffsetByCharIndex(charIndex)
    if (previewOffset !== null) {
      previewRef.value.scrollTop = previewOffset
    }
    setTimeout(() => {
      isSyncingScroll.value = false
    }, 100)
  }, 150)
}

function handleEditorScroll() {
  if (!isSyncingScroll.value) {
    syncScroll()
  }
}

function handleEditorClick() {
  setTimeout(() => {
    if (!isSyncingScroll.value && !isUserScrolling.value) {
      syncPreviewToCaret()
    }
  }, 50)
}

let keyupTimeout = null
function handleEditorKeyup(e) {
  if (keyupTimeout) clearTimeout(keyupTimeout)
  if (e.key === 'ArrowUp' || e.key === 'ArrowDown' || e.key === 'PageUp' || e.key === 'PageDown' || e.key === 'Home' || e.key === 'End') {
    keyupTimeout = setTimeout(() => {
      if (!isSyncingScroll.value && !isUserScrolling.value) {
        syncPreviewToCaret()
      }
    }, 100)
  }
}

function handleEditorKeydown(e) {
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
  
  // Tab 键处理
  if (e.key === 'Tab') {
    e.preventDefault()
    const start = editorRef.value.selectionStart
    const end = editorRef.value.selectionEnd
    addToHistory()
    if (typeof editorRef.value.setRangeText === 'function') {
      editorRef.value.setRangeText('    ', start, end, 'end')
    } else {
      editorContent.value = editorContent.value.substring(0, start) + '    ' + editorContent.value.substring(end)
      editorRef.value.selectionStart = editorRef.value.selectionEnd = start + 4
    }
    updatePreview()
    return
  }
  
  // 其他输入操作时添加到历史记录（延迟添加，避免频繁记录）
  if (!e.ctrlKey && !e.metaKey && !e.altKey && !e.shiftKey) {
    // 延迟添加到历史记录，避免每次输入都记录
    if (handleEditorKeydown.saveTimeout) {
      clearTimeout(handleEditorKeydown.saveTimeout)
    }
    handleEditorKeydown.saveTimeout = setTimeout(() => {
      addToHistory()
    }, 500) // 500ms 后添加到历史记录
  }
}

function saveHistoryItem() {
  const title = getMarkdownTitle(editorContent.value) || '未命名文档'
  const item = {
    id: Date.now(),
    title: title,
    content: editorContent.value,
    fileName: null,
    type: 'compile',
    timestamp: new Date().toISOString(),
    size: editorContent.value.length
  }
  let list = []
  const saved = localStorage.getItem('markdownHistory')
  if (saved) {
    try {
      const parsed = JSON.parse(saved)
      list = Array.isArray(parsed) ? parsed : []
    } catch (e) {
      list = []
    }
  }
  list = list.filter(h => h.content !== editorContent.value)
  list.unshift(item)
  if (list.length > 100) list = list.slice(0, 100)
  localStorage.setItem('markdownHistory', JSON.stringify(list))
}

function saveHistory() {
  if (!editorContent.value || !editorContent.value.trim()) {
    alert('没有可保存的内容')
    return
  }
  saveHistoryItem()
  alert('已保存到历史记录')
}

function goToPreview() {
  if (!editorContent.value || !editorContent.value.trim()) {
    alert('请先输入内容')
    return
  }
  const title = getMarkdownTitle(editorContent.value) || '未命名文档'
  try {
    sessionStorage.setItem('markdownContent', editorContent.value)
    sessionStorage.setItem('markdownTitle', title)
    sessionStorage.setItem('markdownMode', 'preview')
  } catch (e) {}
  router.push('/tools/text/markdown/preview')
}

function goToHome() {
  router.push('/tools/text/markdown')
}


async function copyContent() {
  try {
    await navigator.clipboard.writeText(editorContent.value || '')
    alert('内容已复制到剪贴板！')
  } catch (err) {
    const ta = document.createElement('textarea')
    ta.value = editorContent.value || ''
    document.body.appendChild(ta)
    ta.select()
    try {
      document.execCommand('copy')
      alert('内容已复制到剪贴板！')
    } catch (e) {
      alert('复制失败，请手动复制')
    }
    document.body.removeChild(ta)
  }
}

function downloadMd() {
  const content = editorContent.value || ''
  const blob = new Blob([content], { type: 'text/markdown;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  const title = getMarkdownTitle(content) || 'markdown'
  a.download = `${title}-${Date.now()}.md`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

function downloadHtml() {
  if (!marked.value) return
  const html = marked.value.parse(editorContent.value || '')
  const styleContent = 'body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif;max-width:800px;margin:0 auto;padding:40px 20px;line-height:1.8;color:#333;}pre{background:#f5f5f5;padding:15px;border-radius:8px;overflow-x:auto;}code{background:#f5f5f5;padding:2px 6px;border-radius:4px;}blockquote{border-left:4px solid #667eea;padding-left:20px;margin:20px 0;color:#666;background:#f8f9fa;padding:15px 20px;}table{width:100%;border-collapse:collapse;margin:20px 0;}table th,table td{border:1px solid #ddd;padding:8px;}table th{background:#f8f9fa;}img{max-width:100%;height:auto;}'
  const scriptContent = 'document.querySelectorAll("pre code").forEach(function(b){hljs.highlightElement(b);});'
  const fullHtml = [
    '<!DOCTYPE html>',
    '<html lang="zh-CN">',
    '<head>',
    '<meta charset="UTF-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
    '<title>Markdown 导出<\/title>',
    '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css">',
    '<style>' + styleContent + '<\/style>',
    '<\/head>',
    '<body>',
    html,
    '<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"><\/script>',
    '<script>' + scriptContent + '<\/script>',
    '<\/body>',
    '<\/html>'
  ].join('\n')
  const blob = new Blob([fullHtml], { type: 'text/html;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  const title = getMarkdownTitle(editorContent.value || '') || 'markdown'
  a.download = title + '-' + Date.now() + '.html'
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

onMounted(async () => {
  // 从 localStorage 恢复内容和历史记录
  try {
    const stored = localStorage.getItem('markdownEditorContent')
    if (stored) {
      editorContent.value = stored
    }
    
    const storedHistory = localStorage.getItem('markdownEditorHistory')
    if (storedHistory) {
      history.value = JSON.parse(storedHistory)
      const storedIndex = localStorage.getItem('markdownEditorHistoryIndex')
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
  
  // 加载库
  await loadLibraries()
  
  // 优先从 localStorage 恢复（持久化保存）
  const storedLocal = localStorage.getItem('markdownEditorContent')
  if (storedLocal && storedLocal.trim()) {
    editorContent.value = storedLocal
  } else {
    // 如果没有持久化保存，尝试从 sessionStorage 恢复（临时保存）
    const stored = sessionStorage.getItem('markdownContent') || ''
    if (stored && stored.trim()) {
      editorContent.value = stored
    }
  }
  
  // 如果没有历史记录，初始化
  if (history.value.length === 0) {
    history.value = [editorContent.value]
    historyIndex.value = 0
  }
  
  updatePreview()
  
  // 监听内容变化，保存到 sessionStorage（用于临时保存）
  watch(editorContent, (newVal) => {
    sessionStorage.setItem('markdownContent', newVal)
  })
})
</script>

<style scoped>
.markdown-compile {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-lg);
  height: calc(100vh - 200px);
  min-height: 600px;
}

.action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: var(--spacing-sm);
  padding: var(--spacing-sm) var(--spacing-md);
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.18), rgba(118, 75, 162, 0.18));
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  position: sticky;
  top: 0;
  z-index: 20;
  box-shadow: var(--shadow-sm);
  backdrop-filter: saturate(140%) blur(6px);
}

.topbar-title {
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.action-group {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  flex-wrap: wrap;
}

.toolbar-btn {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  color: var(--color-text-on-surface-alt);
  padding: var(--spacing-sm) var(--spacing-md);
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: var(--font-size-small);
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  white-space: nowrap;
}

.toolbar-btn:hover {
  background: var(--color-hover);
  border-color: var(--color-primary);
  transform: translateY(-1px);
}

.editor-preview-wrapper {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
  gap: var(--spacing-lg);
  align-items: stretch;
  flex: 1;
  min-height: 0;
}

@media (max-width: 1024px) {
  .editor-preview-wrapper {
    grid-template-columns: 1fr;
  }
}

.editor-section,
.preview-section {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  display: flex;
  flex-direction: column;
  min-height: 0;
  overflow: hidden;
  height: 640px;
}

.section-header {
  padding: var(--spacing-sm) var(--spacing-md);
  border-bottom: 1px solid var(--color-border);
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: var(--spacing-sm);
  min-height: 40px;
  box-sizing: border-box;
}

.char-count {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  white-space: nowrap;
  flex-shrink: 0;
}

.editor-shortcuts-bar {
  padding: var(--spacing-xs) var(--spacing-md);
  border-bottom: 1px solid var(--color-border);
  background: var(--color-surface-alt);
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  min-height: 30px;
  box-sizing: border-box;
}

.editor-shortcuts {
  display: flex;
  flex-wrap: wrap;
  gap: 3px;
  align-items: center;
}

.editor-shortcuts .toolbar-btn {
  padding: 2px 5px;
  min-width: 24px;
  height: 22px;
  font-size: 11px;
  line-height: 1;
  justify-content: center;
  border-radius: 3px;
}

.preview-offset-bar {
  padding: var(--spacing-xs) var(--spacing-md);
  border-bottom: 1px solid var(--color-border);
  background: var(--color-surface);
  min-height: 30px;
  box-sizing: border-box;
}

.editor-textarea {
  flex: 1;
  padding: var(--spacing-md);
  border: none;
  background: var(--color-surface);
  color: var(--color-text);
  font-family: 'Courier New', Consolas, monospace;
  font-size: var(--font-size-base);
  line-height: 1.6;
  resize: none;
  outline: none;
  overflow-y: auto;
}

.preview-content {
  flex: 1;
  padding: var(--spacing-xl);
  overflow-y: auto;
  background: var(--color-surface);
  color: var(--color-text);
  line-height: 1.8;
}

.preview-content :deep(pre) {
  background: var(--color-surface-alt);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--spacing-md);
  overflow-x: auto;
  margin: var(--spacing-md) 0;
  line-height: 1.6;
}

.preview-content :deep(code) {
  font-family: 'Courier New', Consolas, monospace;
  font-size: 0.9em;
}

.preview-content :deep(pre code) {
  background: transparent;
  padding: 0;
  border: none;
  color: var(--color-text);
  display: block;
}

.preview-content :deep(:not(pre) > code) {
  background: var(--color-surface-alt);
  padding: 2px 6px;
  border-radius: 3px;
  color: var(--color-primary);
  border: 1px solid var(--color-border);
}
</style>