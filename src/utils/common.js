/**
 * 通用工具函数
 * 提供复制、下载、文件处理等常用功能
 */

/**
 * 复制文本到剪贴板
 * @param {string} text - 要复制的文本
 * @returns {Promise<boolean>} 是否成功
 */
export async function copyToClipboard(text) {
    try {
        if (navigator.clipboard && window.isSecureContext) {
            await navigator.clipboard.writeText(text)
            return true
        } else {
            // 降级方案
            const textarea = document.createElement('textarea')
            textarea.value = text
            textarea.style.position = 'fixed'
            textarea.style.left = '-999999px'
            textarea.style.top = '-999999px'
            document.body.appendChild(textarea)
            textarea.focus()
            textarea.select()
            const success = document.execCommand('copy')
            textarea.remove()
            return success
        }
    } catch (err) {
        console.error('复制失败:', err)
        return false
    }
}

/**
 * 下载文件
 * @param {Blob|string} data - 文件数据或Data URL
 * @param {string} filename - 文件名
 * @param {string} mimeType - MIME类型（可选）
 */
export function downloadFile(data, filename, mimeType) {
    let url

    if (typeof data === 'string') {
        // 如果是Data URL，直接使用
        url = data
    } else {
        // 如果是Blob，创建URL
        const blob = mimeType ? new Blob([data], { type: mimeType }) : data
        url = URL.createObjectURL(blob)
    }

    const link = document.createElement('a')
    link.href = url
    link.download = filename
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)

    // 清理URL对象
    if (typeof data !== 'string') {
        setTimeout(() => URL.revokeObjectURL(url), 100)
    }
}

/**
 * 读取文件为文本
 * @param {File} file - 文件对象
 * @returns {Promise<string>} 文件文本内容
 */
export function readFileAsText(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader()
        reader.onload = (e) => resolve(e.target.result)
        reader.onerror = (e) => reject(e)
        reader.readAsText(file)
    })
}

/**
 * 读取文件为DataURL
 * @param {File} file - 文件对象
 * @returns {Promise<string>} DataURL
 */
export function readFileAsDataURL(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader()
        reader.onload = (e) => resolve(e.target.result)
        reader.onerror = (e) => reject(e)
        reader.readAsDataURL(file)
    })
}

/**
 * 读取文件为ArrayBuffer
 * @param {File} file - 文件对象
 * @returns {Promise<ArrayBuffer>} ArrayBuffer
 */
export function readFileAsArrayBuffer(file) {
    return new Promise((resolve, reject) => {
        const reader = new FileReader()
        reader.onload = (e) => resolve(e.target.result)
        reader.onerror = (e) => reject(e)
        reader.readAsArrayBuffer(file)
    })
}

/**
 * 加载图片
 * @param {string|File} source - 图片URL或File对象
 * @returns {Promise<HTMLImageElement>} Image对象
 */
export function loadImage(source) {
    return new Promise((resolve, reject) => {
        const img = new Image()
        img.onload = () => resolve(img)
        img.onerror = () => reject(new Error('图片加载失败'))

        if (source instanceof File) {
            const reader = new FileReader()
            reader.onload = (e) => {
                img.src = e.target.result
            }
            reader.onerror = () => reject(new Error('文件读取失败'))
            reader.readAsDataURL(source)
        } else {
            img.src = source
        }
    })
}

/**
 * 格式化文件大小
 * @param {number} bytes - 字节数
 * @param {number} decimals - 小数位数
 * @returns {string} 格式化后的大小
 */
export function formatFileSize(bytes, decimals = 2) {
    if (bytes === 0) return '0 B'

    const k = 1024
    const dm = decimals < 0 ? 0 : decimals
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i]
}

/**
 * 延迟函数
 * @param {number} ms - 延迟毫秒数
 * @returns {Promise} Promise对象
 */
export function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
}

/**
 * 防抖函数
 * @param {Function} func - 要防抖的函数
 * @param {number} wait - 等待时间（毫秒）
 * @returns {Function} 防抖后的函数
 */
export function debounce(func, wait = 300) {
    let timeout
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout)
            func(...args)
        }
        clearTimeout(timeout)
        timeout = setTimeout(later, wait)
    }
}

/**
 * 节流函数
 * @param {Function} func - 要节流的函数
 * @param {number} limit - 时间间隔（毫秒）
 * @returns {Function} 节流后的函数
 */
export function throttle(func, limit = 300) {
    let inThrottle
    return function executedFunction(...args) {
        if (!inThrottle) {
            func(...args)
            inThrottle = true
            setTimeout(() => inThrottle = false, limit)
        }
    }
}

/**
 * 生成随机字符串
 * @param {number} length - 字符串长度
 * @param {string} chars - 字符集
 * @returns {string} 随机字符串
 */
export function randomString(length = 8, chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789') {
    let result = ''
    for (let i = 0; i < length; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length))
    }
    return result
}

/**
 * 验证文件类型
 * @param {File} file - 文件对象
 * @param {string|string[]} acceptTypes - 接受的类型
 * @returns {boolean} 是否通过验证
 */
export function validateFileType(file, acceptTypes) {
    if (!acceptTypes) return true

    const types = Array.isArray(acceptTypes) ? acceptTypes : [acceptTypes]

    return types.some(type => {
        // 扩展名匹配 (如 .jpg)
        if (type.startsWith('.')) {
            return file.name.toLowerCase().endsWith(type.toLowerCase())
        }
        // MIME类型通配符 (如 image/*)
        if (type.endsWith('/*')) {
            return file.type.startsWith(type.replace('/*', ''))
        }
        // 完整MIME类型 (如 image/jpeg)
        return file.type === type
    })
}

/**
 * 压缩图片
 * @param {File} file - 图片文件
 * @param {Object} options - 压缩选项
 * @returns {Promise<Blob>} 压缩后的Blob
 */
export async function compressImage(file, options = {}) {
    const {
        maxWidth = 1920,
        maxHeight = 1080,
        quality = 0.92,
        mimeType = 'image/jpeg'
    } = options

    const img = await loadImage(file)

    let { width, height } = img

    // 计算缩放比例
    if (width > maxWidth || height > maxHeight) {
        const ratio = Math.min(maxWidth / width, maxHeight / height)
        width = Math.round(width * ratio)
        height = Math.round(height * ratio)
    }

    // 创建canvas并绘制
    const canvas = document.createElement('canvas')
    canvas.width = width
    canvas.height = height

    const ctx = canvas.getContext('2d')
    ctx.drawImage(img, 0, 0, width, height)

    // 转换为Blob
    return new Promise((resolve, reject) => {
        canvas.toBlob(
            (blob) => {
                if (blob) {
                    resolve(blob)
                } else {
                    reject(new Error('图片压缩失败'))
                }
            },
            mimeType,
            quality
        )
    })
}

// 默认导出
export default {
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
}
