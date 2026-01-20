<template>
  <ToolLayout
    icon="📖"
    title="书本创作"
    description="管理书籍的卷、章节和内容"
  >
    <div class="book-editor">
      <div class="book-header">
        <div class="book-info">
          <div class="book-title">{{ bookData?.title || '加载中...' }}</div>
          <div class="book-meta">{{ bookData ? `${bookData.author} · ${bookData.category || '未分类'}` : '' }}</div>
        </div>
        <router-link to="/tools/text/writing" class="back-btn">
          <span>←</span>
          <span>返回书架</span>
        </router-link>
      </div>

      <div class="tabs">
        <button 
          :class="['tab', activeTab === 'writing' ? 'active' : '']" 
          @click="switchTab('writing')"
        >
          ✍️ 创作
        </button>
        <button 
          :class="['tab', activeTab === 'outline' ? 'active' : '']" 
          @click="switchTab('outline')"
        >
          📋 大纲
        </button>
        <button 
          :class="['tab', activeTab === 'notes' ? 'active' : '']" 
          @click="switchTab('notes')"
        >
          📝 备注
        </button>
      </div>

      <!-- 创作标签页 -->
      <div v-show="activeTab === 'writing'" class="tab-content">
        <div class="main-layout">
          <div class="sidebar">
            <div class="sidebar-section">
              <div class="sidebar-title">
                <span>📚</span>
                <span>卷/章节</span>
              </div>
              <AppButton variant="secondary" size="sm" icon="📁" @click="showAddVolumeModal">新建卷</AppButton>
              <AppButton variant="secondary" size="sm" icon="📄" @click="showAddChapterModal">新建章节</AppButton>
              <div class="volume-chapter-list">
                <!-- 卷列表 -->
                <div 
                  v-for="volume in volumes" 
                  :key="volume.id"
                  class="volume-container"
                >
                  <div 
                    :class="['volume-header', currentVolumeId === volume.id ? 'active' : '']"
                    @click="selectVolume(volume.id)"
                  >
                    <div class="volume-header-left">
                      <span 
                        :class="['volume-toggle', collapsedVolumes.has(volume.id) ? 'collapsed' : '']"
                        @click.stop="toggleVolume(volume.id)"
                      >
                        ▶
                      </span>
                      <span class="volume-title">{{ volume.name }}</span>
                      <span v-if="getVolumeChapters(volume.id).length > 0" class="volume-count">
                        ({{ getVolumeChapters(volume.id).length }})
                      </span>
                    </div>
                    <div class="volume-actions" @click.stop>
                      <button class="volume-action-btn" @click="deleteVolume(volume.id)">🗑️</button>
                    </div>
                  </div>
                  <div 
                    v-if="getVolumeChapters(volume.id).length > 0"
                    :class="['volume-chapters', collapsedVolumes.has(volume.id) ? 'collapsed' : '']"
                  >
                    <div 
                      v-for="chapter in getVolumeChapters(volume.id)"
                      :key="chapter.id"
                      :class="['chapter-item', currentChapterId === chapter.id ? 'active' : '']"
                      @click="selectChapter(chapter.id)"
                    >
                      <span class="chapter-name">{{ chapter.name }}</span>
                      <div class="chapter-actions" @click.stop>
                        <button class="chapter-action-btn" @click="deleteChapter(chapter.id)">🗑️</button>
                      </div>
                    </div>
                  </div>
                </div>
                <!-- 独立章节 -->
                <div 
                  v-for="chapter in ungroupedChapters"
                  :key="chapter.id"
                  :class="['standalone-chapter', currentChapterId === chapter.id ? 'active' : '']"
                  @click="selectChapter(chapter.id)"
                >
                  <span class="standalone-chapter-name">{{ chapter.name }}</span>
                  <div class="standalone-chapter-actions" @click.stop>
                    <button class="standalone-chapter-action-btn" @click="deleteChapter(chapter.id)">🗑️</button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="editor-area">
            <div class="editor-header">
              <input 
                v-model="chapterTitle"
                type="text" 
                class="editor-title-input" 
                placeholder="请输入章节标题..." 
                @input="saveCurrentChapter"
              />
              <AppButton variant="secondary" size="sm" icon="📥" @click="exportCurrentBookAsTxt" style="margin-left: var(--spacing-md);">导出TXT</AppButton>
            </div>
            <div 
              ref="editorContentRef"
              class="editor-content" 
              contenteditable="true" 
              placeholder="开始你的创作之旅..."
              @input="handleEditorInput"
              @keydown="handleEditorKeydown"
            ></div>
            <div class="editor-stats">
              <div>📊 字数: <span>{{ wordCount }}</span></div>
              <div>📄 段落: <span>{{ paragraphCount }}</span></div>
              <div>⏰ 最后保存: <span>{{ lastSave }}</span></div>
            </div>
          </div>
        </div>
      </div>

      <!-- 大纲标签页 -->
      <div v-show="activeTab === 'outline'" class="tab-content">
        <textarea 
          v-model="outline"
          class="outline-editor" 
          placeholder="在这里编写你的大纲..."
          @input="saveBookContent"
        ></textarea>
      </div>

      <!-- 备注标签页 -->
      <div v-show="activeTab === 'notes'" class="tab-content">
        <textarea 
          v-model="notes"
          class="notes-editor" 
          placeholder="在这里记录你的备注、灵感、想法..."
          @input="saveBookContent"
        ></textarea>
      </div>
    </div>

    <!-- 添加卷模态框 -->
    <div v-if="showVolumeModal" class="modal show" @click.self="closeVolumeModal">
      <div class="modal-content">
        <div class="modal-header">
          <span>新建卷</span>
          <button class="modal-close" @click="closeVolumeModal">&times;</button>
        </div>
        <div class="form-group">
          <label class="form-label">卷名称</label>
          <input 
            v-model="volumeNameInput"
            type="text" 
            class="form-input" 
            placeholder="例如：第一卷" 
            @keydown.enter.prevent="addVolume"
          />
        </div>
        <ButtonGroup gap="sm" class="modal-actions">
          <AppButton variant="secondary" @click="closeVolumeModal">取消</AppButton>
          <AppButton variant="primary" icon="✓" @click="addVolume">创建</AppButton>
        </ButtonGroup>
      </div>
    </div>

    <!-- 添加章节模态框 -->
    <div v-if="showChapterModal" class="modal show" @click.self="closeChapterModal">
      <div class="modal-content">
        <div class="modal-header">
          <span>新建章节</span>
          <button class="modal-close" @click="closeChapterModal">&times;</button>
        </div>
        <div class="form-group">
          <label class="form-label">章节名称</label>
          <input 
            v-model="chapterNameInput"
            type="text" 
            class="form-input" 
            placeholder="例如：第一章" 
            @keydown.enter.prevent="addChapter"
          />
        </div>
        <div class="form-group">
          <label class="form-label">所属卷（可选）</label>
          <select v-model="chapterVolumeSelect" class="form-input">
            <option value="">不归属于任何卷</option>
            <option v-for="volume in volumes" :key="volume.id" :value="volume.id">
              {{ volume.name }}
            </option>
          </select>
        </div>
        <ButtonGroup gap="sm" class="modal-actions">
          <AppButton variant="secondary" @click="closeChapterModal">取消</AppButton>
          <AppButton variant="primary" icon="✓" @click="addChapter">创建</AppButton>
        </ButtonGroup>
      </div>
    </div>
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()

