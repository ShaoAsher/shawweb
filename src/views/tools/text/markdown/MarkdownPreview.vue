<template>
  <ToolLayout
    icon="👁️"
    title="Markdown 预览模式"
    description="沉浸式阅读视图，支持目录导航与导出"
  >
    <div class="markdown-preview fullscreen-preview">
      <div class="preview-section">
        <div class="toc-sidebar">
          <div class="toc-header">📑 目录</div>
          <ul class="toc-list" ref="tocListRef">
            <li class="toc-empty">暂无目录</li>
          </ul>
        </div>
        <div class="preview-main">
          <div class="action-bar">
            <div class="action-group">
              <span class="topbar-title"><span>📑</span><span ref="previewTitleRef">目录</span></span>
            </div>
            <div class="action-group">
              <button class="toolbar-btn" @click="toggleTheme"><span>🎨</span><span>切换主题</span></button>
              <button class="toolbar-btn" @click="goToHome"><span>📖</span><span>Markdown 首页</span></button>
              <button class="toolbar-btn" @click="copyContent"><span>📋</span><span>复制</span></button>
              <button class="toolbar-btn" @click="downloadMd"><span>💾</span><span>下载</span></button>
              <button class="toolbar-btn" @click="downloadHtml"><span>🌐</span><span>导出 HTML</span></button>
              <button class="toolbar-btn" @click="goToCompile"><span>🛠️</span><span>编译模式</span></button>
            </div>
          </div>
          <div 
            ref="previewContentRef" 
            class="preview-content" 
            :class="{ empty: !markdownContent || !markdownContent.trim() }"
            v-html="previewHtml"
            @scroll="handlePreviewScroll"
          ></div>
        </div>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useRouter } from 'vue-router'
import { loadScript, loadStyle } from '@/utils/cdn-loader'

const router = useRouter()

const tocListRef = ref(null)
const previewContentRef = ref(null)
const previewTitleRef = ref(null)
const markdownContent = ref('')
const markdownTitle = ref('')
const marked = ref(null)
const hljs = ref(null)
const headings = ref([])
const tocLinks = ref([])

const previewHtml = computed(() => {
  if (!marked.value || !markdownContent.value || !markdownContent.value.trim()) {
    return '<div>预览内容将显示在这里...</div>'
  }
  return marked.value.parse(markdownContent.value)
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

function escapeHtml(text) {
  const div = document.createElement('div')
  div.textContent = text
  return div.innerHTML
}

function generateId(text) {
  const cleanText = text.replace(/<[^>]*>/g, '').trim()
  if (!cleanText) return 'heading-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9)
  let id = cleanText.toLowerCase()
    .replace(/[^\w\u4e00-\u9fa5\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')
    .trim()
  if (!id || id.length === 0) {
    const fallback = cleanText.substring(0, 10).replace(/[^\w\u4e00-\u9fa5]/g, '').toLowerCase() || 'heading'
    id = fallback + '-' + Date.now().toString(36)
  }
  return id
}

function updateCodeTheme() {
  const theme = localStorage.getItem('theme') || window.defaultTheme || 'purple'
  const darkThemes = ['modern', 'cyberpunk']
  const isDark = darkThemes.includes(theme)
  
  // 更新highlight.js样式
  const existingStyle = document.getElementById('hljs-style')
  if (existingStyle) {
    existingStyle.href = isDark 
      ? 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css'
      : 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css'
  }
  
  document.body.setAttribute('data-theme', theme)
}

function generateTOC() {
  if (!tocListRef.value || !previewContentRef.value) return
  
  const allHeadings = previewContentRef.value.querySelectorAll('h1,h2,h3,h4,h5,h6')
  headings.value = []
  allHeadings.forEach(h => {
    if (h.closest('blockquote,pre,code')) return
    headings.value.push(h)
  })
  
  if (headings.value.length === 0) {
    tocListRef.value.innerHTML = '<li class="toc-empty">暂无目录</li>'
    return
  }
  
  const usedIds = new Set()
  let idCounter = 0
  let tocHTML = ''
  
  headings.value.forEach((heading) => {
    let id = heading.id
    const level = parseInt(heading.tagName.charAt(1))
    const text = heading.textContent.trim()
    
    if (!id || id.trim() === '') {
      id = generateId(text)
      while (usedIds.has(id)) {
        id = generateId(text) + '-' + (++idCounter)
      }
      heading.id = id
    }
    
    if (usedIds.has(id)) {
      id = id + '-' + (++idCounter)
      heading.id = id
    }
    
    usedIds.add(id)
    const levelClass = 'toc-item-h' + level
    tocHTML += `<li class="toc-item ${levelClass}"><a href="#${id}" class="toc-link" data-id="${id}">${escapeHtml(text)}</a></li>`
  })
  
  tocListRef.value.innerHTML = tocHTML
  
  // 绑定目录链接点击事件
  nextTick(() => {
    tocLinks.value = tocListRef.value.querySelectorAll('.toc-link')
    tocLinks.value.forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault()
        const targetId = link.getAttribute('data-id')
        if (!targetId) return
        const target = previewContentRef.value.querySelector('#' + CSS.escape(targetId))
        if (target) {
          const scrollTop = previewContentRef.value.scrollTop
          const rect = previewContentRef.value.getBoundingClientRect()
          const targetRect = target.getBoundingClientRect()
          const offset = targetRect.top - rect.top + scrollTop - 80
          previewContentRef.value.scrollTo({ top: offset, behavior: 'smooth' })
          setTimeout(() => {
            updateActiveTOC()
          }, 100)
        }
      })
    })
  })
}

