# APK Tools 移动开发工具箱

一个基于 Web 的移动开发工具集合，包含 Android 签名生成、APK 分析、图片处理等实用工具。纯前端实现，无后端依赖，安全且易于部署。

## 🛠️ 包含工具

| 工具名称 | 文件名 | 描述 |
| --- | --- | --- |
| **Android 签名生成器** | `keystore_generator.html` | 根据包名生成确定性签名文件，支持历史记录管理和导出。 |
| **APK 信息提取工具** | `apk_analyzer.html` | 提取 APK 包名、版本号、签名指纹等信息。 |
| **图片压缩工具** | `image_compressor.html` | 智能压缩图片，保持画质的同时减小体积，支持多种格式。 |
| **启动图生成工具** | `launch_image_generator.html` | 一键生成 iOS 和 Android 所需的各种尺寸启动图。 |
| **文字图片生成工具** | `text_image_generator.html` | 将文字转换为图片，支持自定义背景、字体和样式。 |

## 🚀 使用方法

本工具箱为纯静态 HTML 文件，无需安装任何环境即可运行。

1. **直接打开**：双击 `index.html` 在浏览器中打开即可使用所有工具。
2. **本地服务器**（可选）：
   如果你想通过 HTTP 协议访问（某些功能如剪贴板可能需要），可以在目录下运行：
   ```bash
   # Python 3
   python -m http.server 8000
   ```
   然后访问 `http://localhost:8000`

## 📋 功能特性详情

### Android 签名文件生成
- **确定性生成**：相同包名生成相同的签名文件
- **自动提取信息**：显示 MD5、SHA1、SHA256 指纹
- **数据导出**：支持导出 keystore 和元数据

### 图片压缩
- 支持 JPG, PNG, WEBP
- 可视化对比压缩前后效果
- 纯前端压缩，保护隐私

## 依赖库
本项目使用 CDN 加载以下库：
- [Forge.js](https://github.com/digitalbazaar/forge)
- [CryptoJS](https://github.com/brix/crypto-js)
- [JSZip](https://github.com/Stuk/jszip)

---
License: MIT
