<template>
  <ToolLayout
    icon="📚"
    title="我的书架"
    description="管理你的书籍和创作内容"
  >
    <div class="book-home">
      <div class="bookshelf-header">
        <h2 class="bookshelf-title">📚 我的书架</h2>
        <div style="display: flex; gap: var(--spacing-md); flex-wrap: wrap; align-items: center;">
          <input 
            v-model="searchQuery" 
            type="text" 
            class="search-bar" 
            placeholder="🔍 搜索书籍..." 
            @input="handleSearch"
          />
          <AppButton variant="secondary" size="sm" icon="📤" @click="exportAllBooks">导出全部</AppButton>
          <AppButton variant="secondary" size="sm" icon="📥" @click="importBooks">导入数据</AppButton>
          <AppButton variant="primary" size="sm" icon="➕" @click="showAddBookModal">添加新书</AppButton>
        </div>
      </div>

      <div class="books-grid">
        <div v-if="filteredBooks.length === 0" class="empty-state" style="grid-column: 1 / -1;">
          <div class="empty-state-icon">📚</div>
          <div>{{ books.length === 0 ? '书架空空如也，添加第一本书吧！' : '没有找到匹配的书籍' }}</div>
        </div>
        <div 
          v-for="book in filteredBooks" 
          :key="book.id"
          class="book-card"
          @click="openBook(book.id)"
        >
          <div class="book-cover">
            <img v-if="book.cover" :src="book.cover" :alt="book.title" />
            <span v-else>📖</span>
          </div>
          <div class="book-info">
            <div class="book-title">{{ book.title }}</div>
            <div class="book-author">{{ book.author }}</div>
            <span v-if="book.category" class="book-category">{{ book.category }}</span>
          </div>
          <div class="book-actions" @click.stop>
            <button class="book-action-btn" @click="editBook(book.id)">编辑</button>
            <button class="book-action-btn" @click="exportBookAsTxt(book.id)" title="导出为TXT">📄</button>
            <button class="book-action-btn delete" @click="deleteBook(book.id)">删除</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 添加/编辑书籍模态框 -->
    <div v-if="showModal" class="modal show" @click.self="closeBookModal">
      <div class="modal-content">
        <div class="modal-header">
          <span>{{ currentBookId ? '编辑书籍' : '添加新书' }}</span>
          <button class="modal-close" @click="closeBookModal">&times;</button>
        </div>
        <form @submit.prevent="saveBook">
          <div class="form-group">
            <label class="form-label">书名 *</label>
            <input 
              v-model="bookForm.title" 
              type="text" 
              class="form-input" 
              required 
              placeholder="请输入书名" 
            />
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="form-label">作者名 *</label>
              <input 
                v-model="bookForm.author" 
                type="text" 
                class="form-input" 
                required 
                placeholder="请输入作者名" 
              />
            </div>
            <div class="form-group">
              <label class="form-label">书本分类</label>
              <select v-model="bookForm.category" class="form-select">
                <option value="">请选择分类</option>
                <option value="小说">小说</option>
                <option value="散文">散文</option>
                <option value="诗歌">诗歌</option>
                <option value="剧本">剧本</option>
                <option value="传记">传记</option>
                <option value="历史">历史</option>
                <option value="科幻">科幻</option>
                <option value="奇幻">奇幻</option>
                <option value="悬疑">悬疑</option>
                <option value="言情">言情</option>
                <option value="其他">其他</option>
              </select>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">封面</label>
            <div class="cover-upload">
              <img v-if="bookForm.cover" :src="bookForm.cover" class="cover-preview" alt="封面预览" />
              <input 
                ref="coverInputRef"
                type="file" 
                accept="image/*" 
                style="display: none;" 
                @change="handleCoverSelect"
              />
              <button type="button" class="cover-upload-btn" @click="triggerCoverInput">
                选择封面图片
              </button>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">简介</label>
            <textarea 
              v-model="bookForm.description" 
              class="form-textarea" 
              placeholder="请输入书籍简介..."
            ></textarea>
          </div>
          <div class="form-group">
            <label class="form-label">关键词</label>
            <div class="keywords-input">
              <span 
                v-for="(keyword, index) in bookForm.keywords" 
                :key="index"
                class="keyword-tag"
              >
                {{ keyword }}
                <span class="remove" @click="removeKeyword(index)">×</span>
              </span>
              <input 
                v-model="keywordInput"
                type="text" 
                placeholder="输入关键词后按回车添加"
                style="border: none; flex: 1; min-width: 150px;"
                @keydown.enter.prevent="addKeyword"
              />
            </div>
          </div>
          <ButtonGroup gap="sm" class="modal-actions">
            <AppButton type="button" variant="secondary" @click="closeBookModal">取消</AppButton>
            <AppButton type="submit" variant="primary" icon="💾">保存</AppButton>
          </ButtonGroup>
        </form>
      </div>
    </div>

    <!-- 隐藏的文件输入用于导入 -->
    <input 
      ref="importInputRef"
      type="file" 
      accept=".json,.txt" 
      style="display: none;" 
      @change="handleImportFile"
    />
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const books = ref([])
const searchQuery = ref('')
const showModal = ref(false)
const currentBookId = ref(null)
const coverInputRef = ref(null)
const importInputRef = ref(null)
const keywordInput = ref('')