function updateActiveTOC() {
  if (!previewContentRef.value || !tocLinks.value.length) return
  
  const scrollTop = previewContentRef.value.scrollTop
  const viewportTop = scrollTop + 80
  let currentHeading = null
  let minDistance = Infinity
  
  headings.value.forEach(h => {
    const rect = h.getBoundingClientRect()
    const elementTop = rect.top + previewContentRef.value.scrollTop
    const distance = Math.abs(elementTop - viewportTop)
    if (elementTop <= viewportTop && distance < minDistance) {
      minDistance = distance
      currentHeading = h
    }
  })
  
  tocLinks.value.forEach(link => {
    link.classList.remove('active')
    if (currentHeading && link.getAttribute('data-id') === currentHeading.id) {
      link.classList.add('active')
    }
  })
}

function handlePreviewScroll() {
  updateActiveTOC()
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

watch(previewHtml, () => {
  nextTick(() => {
    if (previewContentRef.value && hljs.value) {
      previewContentRef.value.querySelectorAll('pre code').forEach((block) => {
        hljs.value.highlightElement(block)
      })
    }
    updateCodeTheme()
    const title = getMarkdownTitle(markdownContent.value) || markdownTitle.value || ''
    if (title && previewTitleRef.value) {
      previewTitleRef.value.textContent = title
      document.title = title
    }
    setTimeout(() => {
      generateTOC()
    }, 100)
  })
})

function goToCompile() {
  const c = markdownContent.value || ''
  const t = getMarkdownTitle(c) || markdownTitle.value || '未命名文档'
  try {
    sessionStorage.setItem('markdownContent', c)
    sessionStorage.setItem('markdownTitle', t)
    sessionStorage.setItem('markdownMode', 'compile')
  } catch (e) {}
  router.push('/tools/text/markdown/compile')
}

function goToHome() {
  router.push('/tools/text/markdown')
}

function toggleTheme() {
  if (window.openThemeModal) {
    window.openThemeModal()
    setTimeout(() => {
      updateCodeTheme()
    }, 200)
  }
}

async function copyContent() {
  const c = markdownContent.value || ''
  if (!c.trim()) {
    alert('没有可复制的内容')
    return
  }
  try {
    await navigator.clipboard.writeText(c)
    alert('Markdown 内容已复制到剪贴板！')
  } catch (err) {
    const ta = document.createElement('textarea')
    ta.value = c
    document.body.appendChild(ta)
    ta.select()
    try {
      document.execCommand('copy')
      alert('Markdown 内容已复制到剪贴板！')
    } catch (e) {
      alert('复制失败，请手动复制')
    }
    document.body.removeChild(ta)
  }
}

function downloadMd() {
  const c = markdownContent.value || ''
  if (!c.trim()) {
    alert('没有可下载的内容')
    return
  }
  const blob = new Blob([c], { type: 'text/markdown;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  const title = getMarkdownTitle(c) || 'markdown'
  a.download = `${title}-${Date.now()}.md`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

function downloadHtml() {
  if (!marked.value) return
  const c = markdownContent.value || ''
  if (!c.trim()) {
    alert('没有可导出的内容')
    return
  }
  const html = marked.value.parse(c)
  const fullHtml = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Markdown 导出</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css">
<style>body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif;max-width:800px;margin:0 auto;padding:40px 20px;line-height:1.8;color:#333;}pre{background:#f5f5f5;padding:15px;border-radius:8px;overflow-x:auto;}code{background:#f5f5f5;padding:2px 6px;border-radius:4px;}blockquote{border-left:4px solid #667eea;padding-left:20px;margin:20px 0;color:#666;background:#f8f9fa;padding:15px 20px;}table{width:100%;border-collapse:collapse;margin:20px 0;}table th,table td{border:1px solid #ddd;padding:8px;}table th{background:#f8f9fa;}img{max-width:100%;height:auto;}</style>
</head>
<body>
${html}
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
<script>document.querySelectorAll("pre code").forEach(function(b){hljs.highlightElement(b);});</script>
</body>
</html>`
  const blob = new Blob([fullHtml], { type: 'text/html;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  const title = getMarkdownTitle(c) || 'markdown'
  a.download = title + '-' + Date.now() + '.html'
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

onMounted(async () => {
  await loadLibraries()
  
  // 监听主题变化
  window.addEventListener('storage', (e) => {
    if (e.key === 'theme') updateCodeTheme()
  })
  
  const storedTheme = localStorage.getItem('theme')
  if (storedTheme) updateCodeTheme()
  
  let stored = ''
  try {
    stored = sessionStorage.getItem('markdownContent') || ''
    markdownContent.value = stored
    markdownTitle.value = sessionStorage.getItem('markdownTitle') || ''
  } catch (e) {
    stored = ''
  }
  
  if (stored && stored.trim()) {
    nextTick(() => {
      if (previewContentRef.value && hljs.value) {
        previewContentRef.value.querySelectorAll('pre code').forEach((block) => {
          hljs.value.highlightElement(block)
        })
      }
      updateCodeTheme()
      const title = getMarkdownTitle(stored) || markdownTitle.value || ''
      if (title && previewTitleRef.value) {
        previewTitleRef.value.textContent = title
        document.title = title
      }
      setTimeout(() => {
        generateTOC()
      }, 100)
    })
  }
})
</script>

<style scoped>
.markdown-preview {
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: hidden;
}

.fullscreen-preview {
  padding: 0;
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

.preview-section {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  overflow: hidden;
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: row;
}

.toc-sidebar {
  width: 280px;
  min-width: 280px;
  background: var(--color-surface-alt);
  border-right: 1px solid var(--color-border);
  overflow-y: auto;
  padding: var(--spacing-md);
  display: flex;
  flex-direction: column;
}

.toc-header {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin-bottom: var(--spacing-md);
  padding-bottom: var(--spacing-sm);
  border-bottom: 2px solid var(--color-border);
}

.toc-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.toc-item {
  margin-bottom: var(--spacing-xs);
}

.toc-link {
  display: block;
  padding: var(--spacing-xs) var(--spacing-sm);
  color: var(--color-text-secondary);
  text-decoration: none;
  border-radius: var(--radius-sm);
  transition: all 0.2s;
  font-size: var(--font-size-small);
  line-height: 1.5;
  word-break: break-word;
}

.toc-link:hover {
  background: var(--color-hover);
  color: var(--color-primary);
}

.toc-link.active {
  background: var(--color-primary);
  color: var(--color-text-on-primary);
  font-weight: var(--font-weight-semibold);
}

.toc-item-h1 .toc-link {
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  padding-left: var(--spacing-sm);
}

.toc-item-h2 .toc-link {
  padding-left: var(--spacing-md);
  font-size: var(--font-size-small);
}

.toc-item-h3 .toc-link {
  padding-left: var(--spacing-lg);
  font-size: var(--font-size-small);
}

.toc-item-h4 .toc-link {
  padding-left: var(--spacing-xl);
  font-size: var(--font-size-small);
}

.toc-item-h5 .toc-link,
.toc-item-h6 .toc-link {
  padding-left: var(--spacing-xxl);
  font-size: var(--font-size-small);
}

.preview-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.preview-content {
  flex: 1;
  padding: var(--spacing-xl);
  overflow-y: auto;
  background: var(--color-surface);
  color: var(--color-text);
  line-height: 1.8;
}

.preview-content.empty {
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-text-secondary);
  font-style: italic;
}

.preview-content :deep(h1[id]),
.preview-content :deep(h2[id]),
.preview-content :deep(h3[id]),
.preview-content :deep(h4[id]),
.preview-content :deep(h5[id]),
.preview-content :deep(h6[id]) {
  scroll-margin-top: 80px;
  position: relative;
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

@media (max-width: 1024px) {
  .toc-sidebar {
    display: none;
  }

  .preview-content {
    padding: var(--spacing-lg);
    line-height: 1.9;
  }
}
</style>