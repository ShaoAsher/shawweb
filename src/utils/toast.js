/**
 * Toast 通知系统
 * 提供轻量级的消息提示功能
 */

class ToastManager {
  constructor() {
    this.container = null
    this.toasts = []
    this.defaultDuration = 3000
  }

  /**
   * 初始化 Toast 容器
   */
  init() {
    if (this.container) return

    this.container = document.createElement('div')
    this.container.className = 'toast-container'
    document.body.appendChild(this.container)
  }

  /**
   * 显示 Toast 消息
   * @param {Object} options - 配置选项
   * @param {string} options.message - 消息内容
   * @param {string} options.title - 标题（可选）
   * @param {string} options.type - 类型：success, error, warning, info
   * @param {number} options.duration - 显示时长（毫秒）
   * @param {boolean} options.closable - 是否可关闭
   */
  show(options) {
    this.init()

    const {
      message,
      title = '',
      type = 'info',
      duration = this.defaultDuration,
      closable = true
    } = typeof options === 'string' ? { message: options } : options

    const toast = document.createElement('div')
    toast.className = `toast ${type}`

    const icons = {
      success: '✓',
      error: '✕',
      warning: '⚠',
      info: 'ℹ'
    }

    toast.innerHTML = `
      <span class="toast-icon">${icons[type] || icons.info}</span>
      <div class="toast-content">
        ${title ? `<div class="toast-title">${title}</div>` : ''}
        <div class="toast-message">${message}</div>
      </div>
      ${closable ? '<button class="toast-close">×</button>' : ''}
    `

    // 添加关闭事件
    if (closable) {
      const closeBtn = toast.querySelector('.toast-close')
      closeBtn.addEventListener('click', () => this.hide(toast))
    }

    this.container.appendChild(toast)
    this.toasts.push(toast)

    // 自动隐藏
    if (duration > 0) {
      setTimeout(() => this.hide(toast), duration)
    }

    return toast
  }

  /**
   * 隐藏 Toast
   * @param {HTMLElement} toast - Toast 元素
   */
  hide(toast) {
    if (!toast || !toast.parentNode) return

    toast.classList.add('hiding')
    
    setTimeout(() => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast)
      }
      this.toasts = this.toasts.filter(t => t !== toast)
    }, 300)
  }

  /**
   * 成功提示
   * @param {string} message - 消息内容
   * @param {string} title - 标题（可选）
   */
  success(message, title = '') {
    return this.show({ message, title, type: 'success' })
  }

  /**
   * 错误提示
   * @param {string} message - 消息内容
   * @param {string} title - 标题（可选）
   */
  error(message, title = '') {
    return this.show({ message, title, type: 'error', duration: 5000 })
  }

  /**
   * 警告提示
   * @param {string} message - 消息内容
   * @param {string} title - 标题（可选）
   */
  warning(message, title = '') {
    return this.show({ message, title, type: 'warning', duration: 4000 })
  }

  /**
   * 信息提示
   * @param {string} message - 消息内容
   * @param {string} title - 标题（可选）
   */
  info(message, title = '') {
    return this.show({ message, title, type: 'info' })
  }

  /**
   * 清除所有 Toast
   */
  clear() {
    this.toasts.forEach(toast => this.hide(toast))
  }
}

// 创建单例
const toast = new ToastManager()

// 导出
export default toast
export { toast }
