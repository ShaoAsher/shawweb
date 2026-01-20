/**
 * 按钮涟漪效果
 * 为按钮添加 Material Design 风格的点击涟漪效果
 */

/**
 * 创建涟漪效果
 * @param {MouseEvent} event - 鼠标事件
 * @param {HTMLElement} element - 目标元素
 */
function createRipple(event, element) {
  const rect = element.getBoundingClientRect()
  const size = Math.max(rect.width, rect.height)
  const x = event.clientX - rect.left - size / 2
  const y = event.clientY - rect.top - size / 2

  const ripple = document.createElement('span')
  ripple.className = 'ripple-effect'
  ripple.style.cssText = `
    position: absolute;
    width: ${size}px;
    height: ${size}px;
    left: ${x}px;
    top: ${y}px;
    background: rgba(255, 255, 255, 0.4);
    border-radius: 50%;
    transform: scale(0);
    animation: rippleAnimation 0.6s linear;
    pointer-events: none;
  `

  element.appendChild(ripple)

  ripple.addEventListener('animationend', () => {
    ripple.remove()
  })
}

/**
 * 初始化涟漪效果
 * 自动为带有 .btn-ripple 类的元素添加涟漪效果
 */
function initRipple() {
  // 添加全局样式
  if (!document.getElementById('ripple-styles')) {
    const style = document.createElement('style')
    style.id = 'ripple-styles'
    style.textContent = `
      @keyframes rippleAnimation {
        to {
          transform: scale(4);
          opacity: 0;
        }
      }
      
      .btn-ripple {
        position: relative;
        overflow: hidden;
      }
    `
    document.head.appendChild(style)
  }

  // 使用事件委托
  document.addEventListener('click', (event) => {
    const target = event.target.closest('.btn-ripple')
    if (target) {
      createRipple(event, target)
    }
  })
}

/**
 * 为指定元素添加涟漪效果
 * @param {HTMLElement|string} element - 元素或选择器
 */
function addRipple(element) {
  const el = typeof element === 'string' 
    ? document.querySelector(element) 
    : element

  if (!el) return

  el.classList.add('btn-ripple')
  el.addEventListener('click', (event) => {
    createRipple(event, el)
  })
}

/**
 * Vue 指令：v-ripple
 * 使用方式：<button v-ripple>点击</button>
 */
const vRipple = {
  mounted(el) {
    el.classList.add('btn-ripple')
    el.addEventListener('click', (event) => {
      createRipple(event, el)
    })
  }
}

export { createRipple, initRipple, addRipple, vRipple }
export default { createRipple, initRipple, addRipple, vRipple }
