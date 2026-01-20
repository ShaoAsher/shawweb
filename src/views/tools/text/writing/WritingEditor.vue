<template>
  <ToolLayout
    icon="✍️"
    title="写作编辑器"
    description="专业的写作助手，支持大纲、卷、章节管理"
  >
    <div class="writing-editor" :class="{ 'dark-theme': isDarkTheme }">
      <div class="main-layout">
        <!-- 左侧边栏：大纲、卷和章节 -->
        <div class="sidebar">
          <div class="sidebar-section">
            <div class="sidebar-title">
              <span>📋</span>
              <span>大纲管理</span>
            </div>
            <AppButton variant="primary" size="sm" icon="➕" @click="showAddOutlineModal">新建大纲</AppButton>
            <ul class="outline-list">
              <li v-if="outlines.length === 0" class="empty-state">
                <div class="empty-state-icon">📋</div>
                <div>暂无大纲</div>
              </li>
              <li 
                v-for="outline in outlines" 
                :key="outline.id"
                :class="['outline-item', currentOutlineId === outline.id ? 'active' : '']"
                @click="selectOutline(outline.id)"
              >
                <span class="item-name" :title="outline.name">{{ outline.name }}</span>
                <div class="item-actions" @click.stop>
                  <button class="item-action-btn" @click="deleteOutline(outline.id)" title="删除">🗑️</button>
                </div>
              </li>
            </ul>
          </div>

          <div class="sidebar-section">
            <div class="sidebar-title">
              <span>📚</span>
              <span>卷/章节列表</span>
            </div>
            <AppButton variant="secondary" size="sm" icon="📁" :disabled="!currentOutlineId" @click="showAddVolumeModal">新建卷</AppButton>
            <AppButton variant="secondary" size="sm" icon="📄" :disabled="!currentOutlineId" @click="showAddChapterModal">新建章节</AppButton>
            <ul class="volume-list">
              <li v-if="!currentOutlineId" class="empty-state">
                <div class="empty-state-icon">📚</div>
                <div>请先选择大纲</div>
              </li>
              <template v-else>
                <li v-if="outlineVolumes.length === 0 && outlineChapters.length === 0" class="empty-state">
                  <div class="empty-state-icon">📚</div>
                  <div>暂无内容</div>
                </li>
                <!-- 卷及其下的章节 -->
                <template v-for="volume in outlineVolumes" :key="volume.id">
                  <li 
                    :class="['volume-item', currentVolumeId === volume.id ? 'active' : '']"
                    @click="selectVolume(volume.id)"
                  >
                    <span class="item-name" :title="volume.name">{{ volume.name }}</span>
                    <div class="item-actions" @click.stop>
                      <button class="item-action-btn" @click="deleteVolume(volume.id)" title="删除">🗑️</button>
                    </div>
                  </li>
                  <!-- 该卷下的章节 -->
                  <li 
                    v-for="chapter in getVolumeChapters(volume.id)"
                    :key="chapter.id"
                    :class="['chapter-item', currentChapterId === chapter.id ? 'active' : '']"
                    @click="selectChapter(chapter.id)"
                  >
                    <span class="item-name" :title="chapter.name">{{ chapter.name }}</span>
                    <div class="item-actions" @click.stop>
                      <button class="item-action-btn" @click="deleteChapter(chapter.id)" title="删除">🗑️</button>
                    </div>
                  </li>
                </template>
                <!-- 不属于任何卷的章节 -->
                <li 
                  v-for="chapter in outlineChapters"
                  :key="chapter.id"
                  :class="['chapter-item', currentChapterId === chapter.id ? 'active' : '']"
                  @click="selectChapter(chapter.id)"
                >
                  <span class="item-name" :title="chapter.name">{{ chapter.name }}</span>
                  <div class="item-actions" @click.stop>
                    <button class="item-action-btn" @click="deleteChapter(chapter.id)" title="删除">🗑️</button>
                  </div>
                </li>
              </template>
            </ul>
          </div>
        </div>

        <!-- 中间：编辑器 -->
        <div class="editor-area">
          <div class="editor-header">
            <input 
              v-model="chapterTitle"
              type="text" 
              class="editor-title-input" 
              placeholder="请输入标题..." 
              @input="saveCurrentChapter"
            />
            <div class="editor-toolbar">
              <button class="toolbar-btn" @click="exportContent" title="导出内容">
                <span>📥</span>
                <span>导出</span>
              </button>
            </div>
          </div>
          <div 
            ref="editorContentRef"
            class="editor-content" 
            contenteditable="true" 
            placeholder="开始你的创作之旅..."
            @input="handleEditorInput"
          ></div>
          <div class="editor-stats">
            <div class="stat-item">
              <span>📊</span>
              <span>字数: <span>{{ wordCount }}</span></span>
            </div>
            <div class="stat-item">
              <span>📄</span>
              <span>段落: <span>{{ paragraphCount }}</span></span>
            </div>
            <div class="stat-item">
              <span>⏰</span>
              <span>最后保存: <span>{{ lastSave }}</span></span>
            </div>
          </div>
        </div>

        <!-- 右侧：信息面板 -->
        <div class="info-panel">
          <div class="info-section">
            <div class="info-label">当前大纲</div>
            <div class="info-value">{{ currentOutlineName }}</div>
          </div>
          <div class="info-section">
            <div class="info-label">当前卷</div>
            <div class="info-value">{{ currentVolumeName }}</div>
          </div>
          <div class="info-section">
            <div class="info-label">当前章节</div>
            <div class="info-value">{{ currentChapterName }}</div>
          </div>
          <div class="info-section">
            <div class="info-label">创建时间</div>
            <div class="info-value">{{ createTime }}</div>
          </div>
          <div class="info-section">
            <div class="info-label">修改时间</div>
            <div class="info-value">{{ modifyTime }}</div>
          </div>
          <div class="info-section">
            <div class="info-label">总字数</div>
            <div class="info-value">{{ totalWords }}</div>
          </div>
          <div class="info-section">
            <div class="info-label">操作</div>
            <AppButton variant="danger" size="sm" icon="🗑️" @click="clearAllData" style="margin-top: var(--spacing-sm);">清空所有数据</AppButton>
          </div>
        </div>
      </div>
    </div>

    <!-- 添加大纲模态框 -->
    <div v-if="showOutlineModal" class="modal show" @click.self="closeOutlineModal">
      <div class="modal-content">
        <div class="modal-header">
          <span>新建大纲</span>
          <button class="modal-close" @click="closeOutlineModal">&times;</button>
        </div>
        <div class="form-group">
          <label class="form-label">大纲名称</label>
          <input 
            v-model="outlineNameInput"
            type="text" 
            class="form-input" 
            placeholder="例如：我的小说大纲" 
            @keydown.enter.prevent="addOutline"
          />
        </div>
        <div class="form-group">
          <label class="form-label">大纲描述</label>
          <textarea 
            v-model="outlineDescInput"
            class="form-textarea" 
            placeholder="简要描述这个大纲的内容..."
          ></textarea>
        </div>
        <div class="modal-actions">
          <AppButton variant="secondary" @click="closeOutlineModal">取消</AppButton>
          <AppButton variant="primary" icon="✓" @click="addOutline">创建</AppButton>
        </div>
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
            placeholder="例如：第一卷 初入江湖" 
            @keydown.enter.prevent="addVolume"
          />
        </div>
        <div class="form-group">
          <label class="form-label">卷描述</label>
          <textarea 
            v-model="volumeDescInput"
            class="form-textarea" 
            placeholder="简要描述这个卷的内容..."
          ></textarea>
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
            placeholder="例如：第一章 开始" 
            @keydown.enter.prevent="addChapter"
          />
        </div>
        <div class="form-group">
          <label class="form-label">章节简介</label>
          <textarea 
            v-model="chapterDescInput"
            class="form-textarea" 
            placeholder="简要描述这个章节的内容..."
          ></textarea>
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
import { ref, computed, onMounted, nextTick, watch } from 'vue'

