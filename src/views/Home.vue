<template>
  <div class="home-page" ref="containerRef">
    <div class="header animate-header">
      <div class="header-logo">
        <img src="/robot-icon.png" alt="Robot Icon" class="logo-image" />
      </div>
      
      <!-- 模式切换 -->
      <div class="mode-switch">
        <button class="mode-switch-btn" @click="openModeModal" title="切换模式">
          {{ userMode === 'code' ? '👨‍💻' : '🙂' }}
        </button>
      </div>

      <h1 class="header-title">{{ homeConfig.title }}</h1>
      <p class="header-desc">{{ homeConfig.description }}</p>
      
      <!-- 模式选择弹窗 -->
      <Teleport to="body">
        <transition name="modal">
          <div v-if="showModeModal" class="mode-modal-overlay" @click.self="closeModeModal">
            <div class="mode-modal-content">
              <div class="mode-modal-header">
                <h2 class="mode-modal-title">🎭 选择模式</h2>
                <button class="mode-modal-close" @click="closeModeModal">×</button>
              </div>
              <div class="mode-list">
                <div
                  class="mode-item"
                  :class="{ active: userMode === 'normal' }"
                  @click="switchUserMode('normal')"
                >
                  <div class="mode-item-icon">🙂</div>
                  <div class="mode-item-info">
                    <div class="mode-item-name">普通模式</div>
                    <div class="mode-item-desc">简洁清爽，专注于生活与娱乐工具</div>
                  </div>
                  <div v-if="userMode === 'normal'" class="mode-check">✓</div>
                </div>
                
                <div
                  class="mode-item"
                  :class="{ active: userMode === 'code' }"
                  @click="switchUserMode('code')"
                >
                  <div class="mode-item-icon">👨‍💻</div>
                  <div class="mode-item-info">
                    <div class="mode-item-name">极客模式</div>
                    <div class="mode-item-desc">全功能展示，包含开发、文本处理等专业工具</div>
                  </div>
                  <div v-if="userMode === 'code'" class="mode-check">✓</div>
                </div>
              </div>
            </div>
          </div>
        </transition>
      </Teleport>
    </div>
    <div class="content">
      <!-- 搜索框 -->
      <div class="search-container animate-search">
        <input 
          type="text" 
          class="search-box" 
          ref="searchBoxRef"
          v-model="searchQuery"
          :placeholder="homeConfig.searchPlaceholder"
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
            <span class="tab-text">{{ tab.name }}</span>
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
              :key="tool.id"
              class="tool-card hover-lift"
              :style="{ '--card-index': index }"
              @click="navigateToTool(tool.href)"
            >
              <div class="tool-card-header">
                <div class="tool-icon-wrapper">{{ tool.icon }}</div>
                <div class="tool-info">
                  <div class="tool-title-row">
                    <div class="tool-title">{{ tool.title }}</div>
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
                  <span v-if="tool.status === 'migrating'" class="tool-status status-migrating">
                    🚧 迁移中
                  </span>
                </div>
              </div>
              <div class="tool-desc">{{ tool.desc }}</div>
              <div class="tool-footer">
                <span class="tool-link">
                  立即使用
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
            {{ homeConfig.noResultsTitle }}
          </div>
          <div class="no-results-text">{{ homeConfig.noResultsText }}</div>
        </div>
      </transition>

      <!-- 快捷入口 -->
      <div class="quick-access">
        <div class="quick-access-title">
          <span class="quick-access-icon">⚡</span>
          <span>{{ homeConfig.quickAccessTitle }}</span>
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
            <span class="quick-link-text">{{ tool.title }}</span>
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { useRouter } from 'vue-router'
import { toolsData, homeConfig, categories, toolsMap } from '../data/tools.js'
import '../assets/css/home.css'

const router = useRouter()

const activeTab = ref('all')
const userMode = ref('normal') // 'normal' | 'code'
const showModeModal = ref(false)
const searchQuery = ref('')
const isSearchFocused = ref(false)
const containerRef = ref(null)
const searchBoxRef = ref(null)
const tabsNavRef = ref(null)
const tabRefs = ref({})

const tools = toolsData.tools

