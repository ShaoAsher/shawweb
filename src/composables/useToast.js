/**
 * Toast 通知 Composable
 * 在 Vue 组件中使用 Toast 通知
 */
import toast from '@/utils/toast'

export function useToast() {
  return {
    /**
     * 显示自定义 Toast
     */
    show: (options) => toast.show(options),
    
    /**
     * 显示成功提示
     */
    success: (message, title = '') => toast.success(message, title),
    
    /**
     * 显示错误提示
     */
    error: (message, title = '') => toast.error(message, title),
    
    /**
     * 显示警告提示
     */
    warning: (message, title = '') => toast.warning(message, title),
    
    /**
     * 显示信息提示
     */
    info: (message, title = '') => toast.info(message, title),
    
    /**
     * 清除所有 Toast
     */
    clear: () => toast.clear()
  }
}

export default useToast
