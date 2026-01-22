/**
 * 🎨 统一主题配置中心
 * 
 * 这是整个应用的唯一主题配置文件
 * 所有颜色、字体、间距等都在这里定义
 * 修改这个文件即可影响所有组件
 */

// ==================== 核心颜色配置 ====================
export const CORE_COLORS = {
  // 工具页面标题区域 - 强制白色
  HEADER_TITLE: '#FFFFFF',
  HEADER_DESC: '#FFFFFF',
  
  // 主色调
  PRIMARY: '#667eea',
  PRIMARY_DARK: '#764ba2',
  
  // 背景色
  BACKGROUND: '#f8f9fa',
  SURFACE: '#ffffff',
  SURFACE_ALT: '#f8f9fa',
  
  // 文字色
  TEXT: '#2d3748',
  TEXT_SECONDARY: '#718096',
  TEXT_LIGHT: '#adb5bd',
  
  // 边框色
  BORDER: '#e9ecef',
  
  // 状态色
  SUCCESS: '#10b981',
  ERROR: '#ef4444',
  WARNING: '#f59e0b',
  INFO: '#3b82f6'
}

// ==================== 主题预设 ====================
export const THEMES = {
  purple: {
    name: '优雅紫色',
    primary: '#667eea',
    primaryDark: '#764ba2'
  },
  cyberpunk: {
    name: '赛博朋克',
    primary: '#00f0ff',
    primaryDark: '#ff006e'
  },
  light: {
    name: '清新浅色',
    primary: '#3b82f6',
    primaryDark: '#2563eb'
  },
  modern: {
    name: '现代简约',
    primary: '#5865f2',
    primaryDark: '#4752c4'
  },
  alipay: {
    name: '支付宝蓝',
    primary: '#1677FF',
    primaryDark: '#0958d9'
  },
  wechat: {
    name: '微信绿',
    primary: '#07C160',
    primaryDark: '#06ad56'
  }
}

// ==================== 应用主题配置 ====================
export function applyThemeConfig(themeName = 'purple') {
  const root = document.documentElement
  const theme = THEMES[themeName] || THEMES.purple
  
  // 应用核心颜色（这些不会随主题改变）
  root.style.setProperty('--header-title-color', CORE_COLORS.HEADER_TITLE)
  root.style.setProperty('--header-desc-color', CORE_COLORS.HEADER_DESC)
  
  // 应用主题色
  root.style.setProperty('--color-primary', theme.primary)
  root.style.setProperty('--color-primary-dark', theme.primaryDark)
  
  // 保存当前主题
  localStorage.setItem('theme', themeName)
  document.body.setAttribute('data-theme', themeName)
}

// ==================== 初始化主题 ====================
export function initTheme() {
  const savedTheme = localStorage.getItem('theme') || 'purple'
  applyThemeConfig(savedTheme)
  return savedTheme
}
