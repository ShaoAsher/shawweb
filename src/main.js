import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import './assets/css/theme.css'
import './assets/css/animations.css'
import { initTheme } from './utils/themes'
import { initRipple, vRipple } from './utils/ripple'
import { initFormFeedback } from './utils/form-feedback'
import toast from './utils/toast'

// 全局组件
import AppButton from './components/AppButton.vue'
import ButtonGroup from './components/ButtonGroup.vue'

// 初始化主题
initTheme()

// 初始化涟漪效果
initRipple()

// 初始化表单反馈
initFormFeedback()

// 创建应用
const app = createApp(App)

// 注册全局组件
app.component('AppButton', AppButton)
app.component('ButtonGroup', ButtonGroup)

// 注册全局指令
app.directive('ripple', vRipple)

// 注册全局属性
app.config.globalProperties.$toast = toast

// 使用路由
app.use(router)

// 挂载应用
app.mount('#app')