const outlines = ref([])
const volumes = ref([])
const chapters = ref([])
const currentOutlineId = ref(null)
const currentVolumeId = ref(null)
const currentChapterId = ref(null)
const chapterTitle = ref('')
const editorContentRef = ref(null)
const wordCount = ref(0)
const paragraphCount = ref(0)
const lastSave = ref('--')
const isDarkTheme = ref(false)

const showOutlineModal = ref(false)
const showVolumeModal = ref(false)
const showChapterModal = ref(false)
const outlineNameInput = ref('')
const outlineDescInput = ref('')
const volumeNameInput = ref('')
const volumeDescInput = ref('')
const chapterNameInput = ref('')
const chapterDescInput = ref('')

const outlineVolumes = computed(() => {
  if (!currentOutlineId.value) return []
  return volumes.value.filter(v => v.outlineId === currentOutlineId.value)
})

const outlineChapters = computed(() => {
  if (!currentOutlineId.value) return []
  return chapters.value.filter(ch => ch.outlineId === currentOutlineId.value && !ch.volumeId)
})

const currentOutlineName = computed(() => {
  const outline = outlines.value.find(o => o.id === currentOutlineId.value)
  return outline ? outline.name : '未选择'
})

const currentVolumeName = computed(() => {
  const volume = volumes.value.find(v => v.id === currentVolumeId.value)
  return volume ? volume.name : '未选择'
})