const bookId = ref(null)
const bookData = ref(null)
const volumes = ref([])
const chapters = ref([])
const currentVolumeId = ref(null)
const currentChapterId = ref(null)
const collapsedVolumes = ref(new Set())
const activeTab = ref('writing')
const outline = ref('')
const notes = ref('')
const chapterTitle = ref('')
const editorContentRef = ref(null)
const wordCount = ref(0)
const paragraphCount = ref(0)
const lastSave = ref('--')
const showVolumeModal = ref(false)
const showChapterModal = ref(false)
const volumeNameInput = ref('')
const chapterNameInput = ref('')
const chapterVolumeSelect = ref('')

const ungroupedChapters = computed(() => {
  return chapters.value.filter(ch => !ch.volumeId)
})

function getVolumeChapters(volumeId) {
  return chapters.value.filter(ch => ch.volumeId === volumeId)
}

function loadBookData() {
  const books = JSON.parse(localStorage.getItem('writingAssistant_books') || '[]')
  bookData.value = books.find(b => b.id === bookId.value)

  if (!bookData.value) {
    alert('书籍不存在，将返回书架')
    router.push('/tools/text/writing')
    return
  }
}

function loadBookContent() {
  const saved = localStorage.getItem(`writingAssistant_book_${bookId.value}`)
  if (saved) {
    const data = JSON.parse(saved)
    volumes.value = data.volumes || []
    chapters.value = data.chapters || []
    currentVolumeId.value = data.currentVolumeId || null
    currentChapterId.value = data.currentChapterId || null
    outline.value = data.outline || ''
    notes.value = data.notes || ''

    if (data.collapsedVolumes) {
      collapsedVolumes.value = new Set(data.collapsedVolumes)
    }
  }
}

