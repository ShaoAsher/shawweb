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
        // 字体系列：优雅现代字体（Inter + 中文字体）
        fontFamily: '"Inter", "Noto Sans SC", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',

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

        // 背景色 - 暗黑渐变（确保所有背景都是暗色或暗色渐变）
        background: 'linear-gradient(135deg, #0a0e27 0%, #1a1a3e 50%, #2d1b3d 100%)',  // 页面主背景：深色渐变
        backgroundAlt: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 100%)',  // 备用背景：深蓝黑渐变
        surface: '#1a1a2e',           // 表面色：深蓝黑色（卡片背景）
        surfaceAlt: '#16213e',        // 表面备用色：更深蓝黑色

        // 文本色 - 高对比度白色和发光色
        text: '#ffffff',              // 主文本色：纯白色（标题、正文）- 增强对比度
        textSecondary: '#b0e0ff',     // 次要文本色：浅青色发光（描述）
        textLight: '#80a0c0',         // 浅色文本：青色灰（占位符）
        textOnPrimary: '#ffffff',     // 主色上的文本：白色（按钮文字、标题文字）
        textOnSurface: '#ffffff',     // 表面上的文本：白色（卡片文字）
        textOnSurfaceAlt: '#ffffff',  // 表面备用上的文本：白色

        // 边框色 - 霓虹边框
        border: '#00f0ff',            // 主边框色：青色霓虹（输入框、卡片边框）
        borderLight: '#8338ec',       // 浅边框色：紫色霓虹（分隔线）

        // 阴影色 - 霓虹发光效果
        shadow: 'rgba(0, 240, 255, .4)',        // 主阴影：青色发光（大卡片阴影）- 增强发光
        shadowLight: 'rgba(0, 240, 255, .15)',   // 浅阴影：青色微光（小元素阴影）
        shadowPrimary: 'rgba(0, 240, 255, .5)', // 主色阴影：青色强光（按钮、焦点阴影）- 增强发光
        hover: 'rgba(0, 240, 255, .25)',         // 悬停背景：青色半透明 - 增强效果

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
        sm: '0 2px 8px rgba(0, 240, 255, .25), 0 0 10px rgba(0, 240, 255, .1)',   // 青色微光 + 外发光
        md: '0 4px 12px rgba(0, 240, 255, .35), 0 0 15px rgba(0, 240, 255, .15)',  // 青色中光 + 外发光
        lg: '0 8px 20px rgba(0, 240, 255, .45), 0 0 25px rgba(0, 240, 255, .2)',  // 青色强光 + 外发光
        xl: '0 20px 60px rgba(0, 240, 255, .4), 0 0 40px rgba(0, 240, 255, .15)'  // 青色大光 + 外发光
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

        // 背景色 - 精美浅色渐变
        background: 'linear-gradient(135deg, #f8fafc 0%, #f1f5f9 50%, #e2e8f0 100%)',  // 页面主背景：精美浅灰渐变
        backgroundAlt: 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)',  // 备用背景：纯白渐变
        surface: '#ffffff',           // 表面色：纯白色
        surfaceAlt: '#f8fafc',        // 表面备用色：极浅灰色

        // 文本色 - 深色文本（确保可读性）
        text: '#0f172a',              // 主文本色：深蓝灰色（增强对比度）
        textSecondary: '#475569',     // 次要文本色：中蓝灰色
        textLight: '#94a3b8',         // 浅色文本：浅蓝灰色
        textOnPrimary: '#ffffff',     // 主色上的文本：白色（按钮文字、标题文字）
        textOnSurface: '#0f172a',     // 表面上的文本：深蓝灰色（浅色卡片文字）
        textOnSurfaceAlt: '#0f172a',  // 表面备用上的文本：深蓝灰色（浅色背景文字）

        // 边框色 - 浅色边框
        border: '#e2e8f0',            // 主边框色：浅蓝灰色
        borderLight: '#f1f5f9',       // 浅边框色：极浅蓝灰色

        // 阴影色 - 精美阴影
        shadow: 'rgba(0, 0, 0, .1)',         // 主阴影：精美阴影
        shadowLight: 'rgba(0, 0, 0, .05)',    // 浅阴影：轻微阴影
        shadowPrimary: 'rgba(59, 130, 246, .2)',  // 主色阴影：蓝色阴影（增强）
        hover: 'rgba(59, 130, 246, .12)',      // 悬停背景：蓝色浅色（增强）

        // 状态色 - 清新色彩
        success: '#10b981',           // 成功色：清新绿色
        error: '#ef4444',             // 错误色：红色
        warning: '#f59e0b',           // 警告色：橙色
        info: '#3b82f6'               // 信息色：蓝色
      },

      // ========== 字体配置 ==========
      typography: {
        // 字体系列：清新自然字体（Poppins + 中文字体）
        fontFamily: '"Poppins", "Noto Sans SC", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
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
        sm: '0 1px 3px rgba(0, 0, 0, .1), 0 1px 2px rgba(0, 0, 0, .06)',       // 精美小阴影
        md: '0 4px 6px rgba(0, 0, 0, .1), 0 2px 4px rgba(0, 0, 0, .06)',        // 精美中阴影
        lg: '0 10px 15px rgba(0, 0, 0, .1), 0 4px 6px rgba(0, 0, 0, .05)',      // 精美大阴影
        xl: '0 20px 25px rgba(0, 0, 0, .15), 0 10px 10px rgba(0, 0, 0, .04)'      // 精美超大阴影
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

        // 背景色 - 暗色渐变（确保所有背景都是暗色或暗色渐变）
        background: 'linear-gradient(135deg, #2c2f33 0%, #36393f 50%, #2f3136 100%)',  // 页面主背景：暗色渐变
        backgroundAlt: 'linear-gradient(135deg, #23272a 0%, #2c2f33 100%)',  // 备用背景：深灰渐变
        surface: '#40444b',           // 表面色：中灰色（卡片背景）
        surfaceAlt: '#36393f',        // 表面备用色：主背景色

        // 文本色 - 高对比度白色
        text: '#ffffff',              // 主文本色：纯白色（标题、正文）- 增强对比度
        textSecondary: '#e0e0e0',     // 次要文本色：亮灰色（描述）
        textLight: '#a0a0a0',         // 浅色文本：中灰色（占位符）
        textOnPrimary: '#ffffff',     // 主色上的文本：白色（按钮文字、标题文字）
        textOnSurface: '#ffffff',     // 表面上的文本：白色（卡片文字）
        textOnSurfaceAlt: '#ffffff',  // 表面备用上的文本：白色

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
        // 字体系列：现代简约字体（Montserrat + 中文字体）
        fontFamily: '"Montserrat", "Noto Sans SC", "Helvetica Neue", Helvetica, Arial, sans-serif',
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
    },

    /**
     * 主题5: 支付宝蓝（商务专业风格）
     * 特点：支付宝品牌蓝色，商务专业，现代简约
     */
    alipay: {
      name: { zh: '支付宝蓝', en: 'Alipay Blue' },

      // ========== 颜色配置 ==========
      colors: {
        // 主色系 - 支付宝品牌蓝色
        primary: '#1677FF',           // 主色：支付宝蓝（按钮、链接主色）
        primaryDark: '#0958d9',       // 主色深色：深支付宝蓝（按钮hover、渐变终点）
        primaryLight: '#4096ff',      // 主色浅色：浅支付宝蓝（辅助元素）
        secondary: '#52c41a',         // 辅助色：支付宝绿（次要按钮、标签）

        // 背景色 - 精美浅色渐变
        background: 'linear-gradient(135deg, #e6f4ff 0%, #bae0ff 50%, #91caff 100%)',  // 页面主背景：支付宝蓝渐变
        backgroundAlt: 'linear-gradient(135deg, #ffffff 0%, #f0f9ff 100%)',  // 备用背景：纯白渐变
        surface: '#ffffff',           // 表面色：纯白色
        surfaceAlt: '#f0f9ff',        // 表面备用色：极浅蓝色

        // 文本色 - 深色文本（确保可读性）
        text: '#1d39c4',              // 主文本色：深蓝色（增强对比度）
        textSecondary: '#597ef7',     // 次要文本色：中蓝色
        textLight: '#adc6ff',         // 浅色文本：浅蓝色
        textOnPrimary: '#ffffff',     // 主色上的文本：白色（按钮文字、标题文字）
        textOnSurface: '#1d39c4',     // 表面上的文本：深蓝色（浅色卡片文字）
        textOnSurfaceAlt: '#1d39c4',  // 表面备用上的文本：深蓝色（浅色背景文字）

        // 边框色 - 浅色边框
        border: '#d4e4f7',            // 主边框色：浅蓝色
        borderLight: '#e6f4ff',       // 浅边框色：极浅蓝色

        // 阴影色 - 精美阴影
        shadow: 'rgba(22, 119, 255, .15)',         // 主阴影：支付宝蓝阴影
        shadowLight: 'rgba(22, 119, 255, .08)',    // 浅阴影：轻微阴影
        shadowPrimary: 'rgba(22, 119, 255, .25)',  // 主色阴影：支付宝蓝阴影（增强）
        hover: 'rgba(22, 119, 255, .12)',          // 悬停背景：蓝色浅色（增强）

        // 状态色 - 支付宝风格
        success: '#52c41a',           // 成功色：支付宝绿
        error: '#ff4d4f',             // 错误色：红色
        warning: '#faad14',           // 警告色：橙色
        info: '#1677FF'               // 信息色：支付宝蓝
      },

      // ========== 字体配置 ==========
      typography: {
        // 字体系列：现代商务字体（Inter + 中文字体）
        fontFamily: '"Inter", "Poppins", "Noto Sans SC", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
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
        sm: '0 1px 3px rgba(22, 119, 255, .12), 0 1px 2px rgba(22, 119, 255, .08)',       // 精美小阴影
        md: '0 4px 6px rgba(22, 119, 255, .15), 0 2px 4px rgba(22, 119, 255, .1)',        // 精美中阴影
        lg: '0 10px 15px rgba(22, 119, 255, .18), 0 4px 6px rgba(22, 119, 255, .12)',     // 精美大阴影
        xl: '0 20px 25px rgba(22, 119, 255, .2), 0 10px 10px rgba(22, 119, 255, .08)'      // 精美超大阴影
      }
    },

    /**
     * 主题6: 微信绿（社交活力风格）
     * 特点：微信品牌绿色，社交活力，清新自然
     */
    wechat: {
      name: { zh: '微信绿', en: 'WeChat Green' },

      // ========== 颜色配置 ==========
      colors: {
        // 主色系 - 微信品牌绿色
        primary: '#07C160',           // 主色：微信绿（按钮、链接主色）
        primaryDark: '#06ad56',       // 主色深色：深微信绿（按钮hover、渐变终点）
        primaryLight: '#38d976',      // 主色浅色：浅微信绿（辅助元素）
        secondary: '#576b95',         // 辅助色：微信蓝（次要按钮、标签）

        // 背景色 - 清新绿色渐变
        background: 'linear-gradient(135deg, #f0fdf4 0%, #dcfce7 50%, #bbf7d0 100%)',  // 页面主背景：微信绿渐变
        backgroundAlt: 'linear-gradient(135deg, #ffffff 0%, #f0fdf4 100%)',  // 备用背景：纯白渐变
        surface: '#ffffff',           // 表面色：纯白色
        surfaceAlt: '#f0fdf4',        // 表面备用色：极浅绿色

        // 文本色 - 深色文本（确保可读性）
        text: '#166534',              // 主文本色：深绿色（增强对比度）
        textSecondary: '#16a34a',     // 次要文本色：中绿色
        textLight: '#86efac',         // 浅色文本：浅绿色
        textOnPrimary: '#ffffff',     // 主色上的文本：白色（按钮文字、标题文字）
        textOnSurface: '#166534',     // 表面上的文本：深绿色（浅色卡片文字）
        textOnSurfaceAlt: '#166534',  // 表面备用上的文本：深绿色（浅色背景文字）

        // 边框色 - 浅色边框
        border: '#bbf7d0',            // 主边框色：浅绿色
        borderLight: '#dcfce7',       // 浅边框色：极浅绿色

        // 阴影色 - 精美阴影
        shadow: 'rgba(7, 193, 96, .15)',         // 主阴影：微信绿阴影
        shadowLight: 'rgba(7, 193, 96, .08)',    // 浅阴影：轻微阴影
        shadowPrimary: 'rgba(7, 193, 96, .25)',  // 主色阴影：微信绿阴影（增强）
        hover: 'rgba(7, 193, 96, .12)',          // 悬停背景：绿色浅色（增强）

        // 状态色 - 微信风格
        success: '#07C160',           // 成功色：微信绿
        error: '#ef4444',             // 错误色：红色
        warning: '#f59e0b',           // 警告色：橙色
        info: '#576b95'               // 信息色：微信蓝
      },

      // ========== 字体配置 ==========
      typography: {
        // 字体系列：清新自然字体（Poppins + 中文字体）
        fontFamily: '"Poppins", "Montserrat", "Noto Sans SC", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
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
        sm: '8px',    // 圆角：更柔和
        md: '12px',
        lg: '16px',
        xl: '20px',
        full: '50%'
      },

      // ========== 阴影配置 ==========
      shadows: {
        sm: '0 1px 3px rgba(7, 193, 96, .12), 0 1px 2px rgba(7, 193, 96, .08)',       // 精美小阴影
        md: '0 4px 6px rgba(7, 193, 96, .15), 0 2px 4px rgba(7, 193, 96, .1)',        // 精美中阴影
        lg: '0 10px 15px rgba(7, 193, 96, .18), 0 4px 6px rgba(7, 193, 96, .12)',     // 精美大阴影
        xl: '0 20px 25px rgba(7, 193, 96, .2), 0 10px 10px rgba(7, 193, 96, .08)'      // 精美超大阴影
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
   * @param {string} themeName - 主题名称（purple/cyberpunk/light/modern/alipay/wechat）
   * @returns {Object} 设置的主题配置对象
   */
  function setTheme(themeName) {
    if (!themes[themeName]) {
      console.warn(`主题 "${themeName}" 不存在，使用默认主题`);
      themeName = defaultTheme;
    }
    localStorage.setItem('theme', themeName);
    const theme = themes[themeName];
    applyTheme(theme, themeName);
    return theme;
  }

  /**
   * 将驼峰命名转换为连字符命名（如 primaryDark -> primary-dark）
   * @param {string} key - 驼峰命名的键名
   * @returns {string} 连字符命名的键名
   */
  function camelToKebab(key) {
    return key.replace(/([A-Z])/g, '-$1').toLowerCase();
  }

  /**
   * 应用主题到页面
   * 将所有主题配置转换为CSS变量并应用到文档根元素
   * @param {Object} theme - 主题配置对象
   * @param {string} themeKey - 主题键名（可选）
   */
  function applyTheme(theme, themeKey) {
    const root = document.documentElement;

    // 批量设置CSS变量 - 使用统一的转换函数
    const setCSSVars = (obj, prefix) => {
      Object.keys(obj).forEach(key => {
        const cssKey = camelToKebab(key);
        root.style.setProperty(`--${prefix}-${cssKey}`, obj[key]);
      });
    };

    // 设置各类CSS变量
    setCSSVars(theme.colors, 'color');
    setCSSVars(theme.typography, 'font');
    setCSSVars(theme.spacing, 'spacing');
    setCSSVars(theme.borderRadius, 'radius');
    setCSSVars(theme.shadows, 'shadow');

    // 确保 textOnSurface 和 textOnSurfaceAlt 已设置（向后兼容）
    if (!theme.colors.textOnSurface) {
      const isDarkTheme = themeKey === 'cyberpunk' || themeKey === 'modern';
      root.style.setProperty('--color-text-on-surface', isDarkTheme ? '#ffffff' : theme.colors.text);
    }
    if (!theme.colors.textOnSurfaceAlt) {
      const isDarkTheme = themeKey === 'cyberpunk' || themeKey === 'modern';
      root.style.setProperty('--color-text-on-surface-alt', isDarkTheme ? '#ffffff' : theme.colors.text);
    }

    // 应用背景和基础样式
    document.body.style.background = theme.colors.background;
    document.body.style.fontFamily = theme.typography.fontFamily;
    document.body.style.color = theme.colors.text;

    // 设置主题标识，用于CSS选择器
    if (themeKey) {
      document.body.setAttribute('data-theme', themeKey);
      // 移除所有主题类，添加当前主题类
      const themeClasses = ['purple', 'cyberpunk', 'light', 'modern', 'alipay', 'wechat'];
      themeClasses.forEach(cls => document.body.classList.remove(cls));
      document.body.classList.add(themeKey);
    }
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
    const saved = localStorage.getItem('theme') || defaultTheme;
    const theme = themes[saved] || themes[defaultTheme];
    applyTheme(theme, saved);
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
