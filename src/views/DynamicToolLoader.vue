<template>
  <div class="dynamic-tool-wrapper">
    <component :is="currentComponent" v-if="currentComponent" />
    <ToolPlaceholder v-else-if="!loading" />
    <div v-else class="loading-container">
      <div class="loading-spinner"></div>
      <p>加载中...</p>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref, shallowRef, watch } from 'vue'
import { useRoute } from 'vue-router'
import ToolPlaceholder from './ToolPlaceholder.vue'

const route = useRoute()
const currentComponent = shallowRef(null)
const loading = ref(true)

// 工具路由映射
const toolRoutes = {
  // Formatter 格式化工具
  'formatter/json_formatter': () => import('./tools/formatter/JsonFormatter.vue'),
  'formatter/json_to_model': () => import('./tools/formatter/JsonToModel.vue'),
  
  // Converter 转换工具
  'converter/timestamp_converter': () => import('./tools/converter/TimestampConverter.vue'),
  'converter/currency_converter': () => import('./tools/converter/CurrencyConverter.vue'),
  'converter/unit_converter': () => import('./tools/converter/UnitConverter.vue'),
  
  // Image 图片工具
  'image/color_converter': () => import('./tools/image/ColorConverter.vue'),
  'image/qrcode_generator': () => import('./tools/image/QrcodeGenerator.vue'),
  'image/text_image_generator': () => import('./tools/image/TextImageGenerator.vue'),
  'image/image_compressor': () => import('./tools/image/ImageCompressor.vue'),
  'image/svg_converter': () => import('./tools/image/SvgConverter.vue'),
  'image/icon_factory': () => import('./tools/image/IconFactory.vue'),
  'image/launch_image_generator': () => import('./tools/image/LaunchImageGenerator.vue'),
  
  // Text 文本工具
  'text/string_encryptor': () => import('./tools/text/StringEncryptor.vue'),
  'text/string_generator': () => import('./tools/text/StringGenerator.vue'),
  'text/html_editor': () => import('./tools/text/HtmlEditor.vue'),
  
  // Text - Markdown 工具
  'text/markdown_home': () => import('./tools/text/markdown/MarkdownHome.vue'),
  'text/markdown_compile': () => import('./tools/text/markdown/MarkdownCompile.vue'),
  'text/markdown_preview': () => import('./tools/text/markdown/MarkdownPreview.vue'),
  
  // Developer 开发工具
  'developer/device_preview': () => import('./tools/developer/DevicePreview.vue'),
  'developer/keystore_generator': () => import('./tools/developer/KeystoreGenerator.vue'),
  
  // Analyzer 分析工具
  'analyzer/apk_analyzer': () => import('./tools/analyzer/ApkAnalyzer.vue'),
  'analyzer/api_debugger': () => import('./tools/analyzer/ApiDebugger.vue'),
  
  // Life 生活工具
  'life/ip_query': () => import('./tools/life/IpQuery.vue'),
  'life/speed_test': () => import('./tools/life/SpeedTest.vue'),
  'life/pomodoro_timer': () => import('./tools/life/PomodoroTimer.vue'),
  'life/decision_wheel': () => import('./tools/life/DecisionWheel.vue'),
  'life/mbti_test': () => import('./tools/life/MbtiTest.vue'),
  'life/chinese_calendar': () => import('./tools/life/ChineseCalendar.vue'),

  // Entertainment 娱乐工具
  'entertainment/liars_dice': () => import('./tools/entertainment/LiarsDice.vue'),
  'entertainment/truth_bottle': () => import('./tools/entertainment/TruthBottle.vue'),
  'entertainment/reaction_challenge': () => import('./tools/entertainment/ReactionChallenge.vue'),
}

async function loadComponent() {
  loading.value = true
  currentComponent.value = null
  
  const category = route.params.category
  const tool = route.params.tool
  
  if (category && tool) {
    const toolPath = `${category}/${tool}`
    const routeLoader = toolRoutes[toolPath]
    
    if (routeLoader) {
      try {
        const module = await routeLoader()
        currentComponent.value = module.default
      } catch (error) {
        console.error('加载工具组件失败:', error)
        currentComponent.value = null
      }
    }
  }
  
  loading.value = false
}

onMounted(() => {
  loadComponent()
})

// 监听路由变化重新加载组件
watch(() => route.params, () => {
  loadComponent()
}, { deep: true })
</script>

<style scoped>
.dynamic-tool-wrapper {
  width: 100%;
  min-height: 100vh;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 50vh;
  color: var(--color-text-secondary);
}

.loading-container p {
  margin-top: var(--spacing-md);
  font-size: var(--font-size-base);
}
</style>
