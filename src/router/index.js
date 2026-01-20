import { createRouter, createWebHistory } from 'vue-router'
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
  'text/markdown': () => import('../views/tools/text/markdown/MarkdownHome.vue'),
  'text/markdown/compile': () => import('../views/tools/text/markdown/MarkdownCompile.vue'),
  'text/markdown/preview': () => import('../views/tools/text/markdown/MarkdownPreview.vue'),
  'text/writing': () => import('../views/tools/text/writing/BookHome.vue'),
  'text/writing/editor': () => import('../views/tools/text/writing/BookEditor.vue'),
  'text/writing/writing_editor': () => import('../views/tools/text/writing/WritingEditor.vue'),

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
  // 写作助手多页面路由
  {
    path: '/tools/text/writing',
    name: 'BookHome',
    component: () => import('../views/tools/text/writing/BookHome.vue')
  },
  {
    path: '/tools/text/writing/editor',
    name: 'BookEditor',
    component: () => import('../views/tools/text/writing/BookEditor.vue')
  },
  {
    path: '/tools/text/writing/writing_editor',
    name: 'WritingEditor',
    component: () => import('../views/tools/text/writing/WritingEditor.vue')
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
  history: createWebHistory(),
  routes
})

export default router