const bookForm = ref({
  title: '',
  author: '',
  category: '',
  description: '',
  cover: '',
  keywords: []
})

const filteredBooks = computed(() => {
  if (!searchQuery.value) return books.value
  const query = searchQuery.value.toLowerCase()
  return books.value.filter(book => {
    return book.title.toLowerCase().includes(query) ||
      book.author.toLowerCase().includes(query) ||
      (book.description && book.description.toLowerCase().includes(query)) ||
      (book.keywords && book.keywords.some(k => k.toLowerCase().includes(query)))
  })
})

function loadBooks() {
  const saved = localStorage.getItem('writingAssistant_books')
  if (saved) {
    books.value = JSON.parse(saved)
  }
}

function saveBooks() {
  localStorage.setItem('writingAssistant_books', JSON.stringify(books.value))
}

function handleSearch() {
  // 搜索通过computed自动处理
}

function showAddBookModal() {
  currentBookId.value = null
  bookForm.value = {
    title: '',
    author: '',
    category: '',
    description: '',
    cover: '',
    keywords: []
  }
  keywordInput.value = ''
  showModal.value = true
}

function editBook(bookId) {
  const book = books.value.find(b => b.id === bookId)
  if (!book) return

  currentBookId.value = bookId
  bookForm.value = {
    title: book.title,
    author: book.author,
    category: book.category || '',
    description: book.description || '',
    cover: book.cover || '',
    keywords: book.keywords ? [...book.keywords] : []
  }
  keywordInput.value = ''
  showModal.value = true
}

function closeBookModal() {
  showModal.value = false
  currentBookId.value = null
}

function addKeyword() {
  const keyword = keywordInput.value.trim()
  if (keyword && !bookForm.value.keywords.includes(keyword)) {
    bookForm.value.keywords.push(keyword)
    keywordInput.value = ''
  }
}

function removeKeyword(index) {
  bookForm.value.keywords.splice(index, 1)
}

function triggerCoverInput() {
  coverInputRef.value?.click()
}

function handleCoverSelect(e) {
  const file = e.target.files?.[0]
  if (file) {
    const reader = new FileReader()
    reader.onload = (event) => {
      bookForm.value.cover = event.target.result
    }
    reader.readAsDataURL(file)
  }
}

function saveBook() {
  const title = bookForm.value.title.trim()
  const author = bookForm.value.author.trim()
  const category = bookForm.value.category
  const description = bookForm.value.description.trim()
  const cover = bookForm.value.cover && bookForm.value.cover !== window.location.href ? bookForm.value.cover : null
  const keywords = bookForm.value.keywords.length > 0 ? bookForm.value.keywords : null

  if (!title || !author) {
    alert('请填写书名和作者名')
    return
  }

  const bookData = {
    id: currentBookId.value || Date.now().toString(),
    title,
    author,
    category: category || null,
    description: description || null,
    cover: cover,
    keywords: keywords,
    createdAt: currentBookId.value ? books.value.find(b => b.id === currentBookId.value).createdAt : new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }

  if (currentBookId.value) {
    const index = books.value.findIndex(b => b.id === currentBookId.value)
    if (index !== -1) {
      books.value[index] = bookData
    }
  } else {
    books.value.push(bookData)
  }

  saveBooks()
  closeBookModal()
}

function deleteBook(bookId) {
  if (!confirm('确定要删除这本书吗？相关的创作内容也会被删除。')) return

  books.value = books.value.filter(b => b.id !== bookId)
  localStorage.removeItem(`writingAssistant_book_${bookId}`)
  saveBooks()
}

