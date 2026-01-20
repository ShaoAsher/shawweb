// 主题配置系统
const themes = {
  purple: {
    name: { zh: '优雅紫色', en: 'Elegant Purple' },
    colors: {
      primary: '#667eea',
      primaryDark: '#764ba2',
      primaryLight: '#764ba2',
      secondary: '#764ba2',
      background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
      backgroundAlt: 'linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%)',
      surface: '#ffffff',
      surfaceAlt: '#f8f9fa',
      text: '#2d3748',
      textSecondary: '#718096',
      textLight: '#adb5bd',
      textOnPrimary: '#ffffff',
      textOnSurface: '#2d3748',
      textOnSurfaceAlt: '#2d3748',
      border: '#e9ecef',
      borderLight: '#f1f3f5',
      shadow: 'rgba(0, 0, 0, .3)',
      shadowLight: 'rgba(0, 0, 0, .05)',
      shadowPrimary: 'rgba(102, 126, 234, .2)',
      hover: 'rgba(102, 126, 234, .1)',
      success: '#10b981',
      error: '#ef4444',
      warning: '#f59e0b',
      info: '#3b82f6'
    },
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
      lineHeight: '1.5'
    },
    spacing: {
      xs: '4px',
      sm: '8px',
      md: '16px',
      lg: '24px',
      xl: '30px',
      xxl: '40px'
    },
    borderRadius: {
      sm: '8px',
      md: '12px',
      lg: '16px',
      xl: '20px',
      full: '50%'
    },
    shadows: {
      sm: '0 2px 8px rgba(0, 0, 0, .05)',
      md: '0 4px 12px rgba(0, 0, 0, .1)',
      lg: '0 8px 20px rgba(102, 126, 234, .25)',
      xl: '0 20px 60px rgba(0, 0, 0, .3)'
    }
  },
  cyberpunk: {
    name: { zh: '赛博朋克', en: 'Cyberpunk' },
    colors: {
      primary: '#00f0ff',
      primaryDark: '#ff006e',
      primaryLight: '#ffbe0b',
      secondary: '#8338ec',
      background: 'linear-gradient(135deg, #0a0e27 0%, #1a1a3e 50%, #2d1b3d 100%)',
      backgroundAlt: 'linear-gradient(135deg, #1a1a2e 0%, #16213e 100%)',
      surface: '#1a1a2e',
      surfaceAlt: '#16213e',
      text: '#ffffff',
      textSecondary: '#b0e0ff',
      textLight: '#80a0c0',
      textOnPrimary: '#ffffff',
      textOnSurface: '#ffffff',
      textOnSurfaceAlt: '#ffffff',
      border: '#00f0ff',
      borderLight: '#8338ec',
      shadow: 'rgba(0, 240, 255, .4)',
      shadowLight: 'rgba(0, 240, 255, .15)',
      shadowPrimary: 'rgba(0, 240, 255, .5)',
      hover: 'rgba(0, 240, 255, .25)',
      success: '#00ff88',
      error: '#ff006e',
      warning: '#ffbe0b',
      info: '#00f0ff'
    },
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
      lineHeight: '1.5'
    },
    spacing: {
      xs: '4px',
      sm: '8px',
      md: '16px',
      lg: '24px',
      xl: '30px',
      xxl: '40px'
    },
    borderRadius: {
      sm: '4px',
      md: '8px',
      lg: '12px',
      xl: '16px',
      full: '50%'
    },
    shadows: {
      sm: '0 2px 8px rgba(0, 240, 255, .25), 0 0 10px rgba(0, 240, 255, .1)',
      md: '0 4px 12px rgba(0, 240, 255, .35), 0 0 15px rgba(0, 240, 255, .15)',
      lg: '0 8px 20px rgba(0, 240, 255, .45), 0 0 25px rgba(0, 240, 255, .2)',
      xl: '0 20px 60px rgba(0, 240, 255, .4), 0 0 40px rgba(0, 240, 255, .15)'
    }
  },
  light: {
    name: { zh: '清新浅色', en: 'Light & Fresh' },
    colors: {
      primary: '#3b82f6',
      primaryDark: '#2563eb',
      primaryLight: '#60a5fa',
      secondary: '#8b5cf6',
      background: 'linear-gradient(135deg, #f8fafc 0%, #f1f5f9 50%, #e2e8f0 100%)',
      backgroundAlt: 'linear-gradient(135deg, #ffffff 0%, #f8fafc 100%)',
      surface: '#ffffff',
      surfaceAlt: '#f8fafc',
      text: '#0f172a',
      textSecondary: '#475569',
      textLight: '#94a3b8',
      textOnPrimary: '#ffffff',
      textOnSurface: '#0f172a',
      textOnSurfaceAlt: '#0f172a',
      border: '#e2e8f0',
      borderLight: '#f1f5f9',
      shadow: 'rgba(0, 0, 0, .1)',
      shadowLight: 'rgba(0, 0, 0, .05)',
      shadowPrimary: 'rgba(59, 130, 246, .2)',
      hover: 'rgba(59, 130, 246, .12)',
      success: '#10b981',
      error: '#ef4444',
      warning: '#f59e0b',
      info: '#3b82f6'
    },
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
      lineHeight: '1.6'
    },
    spacing: {
      xs: '4px',
      sm: '8px',
      md: '16px',
      lg: '24px',
      xl: '30px',
      xxl: '40px'
    },
    borderRadius: {
      sm: '6px',
      md: '10px',
      lg: '14px',
      xl: '18px',
      full: '50%'
    },
    shadows: {
      sm: '0 1px 3px rgba(0, 0, 0, .1), 0 1px 2px rgba(0, 0, 0, .06)',
      md: '0 4px 6px rgba(0, 0, 0, .1), 0 2px 4px rgba(0, 0, 0, .06)',
      lg: '0 10px 15px rgba(0, 0, 0, .1), 0 4px 6px rgba(0, 0, 0, .05)',
      xl: '0 20px 25px rgba(0, 0, 0, .15), 0 10px 10px rgba(0, 0, 0, .04)'
    }
  },
  modern: {
    name: { zh: '现代简约', en: 'Modern' },
    colors: {
      primary: '#5865f2',
      primaryDark: '#4752c4',
      primaryLight: '#7289da',
      secondary: '#57f287',
      background: 'linear-gradient(135deg, #2c2f33 0%, #36393f 50%, #2f3136 100%)',
      backgroundAlt: 'linear-gradient(135deg, #23272a 0%, #2c2f33 100%)',
      surface: '#40444b',
      surfaceAlt: '#36393f',
      text: '#ffffff',
      textSecondary: '#e0e0e0',
      textLight: '#a0a0a0',
      textOnPrimary: '#ffffff',
      textOnSurface: '#ffffff',
      textOnSurfaceAlt: '#ffffff',
      border: '#202225',
      borderLight: '#2f3136',
      shadow: 'rgba(0, 0, 0, .3)',
      shadowLight: 'rgba(0, 0, 0, .2)',
      shadowPrimary: 'rgba(88, 101, 242, .3)',
      hover: 'rgba(88, 101, 242, .1)',
      success: '#57f287',
      error: '#ed4245',
      warning: '#fee75c',
      info: '#5865f2'
    },
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
      lineHeight: '1.375'
    },
    spacing: {
      xs: '4px',
      sm: '8px',
      md: '16px',
      lg: '24px',
      xl: '30px',
      xxl: '40px'
    },
    borderRadius: {
      sm: '3px',
      md: '4px',
      lg: '8px',
      xl: '12px',
      full: '50%'
    },
    shadows: {
      sm: '0 2px 4px rgba(0, 0, 0, .2)',
      md: '0 4px 8px rgba(0, 0, 0, .2)',
      lg: '0 8px 16px rgba(0, 0, 0, .24)',
      xl: '0 16px 32px rgba(0, 0, 0, .3)'
    }
  },
  alipay: {
    name: { zh: '支付宝蓝', en: 'Alipay Blue' },
    colors: {
      primary: '#1677FF',
      primaryDark: '#0958d9',
      primaryLight: '#4096ff',
      secondary: '#52c41a',
      background: 'linear-gradient(135deg, #e6f4ff 0%, #bae0ff 50%, #91caff 100%)',
      backgroundAlt: 'linear-gradient(135deg, #ffffff 0%, #f0f9ff 100%)',
      surface: '#ffffff',
      surfaceAlt: '#f0f9ff',
      text: '#1d39c4',
      textSecondary: '#597ef7',
      textLight: '#adc6ff',
      textOnPrimary: '#ffffff',
      textOnSurface: '#1d39c4',
      textOnSurfaceAlt: '#1d39c4',
      border: '#d4e4f7',
      borderLight: '#e6f4ff',
      shadow: 'rgba(22, 119, 255, .15)',
      shadowLight: 'rgba(22, 119, 255, .08)',
      shadowPrimary: 'rgba(22, 119, 255, .25)',
      hover: 'rgba(22, 119, 255, .12)',
      success: '#52c41a',
      error: '#ff4d4f',
      warning: '#faad14',
      info: '#1677FF'
    },
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
      lineHeight: '1.6'
    },
    spacing: {
      xs: '4px',
      sm: '8px',
      md: '16px',
      lg: '24px',
      xl: '30px',
      xxl: '40px'
    },
    borderRadius: {
      sm: '6px',
      md: '10px',
      lg: '14px',
      xl: '18px',
      full: '50%'
    },
    shadows: {
      sm: '0 1px 3px rgba(22, 119, 255, .12), 0 1px 2px rgba(22, 119, 255, .08)',
      md: '0 4px 6px rgba(22, 119, 255, .15), 0 2px 4px rgba(22, 119, 255, .1)',
      lg: '0 10px 15px rgba(22, 119, 255, .18), 0 4px 6px rgba(22, 119, 255, .12)',
      xl: '0 20px 25px rgba(22, 119, 255, .2), 0 10px 10px rgba(22, 119, 255, .08)'
    }
  },
  wechat: {
    name: { zh: '微信绿', en: 'WeChat Green' },
    colors: {
      primary: '#07C160',
      primaryDark: '#06ad56',
      primaryLight: '#38d976',
      secondary: '#576b95',
      background: 'linear-gradient(135deg, #f0fdf4 0%, #dcfce7 50%, #bbf7d0 100%)',
      backgroundAlt: 'linear-gradient(135deg, #ffffff 0%, #f0fdf4 100%)',
      surface: '#ffffff',
      surfaceAlt: '#f0fdf4',
      text: '#166534',
      textSecondary: '#16a34a',
      textLight: '#86efac',
      textOnPrimary: '#ffffff',
      textOnSurface: '#166534',
      textOnSurfaceAlt: '#166534',
      border: '#bbf7d0',
      borderLight: '#dcfce7',
      shadow: 'rgba(7, 193, 96, .15)',
      shadowLight: 'rgba(7, 193, 96, .08)',
      shadowPrimary: 'rgba(7, 193, 96, .25)',
      hover: 'rgba(7, 193, 96, .12)',
      success: '#07C160',
      error: '#ef4444',
      warning: '#f59e0b',
      info: '#576b95'
    },
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
      lineHeight: '1.6'
    },
    spacing: {
      xs: '4px',
      sm: '8px',
      md: '16px',
      lg: '24px',
      xl: '30px',
      xxl: '40px'
    },
    borderRadius: {
      sm: '8px',
      md: '12px',
      lg: '16px',
      xl: '20px',
      full: '50%'
    },
    shadows: {
      sm: '0 1px 3px rgba(7, 193, 96, .12), 0 1px 2px rgba(7, 193, 96, .08)',
      md: '0 4px 6px rgba(7, 193, 96, .15), 0 2px 4px rgba(7, 193, 96, .1)',
      lg: '0 10px 15px rgba(7, 193, 96, .18), 0 4px 6px rgba(7, 193, 96, .12)',
      xl: '0 20px 25px rgba(7, 193, 96, .2), 0 10px 10px rgba(7, 193, 96, .08)'
    }
  }
}

