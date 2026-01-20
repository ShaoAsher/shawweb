<template>
  <div v-html="toolContent" ref="toolContainer"></div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const toolContent = ref('')
const toolContainer = ref(null)

onMounted(async () => {
  // 获取工具路径
  const toolPath = route.params.pathMatch
  if (!toolPath) {
    toolContent.value = '<div>工具路径不存在</div>'
    return
  }

  // 构建完整的工具页面路径
  const fullPath = `/tools/${Array.isArray(toolPath) ? toolPath.join('/') : toolPath}`
  
  try {
    // 加载工具页面 HTML
    const response = await fetch(fullPath)
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    const html = await response.text()
    toolContent.value = html
  } catch (error) {
    console.error('加载工具页面失败:', error)
    toolContent.value = `<div>加载工具页面失败: ${error.message}</div>`
  }
})
</script>

<style scoped>
/* 工具页面容器样式 */
</style>