function openBook(bookId) {
  router.push(`/tools/text/writing/editor?bookId=${bookId}`)
}

function exportBookAsTxt(bookId) {
  const book = books.value.find(b => b.id === bookId)
  if (!book) {
    alert('书籍不存在')
    return
  }

  const bookContent = localStorage.getItem(`writingAssistant_book_${bookId}`)
  if (!bookContent) {
    alert('这本书还没有创作内容')
    return
  }

  const content = JSON.parse(bookContent)
  let txtContent = ''

  txtContent += `书名：${book.title}\n`
  txtContent += `作者：${book.author}\n`
  if (book.category) txtContent += `分类：${book.category}\n`
  if (book.description) txtContent += `简介：${book.description}\n`
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
            const textContent = chapter.content.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').trim()
            txtContent += textContent + '\n\n'
          }
          txtContent += '-'.repeat(30) + '\n\n'
        })
      }
    })

    const ungroupedChapters = content.chapters.filter(ch => !ch.volumeId)
    if (ungroupedChapters.length > 0) {
      ungroupedChapters.forEach(chapter => {
        txtContent += `${chapter.name}\n`
        if (chapter.title) txtContent += `标题：${chapter.title}\n`
        if (chapter.content) {
          const textContent = chapter.content.replace(/<[^>]*>/g, '').replace(/&nbsp;/g, ' ').trim()
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
  a.download = `${book.title}.txt`
  a.click()
  URL.revokeObjectURL(url)
}

function exportAllBooks() {
  try {
    const exportData = {
      version: '1.0',
      exportDate: new Date().toISOString(),
      books: [],
      bookContents: []
    }

    books.value.forEach(book => {
      exportData.books.push(book)

      const bookContent = localStorage.getItem(`writingAssistant_book_${book.id}`)
      if (bookContent) {
        exportData.bookContents.push({
          bookId: book.id,
          content: JSON.parse(bookContent)
        })
      }
    })

    const jsonData = JSON.stringify(exportData, null, 2)
    const blob = new Blob([jsonData], { type: 'application/json;charset=utf-8' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `写作助手备份_${new Date().toISOString().split('T')[0]}.json`
    a.click()
    URL.revokeObjectURL(url)

    alert(`成功导出 ${books.value.length} 本书籍的数据！`)
  } catch (error) {
    console.error('导出失败:', error)
    alert('导出失败：' + error.message)
  }
}

function importBooks() {
  importInputRef.value?.click()
}

function handleImportFile(e) {
  const file = e.target.files?.[0]
  if (!file) return

  const reader = new FileReader()
  reader.onload = (event) => {
    try {
      const content = event.target.result

      if (file.name.endsWith('.json')) {
        const importData = JSON.parse(content)

        if (!importData.books || !Array.isArray(importData.books)) {
          throw new Error('无效的导入文件格式')
        }

        if (!confirm(`确定要导入 ${importData.books.length} 本书籍吗？\n这将覆盖现有的同名书籍。`)) {
          return
        }

        importData.books.forEach(importBook => {
          const existingIndex = books.value.findIndex(b => b.id === importBook.id)
          if (existingIndex !== -1) {
            books.value[existingIndex] = importBook
          } else {
            books.value.push(importBook)
          }
        })

        if (importData.bookContents && Array.isArray(importData.bookContents)) {
          importData.bookContents.forEach(({ bookId, content }) => {
            localStorage.setItem(`writingAssistant_book_${bookId}`, JSON.stringify(content))
          })
        }

        saveBooks()
        alert(`成功导入 ${importData.books.length} 本书籍！`)
      } else if (file.name.endsWith('.txt')) {
        alert('TXT文件导入功能正在开发中，请使用JSON格式导入完整数据。\n\n您可以使用"导出全部"功能导出JSON格式的完整数据。')
      }
    } catch (error) {
      console.error('导入失败:', error)
      alert('导入失败：' + error.message + '\n\n请确保文件格式正确。')
    }
  }
  reader.readAsText(file)
}

onMounted(() => {
  loadBooks()
})
</script>

<style scoped>
.book-home {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-xl);
}

.bookshelf-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: var(--spacing-xl);
  flex-wrap: wrap;
  gap: var(--spacing-md);
}

.bookshelf-title {
  font-size: var(--font-size-xlarge);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
}

.btn {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-text-on-primary) !important;
  padding: var(--spacing-sm) var(--spacing-lg);
  border-radius: var(--radius-sm);
  border: none;
  cursor: pointer;
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-semibold);
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.btn span {
  color: var(--color-text-on-primary) !important;
}

.btn.btn-secondary {
  background: var(--color-surface-alt);
  color: var(--color-text) !important;
  border: 1px solid var(--color-border);
}

.btn.btn-secondary span {
  color: var(--color-text) !important;
}

.btn.btn-secondary:hover {
  background: var(--color-hover);
}

.btn:hover {
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.search-bar {
  width: 100%;
  max-width: 400px;
  padding: var(--spacing-sm) var(--spacing-md);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-base);
  background: var(--color-surface);
  color: var(--color-text);
}

.search-bar:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.books-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: var(--spacing-lg);
  margin-top: var(--spacing-lg);
}

.book-card {
  background: var(--color-surface);
  border-radius: var(--radius-md);
  padding: var(--spacing-md);
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--color-border);
  cursor: pointer;
  transition: all 0.3s;
  display: flex;
  flex-direction: column;
  position: relative;
  overflow: hidden;
}