const currentChapterName = computed(() => {
  const chapter = chapters.value.find(ch => ch.id === currentChapterId.value)
  return chapter ? chapter.name : '未选择'
})

const createTime = computed(() => {
  const chapter = chapters.value.find(ch => ch.id === currentChapterId.value)
  return chapter ? new Date(chapter.createdAt).toLocaleString('zh-CN') : '--'
})

const modifyTime = computed(() => {
  const chapter = chapters.value.find(ch => ch.id === currentChapterId.value)
  return chapter ? new Date(chapter.updatedAt).toLocaleString('zh-CN') : '--'
})

const totalWords = computed(() => {
  return chapters.value.reduce((sum, ch) => {
    return sum + (ch.content ? ch.content.replace(/<[^>]*>/g, '').length : 0)
  }, 0)
})

function getVolumeChapters(volumeId) {
  return chapters.value.filter(ch => ch.volumeId === volumeId)
}

function loadData() {
  const savedOutlines = localStorage.getItem('writingEditor_outlines')
  const savedVolumes = localStorage.getItem('writingEditor_volumes')
  const savedChapters = localStorage.getItem('writingEditor_chapters')
  const savedCurrentOutline = localStorage.getItem('writingEditor_currentOutline')
  const savedCurrentVolume = localStorage.getItem('writingEditor_currentVolume')
  const savedCurrentChapter = localStorage.getItem('writingEditor_currentChapter')

  if (savedOutlines) outlines.value = JSON.parse(savedOutlines)
  if (savedVolumes) volumes.value = JSON.parse(savedVolumes)
  if (savedChapters) chapters.value = JSON.parse(savedChapters)
  if (savedCurrentOutline) currentOutlineId.value = savedCurrentOutline
  if (savedCurrentVolume) currentVolumeId.value = savedCurrentVolume
  if (savedCurrentChapter) currentChapterId.value = savedCurrentChapter
}

function saveData() {
  localStorage.setItem('writingEditor_outlines', JSON.stringify(outlines.value))
  localStorage.setItem('writingEditor_volumes', JSON.stringify(volumes.value))
  localStorage.setItem('writingEditor_chapters', JSON.stringify(chapters.value))
  localStorage.setItem('writingEditor_currentOutline', currentOutlineId.value)
  localStorage.setItem('writingEditor_currentVolume', currentVolumeId.value)
  localStorage.setItem('writingEditor_currentChapter', currentChapterId.value)
}