const allTabs = [
  { id: 'all', icon: '🌟', name: '全部' },
  { id: 'dev', icon: '💻', name: '开发工具' },
  { id: 'image', icon: '🖼️', name: '图片工具' },
  { id: 'text', icon: '📝', name: '文本工具' },
  { id: 'converter', icon: '🔄', name: '转换工具' },
  { id: 'life', icon: '🌍', name: '生活工具' },
  { id: 'entertainment', icon: '🎮', name: '娱乐工具' }
]

const tabs = computed(() => {
  if (userMode.value === 'code') {
    return allTabs
  }
  // 普通模式：只展示全部、生活、娱乐、图片
  return allTabs.filter(t => ['all', 'life', 'entertainment', 'image'].includes(t.id))
})

// 监听模式变化，如果当前 tab 不在允许列表中，重置为 all
watch(userMode, (newMode) => {
  if (newMode === 'normal') {
    const allowedTabs = ['all', 'life', 'entertainment', 'image']
    if (!allowedTabs.includes(activeTab.value)) {
      switchTab('all')
    }
  }
  // 更新指示器
  setTimeout(updateIndicator, 100)
})

function switchUserMode(mode) {
  userMode.value = mode
  localStorage.setItem('userMode', mode)
  closeModeModal()
}

function openModeModal() {
  showModeModal.value = true
  document.body.style.overflow = 'hidden'
}

function closeModeModal() {
  showModeModal.value = false
  document.body.style.overflow = ''
}

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
  
  // 根据当前模式过滤工具池
  let availableTools = tools
  if (userMode.value === 'normal') {
    availableTools = tools.filter(t => t.minUserMode === 'normal')
  }

  let popularTools = ratingThreshold > 0
    ? availableTools.filter(t => t.rating >= ratingThreshold)
    : availableTools
    
  if (limit > 0) {
    popularTools = popularTools.slice(0, limit)
  }
  return popularTools
})

function getCategoryName(category) {
  return categories[category] || category
}

function getCategoryClass(category) {
  const classes = {
    dev: 'category-dev',
    image: 'category-image',
    text: 'category-text',
    converter: 'category-converter',
    life: 'category-life',
    entertainment: 'category-entertainment'
  }
  return classes[category] || 'category-dev'
}