function saveBookContent() {
  const data = {
    volumes: volumes.value,
    chapters: chapters.value,
    currentVolumeId: currentVolumeId.value,
    currentChapterId: currentChapterId.value,
    outline: outline.value,
    notes: notes.value,
    collapsedVolumes: Array.from(collapsedVolumes.value)
  }
  localStorage.setItem(`writingAssistant_book_${bookId.value}`, JSON.stringify(data))
}

function switchTab(tabName) {
  activeTab.value = tabName
}

function toggleVolume(volumeId) {
  if (collapsedVolumes.value.has(volumeId)) {
    collapsedVolumes.value.delete(volumeId)
  } else {
    collapsedVolumes.value.add(volumeId)
  }
  saveBookContent()
}

function showAddVolumeModal() {
  volumeNameInput.value = ''
  showVolumeModal.value = true
}

function showAddChapterModal() {
  chapterNameInput.value = ''
  chapterVolumeSelect.value = currentVolumeId.value || ''
  showChapterModal.value = true
}

function closeVolumeModal() {
  showVolumeModal.value = false
}

function closeChapterModal() {
  showChapterModal.value = false
}

function addVolume() {
  const name = volumeNameInput.value.trim()
  if (!name) {
    alert('请输入卷名称')
    return
  }

  volumes.value.push({
    id: Date.now().toString(),
    name,
    bookId: bookId.value
  })

  saveBookContent()
  closeVolumeModal()
}

function addChapter() {
  const name = chapterNameInput.value.trim()
  if (!name) {
    alert('请输入章节名称')
    return
  }

  const newChapter = {
    id: Date.now().toString(),
    name,
    bookId: bookId.value,
    volumeId: chapterVolumeSelect.value || null,
    title: '',
    content: '',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }

  chapters.value.push(newChapter)
  saveBookContent()
  closeChapterModal()
  selectChapter(newChapter.id)
}

function selectVolume(volumeId) {
  saveCurrentChapter()
  currentVolumeId.value = volumeId
  currentChapterId.value = null
  saveBookContent()
  clearEditor()
}

function selectChapter(chapterId) {
  saveCurrentChapter()
  const chapter = chapters.value.find(ch => ch.id === chapterId)
  if (chapter) {
    currentVolumeId.value = chapter.volumeId || null
  }
  currentChapterId.value = chapterId
  saveBookContent()
  loadChapterContent()
}

function saveCurrentChapter() {
  if (!currentChapterId.value || !editorContentRef.value) return
  const chapter = chapters.value.find(ch => ch.id === currentChapterId.value)
  if (chapter) {
    chapter.title = chapterTitle.value
    chapter.content = editorContentRef.value.innerHTML
    chapter.updatedAt = new Date().toISOString()
    saveBookContent()
  }
}

function loadChapterContent() {
  if (!currentChapterId.value) {
    clearEditor()
    return
  }
  const chapter = chapters.value.find(ch => ch.id === currentChapterId.value)
  if (chapter && editorContentRef.value) {
    chapterTitle.value = chapter.title || ''
    editorContentRef.value.innerHTML = chapter.content || ''
    updateStats()
  }
}

function clearEditor() {
  chapterTitle.value = ''
  if (editorContentRef.value) {
    editorContentRef.value.innerHTML = ''
  }
  updateStats()
}

function deleteVolume(volumeId) {
  if (!confirm('确定要删除这个卷吗？卷下的章节也会被删除。')) return
  volumes.value = volumes.value.filter(v => v.id !== volumeId)
  chapters.value = chapters.value.filter(ch => ch.volumeId !== volumeId)
  if (currentVolumeId.value === volumeId) {
    currentVolumeId.value = null
    currentChapterId.value = null
    clearEditor()
  }
  saveBookContent()
}

function deleteChapter(chapterId) {
  if (!confirm('确定要删除这个章节吗？')) return
  chapters.value = chapters.value.filter(ch => ch.id !== chapterId)
  if (currentChapterId.value === chapterId) {
    currentChapterId.value = null
    clearEditor()
  }
  saveBookContent()
}

