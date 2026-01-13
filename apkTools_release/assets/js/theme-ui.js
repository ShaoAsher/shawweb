// 主题切换UI组件
// 提供主题切换按钮和主题选择器

(function () {
  'use strict';

  // 创建主题切换器UI
  function createThemeSwitcher() {
    // 检查是否已存在主题切换器
    if (document.getElementById('themeSwitcher')) {
      return;
    }

    const switcher = document.createElement('div');
    switcher.id = 'themeSwitcher';
    switcher.className = 'theme-switcher';

    const themes = window.getThemes();
    const currentTheme = localStorage.getItem('theme') || window.defaultTheme;

    themes.forEach((theme, index) => {
      const btn = document.createElement('button');
      btn.className = 'theme-btn';
      btn.setAttribute('data-theme', theme.key);
      btn.setAttribute('title', theme.name.zh || theme.name.en || theme.key);

      // 为每个主题设置不同的图标或颜色
      const icons = ['💜', '⚡', '🌸', '💙'];
      btn.textContent = icons[index] || '🎨';

      // 设置按钮背景色（使用主题的主色）
      const themeData = window.themes[theme.key];
      if (themeData && themeData.colors) {
        btn.style.background = themeData.colors.primary;
        btn.style.color = themeData.colors.textOnPrimary || '#ffffff';
      }

      if (theme.key === currentTheme) {
        btn.classList.add('active');
      }

      btn.addEventListener('click', () => {
        switchTheme(theme.key);
      });

      switcher.appendChild(btn);
    });

    document.body.appendChild(switcher);
  }

  // 切换主题
  function switchTheme(themeName) {
    const theme = window.setTheme(themeName);

    // 更新所有主题按钮的active状态
    const buttons = document.querySelectorAll('.theme-btn');
    buttons.forEach(btn => {
      if (btn.getAttribute('data-theme') === themeName) {
        btn.classList.add('active');
      } else {
        btn.classList.remove('active');
      }
    });

    // 触发主题切换事件
    const event = new CustomEvent('themechanged', {
      detail: { theme: themeName, themeData: theme }
    });
    window.dispatchEvent(event);
  }

  // 初始化主题切换器
  function initThemeSwitcher() {
    if (typeof window.getThemes === 'undefined' || typeof window.setTheme === 'undefined') {
      console.warn('主题系统未加载，请确保themes.js已加载');
      return;
    }

    createThemeSwitcher();
  }

  // 导出到全局
  window.createThemeSwitcher = createThemeSwitcher;
  window.switchTheme = switchTheme;
  window.initThemeSwitcher = initThemeSwitcher;

  // 自动初始化
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initThemeSwitcher);
  } else {
    initThemeSwitcher();
  }
})();