function getToolsByTab(tabId) {
  let filteredTools = tools
  
  // 普通模式下过滤掉非生活/娱乐/图片的工具
  if (userMode.value === 'normal') {
    filteredTools = tools.filter(t => t.minUserMode === 'normal')
  }
  
  if (tabId === 'all') return filteredTools
  return filteredTools.filter(t => t.category === tabId)
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

// 优化的搜索函数，使用 id 进行快速匹配
function fuzzySearch(query) {
  if (!query || query.trim() === '') return []
  
  const lowerQuery = query.toLowerCase().trim()
  const queryWords = lowerQuery.split(/\s+/).filter(w => w.length > 0)

  // 根据当前模式过滤可用工具
  let availableTools = tools
  if (userMode.value === 'normal') {
    availableTools = tools.filter(t => t.minUserMode === 'normal')
  }
  
  // 如果查询是工具 ID，直接返回匹配的工具（需在可用范围内）
  if (toolsMap.has(lowerQuery)) {
    const tool = toolsMap.get(lowerQuery)
    if (availableTools.includes(tool)) {
      return [tool]
    }
  }

  // 构建搜索文本并计算匹配分数
  const results = availableTools.map(tool => {
    const title = tool.title.toLowerCase()
    const desc = tool.desc.toLowerCase()
    const keywords = (tool.keywords || []).map(kw => kw.toLowerCase())
    const categoryName = getCategoryName(tool.category).toLowerCase()
    const toolId = tool.id.toLowerCase()
    
    // 构建完整搜索文本
    const searchText = `${title} ${desc} ${keywords.join(' ')} ${categoryName} ${toolId}`.toLowerCase()
    
    let score = 0
    
    // ID 精确匹配（最高优先级）
    if (toolId === lowerQuery) {
      score += 1000
    } else if (toolId.includes(lowerQuery)) {
      score += 500
    }
    
    // 标题匹配（高优先级）
    if (title === lowerQuery) {
      score += 100
    } else if (title.includes(lowerQuery)) {
      score += 50
    } else if (queryWords.some(word => title.includes(word))) {
      score += 20
    }
    
    // 关键词匹配（中优先级）
    const keywordMatches = keywords.filter(kw => 
      kw.includes(lowerQuery) || queryWords.some(word => kw.includes(word))
    )
    score += keywordMatches.length * 15
    
    // 描述匹配（低优先级）
    if (desc.includes(lowerQuery)) {
      score += 10
    } else if (queryWords.some(word => desc.includes(word))) {
      score += 5
    }
    
    // 分类匹配
    if (categoryName.includes(lowerQuery)) {
      score += 8
    }
    
    // 全文匹配
    if (searchText.includes(lowerQuery)) {
      score += 3
    } else if (queryWords.every(word => searchText.includes(word))) {
      score += 2
    }
    
    return { tool, score }
  })
  
  // 过滤掉分数为 0 的结果，并按分数降序排序
  return results
    .filter(item => item.score > 0)
    .sort((a, b) => b.score - a.score)
    .map(item => item.tool)
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
  if (['all', 'dev', 'image', 'text', 'converter', 'life', 'entertainment'].includes(savedTab)) {
    activeTab.value = savedTab
  }
  
  // 恢复用户模式
  const savedMode = localStorage.getItem('userMode') || 'normal'
  userMode.value = savedMode

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
/* ========== Logo 样式 ========== */
.header-logo {
  display: flex;
  justify-content: center;
  margin-bottom: 24px;
  animation: fadeInDown 0.6s ease-out;
  position: relative; /* 确保 z-index 上下文 */
}

.logo-image {
  width: 120px;
  height: 120px;
  object-fit: contain;
  animation: float 3s ease-in-out infinite;
  filter: drop-shadow(0 10px 25px rgba(0, 0, 0, 0.15));
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.logo-image:hover {
  transform: scale(1.1) rotate(5deg);
  filter: drop-shadow(0 15px 35px rgba(0, 0, 0, 0.2));
}

/* ========== 模式切换按钮 ========== */
.mode-switch {
  display: flex;
  justify-content: center;
  margin-bottom: 12px;
  animation: fadeInDown 0.6s ease-out;
  position: relative;
  z-index: 10;
}

.mode-switch-btn {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  border: none;
  background: var(--color-surface-alt);
  color: var(--color-text);
  font-size: 24px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.mode-switch-btn:hover {
  transform: scale(1.1);
  background: var(--color-surface);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.15);
}

/* 弹窗样式复用 ThemeToggle 的设计 */
.mode-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  z-index: 10001;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.mode-modal-content {
  background: var(--color-surface);
  border-radius: var(--radius-xl);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  width: 100%;
  max-width: 400px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.mode-modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px;
  border-bottom: 1px solid var(--color-border);
}

.mode-modal-title {
  font-size: 20px;
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin: 0;
}

.mode-modal-close {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: none;
  background: var(--color-surface-alt);
  color: var(--color-text-secondary);
  font-size: 24px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.mode-modal-close:hover {
  background: var(--color-error);
  color: #fff;
}

.mode-list {
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.mode-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  border-radius: var(--radius-lg);
  border: 2px solid transparent;
  background: var(--color-surface-alt);
  cursor: pointer;
  transition: all 0.3s;
}

.mode-item:hover {
  background: var(--color-hover);
  transform: translateX(4px);
}

.mode-item.active {
  border-color: var(--color-primary);
  background: var(--color-hover);
}

.mode-item-icon {
  width: 48px;
  height: 48px;
  font-size: 24px;
  background: var(--color-background);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.mode-item-info {
  flex: 1;
}

.mode-item-name {
  font-weight: var(--font-weight-bold);
  color: var(--color-text);
  margin-bottom: 4px;
}

.mode-item-desc {
  font-size: 13px;
  color: var(--color-text-secondary);
  line-height: 1.4;
}

.mode-check {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: var(--color-primary);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: bold;
}

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

.category-entertainment {
  background: linear-gradient(135deg, #f472b620 0%, #ec489920 100%);
  color: #ec4899;
}

.tool-status {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  margin-left: 8px;
}

.status-migrating {
  background: linear-gradient(135deg, #fbbf2420 0%, #f59e0b20 100%);
  color: #d97706;
  border: 1px solid rgba(245, 158, 11, 0.2);
}
</style>
