/**
 * 统一导出所有工具函数
 * 简化导入，提供一致的API
 */

// Toast 通知系统
export { default as toast } from './toast.js'

// 涟漪效果
export { createRipple, initRipple, addRipple, vRipple } from './ripple.js'

// 表单验证反馈
export {
    setFormState,
    showSuccess,
    showError,
    showWarning,
    clearState,
    validateField,
    initFormFeedback
} from './form-feedback.js'

// CDN 资源加载
export { loadScript, loadStyle, CDN_RESOURCES } from './cdn-loader.js'

// 主题管理
export { initTheme, setTheme, getCurrentTheme, getThemes } from './themes.js'

// 通用工具函数
export {
    copyToClipboard,
    downloadFile,
    readFileAsText,
    readFileAsDataURL,
    readFileAsArrayBuffer,
    loadImage,
    formatFileSize,
    delay,
    debounce,
    throttle,
    randomString,
    validateFileType,
    compressImage
} from './common.js'

// 默认导出（方便使用）
export default {
    toast: () => import('./toast.js').then(m => m.default),
    ripple: () => import('./ripple.js'),
    form: () => import('./form-feedback.js'),
    cdn: () => import('./cdn-loader.js'),
    theme: () => import('./themes.js')
}