function handleEditorInput() {
  updateStats()
  saveCurrentChapter()
}

function handleEditorKeydown(e) {
  if (e.key === 'Tab') {
    e.preventDefault()
    const selection = window.getSelection()
    if (selection.rangeCount > 0) {
      const range = selection.getRangeAt(0)
      const tab = document.createTextNode('\u00A0\u00A0\u00A0\u00A0')
      range.insertNode(tab)
      range.setStartAfter(tab)
      range.collapse(true)
      selection.removeAllRanges()
      selection.addRange(range)
    }
  }
}

function updateStats() {
  if (!editorContentRef.value) return
  const content = editorContentRef.value.innerText || ''
  wordCount.value = content.trim().length
  paragraphCount.value = content.split('\n').filter(p => p.trim()).length
}

function setupAutoSave() {
  setInterval(() => {
    saveCurrentChapter()
    saveBookContent()
    lastSave.value = new Date().toLocaleTimeString('zh-CN')
  }, 30000)
}

function exportCurrentBookAsTxt() {
  if (!bookData.value) {
    alert('书籍信息不存在')
    return
  }

  saveCurrentChapter()
  saveBookContent()

  const bookContent = localStorage.getItem(`writingAssistant_book_${bookId.value}`)
  if (!bookContent) {
    alert('这本书还没有创作内容')
    return
  }

  const content = JSON.parse(bookContent)
  let txtContent = ''

  txtContent += `书名：${bookData.value.title}\n`
  txtContent += `作者：${bookData.value.author}\n`
  if (bookData.value.category) txtContent += `分类：${bookData.value.category}\n`
  if (bookData.value.description) txtContent += `简介：${bookData.value.description}\n`
  txtContent += '\n' + '='.repeat(50) + '\n\n'

  if (content.outline) {
    txtContent += '【大纲】\n'
    txtContent += content.outline + '\n\n'
    txtContent += '='.repeat(50) + '\n\n'
  }

  if (content.chapters && content.chapters.length > 0) {
    const volumes = content.volumes || []

    volumes.forEach(volume => {
      const volumeChapters = content.chapters.filter(ch => ch.volumeId === volume.id)
      if (volumeChapters.length > 0) {
        txtContent += `\n【${volume.name}】\n\n`
        volumeChapters.forEach(chapter => {
          txtContent += `${chapter.name}\n`
          if (chapter.title) txtContent += `标题：${chapter.title}\n`
          if (chapter.content) {
            const textContent = chapter.content.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&').trim()
            txtContent += textContent + '\n\n'
          }
          txtContent += '-'.repeat(30) + '\n\n'
        })
      }
    })

    const ungroupedChapters = content.chapters.filter(ch => !ch.volumeId)
    if (ungroupedChapters.length > 0) {
      txtContent += '\n【独立章节】\n\n'
      ungroupedChapters.forEach(chapter => {
        txtContent += `${chapter.name}\n`
        if (chapter.title) txtContent += `标题：${chapter.title}\n`
        if (chapter.content) {
          const textContent = chapter.content.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&').trim()
          txtContent += textContent + '\n\n'
        }
        txtContent += '-'.repeat(30) + '\n\n'
      })
    }
  }

  if (content.notes) {
    txtContent += '\n' + '='.repeat(50) + '\n\n'
    txtContent += '【备注】\n'
    txtContent += content.notes + '\n'
  }

  const blob = new Blob([txtContent], { type: 'text/plain;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `${bookData.value.title}.txt`
  a.click()
  URL.revokeObjectURL(url)

  alert('导出成功！')
}

onMounted(() => {
  bookId.value = route.query.bookId

  if (!bookId.value) {
    alert('缺少书籍ID，将返回书架')
    router.push('/tools/text/writing')
    return
  }

  loadBookData()
  loadBookContent()
  setupAutoSave()
  
  nextTick(() => {
    if (currentChapterId.value) {
      loadChapterContent()
    }
  })
})
</script>

<style scoped>
.book-editor {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-lg);
}

.book-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-lg);
  padding: var(--spacing-md);
  background: var(--color-surface);
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border);
}

.book-info {
  flex: 1;
}

.book-title {
  font-size: var(--font-size-large);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin-bottom: var(--spacing-xs);
}

.book-meta {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}

