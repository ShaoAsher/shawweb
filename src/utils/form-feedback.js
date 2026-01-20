/**
 * 表单验证反馈工具
 * 提供视觉反馈和动画效果
 */

/**
 * 设置表单组的验证状态
 * @param {HTMLElement} formGroup - 表单组元素 (.form-group)
 * @param {string} state - 状态：'success', 'error', 'warning', 'none'
 * @param {string} message - 提示消息（可选）
 */
function setFormState(formGroup, state, message = '') {
  if (!formGroup) return

  // 移除所有状态类
  formGroup.classList.remove('has-success', 'has-error', 'has-warning')
  
  // 移除已有的消息元素
  const existingMessage = formGroup.querySelector('.form-feedback-message')
  if (existingMessage) {
    existingMessage.remove()
  }

  if (state === 'none') return

  // 添加状态类
  formGroup.classList.add(`has-${state}`)

  // 添加消息
  if (message) {
    const messageEl = document.createElement('div')
    messageEl.className = `form-feedback-message form-${state}-message`
    
    const icons = {
      success: '✓',
      error: '✕',
      warning: '⚠'
    }
    
    messageEl.innerHTML = `<span>${icons[state] || ''}</span> ${message}`
    formGroup.appendChild(messageEl)
  }
}

/**
 * 显示成功状态
 * @param {HTMLElement|string} element - 表单组元素或选择器
 * @param {string} message - 成功消息
 */
function showSuccess(element, message = '') {
  const el = typeof element === 'string' ? document.querySelector(element) : element
  setFormState(el, 'success', message)
}

/**
 * 显示错误状态
 * @param {HTMLElement|string} element - 表单组元素或选择器
 * @param {string} message - 错误消息
 */
function showError(element, message = '') {
  const el = typeof element === 'string' ? document.querySelector(element) : element
  setFormState(el, 'error', message)
  
  // 添加摇晃动画
  const input = el?.querySelector('input, textarea, select')
  if (input) {
    input.classList.add('shake-animation')
    setTimeout(() => {
      input.classList.remove('shake-animation')
    }, 500)
  }
}

/**
 * 显示警告状态
 * @param {HTMLElement|string} element - 表单组元素或选择器
 * @param {string} message - 警告消息
 */
function showWarning(element, message = '') {
  const el = typeof element === 'string' ? document.querySelector(element) : element
  setFormState(el, 'warning', message)
}

/**
 * 清除验证状态
 * @param {HTMLElement|string} element - 表单组元素或选择器
 */
function clearState(element) {
  const el = typeof element === 'string' ? document.querySelector(element) : element
  setFormState(el, 'none')
}

/**
 * 验证表单字段
 * @param {HTMLInputElement} input - 输入元素
 * @param {Object} rules - 验证规则
 * @returns {Object} 验证结果 { valid: boolean, message: string }
 */
function validateField(input, rules = {}) {
  const value = input.value.trim()
  
  // 必填验证
  if (rules.required && !value) {
    return { valid: false, message: rules.requiredMessage || '此字段为必填项' }
  }

  // 最小长度验证
  if (rules.minLength && value.length < rules.minLength) {
    return { valid: false, message: rules.minLengthMessage || `最少需要 ${rules.minLength} 个字符` }
  }

  // 最大长度验证
  if (rules.maxLength && value.length > rules.maxLength) {
    return { valid: false, message: rules.maxLengthMessage || `最多允许 ${rules.maxLength} 个字符` }
  }

  // 正则验证
  if (rules.pattern && !rules.pattern.test(value)) {
    return { valid: false, message: rules.patternMessage || '格式不正确' }
  }

  // 邮箱验证
  if (rules.email && value) {
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailPattern.test(value)) {
      return { valid: false, message: rules.emailMessage || '请输入有效的邮箱地址' }
    }
  }

  // 数字验证
  if (rules.number && value) {
    if (isNaN(Number(value))) {
      return { valid: false, message: rules.numberMessage || '请输入有效的数字' }
    }
  }

  // 自定义验证
  if (rules.custom) {
    const customResult = rules.custom(value)
    if (customResult !== true) {
      return { valid: false, message: customResult || '验证失败' }
    }
  }

  return { valid: true, message: rules.successMessage || '' }
}

/**
 * 初始化表单验证反馈样式
 */
function initFormFeedback() {
  if (!document.getElementById('form-feedback-styles')) {
    const style = document.createElement('style')
    style.id = 'form-feedback-styles'
    style.textContent = `
      .form-feedback-message {
        font-size: var(--font-size-small, 14px);
        margin-top: var(--spacing-xs, 4px);
        display: flex;
        align-items: center;
        gap: var(--spacing-xs, 4px);
        animation: fadeInUp 0.3s ease;
      }
      
      .form-success-message {
        color: var(--color-success, #10b981);
      }
      
      .form-error-message {
        color: var(--color-error, #ef4444);
      }
      
      .form-warning-message {
        color: var(--color-warning, #f59e0b);
      }
      
      .shake-animation {
        animation: shake 0.5s ease;
      }
      
      @keyframes shake {
        0%, 100% { transform: translateX(0); }
        10%, 30%, 50%, 70%, 90% { transform: translateX(-5px); }
        20%, 40%, 60%, 80% { transform: translateX(5px); }
      }
      
      @keyframes fadeInUp {
        from {
          opacity: 0;
          transform: translateY(5px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }
    `
    document.head.appendChild(style)
  }
}

export {
  setFormState,
  showSuccess,
  showError,
  showWarning,
  clearState,
  validateField,
  initFormFeedback
}

export default {
  setFormState,
  showSuccess,
  showError,
  showWarning,
  clearState,
  validateField,
  initFormFeedback
}