.book-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
  border-color: var(--color-primary);
}

.book-cover {
  width: 100%;
  aspect-ratio: 3/4;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  border-radius: var(--radius-sm);
  margin-bottom: var(--spacing-md);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 48px;
  color: var(--color-text-on-primary);
  overflow: hidden;
  position: relative;
}

.book-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.book-info {
  flex: 1;
}

.book-title {
  font-size: var(--font-size-base);
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin-bottom: var(--spacing-xs);
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.book-author {
  font-size: var(--font-size-small);
  color: var(--color-text-secondary);
  margin-bottom: var(--spacing-xs);
}

.book-category {
  display: inline-block;
  padding: 2px 8px;
  background: var(--color-surface-alt);
  border-radius: var(--radius-sm);
  font-size: 11px;
  color: var(--color-text-secondary);
  margin-bottom: var(--spacing-xs);
}

.book-actions {
  display: flex;
  gap: var(--spacing-xs);
  margin-top: var(--spacing-sm);
  opacity: 0;
  transition: opacity 0.2s;
}

.book-card:hover .book-actions {
  opacity: 1;
}

.book-action-btn {
  flex: 1;
  padding: var(--spacing-xs) var(--spacing-sm);
  background: var(--color-surface-alt);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: var(--font-size-small);
  color: var(--color-text);
  transition: all 0.2s;
}

.book-action-btn:hover {
  background: var(--color-hover);
  border-color: var(--color-primary);
}

.book-action-btn.delete {
  color: var(--color-error);
}

.book-action-btn.delete:hover {
  background: var(--color-error);
  color: var(--color-text-on-primary);
}

.empty-state {
  text-align: center;
  padding: var(--spacing-xxl);
  color: var(--color-text-light);
}

.empty-state-icon {
  font-size: 64px;
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
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
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
.form-textarea,
.form-select {
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
.form-textarea:focus,
.form-select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 4px var(--color-shadow-primary);
}

.form-textarea {
  min-height: 100px;
  resize: vertical;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-md);
}

.cover-upload {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--spacing-sm);
}

.cover-preview {
  width: 120px;
  height: 160px;
  border-radius: var(--radius-sm);
  object-fit: cover;
  border: 2px solid var(--color-border);
}

.cover-upload-btn {
  padding: var(--spacing-xs) var(--spacing-md);
  background: var(--color-surface-alt);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  cursor: pointer;
  font-size: var(--font-size-small);
  color: var(--color-text);
}

.keywords-input {
  display: flex;
  flex-wrap: wrap;
  gap: var(--spacing-xs);
  padding: var(--spacing-sm);
  border: 2px solid var(--color-border);
  border-radius: var(--radius-sm);
  min-height: 50px;
}

.keyword-tag {
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-xs);
  padding: 4px 8px;
  background: var(--color-primary);
  color: var(--color-text-on-primary);
  border-radius: var(--radius-sm);
  font-size: var(--font-size-small);
}

.keyword-tag .remove {
  cursor: pointer;
  font-weight: bold;
}

.modal-actions {
  display: flex;
  gap: var(--spacing-md);
  justify-content: flex-end;
  margin-top: var(--spacing-lg);
}

@media (max-width: 768px) {
  .books-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  }

  .form-row {
    grid-template-columns: 1fr;
  }
}
</style>