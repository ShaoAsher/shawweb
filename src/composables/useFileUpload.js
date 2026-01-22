/**
 * 文件上传 Composable
 * 提供文件上传的通用逻辑
 */

import { ref } from 'vue'
import { readFileAsDataURL, validateFileType } from '@/utils/common'

export function useFileUpload(options = {}) {
    const {
        accept = '*/*',
        maxSize = 10 * 1024 * 1024, // 10MB
        onSuccess = null,
        onError = null
    } = options

    const file = ref(null)
    const fileUrl = ref(null)
    const loading = ref(false)
    const error = ref(null)

    /**
     * 选择文件
     */
    async function selectFile(selectedFile) {
        if (!selectedFile) return

        error.value = null
        loading.value = true

        try {
            // 验证文件大小
            if (selectedFile.size > maxSize) {
                throw new Error(`文件大小不能超过 ${formatSize(maxSize)}`)
            }

            // 验证文件类型
            if (accept !== '*/*' && !validateFileType(selectedFile, accept)) {
                throw new Error('不支持的文件类型')
            }

            file.value = selectedFile

            // 如果是图片，生成预览URL
            if (selectedFile.type.startsWith('image/')) {
                fileUrl.value = await readFileAsDataURL(selectedFile)
            }

            onSuccess?.(selectedFile)
        } catch (err) {
            error.value = err.message
            onError?.(err)
        } finally {
            loading.value = false
        }
    }

    /**
     * 清除文件
     */
    function clearFile() {
        if (fileUrl.value && fileUrl.value.startsWith('blob:')) {
            URL.revokeObjectURL(fileUrl.value)
        }
        file.value = null
        fileUrl.value = null
        error.value = null
    }

    /**
     * 格式化文件大小
     */
    function formatSize(bytes) {
        const k = 1024
        const sizes = ['B', 'KB', 'MB', 'GB']
        const i = Math.floor(Math.log(bytes) / Math.log(k))
        return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
    }

    return {
        file,
        fileUrl,
        loading,
        error,
        selectFile,
        clearFile
    }
}

export default useFileUpload
