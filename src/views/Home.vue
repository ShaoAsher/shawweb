<template>
  <div class="home-page" ref="containerRef">
    <div class="header animate-header">
      <h1 class="header-title">{{ homeConfig.title[currentLang] }}</h1>
      <p class="header-desc">{{ homeConfig.description[currentLang] }}</p>
    </div>
    <div class="content">
      <!-- 搜索框 -->
      <div class="search-container animate-search">
        <input 
          type="text" 
          class="search-box" 
          ref="searchBoxRef"
          v-model="searchQuery"
          :placeholder="homeConfig.searchPlaceholder[currentLang]"
          @input="handleSearch"
          @focus="isSearchFocused = true"
          @blur="isSearchFocused = false"
        />
        <span class="search-icon" :class="{ active: isSearchFocused }">🔍</span>
        <transition name="fade">
          <div 
            v-if="searchQuery && filteredTools.length > 0"
            class="search-results-info"
          >
            找到 {{ filteredTools.length }} 个工具
          </div>
        </transition>
      </div>

      <!-- 页签导航 -->
      <div class="tabs-container">
        <div class="tabs-nav" ref="tabsNavRef">
          <button
            v-for="tab in tabs"
            :key="tab.id"
            class="tab-btn"
            :class="{ active: activeTab === tab.id }"
            :ref="el => tabRefs[tab.id] = el"
            @click="switchTab(tab.id)"
          >
            <span class="tab-icon">{{ tab.icon }}</span>
            <span class="tab-text">{{ tab.name[currentLang] }}</span>
            <span class="tab-count">{{ getTabToolCount(tab.id) }}</span>
          </button>
          <!-- 滑动指示器 -->
          <div class="tab-indicator" :style="indicatorStyle"></div>
        </div>
      </div>

      <!-- 页签内容 -->
      <transition name="tab-fade" mode="out-in">
        <div 
          class="tab-content active" 
          :key="activeTab + searchQuery"
          v-if="displayTools.length > 0"
        >
          <TransitionGroup name="card-list" tag="div" class="tools-grid">
            <div
              v-for="(tool, index) in displayTools"
              :key="tool.href"
              class="tool-card hover-lift"
              :style="{ '--card-index': index }"
              @click="navigateToTool(tool.href)"
            >
              <div class="tool-card-header">
                <div class="tool-icon-wrapper">{{ tool.icon }}</div>
                <div class="tool-info">
                  <div class="tool-title-row">
                    <div class="tool-title">{{ getToolText(tool, 'title') }}</div>
                    <div class="tool-rating">
                      <span
                        v-for="i in 5"
                        :key="i"
                        class="star"
                        :class="{ empty: i > tool.rating }"
                      >★</span>
                    </div>
                  </div>
                  <span class="tool-category" :class="getCategoryClass(tool.category)">
                    {{ getCategoryName(tool.category) }}
                  </span>
                </div>
              </div>
              <div class="tool-desc">{{ getToolText(tool, 'desc') }}</div>
              <div class="tool-footer">
                <span class="tool-link">
                  {{ currentLang === 'en' ? 'Use Now' : '立即使用' }}
                  <span class="tool-link-arrow">→</span>
                </span>
              </div>
            </div>
          </TransitionGroup>
        </div>
      </transition>

      <!-- 无结果提示 -->
      <transition name="fade">
        <div v-if="displayTools.length === 0" class="no-results show">
          <div class="no-results-icon animate-float">🔍</div>
          <div class="no-results-title">
            {{ homeConfig.noResultsTitle[currentLang] }}
          </div>
          <div class="no-results-text">{{ homeConfig.noResultsText[currentLang] }}</div>
        </div>
      </transition>

      <!-- 快捷入口 -->
      <div class="quick-access">
        <div class="quick-access-title">
          <span class="quick-access-icon">⚡</span>
          <span>{{ homeConfig.quickAccessTitle[currentLang] }}</span>
        </div>
        <div class="quick-links">
          <a
            v-for="(tool, index) in quickAccessTools"
            :key="tool.href"
            :href="tool.href"
            class="quick-link"
            :style="{ '--link-index': index }"
            @click.prevent="navigateToTool(tool.href)"
          >
            <span class="quick-link-icon">{{ tool.icon }}</span>
            <span class="quick-link-text">{{ getToolText(tool, 'title') }}</span>
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { useRouter } from 'vue-router'
import { toolsData, homeConfig, categories } from '../data/tools.js'
import '../assets/css/home.css'

