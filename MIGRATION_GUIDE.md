# 工具页面迁移指南

本指南将帮助你将所有 HTML 工具页面迁移到 Vue 组件架构。

## 📋 迁移步骤

### 1. 创建 Vue 组件文件

在 `src/views/tools/` 目录下创建对应的 Vue 组件文件，命名规则：
- HTML 文件名：`json_formatter.html` → Vue 组件：`JsonFormatter.vue`
- HTML 文件名：`timestamp_converter.html` → Vue 组件：`TimestampConverter.vue`

### 2. 组件结构模板

```vue
<template>
  <ToolLayout
    icon="🔧"
    title="工具名称"
    description="工具描述"
  >
    <!-- 工具内容 -->
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
import { ref, computed, onMounted } from 'vue'

// 响应式数据
const inputValue = ref('')
const result = ref('')

// 方法
function handleAction() {
  // 工具逻辑
}

onMounted(() => {
  // 初始化逻辑
})
</script>

<style scoped>
/* 组件特定样式 */
</style>
```

### 3. 迁移要点

#### HTML → Template
- 将 HTML 结构移到 `<template>` 中
- 使用 Vue 指令：
  - `v-model` 替代 `value` 绑定
  - `v-if` / `v-show` 替代条件显示
  - `v-for` 替代循环渲染
  - `@click` 替代 `onclick`
  - `@input` 替代 `oninput`

#### JavaScript → Script Setup
- 使用 `ref()` 创建响应式变量
- 使用 `computed()` 创建计算属性
- 使用 `onMounted()` 替代 `DOMContentLoaded`
- 移除 `document.getElementById()`，直接使用 ref

#### 样式处理
- 将 `<style>` 标签移到组件中
- 使用 `scoped` 避免样式污染
- 深度选择器使用 `:deep()`

### 4. 外部库处理

#### 使用 npm 包（推荐）
```javascript
import CryptoJS from 'crypto-js'
import JSZip from 'jszip'
import forge from 'node-forge'
```

#### 使用 CDN（如果 npm 包不可用）
```javascript
import { loadScript } from '@/utils/cdn-loader'
import { CDN_RESOURCES } from '@/utils/cdn-loader'

onMounted(async () => {
  await loadScript(CDN_RESOURCES.forge)
  // 使用库
})
```

### 5. 更新路由

在 `src/router/index.js` 中添加路由映射：

```javascript
const toolRoutes = {
  'formatter/json_formatter': () => import('../views/tools/JsonFormatter.vue'),
  'converter/timestamp_converter': () => import('../views/tools/TimestampConverter.vue'),
  // 添加新路由
}
```

### 6. 更新工具数据

在 `src/data/tools.js` 中更新工具链接：

```javascript
{
  href: "/tools/formatter/json_formatter", // 从 ./tools/...html 改为 /tools/...
}
```

## 📝 迁移示例

### 示例 1: JSON Formatter ✅

已完成的示例，参考 `src/views/tools/JsonFormatter.vue`

### 示例 2: Timestamp Converter ✅

已完成的示例，参考 `src/views/tools/TimestampConverter.vue`

## 🔧 常见问题

### Q: 如何处理 DOM 操作？
A: 使用 Vue 的响应式系统和 ref：

```vue
<template>
  <div ref="container"></div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const container = ref(null)

onMounted(() => {
  // 访问 DOM
  if (container.value) {
    container.value.innerHTML = '...'
  }
})
</script>
```

### Q: 如何处理事件绑定？
A: 使用 Vue 事件指令：

```vue
<!-- HTML -->
<button onclick="handleClick()">Click</button>

<!-- Vue -->
<button @click="handleClick">Click</button>
```

### Q: 如何处理 v-html？
A: 使用 `v-html` 指令，注意 XSS 安全：

```vue
<div v-html="htmlContent"></div>
```

### Q: 如何访问全局对象（如 window、document）？
A: 在 Vue 3 中可以直接访问：

```javascript
window.localStorage.setItem('key', 'value')
document.title = 'New Title'
```

## 📦 需要迁移的工具列表

### Formatter（格式化工具）
- [x] JSON Formatter
- [ ] JSON to Model

### Converter（转换工具）
- [x] Timestamp Converter
- [ ] Currency Converter
- [ ] Unit Converter
- [ ] Color Converter
- [ ] SVG Converter

### Developer（开发工具）
- [ ] Keystore Generator
- [ ] APK Analyzer
- [ ] API Debugger
- [ ] Device Preview

### Image（图片工具）
- [ ] Image Compressor
- [ ] Icon Factory
- [ ] Launch Image Generator
- [ ] QR Code Generator
- [ ] Text Image Generator

### Text（文本工具）
- [ ] String Encryptor
- [ ] String Generator
- [ ] Markdown Editor
- [ ] Writing Assistant

### Life（生活工具）
- [ ] IP Query
- [ ] Speed Test

## 🚀 快速开始

1. 选择一个工具页面
2. 复制 `src/views/tools/JsonFormatter.vue` 作为模板
3. 根据 HTML 文件修改模板
4. 更新路由和工具数据
5. 测试功能

## ✅ 迁移检查清单

- [ ] 创建 Vue 组件文件
- [ ] 迁移 HTML 结构到 template
- [ ] 迁移 JavaScript 逻辑到 script setup
- [ ] 迁移样式到 style scoped
- [ ] 更新路由配置
- [ ] 更新工具数据链接
- [ ] 测试所有功能
- [ ] 检查响应式设计
- [ ] 检查主题兼容性

## 📚 参考资源

- [Vue 3 文档](https://cn.vuejs.org/)
- [Vue Router 文档](https://router.vuejs.org/zh/)
- [Vite 文档](https://cn.vitejs.dev/)