.back-btn {
  padding: var(--spacing-sm) var(--spacing-md);
  background: var(--color-surface-alt);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  color: var(--color-text);
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  transition: all 0.2s;
}

.back-btn:hover {
  background: var(--color-hover);
  border-color: var(--color-primary);
}

.tabs {
  display: flex;
  gap: var(--spacing-xs);
  margin-bottom: var(--spacing-lg);
  border-bottom: 2px solid var(--color-border);
  flex-wrap: wrap;
}

.tab {
  padding: var(--spacing-md) var(--spacing-lg);
  background: transparent;
  border: none;
  border-bottom: 3px solid transparent;
  color: var(--color-text-secondary);
  cursor: pointer;
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  transition: all 0.3s;
  position: relative;
  margin-bottom: -2px;
}

.tab:hover {
  color: var(--color-primary);
  background: var(--color-hover);
}

.tab.active {
  color: var(--color-primary);
  border-bottom-color: var(--color-primary);
}

.main-layout {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: var(--spacing-lg);
  height: calc(100vh - 350px);
  min-height: 600px;
}

.sidebar {
  background: var(--color-surface);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  border: 1px solid var(--color-border);
  overflow-y: auto;
}

.sidebar-section {
  margin-bottom: var(--spacing-xl);
}

.sidebar-title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin-bottom: var(--spacing-md);
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  padding-bottom: var(--spacing-sm);
  border-bottom: 2px solid var(--color-border);
}

.btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  padding: var(--spacing-sm) var(--spacing-md);
  border-radius: var(--radius-sm);
  border: none;
  cursor: pointer;
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-semibold);
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
  width: 100%;
  justify-content: center;
  margin-bottom: var(--spacing-sm);
}

.btn:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.btn-secondary {
  background: var(--color-surface-alt);
  color: var(--color-text);
  border: 1px solid var(--color-border);
}

.btn-secondary:hover {
  background: var(--color-hover);
}

.volume-chapter-list {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.volume-container {
  background: var(--color-surface-alt);
  border-radius: var(--radius-md);
  border: 1px solid var(--color-border);
  margin-bottom: var(--spacing-md);
  overflow: hidden;
  transition: all 0.2s;
}

.volume-container:hover {
  border-color: var(--color-primary);
  box-shadow: var(--shadow-sm);
}

.volume-header {
  padding: var(--spacing-md);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--color-surface-alt);
  transition: background 0.2s;
  user-select: none;
}

.volume-header:hover {
  background: var(--color-hover);
}

.volume-header.active {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
}

.volume-header-left {
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
  flex: 1;
}

.volume-toggle {
  cursor: pointer;
  user-select: none;
  font-size: 12px;
  transition: transform 0.2s;
  width: 20px;
  text-align: center;
}

.volume-toggle.collapsed {
  transform: rotate(-90deg);
}

.volume-title {
  font-weight: var(--font-weight-semibold);
  font-size: var(--font-size-base);
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.volume-count {
  font-size: var(--font-size-small);
  opacity: 0.7;
  margin-left: var(--spacing-xs);
}

.volume-actions {
  display: flex;
  gap: var(--spacing-xs);
  opacity: 0;
  transition: opacity 0.2s;
}

.volume-header:hover .volume-actions {
  opacity: 1;
}

.volume-action-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 4px 8px;
  font-size: 12px;
  color: var(--color-text-secondary);
  transition: color 0.2s;
}

.volume-action-btn:hover {
  color: var(--color-error);
}

.volume-chapters {
  padding: 0 var(--spacing-md) var(--spacing-md) var(--spacing-md);
  max-height: 2000px;
  overflow: hidden;
  transition: max-height 0.3s ease-out, opacity 0.3s ease-out;
  opacity: 1;
}

.volume-chapters.collapsed {
  max-height: 0;
  opacity: 0;
  padding: 0 var(--spacing-md);
}

.chapter-item {
  padding: var(--spacing-sm) var(--spacing-lg);
  margin: var(--spacing-xs) 0;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-radius: var(--radius-sm);
  position: relative;
}

.chapter-item::before {
  content: '•';
  position: absolute;
  left: 0;
  color: var(--color-text-secondary);
  font-size: 16px;
}

.chapter-item:hover {
  background: var(--color-hover);
  transform: translateX(4px);
}

.chapter-item.active {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
}

.chapter-item.active::before {
  color: var(--color-text-on-primary);
}

.chapter-name {
  flex: 1;
  font-size: var(--font-size-small);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-left: var(--spacing-sm);
}