const router = useRouter()

const currentLang = ref('zh')
const activeTab = ref('all')
const searchQuery = ref('')
const isSearchFocused = ref(false)
const containerRef = ref(null)
const searchBoxRef = ref(null)
const tabsNavRef = ref(null)
const tabRefs = ref({})

const tools = toolsData.tools

const tabs = [
  { id: 'all', icon: '🌟', name: { zh: '全部', en: 'All' } },
  { id: 'dev', icon: '💻', name: { zh: '开发工具', en: 'Development Tools' } },
  { id: 'image', icon: '🖼️', name: { zh: '图片工具', en: 'Image Tools' } },
  { id: 'text', icon: '📝', name: { zh: '文本工具', en: 'Text Tools' } },
  { id: 'converter', icon: '🔄', name: { zh: '转换工具', en: 'Converter Tools' } },
  { id: 'life', icon: '🌍', name: { zh: '生活工具', en: 'Life Tools' } }
]

// 页签指示器样式
const indicatorStyle = ref({
  width: '0px',
  transform: 'translateX(0px)'
})

// 更新指示器位置
function updateIndicator() {
  nextTick(() => {
    const activeTabEl = tabRefs.value[activeTab.value]
    if (activeTabEl) {
      const rect = activeTabEl.getBoundingClientRect()
      const parentRect = tabsNavRef.value?.getBoundingClientRect()
      if (parentRect) {
        indicatorStyle.value = {
          width: `${rect.width}px`,
          transform: `translateX(${rect.left - parentRect.left}px)`
        }
      }
    }
  })
}

// 监听 activeTab 变化
watch(activeTab, updateIndicator)

const filteredTools = computed(() => {
  if (!searchQuery.value.trim()) {
    return []
  }
  return fuzzySearch(searchQuery.value)
})

const displayTools = computed(() => {
  if (searchQuery.value.trim()) {
    return filteredTools.value
  }
  return getToolsByTab(activeTab.value)
})

const quickAccessTools = computed(() => {
  const ratingThreshold = homeConfig.quickAccessRating || 0
  const limit = homeConfig.quickAccessLimit || 0
  let popularTools = ratingThreshold > 0
    ? tools.filter(t => t.rating >= ratingThreshold)
    : tools
  if (limit > 0) {
    popularTools = popularTools.slice(0, limit)
  }
  return popularTools
})

function getToolText(tool, field) {
  if (!tool || !tool[field]) return ''
  const value = tool[field]
  return typeof value === 'object' ? (value[currentLang.value] || value.zh || '') : value
}

function getCategoryName(category) {
  if (!categories[category]) return category
  const cat = categories[category]
  return typeof cat === 'object' ? (cat[currentLang.value] || cat.zh || category) : cat
}

function getCategoryClass(category) {
  const classes = {
    dev: 'category-dev',
    image: 'category-image',
    text: 'category-text',
    converter: 'category-converter',
    life: 'category-life'
  }
  return classes[category] || 'category-dev'
}

function getToolsByTab(tabId) {
  if (tabId === 'all') return tools
  return tools.filter(t => t.category === tabId)
}

function getTabToolCount(tabId) {
  return getToolsByTab(tabId).length
}

function switchTab(tabId) {
  activeTab.value = tabId
  searchQuery.value = ''
  sessionStorage.setItem('homeActiveTab', tabId)
}

