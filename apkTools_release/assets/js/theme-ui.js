// 主题切换UI组件
// 提供主题切换按钮和主题选择弹窗

(function () {
  'use strict';

  // 创建主题选择弹窗
  function createThemeModal() {
    // 检查是否已存在弹窗
    if (document.getElementById('themeModal')) {
      return;
    }

    const modal = document.createElement('div');
    modal.id = 'themeModal';
    modal.className = 'theme-modal';

    const modalContent = document.createElement('div');
    modalContent.className = 'theme-modal-content';

    // 弹窗头部
    const modalHeader = document.createElement('div');
    modalHeader.className = 'theme-modal-header';

    const modalTitle = document.createElement('h2');
    modalTitle.className = 'theme-modal-title';
    modalTitle.textContent = '选择主题'; // 默认中文，会在打开时更新

    const modalClose = document.createElement('button');
    modalClose.className = 'theme-modal-close';
    modalClose.innerHTML = '×';
    modalClose.setAttribute('aria-label', '关闭');
    modalClose.addEventListener('click', closeThemeModal);

    modalHeader.appendChild(modalTitle);
    modalHeader.appendChild(modalClose);

    // 主题列表
    const themeList = document.createElement('div');
    themeList.className = 'theme-list';

    const themes = window.getThemes();
    const currentTheme = localStorage.getItem('theme') || window.defaultTheme;

    themes.forEach((theme) => {
      const themeItem = document.createElement('div');
      themeItem.className = 'theme-item';
      themeItem.setAttribute('data-theme', theme.key);

      // 主题预览
      const themePreview = document.createElement('div');
      themePreview.className = 'theme-item-preview';
      const themeData = window.themes[theme.key];
      if (themeData && themeData.colors) {
        themePreview.style.background = themeData.colors.background;
      }

      // 主题名称
      const themeName = document.createElement('div');
      themeName.className = 'theme-item-name';
      themeName.setAttribute('data-theme-key', theme.key);
      // 默认中文，会在打开时更新
      themeName.textContent = theme.name.zh || theme.name.en || theme.key;

      // 主题描述
      const themeDesc = document.createElement('div');
      themeDesc.className = 'theme-item-desc';
      themeDesc.setAttribute('data-theme-key', theme.key);
      // 默认中文，会在打开时更新
      const descriptions = {
        purple: {
          zh: '优雅紫色，渐变紫色背景',
          en: 'Elegant purple gradient background'
        },
        cyberpunk: {
          zh: '赛博朋克，暗黑霓虹风格',
          en: 'Cyberpunk style with neon colors'
        },
        light: {
          zh: '清新浅色，简约现代',
          en: 'Fresh light theme, simple and modern'
        },
        modern: {
          zh: '现代简约，暗色主题',
          en: 'Modern minimal dark theme'
        }
      };
      const desc = descriptions[theme.key] || {};
      themeDesc.textContent = desc.zh || '';

      themeItem.appendChild(themePreview);
      themeItem.appendChild(themeName);
      themeItem.appendChild(themeDesc);

      if (theme.key === currentTheme) {
        themeItem.classList.add('active');
      }

      themeItem.addEventListener('click', () => {
        switchTheme(theme.key);
        closeThemeModal();
      });

      themeList.appendChild(themeItem);
    });

    modalContent.appendChild(modalHeader);
    modalContent.appendChild(themeList);
    modal.appendChild(modalContent);

    // 点击背景关闭
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        closeThemeModal();
      }
    });

    // ESC键关闭
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && modal.classList.contains('show')) {
        closeThemeModal();
      }
    });

    document.body.appendChild(modal);
  }

  // 打开主题弹窗
  function openThemeModal() {
    const modal = document.getElementById('themeModal');
    if (modal) {
      // 更新弹窗文本（支持中英文）
      const currentLang = (window.getLanguage && window.getLanguage()) || 'zh';
      const modalTitle = modal.querySelector('.theme-modal-title');
      if (modalTitle) {
        modalTitle.textContent = currentLang === 'en' ? 'Select Theme' : '选择主题';
      }
      const modalClose = modal.querySelector('.theme-modal-close');
      if (modalClose) {
        modalClose.setAttribute('aria-label', currentLang === 'en' ? 'Close' : '关闭');
      }

      // 更新主题描述（支持中英文）
      const themeItems = modal.querySelectorAll('.theme-item');
      const descriptions = {
        purple: {
          zh: '优雅紫色，渐变紫色背景',
          en: 'Elegant purple gradient background'
        },
        cyberpunk: {
          zh: '赛博朋克，暗黑霓虹风格',
          en: 'Cyberpunk style with neon colors'
        },
        light: {
          zh: '清新浅色，简约现代',
          en: 'Fresh light theme, simple and modern'
        },
        modern: {
          zh: '现代简约，暗色主题',
          en: 'Modern minimal dark theme'
        }
      };

      themeItems.forEach(item => {
        const themeKey = item.getAttribute('data-theme');
        const desc = descriptions[themeKey];
        const descEl = item.querySelector('.theme-item-desc');
        if (descEl && desc) {
          descEl.textContent = currentLang === 'en' ? desc.en : desc.zh;
        }
      });

      // 更新主题名称（支持中英文）
      themeItems.forEach(item => {
        const themeKey = item.getAttribute('data-theme');
        const theme = window.themes[themeKey];
        const nameEl = item.querySelector('.theme-item-name');
        if (nameEl && theme && theme.name) {
          nameEl.textContent = currentLang === 'en' ? (theme.name.en || theme.name.zh) : (theme.name.zh || theme.name.en);
        }
      });

      modal.classList.add('show');
      // 更新当前选中状态
      updateThemeSelection();
    }
  }

  // 关闭主题弹窗
  function closeThemeModal() {
    const modal = document.getElementById('themeModal');
    if (modal) {
      modal.classList.remove('show');
    }
  }

  // 更新主题选择状态
  function updateThemeSelection() {
    const currentTheme = localStorage.getItem('theme') || window.defaultTheme;
    const themeItems = document.querySelectorAll('.theme-item');
    themeItems.forEach(item => {
      if (item.getAttribute('data-theme') === currentTheme) {
        item.classList.add('active');
      } else {
        item.classList.remove('active');
      }
    });
  }

  // 创建主题切换按钮（在卡片右上角）
  function createThemeToggleButton() {
    // 检查是否已存在按钮（在header中）
    let btn = document.getElementById('themeToggleBtn');

    if (!btn) {
      // 如果不存在，创建按钮
      btn = document.createElement('button');
      btn.id = 'themeToggleBtn';
      btn.className = 'theme-toggle-btn';
      btn.innerHTML = '🎨';

      const header = document.querySelector('.header');
      if (header) {
        header.style.position = 'relative';
        header.appendChild(btn);
      } else {
        document.body.appendChild(btn);
      }
    }

    // 更新按钮标题（支持中英文）
    const currentLang = (window.getLanguage && window.getLanguage()) || 'zh';
    btn.setAttribute('title', currentLang === 'en' ? 'Select Theme' : '切换主题');

    // 添加点击事件（移除旧的监听器，避免重复）
    btn.onclick = openThemeModal;

    // 监听语言切换事件，更新按钮标题
    window.addEventListener('languagechanged', () => {
      const lang = (window.getLanguage && window.getLanguage()) || 'zh';
      btn.setAttribute('title', lang === 'en' ? 'Select Theme' : '切换主题');
      // 更新弹窗标题
      const modalTitle = document.querySelector('.theme-modal-title');
      if (modalTitle) {
        modalTitle.textContent = lang === 'en' ? 'Select Theme' : '选择主题';
      }
    });
  }

  // 切换主题
  function switchTheme(themeName) {
    const theme = window.setTheme(themeName);

    // 更新主题选择状态
    updateThemeSelection();

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

    createThemeModal();
    createThemeToggleButton();
  }

  // 导出到全局
  window.createThemeModal = createThemeModal;
  window.createThemeToggleButton = createThemeToggleButton;
  window.switchTheme = switchTheme;
  window.initThemeSwitcher = initThemeSwitcher;
  window.openThemeModal = openThemeModal;
  window.closeThemeModal = closeThemeModal;

  // 自动初始化
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initThemeSwitcher);
  } else {
    initThemeSwitcher();
  }
})();
