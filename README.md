# 🛠️ Shaw Web Tools

> 基于 Vue 3 + Vite 的现代化Web工具集，提供 25+ 实用工具

一个优雅、高效、易用的前端工具箱，包含 Android 签名生成、图片处理、代码格式化、加解密、文件转换等常用开发工具。

## ✨ 特性

- 🎨 **现代化UI** - 响应式设计，支持深色/浅色主题切换
- ⚡ **极速体验** - Vite 驱动，热重载秒级响应
- 🎯 **25+工具** - 涵盖开发、图片、文本、分析等多个领域
- 📦 **零配置** - 开箱即用，无需复杂配置
- 🎭 **动画流畅** - GSAP + Vanta.js 打造丝滑体验
- 🔧 **组件化** - 统一公共组件，代码高度复用
- ♻️ **精简架构** - 移除冗余代码，优化项目结构

## 🚀 快速开始

### 安装依赖
   ```bash
   npm install
   ```

### 启动开发服务器
   ```bash
   npm run dev
   ```
访问 http://localhost:3000/shawweb/

### 构建生产版本
   ```bash
   npm run build
   ```

### 预览生产构建
   ```bash
   npm run preview
   ```

---

## 📋 最近更新 (2026-01-22)

### ✅ 统一公共组件
所有图片工具已统一使用 `ImageUploader` 和 `FileUploader` 公共组件：
- ✅ 图片压缩工具
- ✅ 图标工厂
- ✅ SVG转换器  
- ✅ 启动图生成器

### 🗑️ 代码精简
- 移除各工具中重复的文件上传逻辑（减少 ~500 行代码）
- 移除未使用的CSS样式
- 统一全屏预览功能

### 🎨 用户体验优化
- 统一的拖拽上传交互
- 统一的图片预览和删除功能
- 统一的全屏查看（支持长图滚动）
- 响应式布局优化

---

## 📦 项目架构

```
src/
├── components/          # 公共组件
│   ├── AppButton.vue           # 统一按钮组件
│   ├── ButtonGroup.vue         # 按钮组
│   ├── FileUploader.vue        # 文件上传组件（支持拖拽）
│   ├── ImageUploader.vue       # 图片上传组件（带预览和全屏）
│   ├── ImagePreview.vue        # 图片预览组件（支持全屏）
│   ├── ThemeToggle.vue         # 主题切换
│   ├── ToolLayout.vue          # 工具页面布局
│   └── VantaBackground.vue     # 3D背景特效
├── composables/         # 组合式函数
│   └── useFileUpload.js        # 文件上传逻辑
├── utils/              # 工具函数
│   ├── index.js                # 统一导出
│   ├── common.js               # 通用工具（复制、下载、文件处理）
│   ├── toast.js                # 通知系统
│   ├── ripple.js               # 涟漪效果
│   ├── form-feedback.js        # 表单验证反馈
│   ├── cdn-loader.js           # CDN资源加载
│   └── themes.js               # 主题管理
├── config/             # 配置文件
│   └── theme-config.js         # 主题配置
├── assets/css/         # 全局样式
│   ├── theme.css               # 主题变量和全局样式
│   ├── animations.css          # 动画关键帧
│   └── home.css                # 首页样式
└── views/              # 页面组件
    ├── Home.vue                # 首页
    └── tools/                  # 工具页面（26+）
        ├── analyzer/           # 分析工具
        ├── converter/          # 转换工具
        ├── developer/          # 开发工具
        ├── formatter/          # 格式化工具
        ├── image/              # 图片工具
        ├── life/               # 生活工具
        └── text/               # 文本工具
```

## 🎯 核心功能

### 🔧 开发工具
- **Android签名生成** - 生成.jks签名文件并提取指纹信息
- **APK分析** - 分析APK包信息、权限、证书
- **设备预览** - 多设备响应式预览

### 🖼️ 图片工具
- **图片压缩** - 智能压缩，支持多格式
- **图标工厂** - 批量生成应用图标
- **启动图生成** - iOS/Android启动图一键生成
- **二维码生成** - 支持Logo、颜色自定义
- **SVG转换** - SVG与位图互转
- **颜色转换** - 取色、格式转换

### 📝 文本工具
- **JSON格式化** - 格式化、验证、压缩
- **Markdown预览** - 实时预览和编译
- **字符串加密** - 多种加密算法
- **随机字符串** - 自定义规则生成

### 🔄 转换工具
- **时间戳转换** - 多格式时间转换
- **单位转换** - 长度、重量、温度等
- **货币转换** - 实时汇率转换

### 📊 分析工具
- **API调试** - 接口测试工具
- **网速测试** - 网络速度检测
- **IP查询** - IP地址归属查询

## 🛠️ 公共组件使用

### ⭐ 全局组件说明

以下组件已注册为**全局组件**，可在任何 `.vue` 文件中直接使用，**无需 import 导入**：