function navigateToTool(href) {
  if (href.startsWith('/tools/')) {
    router.push(href)
  } else {
    window.location.href = href
  }
}

function fuzzySearch(query) {
  if (!query || query.trim() === '') return tools
  const lowerQuery = query.toLowerCase().trim()
  const queryWords = lowerQuery.split(/\s+/).filter(w => w.length > 0)

  return tools.filter(tool => {
    const titleZh = getToolText(tool, 'title')
    const titleEn = (tool.title && typeof tool.title === 'object') ? (tool.title.en || '') : ''
    const descZh = getToolText(tool, 'desc')
    const descEn = (tool.desc && typeof tool.desc === 'object') ? (tool.desc.en || '') : ''
    const keywords = tool.keywords || {}
    const keywordsZh = keywords.zh || []
    const keywordsEn = keywords.en || []

    const searchText = (
      titleZh + ' ' + titleEn + ' ' +
      descZh + ' ' + descEn + ' ' +
      keywordsZh.join(' ') + ' ' +
      keywordsEn.join(' ')
    ).toLowerCase()

    const titleMatch = queryWords.some(word =>
      titleZh.toLowerCase().includes(word) ||
      titleEn.toLowerCase().includes(word)
    ) || titleZh.toLowerCase().includes(lowerQuery) ||
      titleEn.toLowerCase().includes(lowerQuery)

    const descMatch = queryWords.some(word =>
      descZh.toLowerCase().includes(word) ||
      descEn.toLowerCase().includes(word)
    ) || descZh.toLowerCase().includes(lowerQuery) ||
      descEn.toLowerCase().includes(lowerQuery)

    const keywordMatch = queryWords.some(word =>
      keywordsZh.some(kw => kw.toLowerCase().includes(word) || word.includes(kw.toLowerCase())) ||
      keywordsEn.some(kw => kw.toLowerCase().includes(word) || word.includes(kw.toLowerCase()))
    ) || keywordsZh.some(kw => kw.toLowerCase().includes(lowerQuery)) ||
      keywordsEn.some(kw => kw.toLowerCase().includes(lowerQuery))

    const categoryName = getCategoryName(tool.category)
    const categoryMatch = categoryName.toLowerCase().includes(lowerQuery)

    const fullTextMatch = searchText.includes(lowerQuery) ||
      queryWords.every(word => searchText.includes(word))

    return titleMatch || descMatch || keywordMatch || categoryMatch || fullTextMatch
  })
}

function handleSearch() {
  // 搜索逻辑已在 computed 中处理
}

function handleKeydown(e) {
  if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
    e.preventDefault()
    searchBoxRef.value?.focus()
  }
}

function handleResize() {
  updateIndicator()
}

