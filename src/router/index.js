import { createRouter, createWebHashHistory } from 'vue-router'
import Home from '../views/Home.vue'

// 工具路由映射 - 按类别分组
const toolRoutes = {
  // Formatter 格式化工具
  'formatter/json_formatter': () => import('../views/tools/formatter/JsonFormatter.vue'),
  'formatter/json_to_model': () => import('../views/tools/formatter/JsonToModel.vue'),

  // Converter 转换工具
  'converter/timestamp_converter': () => import('../views/tools/converter/TimestampConverter.vue'),
  'converter/currency_converter': () => import('../views/tools/converter/CurrencyConverter.vue'),
  'converter/unit_converter': () => import('../views/tools/converter/UnitConverter.vue'),

  // Image 图片工具
  'image/color_converter': () => import('../views/tools/image/ColorConverter.vue'),
  'image/qrcode_generator': () => import('../views/tools/image/QrcodeGenerator.vue'),
  'image/text_image_generator': () => import('../views/tools/image/TextImageGenerator.vue'),
  'image/image_compressor': () => import('../views/tools/image/ImageCompressor.vue'),
  'image/svg_converter': () => import('../views/tools/image/SvgConverter.vue'),
  'image/icon_factory': () => import('../views/tools/image/IconFactory.vue'),
  'image/launch_image_generator': () => import('../views/tools/image/LaunchImageGenerator.vue'),

  // Text 文本工具
  'text/string_encryptor': () => import('../views/tools/text/StringEncryptor.vue'),
  'text/string_generator': () => import('../views/tools/text/StringGenerator.vue'),
  'text/html_editor': () => import('../views/tools/text/HtmlEditor.vue'),
  'text/markdown': () => import('../views/tools/text/markdown/MarkdownHome.vue'),
  'text/markdown/compile': () => import('../views/tools/text/markdown/MarkdownCompile.vue'),
  'text/markdown/preview': () => import('../views/tools/text/markdown/MarkdownPreview.vue'),

  // Developer 开发工具
  'developer/device_preview': () => import('../views/tools/developer/DevicePreview.vue'),
  'developer/keystore_generator': () => import('../views/tools/developer/KeystoreGenerator.vue'),

  // Analyzer 分析工具
  'analyzer/apk_analyzer': () => import('../views/tools/analyzer/ApkAnalyzer.vue'),
  'analyzer/api_debugger': () => import('../views/tools/analyzer/ApiDebugger.vue'),

  // Life 生活工具
  'life/ip_query': () => import('../views/tools/life/IpQuery.vue'),
  'life/speed_test': () => import('../views/tools/life/SpeedTest.vue'),
}

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  // Markdown 编辑器多页面路由
  {
    path: '/tools/text/markdown',
    name: 'MarkdownHome',
    component: () => import('../views/tools/text/markdown/MarkdownHome.vue')
  },
  {
    path: '/tools/text/markdown/compile',
    name: 'MarkdownCompile',
    component: () => import('../views/tools/text/markdown/MarkdownCompile.vue')
  },
  {
    path: '/tools/text/markdown/preview',
    name: 'MarkdownPreview',
    component: () => import('../views/tools/text/markdown/MarkdownPreview.vue')
  },
  // 工具页面路由
  {
    path: '/tools/:category/:tool',
    name: 'Tool',
    component: () => import('../views/DynamicToolLoader.vue')
  },
  // 兼容旧路径格式
  {
    path: '/tools/:pathMatch(.*)*',
    name: 'ToolLegacy',
    component: () => import('../views/ToolPlaceholder.vue')
  }
]

const router = createRouter({
  // 使用 hash 模式，适合 GitHub Pages 部署
  history: createWebHashHistory(),
  routes,
  // 滚动行为
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else {
      return { top: 0 }
    }
  }
})

// 路由切换时确保恢复 body 滚动
router.beforeEach((to, from, next) => {
  // 恢复 body 滚动（防止全屏预览等功能未正确清理）
  document.body.style.overflow = ''
  next()
})

export default router