| 组件 | 用途 | 推荐场景 |
|------|------|----------|
| `<ImageUploader>` | ⭐ 图片上传（带预览、删除、全屏） | 所有图片工具 |
| `<FileUploader>` | 通用文件上传 | 文件处理工具 |
| `<ImagePreview>` | 图片预览（支持全屏） | 图片查看 |
| `<AppButton>` | 统一按钮组件 | 所有工具 |
| `<ButtonGroup>` | 按钮组 | 多按钮布局 |

---

### ImageUploader - 图片上传组件（推荐）

**专为图片工具设计，带预览、删除和全屏查看功能**

**特性：**
- ✅ 点击或拖拽上传
- ✅ 实时预览（显示尺寸和大小）
- ✅ 点击预览图全屏查看
- ✅ 全屏支持长图滚动
- ✅ ESC键关闭全屏
- ✅ 删除并重新选择

```vue
<template>
  <!-- 无需导入，直接使用 -->
  <ImageUploader
    v-model="imageFile"
    icon="📷"
    text="点击或拖拽图片到此处"
    hint="支持 JPG、PNG、WEBP"
    preview-title="📷 已选择的图片"
    @change="handleImageChange"
    @delete="handleImageDelete"
  />
</template>

<script setup>
import { ref } from 'vue'

const imageFile = ref(null)

function handleImageChange(file) {
  console.log('图片已选择:', file)
}

function handleImageDelete() {
  console.log('图片已删除')
}
</script>
```

### FileUploader - 通用文件上传组件

```vue
<template>
  <!-- 无需导入，直接使用 -->
  <FileUploader
    v-model="file"
    accept="*/*"
    icon="📁"
    text="上传文件"
    hint="支持所有文件格式"
    @change="handleFileChange"
  />
</template>

<script setup>
import { ref } from 'vue'

const file = ref(null)

function handleFileChange(file) {
  console.log('文件已选择:', file)
}
</script>
```

### ImagePreview - 图片预览组件

```vue
<template>
  <!-- 无需导入，直接使用 -->
  <ImagePreview
    :show="showPreview"
    :src="imageUrl"
    title="图片预览"
    @close="showPreview = false"
  />
</template>

<script setup>
import { ref } from 'vue'

const imageUrl = ref('/path/to/image.jpg')
const showPreview = ref(false)
</script>
```

### 通用工具函数

```javascript
import { 
  copyToClipboard, 
  downloadFile, 
  loadImage,
  formatFileSize,
  compressImage
} from '@/utils'

// 复制到剪贴板
await copyToClipboard('Hello World')

// 下载文件
downloadFile(blob, 'file.txt', 'text/plain')

// 加载图片
const img = await loadImage('/path/to/image.jpg')

// 格式化文件大小
const size = formatFileSize(1024000) // '1000 KB'

// 压缩图片
const compressed = await compressImage(file, {
  maxWidth: 1920,
  quality: 0.92
})
```

## 📝 开发指南

### 添加新工具

1. **创建组件** - 在 `src/views/tools/` 对应分类下创建 `.vue` 文件
2. **添加路由** - 在 `src/router/index.js` 中配置路由
3. **注册工具** - 在 `src/data/tools.js` 中添加工具信息

```javascript
// tools.js
{
  id: 'my-tool',
  name: '我的工具',
  icon: '🔧',
  category: 'developer',
  path: '/tools/developer/my-tool',
  description: '工具描述'
}
```

### 使用 ToolLayout 布局

所有工具页面都使用统一的布局：

```vue
<template>
  <ToolLayout
    icon="🔧"
    title="工具标题"
    description="工具描述"
  >
    <!-- 工具内容 -->
  </ToolLayout>
</template>

<script setup>
import ToolLayout from '@/components/ToolLayout.vue'
</script>
```

### 主题定制

主题配置在 `src/config/theme-config.js`，所有颜色使用 CSS 变量：

```css
:root {
  --color-primary: #667eea;
  --color-background: linear-gradient(...);
  --spacing-md: 16px;
  --radius-md: 12px;
}
```

## 🎨 技术栈

- **框架**: Vue 3 (Composition API)
- **构建**: Vite 5
- **路由**: Vue Router 4
- **动画**: GSAP + Vanta.js
- **样式**: CSS Variables + Scoped CSS
- **工具库**: crypto-js, jszip, node-forge

## 🌐 部署

项目已配置 GitHub Actions 自动部署：

1. 推送代码到 `main` 分支
2. GitHub Actions 自动构建
3. 自动部署到 GitHub Pages

访问地址：`https://你的用户名.github.io/仓库名/`

## 📈 性能优化

- ✅ 按需加载工具组件
- ✅ 图片懒加载和压缩
- ✅ GSAP动画GPU加速
- ✅ Vite代码分割
- ✅ 生产环境压缩优化

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 开源协议

MIT License - 自由使用、修改和分发
