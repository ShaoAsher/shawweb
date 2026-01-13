/**
 * 主题配置系统
 * 支持多主题切换，统一管理颜色、字号、间距等样式
 * 
 * 使用方法：
 * 1. 在HTML中引入此文件：<script src="./themes.js"></script>
 * 2. 调用 window.initTheme() 初始化主题
 * 3. 调用 window.setTheme('themeName') 切换主题
 * 4. 使用CSS变量（如 var(--color-primary)）应用主题样式
 */

(function () {
  'use strict';

  /**
   * 主题配置对象
   * 每个主题包含：
   * - colors: 颜色配置（主色、背景色、文本色等）
   * - typography: 字体配置（字号、字重、行高等）
   * - spacing: 间距配置（内边距、外边距等）
   * - borderRadius: 圆角配置
   * - shadows: 阴影配置
   */
  const themes = {
    /**
     * 主题1: 优雅紫色（默认主题）
     * 特点：渐变紫色背景，优雅现代的设计风格
     */
    purple: {
      name: { zh: '优雅紫色', en: 'Elegant Purple' },

      // ========== 颜色配置 ==========
      colors: {
        // 主色系 - 用于按钮、链接、强调元素
        primary: '#667eea',           // 主色：蓝紫色（按钮、链接主色）
        primaryDark: '#764ba2',       // 主色深色：深紫色（按钮hover、渐变终点）
        primaryLight: '#764ba2',      // 主色浅色：用于浅色背景上的主色元素
        secondary: '#764ba2',         // 辅助色：用于次要按钮、标签等

        // 背景色 - 用于页面和容器背景
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',  // 页面主背景：紫色渐变
        backgroundAlt: 'linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%)',  // 备用背景：浅灰渐变（卡片背景）
        surface: '#ffffff',           // 表面色：白色（卡片、容器背景）
        surfaceAlt: '#f8f9fa',        // 表面备用色：浅灰色（二级卡片背景）

        // 文本色 - 用于不同层级的文本显示
        text: '#2d3748',              // 主文本色：深灰色（标题、正文）
        textSecondary: '#718096',     // 次要文本色：中灰色（描述、辅助信息）
        textLight: '#adb5bd',         // 浅色文本：浅灰色（占位符、禁用文本）
        textOnPrimary: '#ffffff',     // 主色上的文本：白色（按钮文字、标题文字）

        // 边框色 - 用于分隔和轮廓
        border: '#e9ecef',            // 主边框色：浅灰色（输入框、卡片边框）
        borderLight: '#f1f3f5',       // 浅边框色：更浅的灰色（分隔线）

        // 阴影色 - 用于深度和层次感
        shadow: 'rgba(0, 0, 0, .3)',              // 主阴影：深色半透明（大卡片阴影）
        shadowLight: 'rgba(0, 0, 0, .05)',        // 浅阴影：极浅阴影（小元素阴影）
        shadowPrimary: 'rgba(102, 126, 234, .2)', // 主色阴影：主色半透明（按钮、焦点阴影）
        hover: 'rgba(102, 126, 234, .1)',         // 悬停背景：主色极浅（按钮、链接hover背景）

        // 状态色 - 用于提示、警告、成功、错误等状态
        success: '#10b981',           // 成功色：绿色（成功提示、完成状态）
        error: '#ef4444',             // 错误色：红色（错误提示、危险操作）
        warning: '#f59e0b',           // 警告色：橙色（警告提示、注意状态）
        info: '#3b82f6'               // 信息色：蓝色（信息提示、一般状态）
      },

      // ========== 字体配置 ==========
      typography: {
        // 字体系列：系统字体栈，确保跨平台一致性
        fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',

        // 字号配置：响应式字体大小系统
        fontSizeBase: '16px',         // 基础字号：正文、按钮文字
        fontSizeSmall: '14px',        // 小字号：辅助信息、标签
        fontSizeLarge: '20px',        // 大字号：小标题、强调文本
        fontSizeXLarge: '28px',       // 超大字号：页面标题（工具页面）
        fontSizeXXLarge: '32px',      // 超大字号：首页主标题

        // 字重配置：文本粗细等级
        fontWeightNormal: '400',      // 正常字重：正文文本
        fontWeightMedium: '500',      // 中等字重：按钮文字、次要标题
        fontWeightSemiBold: '600',    // 半粗字重：小标题、标签
        fontWeightBold: '700',        // 粗字重：主标题、强调文本

        // 行高：文本行间距
        lineHeight: '1.5'             // 行高：1.5倍字号（良好的阅读体验）
      },

      // ========== 间距配置 ==========
      spacing: {
        xs: '4px',    // 极小间距：图标与文字间距、紧密排列
        sm: '8px',    // 小间距：表单元素间距、小元素padding
        md: '16px',   // 中等间距：卡片内边距、元素组间距
        lg: '24px',   // 大间距：区块间距、主要内容padding
        xl: '30px',   // 超大间距：页面边距、大区块间距
        xxl: '40px'   // 极大间距：页面顶部间距、标题区域padding
      },

      // ========== 圆角配置 ==========
      borderRadius: {
        sm: '8px',    // 小圆角：输入框、小按钮
        md: '12px',   // 中等圆角：卡片、标准按钮
        lg: '16px',   // 大圆角：大卡片、主要容器
        xl: '20px',   // 超大圆角：主容器、页面容器
        full: '50%'   // 完全圆角：圆形按钮、头像
      },

      // ========== 阴影配置 ==========
      shadows: {
        sm: '0 2px 8px rgba(0, 0, 0, .05)',          // 小阴影：输入框、小卡片（轻微提升）
        md: '0 4px 12px rgba(0, 0, 0, .1)',          // 中等阴影：标准卡片（明显提升）
        lg: '0 8px 20px rgba(102, 126, 234, .25)',   // 大阴影：悬浮卡片（强烈提升，带主色）
        xl: '0 20px 60px rgba(0, 0, 0, .3)'          // 超大阴影：主容器（深度层次）
      }
    },

    /**
     * 主题2: 赛博朋克（暗黑霓虹风格）
     * 特点：暗黑背景，霓虹色彩，科技感强
     */
    cyberpunk: {
      name: { zh: '赛博朋克', en: 'Cyberpunk' },

      // ========== 颜色配置 ==========
      colors: {
        // 主色系 - 霓虹色彩
        primary: '#00f0ff',           // 主色：青色霓虹（按钮、链接主色）
        primaryDark: '#ff006e',       // 主色深色：粉红霓虹（按钮hover、渐变终点）
        primaryLight: '#ffbe0b',      // 主色浅色：黄色霓虹（辅助元素）
        secondary: '#8338ec',         // 辅助色：紫色霓虹（次要按钮、标签）

        // 背景色 - 暗黑渐变
        background: 'linear-gradient(135deg, #0a0e27 0%, #1a1a3e 50%, #2d1b3d 100%)',  // 页面主背景：深色渐变
        backgroundAlt: 'linear-gradient(135deg, #1a1a3e 0%, #2d1b3d 100%)',  // 备用背景：深紫渐变
        surface: '#1a1a2e',           // 表面色：深蓝黑色（卡片背景）
        surfaceAlt: '#16213e',        // 表面备用色：更深蓝黑色

        // 文本色 - 高对比度
        text: '#e0e0e0',              // 主文本色：浅灰色（标题、正文）
        textSecondary: '#a0a0a0',     // 次要文本色：中灰色（描述）
        textLight: '#666666',         // 浅色文本：深灰色（占位符）
        textOnPrimary: '#0a0e27',     // 主色上的文本：深色（按钮文字）

        // 边框色 - 霓虹边框
        border: '#00f0ff',            // 主边框色：青色霓虹（输入框、卡片边框）
        borderLight: '#8338ec',       // 浅边框色：紫色霓虹（分隔线）

        // 阴影色 - 霓虹发光效果
        shadow: 'rgba(0, 240, 255, .3)',        // 主阴影：青色发光（大卡片阴影）
        shadowLight: 'rgba(0, 240, 255, .1)',   // 浅阴影：青色微光（小元素阴影）
        shadowPrimary: 'rgba(0, 240, 255, .4)', // 主色阴影：青色强光（按钮、焦点阴影）
        hover: 'rgba(0, 240, 255, .2)',         // 悬停背景：青色半透明

        // 状态色 - 霓虹色彩
        success: '#00ff88',           // 成功色：绿色霓虹
        error: '#ff006e',             // 错误色：粉红霓虹
        warning: '#ffbe0b',           // 警告色：黄色霓虹
        info: '#00f0ff'               // 信息色：青色霓虹
      },

      // ========== 字体配置 ==========
      typography: {
        // 字体系列：科技感字体（需要加载外部字体）
        fontFamily: '"Orbitron", "Rajdhani", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
        fontSizeBase: '16px',
        fontSizeSmall: '14px',
        fontSizeLarge: '20px',
        fontSizeXLarge: '28px',
        fontSizeXXLarge: '32px',
        fontWeightNormal: '400',
        fontWeightMedium: '500',
        fontWeightSemiBold: '600',
        fontWeightBold: '700',
        lineHeight: '1.5'
      },

      // ========== 间距配置 ==========
      spacing: {
        xs: '4px',
        sm: '8px',
        md: '16px',
        lg: '24px',
        xl: '30px',
        xxl: '40px'
      },

      // ========== 圆角配置 ==========
      borderRadius: {
        sm: '4px',    // 较小圆角：更锋利的科技感
        md: '8px',
        lg: '12px',
        xl: '16px',
        full: '50%'
      },

      // ========== 阴影配置 ==========
      shadows: {
        sm: '0 2px 8px rgba(0, 240, 255, .2)',   // 青色微光
        md: '0 4px 12px rgba(0, 240, 255, .3)',  // 青色中光
        lg: '0 8px 20px rgba(0, 240, 255, .4)',  // 青色强光
        xl: '0 20px 60px rgba(0, 240, 255, .3)'  // 青色大光
      }
    },

    /**
     * 主题3: 清新浅色（现代简约风格）
     * 特点：浅色背景，清新配色，简约现代
     */
    light: {
      name: { zh: '清新浅色', en: 'Light & Fresh' },

      // ========== 颜色配置 ==========
      colors: {
        // 主色系 - 清新蓝色
        primary: '#3b82f6',           // 主色：清新蓝色
        primaryDark: '#2563eb',       // 主色深色：深蓝色
        primaryLight: '#60a5fa',      // 主色浅色：浅蓝色
        secondary: '#8b5cf6',         // 辅助色：紫色

        // 背景色 - 浅色渐变
        background: 'linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #f0fdf4 100%)',  // 页面主背景：浅蓝绿渐变
        backgroundAlt: 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)',  // 备用背景：纯白渐变
        surface: '#ffffff',           // 表面色：纯白色
        surfaceAlt: '#f8fafc',        // 表面备用色：极浅灰色

        // 文本色 - 深色文本
        text: '#1e293b',              // 主文本色：深蓝灰色
        textSecondary: '#64748b',     // 次要文本色：中蓝灰色
        textLight: '#94a3b8',         // 浅色文本：浅蓝灰色
        textOnPrimary: '#ffffff',     // 主色上的文本：白色

        // 边框色 - 浅色边框
        border: '#e2e8f0',            // 主边框色：浅蓝灰色
        borderLight: '#f1f5f9',       // 浅边框色：极浅蓝灰色

        // 阴影色 - 轻微阴影
        shadow: 'rgba(0, 0, 0, .08)',         // 主阴影：极浅阴影
        shadowLight: 'rgba(0, 0, 0, .04)',    // 浅阴影：几乎不可见
        shadowPrimary: 'rgba(59, 130, 246, .15)',  // 主色阴影：蓝色浅阴影
        hover: 'rgba(59, 130, 246, .1)',      // 悬停背景：蓝色极浅

        // 状态色 - 清新色彩
        success: '#10b981',           // 成功色：清新绿色
        error: '#ef4444',             // 错误色：红色
        warning: '#f59e0b',           // 警告色：橙色
        info: '#3b82f6'               // 信息色：蓝色
      },

      // ========== 字体配置 ==========
      typography: {
        fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
        fontSizeBase: '16px',
        fontSizeSmall: '14px',
        fontSizeLarge: '20px',
        fontSizeXLarge: '28px',
        fontSizeXXLarge: '32px',
        fontWeightNormal: '400',
        fontWeightMedium: '500',
        fontWeightSemiBold: '600',
        fontWeightBold: '700',
        lineHeight: '1.6'             // 较大行高：更舒适的阅读体验
      },

      // ========== 间距配置 ==========
      spacing: {
        xs: '4px',
        sm: '8px',
        md: '16px',
        lg: '24px',
        xl: '30px',
        xxl: '40px'
      },

      // ========== 圆角配置 ==========
      borderRadius: {
        sm: '6px',    // 稍小圆角：更精致
        md: '10px',
        lg: '14px',
        xl: '18px',
        full: '50%'
      },

      // ========== 阴影配置 ==========
      shadows: {
        sm: '0 1px 3px rgba(0, 0, 0, .08)',       // 极小阴影
        md: '0 4px 6px rgba(0, 0, 0, .1)',        // 轻微阴影
        lg: '0 10px 15px rgba(0, 0, 0, .1)',      // 中等阴影
        xl: '0 20px 25px rgba(0, 0, 0, .15)'      // 较大阴影
      }
    },

    /**
     * 主题4: 现代简约（GitHub/Discord风格）
     * 特点：暗色主题，现代简约，类似Discord/GitHub Dark
     */
    modern: {
      name: { zh: '现代简约', en: 'Modern' },

      // ========== 颜色配置 ==========
      colors: {
        // 主色系 - Discord风格蓝色
        primary: '#5865f2',           // 主色：Discord蓝
        primaryDark: '#4752c4',       // 主色深色：深Discord蓝
        primaryLight: '#7289da',      // 主色浅色：浅Discord蓝
        secondary: '#57f287',         // 辅助色：Discord绿

        // 背景色 - 暗色背景
        background: '#36393f',        // 页面主背景：Discord灰（固定色，不用渐变）
        backgroundAlt: '#2f3136',     // 备用背景：更深灰
        surface: '#40444b',           // 表面色：中灰色（卡片背景）
        surfaceAlt: '#36393f',        // 表面备用色：同主背景

        // 文本色 - 浅色文本
        text: '#dcddde',              // 主文本色：Discord浅灰
        textSecondary: '#b9bbbe',     // 次要文本色：Discord中灰
        textLight: '#72767d',         // 浅色文本：Discord深灰
        textOnPrimary: '#ffffff',     // 主色上的文本：白色

        // 边框色 - 深色边框
        border: '#202225',            // 主边框色：极深灰
        borderLight: '#2f3136',       // 浅边框色：深灰

        // 阴影色 - 深色阴影
        shadow: 'rgba(0, 0, 0, .3)',              // 主阴影：黑色半透明
        shadowLight: 'rgba(0, 0, 0, .2)',         // 浅阴影：黑色浅透明
        shadowPrimary: 'rgba(88, 101, 242, .3)',  // 主色阴影：Discord蓝半透明
        hover: 'rgba(88, 101, 242, .1)',          // 悬停背景：Discord蓝极浅

        // 状态色 - Discord风格
        success: '#57f287',           // 成功色：Discord绿
        error: '#ed4245',             // 错误色：Discord红
        warning: '#fee75c',           // 警告色：Discord黄
        info: '#5865f2'               // 信息色：Discord蓝
      },

      // ========== 字体配置 ==========
      typography: {
        // 字体系列：Discord字体栈
        fontFamily: '"Whitney", "Helvetica Neue", Helvetica, Arial, sans-serif',
        fontSizeBase: '16px',
        fontSizeSmall: '14px',
        fontSizeLarge: '20px',
        fontSizeXLarge: '28px',
        fontSizeXXLarge: '32px',
        fontWeightNormal: '400',
        fontWeightMedium: '500',
        fontWeightSemiBold: '600',
        fontWeightBold: '700',
        lineHeight: '1.375'           // Discord风格行高：稍紧凑
      },

      // ========== 间距配置 ==========
      spacing: {
        xs: '4px',
        sm: '8px',
        md: '16px',
        lg: '24px',
        xl: '30px',
        xxl: '40px'
      },

      // ========== 圆角配置 ==========
      borderRadius: {
        sm: '3px',    // 小圆角：Discord风格
        md: '4px',
        lg: '8px',
        xl: '12px',
        full: '50%'
      },

      // ========== 阴影配置 ==========
      shadows: {
        sm: '0 2px 4px rgba(0, 0, 0, .2)',        // Discord风格阴影
        md: '0 4px 8px rgba(0, 0, 0, .2)',
        lg: '0 8px 16px rgba(0, 0, 0, .24)',
        xl: '0 16px 32px rgba(0, 0, 0, .3)'
      }
    }
  };

  // 默认主题键名
  const defaultTheme = 'purple';

  /**
   * 获取当前主题配置
   * @returns {Object} 当前主题配置对象
   */
  function getCurrentTheme() {
    const saved = localStorage.getItem('theme') || defaultTheme;
    return themes[saved] || themes[defaultTheme];
  }

  /**
   * 设置主题
   * @param {string} themeName - 主题名称（purple/cyberpunk/light/modern）
   * @returns {Object} 设置的主题配置对象
   */
  function setTheme(themeName) {
    if (!themes[themeName]) {
      console.warn(`主题 "${themeName}" 不存在，使用默认主题`);
      themeName = defaultTheme;
    }
    localStorage.setItem('theme', themeName);
    applyTheme(themes[themeName]);
    return themes[themeName];
  }

  /**
   * 应用主题到页面
   * 将所有主题配置转换为CSS变量并应用到文档根元素
   * @param {Object} theme - 主题配置对象
   */
  function applyTheme(theme) {
    const root = document.documentElement;

    // 设置CSS变量 - 颜色变量
    Object.keys(theme.colors).forEach(key => {
      root.style.setProperty(`--color-${key}`, theme.colors[key]);
    });

    // 设置CSS变量 - 字体变量
    Object.keys(theme.typography).forEach(key => {
      root.style.setProperty(`--font-${key}`, theme.typography[key]);
    });

    // 设置CSS变量 - 间距变量
    Object.keys(theme.spacing).forEach(key => {
      root.style.setProperty(`--spacing-${key}`, theme.spacing[key]);
    });

    // 设置CSS变量 - 圆角变量
    Object.keys(theme.borderRadius).forEach(key => {
      root.style.setProperty(`--radius-${key}`, theme.borderRadius[key]);
    });

    // 设置CSS变量 - 阴影变量
    Object.keys(theme.shadows).forEach(key => {
      root.style.setProperty(`--shadow-${key}`, theme.shadows[key]);
    });

    // 应用背景和基础样式
    document.body.style.background = theme.colors.background;
    document.body.style.fontFamily = theme.typography.fontFamily;
    document.body.style.color = theme.colors.text;
  }

  /**
   * 获取所有主题列表
   * @returns {Array} 主题列表数组，每个元素包含key和name
   */
  function getThemes() {
    return Object.keys(themes).map(key => ({
      key,
      name: themes[key].name
    }));
  }

  /**
   * 初始化主题系统
   * 在页面加载时自动调用，应用保存的主题或默认主题
   * @returns {Object} 应用的主题配置对象
   */
  function initTheme() {
    const theme = getCurrentTheme();
    applyTheme(theme);
    return theme;
  }

  // ========== 导出到全局作用域 ==========
  window.themes = themes;              // 主题配置对象
  window.getCurrentTheme = getCurrentTheme;  // 获取当前主题
  window.setTheme = setTheme;          // 设置主题
  window.applyTheme = applyTheme;      // 应用主题
  window.getThemes = getThemes;        // 获取主题列表
  window.initTheme = initTheme;        // 初始化主题
  window.defaultTheme = defaultTheme;  // 默认主题名称

  // 自动初始化：页面加载时自动应用主题
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initTheme);
  } else {
    initTheme();
  }
})();