onMounted(() => {
  // 恢复页签状态
  const savedTab = sessionStorage.getItem('homeActiveTab') || 'all'
  if (['all', 'dev', 'image', 'text', 'converter', 'life'].includes(savedTab)) {
    activeTab.value = savedTab
  }

  // 初始化指示器
  updateIndicator()

  // 监听键盘快捷键
  document.addEventListener('keydown', handleKeydown)
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
/* ========== 入场动画 ========== */
.animate-header {
  animation: fadeInDown 0.6s ease-out;
}

.header-title {
  animation: fadeInUp 0.6s ease-out 0.1s both;
}

.header-desc {
  animation: fadeInUp 0.6s ease-out 0.2s both;
}

.animate-search {
  animation: fadeInUp 0.5s ease-out 0.3s both;
}

/* ========== 搜索框增强 ========== */
.search-icon {
  transition: transform 0.3s, color 0.3s;
}

.search-icon.active {
  transform: translateY(-50%) scale(1.2);
  color: var(--color-primary);
}

.search-box:focus {
  animation: searchFocus 0.3s ease-out;
}

@keyframes searchFocus {
  0% { transform: scale(1); }
  50% { transform: scale(1.01); }
  100% { transform: scale(1); }
}

/* ========== 页签指示器 ========== */
.tabs-nav {
  position: relative;
}

.tab-indicator {
  position: absolute;
  bottom: 0;
  left: 0;
  height: 3px;
  background: linear-gradient(90deg, var(--color-primary), var(--color-primary-dark));
  border-radius: 3px 3px 0 0;
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.tab-btn {
  position: relative;
  z-index: 1;
}

.tab-btn .tab-icon {
  transition: transform 0.3s;
}

.tab-btn:hover .tab-icon {
  transform: scale(1.2) rotate(5deg);
}

.tab-btn.active .tab-icon {
  animation: iconPop 0.3s ease-out;
}

@keyframes iconPop {
  0% { transform: scale(1); }
  50% { transform: scale(1.3); }
  100% { transform: scale(1.15); }
}

/* ========== 页签切换动画 ========== */
.tab-fade-enter-active,
.tab-fade-leave-active {
  transition: opacity 0.25s ease, transform 0.25s ease;
}

.tab-fade-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.tab-fade-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

/* ========== 卡片列表动画 ========== */
.card-list-enter-active {
  transition: all 0.4s ease-out;
  transition-delay: calc(var(--card-index, 0) * 0.05s);
}

.card-list-leave-active {
  transition: all 0.3s ease-in;
  position: absolute;
}

.card-list-enter-from {
  opacity: 0;
  transform: translateY(20px) scale(0.95);
}

.card-list-leave-to {
  opacity: 0;
  transform: scale(0.9);
}

.card-list-move {
  transition: transform 0.4s ease;
}

/* ========== 工具卡片增强 ========== */
.tool-card {
  cursor: pointer;
  transform-origin: center;
}

.tool-card:active {
  transform: scale(0.98);
}

.tool-icon-wrapper {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.3s;
}

.tool-card:hover .tool-icon-wrapper {
  transform: scale(1.1) rotate(5deg);
  box-shadow: 0 8px 20px var(--color-shadow-primary);
}

.tool-link {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.tool-link-arrow {
  transition: transform 0.3s;
}

.tool-card:hover .tool-link-arrow {
  transform: translateX(4px);
}

/* ========== 快捷入口动画 ========== */
.quick-access-icon {
  display: inline-block;
  animation: pulse 2s ease-in-out infinite;
}

.quick-link {
  animation: fadeInUp 0.4s ease-out both;
  animation-delay: calc(var(--link-index, 0) * 0.05s);
}

.quick-link:hover {
  transform: translateY(-3px);
}

.quick-link:active {
  transform: translateY(0) scale(0.98);
}

/* ========== 无结果动画 ========== */
.no-results-icon {
  animation: float 3s ease-in-out infinite;
}

.no-results-title {
  font-size: 18px;
  font-weight: var(--font-weight-semibold);
  margin-bottom: 8px;
  color: var(--color-text);
}

.no-results-text {
  color: var(--color-text-secondary);
}

/* ========== 弹窗动画 ========== */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-active .theme-modal-content,
.modal-leave-active .theme-modal-content {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .theme-modal-content {
  transform: scale(0.9) translateY(20px);
  opacity: 0;
}

.modal-leave-to .theme-modal-content {
  transform: scale(0.9) translateY(-20px);
  opacity: 0;
}

/* ========== 淡入淡出通用 ========== */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* ========== 浮动动画 ========== */
@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

@keyframes pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

@keyframes fadeInDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ========== 分类标签增强 ========== */
.category-converter {
  background: linear-gradient(135deg, #a78bfa20 0%, #8b5cf620 100%);
  color: #8b5cf6;
}

.category-life {
  background: linear-gradient(135deg, #34d39920 0%, #10b98120 100%);
  color: #10b981;
}
</style>