const defaultTheme = 'purple'

function camelToKebab(key) {
  return key.replace(/([A-Z])/g, '-$1').toLowerCase()
}

function applyTheme(theme, themeKey) {
  const root = document.documentElement

  const setCSSVars = (obj, prefix) => {
    Object.keys(obj).forEach(key => {
      const cssKey = camelToKebab(key)
      root.style.setProperty(`--${prefix}-${cssKey}`, obj[key])
    })
  }

  setCSSVars(theme.colors, 'color')
  setCSSVars(theme.typography, 'font')
  setCSSVars(theme.spacing, 'spacing')
  setCSSVars(theme.borderRadius, 'radius')
  setCSSVars(theme.shadows, 'shadow')

  if (!theme.colors.textOnSurface) {
    const isDarkTheme = themeKey === 'cyberpunk' || themeKey === 'modern'
    root.style.setProperty('--color-text-on-surface', isDarkTheme ? '#ffffff' : theme.colors.text)
  }
  if (!theme.colors.textOnSurfaceAlt) {
    const isDarkTheme = themeKey === 'cyberpunk' || themeKey === 'modern'
    root.style.setProperty('--color-text-on-surface-alt', isDarkTheme ? '#ffffff' : theme.colors.text)
  }

  document.body.style.background = theme.colors.background
  document.body.style.fontFamily = theme.typography.fontFamily
  document.body.style.color = theme.colors.text

  if (themeKey) {
    document.body.setAttribute('data-theme', themeKey)
    const themeClasses = ['purple', 'cyberpunk', 'light', 'modern', 'alipay', 'wechat']
    themeClasses.forEach(cls => document.body.classList.remove(cls))
    document.body.classList.add(themeKey)
  }
}

export function getCurrentTheme() {
  const saved = localStorage.getItem('theme') || defaultTheme
  return themes[saved] || themes[defaultTheme]
}

export function setTheme(themeName) {
  if (!themes[themeName]) {
    console.warn(`主题 "${themeName}" 不存在，使用默认主题`)
    themeName = defaultTheme
  }
  localStorage.setItem('theme', themeName)
  const theme = themes[themeName]
  applyTheme(theme, themeName)
  return theme
}

export function getThemes() {
  return Object.keys(themes).map(key => ({
    key,
    name: themes[key].name,
    data: themes[key]
  }))
}

export function initTheme() {
  const saved = localStorage.getItem('theme') || defaultTheme
  const theme = themes[saved] || themes[defaultTheme]
  applyTheme(theme, saved)
  return theme
}

export { themes }