.chapter-actions {
  display: flex;
  gap: var(--spacing-xs);
  opacity: 0;
  transition: opacity 0.2s;
}

.chapter-item:hover .chapter-actions {
  opacity: 1;
}

.chapter-action-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 2px 6px;
  font-size: 12px;
  color: var(--color-text-secondary);
  transition: color 0.2s;
}

.chapter-action-btn:hover {
  color: var(--color-error);
}

.standalone-chapter {
  padding: var(--spacing-sm) var(--spacing-md);
  margin-bottom: var(--spacing-xs);
  background: var(--color-surface-alt);
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.standalone-chapter:hover {
  background: var(--color-hover);
  border-color: var(--color-primary);
  transform: translateX(4px);
}

.standalone-chapter.active {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border-color: var(--color-primary);
}

.standalone-chapter-name {
  flex: 1;
  font-size: var(--font-size-small);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.standalone-chapter-actions {
  display: flex;
  gap: var(--spacing-xs);
  opacity: 0;
  transition: opacity 0.2s;
}

.standalone-chapter:hover .standalone-chapter-actions {
  opacity: 1;
}

.standalone-chapter-action-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 2px 6px;
  font-size: 12px;
  color: var(--color-text-secondary);
  transition: color 0.2s;
}

.standalone-chapter-action-btn:hover {
  color: var(--color-error);
}

.editor-area {
  background: var(--color-surface);
  border-radius: var(--radius-md);
  padding: var(--spacing-xl);
  border: 1px solid var(--color-border);
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.editor-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: var(--spacing-lg);
  padding-bottom: var(--spacing-md);
  border-bottom: 2px solid var(--color-border);
}

.editor-title-input {
  font-size: var(--font-size-xlarge);
  font-weight: var(--font-weight-bold);
  border: none;
  background: transparent;
  color: var(--color-text);
  flex: 1;
  padding: var(--spacing-sm);
}

.editor-title-input:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: 4px;
  border-radius: var(--radius-sm);
}

.editor-content {
  flex: 1;
  overflow-y: auto;
  padding: var(--spacing-lg);
  background: var(--color-surface-alt);
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  font-family: 'Georgia', 'Times New Roman', serif;
  font-size: 18px;
  line-height: 1.8;
  color: var(--color-text);
  min-height: 400px;
}

.editor-content:focus {
  outline: none;
}

.editor-stats {
  display: flex;
  gap: var(--spacing-lg);
  margin-top: var(--spacing-md);
  padding-top: var(--spacing-md);
  border-top: 1px solid var(--color-border);
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
}

.outline-editor,
.notes-editor {
  min-height: 500px;
  padding: var(--spacing-lg);
  background: var(--color-surface-alt);
  border-radius: var(--radius-sm);
  border: 1px solid var(--color-border);
  font-family: var(--font-family);
  font-size: var(--font-size-base);
  color: var(--color-text);
  width: 100%;
}

.outline-editor:focus,
.notes-editor:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: 4px;
}

.modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(5px);
  z-index: 1000;
  align-items: center;
  justify-content: center;
}

.modal.show {
  display: flex;
}

.modal-content {
  background: var(--color-surface);
  border-radius: var(--radius-lg);
  padding: var(--spacing-xl);
  max-width: 500px;
  width: 90%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  border: 1px solid var(--color-border);
}

.modal-header {
  font-size: var(--font-size-large);
  font-weight: var(--font-weight-bold);
  margin-bottom: var(--spacing-lg);
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: var(--color-text);
}

.modal-close {
  background: transparent;
  border: none;
  font-size: var(--font-size-xlarge);
  cursor: pointer;
  color: var(--color-text-secondary);
}

.form-group {
  margin-bottom: var(--spacing-lg);
}

.form-label {
  display: block;
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text);
  margin-bottom: var(--spacing-xs);
}

.form-input {
  width: 100%;
  padding: var(--spacing-sm) var(--spacing-md);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  font-family: var(--font-family);
  background: var(--color-surface);
  color: var(--color-text);
}

.form-input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.modal-actions {
  display: flex;
  gap: var(--spacing-md);
  justify-content: flex-end;
  margin-top: var(--spacing-lg);
}

@media (max-width: 968px) {
  .main-layout {
    grid-template-columns: 1fr;
    height: auto;
  }

  .sidebar {
    max-height: 300px;
  }
}
</style>