function updateThemeBackground() {
  const theme = localStorage.getItem('theme') || 'purple'
  isDarkTheme.value = theme === 'dark' || theme === 'modern' || theme === 'cyberpunk'
}

function showAddOutlineModal() {
  outlineNameInput.value = ''
  outlineDescInput.value = ''
  showOutlineModal.value = true
}

function showAddVolumeModal() {
  if (!currentOutlineId.value) {
    alert('请先选择一个大纲')
    return
  }
  volumeNameInput.value = ''
  volumeDescInput.value = ''
  showVolumeModal.value = true
}

function showAddChapterModal() {
  if (!currentOutlineId.value) {
    alert('请先选择一个大纲')
    return
  }
  chapterNameInput.value = ''
  chapterDescInput.value = ''
  showChapterModal.value = true
}

function closeOutlineModal() {
  showOutlineModal.value = false
}

function closeVolumeModal() {
  showVolumeModal.value = false
}

function closeChapterModal() {
  showChapterModal.value = false
}

function addOutline() {
  const name = outlineNameInput.value.trim()
  if (!name) {
    alert('请输入大纲名称')
    return
  }

  const outline = {
    id: Date.now().toString(),
    name: name,
    description: outlineDescInput.value.trim(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }

  outlines.value.push(outline)
  saveData()
  closeOutlineModal()
  selectOutline(outline.id)
}

function addVolume() {
  if (!currentOutlineId.value) {
    alert('请先选择一个大纲')
    return
  }

  const name = volumeNameInput.value.trim()
  if (!name) {
    alert('请输入卷名称')
    return
  }

  const volume = {
    id: Date.now().toString(),
    outlineId: currentOutlineId.value,
    name: name,
    description: volumeDescInput.value.trim(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }

  volumes.value.push(volume)
  saveData()
  closeVolumeModal()
}

function addChapter() {
  if (!currentOutlineId.value) {
    alert('请先选择一个大纲')
    return
  }

  const name = chapterNameInput.value.trim()
  if (!name) {
    alert('请输入章节名称')
    return
  }

  const chapter = {
    id: Date.now().toString(),
    outlineId: currentOutlineId.value,
    volumeId: currentVolumeId.value || null,
    name: name,
    description: chapterDescInput.value.trim(),
    title: '',
    content: '',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }

  chapters.value.push(chapter)
  saveData()
  closeChapterModal()
  selectChapter(chapter.id)
}

function selectOutline(outlineId) {
  saveCurrentChapter()
  currentOutlineId.value = outlineId
  currentVolumeId.value = null
  currentChapterId.value = null
  saveData()
  clearEditor()
}

function selectVolume(volumeId) {
  saveCurrentChapter()
  currentVolumeId.value = volumeId
  currentChapterId.value = null
  saveData()
  clearEditor()
}

function selectChapter(chapterId) {
  saveCurrentChapter()
  const chapter = chapters.value.find(ch => ch.id === chapterId)
  if (chapter) {
    currentVolumeId.value = chapter.volumeId || null
  }
  currentChapterId.value = chapterId
  saveData()
  loadChapterContent()
}

function saveCurrentChapter() {
  if (!currentChapterId.value || !editorContentRef.value) return

  const chapter = chapters.value.find(ch => ch.id === currentChapterId.value)
  if (chapter) {
    chapter.title = chapterTitle.value
    chapter.content = editorContentRef.value.innerHTML
    chapter.updatedAt = new Date().toISOString()
    saveData()
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

function deleteOutline(outlineId) {
  if (!confirm('确定要删除这个大纲吗？相关的卷和章节也会被删除。')) return

  outlines.value = outlines.value.filter(o => o.id !== outlineId)
  volumes.value = volumes.value.filter(v => v.outlineId !== outlineId)
  chapters.value = chapters.value.filter(ch => ch.outlineId !== outlineId)

  if (currentOutlineId.value === outlineId) {
    currentOutlineId.value = null
    currentVolumeId.value = null
    currentChapterId.value = null
  }

  saveData()
  clearEditor()
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

  saveData()
}

function deleteChapter(chapterId) {
  if (!confirm('确定要删除这个章节吗？')) return

  chapters.value = chapters.value.filter(ch => ch.id !== chapterId)

  if (currentChapterId.value === chapterId) {
    currentChapterId.value = null
    clearEditor()
  }

  saveData()
}

function handleEditorInput() {
  updateStats()
  saveCurrentChapter()
}

function updateStats() {
  if (!editorContentRef.value) return
  const content = editorContentRef.value.innerText || ''
  wordCount.value = content.trim().length
  paragraphCount.value = content.split('\n').filter(p => p.trim()).length
}

function setupAutoSave() {
  setInterval(() => {
    if (currentChapterId.value) {
      saveCurrentChapter()
      updateLastSave()
    }
  }, 30000)
}

function updateLastSave() {
  lastSave.value = new Date().toLocaleTimeString('zh-CN')
}

function exportContent() {
  const title = chapterTitle.value || '未命名文档'
  const content = editorContentRef.value?.innerText || editorContentRef.value?.innerHTML || ''

  const blob = new Blob([`${title}\n\n${content}`], { type: 'text/plain;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `${title}.txt`
  a.click()
  URL.revokeObjectURL(url)
}

function clearAllData() {
  if (!confirm('确定要清空所有数据吗？此操作不可恢复！')) return

  outlines.value = []
  volumes.value = []
  chapters.value = []
  currentOutlineId.value = null
  currentVolumeId.value = null
  currentChapterId.value = null

  saveData()
  clearEditor()
  alert('所有数据已清空')
}

onMounted(() => {
  loadData()
  updateThemeBackground()
  setupAutoSave()

  // 监听主题变化
  const observer = new MutationObserver(() => {
    updateThemeBackground()
  })
  observer.observe(document.body, { attributes: true, attributeFilter: ['data-theme'] })

  nextTick(() => {
    if (currentChapterId.value) {
      loadChapterContent()
    }
  })
})
</script>

<style scoped>
.writing-editor {
  min-height: calc(100vh - 200px);
}

.writing-editor.dark-theme {
  background: linear-gradient(135deg, #3d2e1f 0%, #4a3a2a 50%, #3d2e1f 100%);
  background-image:
    repeating-linear-gradient(90deg,
      transparent,
      transparent 2px,
      rgba(0, 0, 0, 0.1) 2px,
      rgba(0, 0, 0, 0.1) 4px),
    repeating-linear-gradient(0deg,
      transparent,
      transparent 2px,
      rgba(0, 0, 0, 0.1) 2px,
      rgba(0, 0, 0, 0.1) 4px),
    radial-gradient(circle at 20% 50%,
      rgba(61, 46, 31, 0.5) 0%,
      transparent 50%),
    radial-gradient(circle at 80% 80%,
      rgba(74, 58, 42, 0.4) 0%,
      transparent 50%);
}

.main-layout {
  display: grid;
  grid-template-columns: 300px 1fr 320px;
  gap: var(--spacing-lg);
  height: calc(100vh - 200px);
  min-height: 600px;
}

.sidebar {
  background: var(--color-surface);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  border: 1px solid var(--color-border);
  backdrop-filter: blur(10px);
  overflow-y: auto;
}

.sidebar-section {
  margin-bottom: var(--spacing-xl);
}

.sidebar-section:last-child {
  margin-bottom: 0;
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

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-secondary {
  background: var(--color-surface-alt);
  color: var(--color-text);
  border: 1px solid var(--color-border);
}

.btn-secondary:hover {
  background: var(--color-hover);
}

.outline-list,
.volume-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.outline-item,
.volume-item,
.chapter-item {
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

.outline-item:hover,
.volume-item:hover,
.chapter-item:hover {
  background: var(--color-hover);
  border-color: var(--color-primary);
  transform: translateX(4px);
}

.outline-item.active,
.volume-item.active,
.chapter-item.active {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary);
  border-color: var(--color-primary);
}

.volume-item {
  padding-left: var(--spacing-xl);
  font-weight: var(--font-weight-semibold);
}

.chapter-item {
  padding-left: var(--spacing-xxl);
  font-size: var(--font-size-small);
}

.item-name {
  flex: 1;
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-medium);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-actions {
  display: flex;
  gap: var(--spacing-xs);
  opacity: 0;
  transition: opacity 0.2s;
}

.outline-item:hover .item-actions,
.volume-item:hover .item-actions,
.chapter-item:hover .item-actions {
  opacity: 1;
}

.item-action-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 2px 6px;
  font-size: 12px;
  color: var(--color-text-secondary);
  transition: all 0.2s;
}

.item-action-btn:hover {
  color: var(--color-error);
  transform: scale(1.2);
}

.editor-area {
  background: var(--color-surface);
  border-radius: var(--radius-md);
  padding: var(--spacing-xl);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  border: 1px solid var(--color-border);
  backdrop-filter: blur(10px);
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
  border-radius: var(--radius-sm);
}

.editor-title-input:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: 4px;
}

.editor-toolbar {
  display: flex;
  gap: var(--spacing-sm);
  flex-wrap: wrap;
}

.toolbar-btn {
  background: var(--color-surface-alt);
  border: 1px solid var(--color-border);
  color: var(--color-text);
  padding: var(--spacing-xs) var(--spacing-sm);
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: var(--font-size-small);
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
}

.toolbar-btn:hover {
  background: var(--color-hover);
  border-color: var(--color-primary);
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
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.05);
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

.stat-item {
  display: flex;
  align-items: center;
  gap: var(--spacing-xs);
}

.info-panel {
  background: var(--color-surface);
  border-radius: var(--radius-md);
  padding: var(--spacing-lg);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  border: 1px solid var(--color-border);
  backdrop-filter: blur(10px);
  overflow-y: auto;
}

.info-section {
  margin-bottom: var(--spacing-lg);
}

.info-section:last-child {
  margin-bottom: 0;
}

.info-label {
  font-size: var(--font-size-small);
  font-weight: var(--font-weight-semibold);
  color: var(--color-text-secondary);
  margin-bottom: var(--spacing-xs);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-value {
  font-size: var(--font-size-base);
  color: var(--color-text);
  font-weight: var(--font-weight-medium);
}

.empty-state {
  text-align: center;
  padding: var(--spacing-xxl);
  color: var(--color-text-light);
}

.empty-state-icon {
  font-size: 48px;
  margin-bottom: var(--spacing-md);
  opacity: 0.5;
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
  transition: color 0.2s;
}

.modal-close:hover {
  color: var(--color-text);
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

.form-input,
.form-textarea {
  width: 100%;
  padding: var(--spacing-sm) var(--spacing-md);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  font-family: var(--font-family);
  background: var(--color-surface);
  color: var(--color-text);
  transition: border-color 0.2s;
}

.form-input:focus,
.form-textarea:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.form-textarea {
  min-height: 120px;
  resize: vertical;
}

.modal-actions {
  display: flex;
  gap: var(--spacing-md);
  justify-content: flex-end;
}

@media (max-width: 1200px) {
  .main-layout {
    grid-template-columns: 260px 1fr 280px;
  }
}

@media (max-width: 968px) {
  .main-layout {
    grid-template-columns: 1fr;
    grid-template-rows: auto auto 1fr;
    height: auto;
  }

  .sidebar,
  .info-panel {
    max-height: 200px;
  }
}
</style>