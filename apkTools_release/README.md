# APK Tools 移动开发工具箱

一个基于 Web 的移动开发工具集合，包含 Android 签名生成、APK 分析、图片处理、加解密、颜色转换、时间戳转换等实用工具。纯前端实现，无后端依赖，安全且易于部署。

## 🛠️ 包含工具

| 工具名称 | 文件名 | 描述 |
| --- | --- | --- |
| **Android 签名生成器** | `keystore_generator.html` | 根据包名生成确定性签名文件，支持历史记录管理和导出。 |
| **APK 信息提取工具** | `apk_analyzer.html` | 提取 APK 包名、版本号、签名指纹等信息。 |
| **图片压缩工具** | `image_compressor.html` | 智能压缩图片，保持画质的同时减小体积，支持多种格式。 |
| **启动图生成工具** | `launch_image_generator.html` | 一键生成 iOS 和 Android 所需的各种尺寸启动图。 |
| **文字图片生成工具** | `text_image_generator.html` | 将文字转换为图片，支持自定义背景、字体和样式。 |
| **图标工厂** | `icon_factory.html` | 上传一个图标，一键生成 iOS 与 Android 标准尺寸及文件夹结构。 |
| **SVG 互转工具** | `svg_converter.html` | 支持 SVG 与位图（PNG/JPG/JPEG）的双向转换，设置尺寸与比例。 |
| **字符串加解密工具** | `string_encryptor.html` | 支持 Base64、URL、Hex、Unicode、摩斯密码等编码，以及 MD5、SHA、AES、凯撒密码等加解密。 |
| **RGB 颜色互转工具** | `color_converter.html` | 支持 RGB、HEX、HSL 颜色格式互转，提供主流颜色预设卡片。 |
| **时间戳转换工具** | `timestamp_converter.html` | 支持秒级和毫秒级时间戳与日期时间互转，自动识别时间戳类型。 |

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

### 字符串加解密
- **编码/解码**：Base64、URL、HTML 实体、Hex、Unicode、摩斯密码
- **哈希算法**：MD5、SHA-1、SHA-256、SHA-512
- **加密算法**：AES（支持 GCM、CBC、CTR、CFB、OFB 模式）、凯撒密码
- **高级选项**：自定义盐值、IV、PBKDF2 迭代次数和哈希算法

### RGB 颜色互转
- 支持 HEX、RGB、RGBA、HSL、HSLA 格式互转
- 30+ 主流颜色预设卡片，条状展示
- 实时颜色预览
- 点击预设卡片快速填充

### 时间戳转换
- 时间戳转日期（支持秒级和毫秒级，自动识别）
- 日期转时间戳（支持秒级和毫秒级输出）
- 多种日期格式输出（ISO 8601、本地时间、UTC 等）
- 一键获取当前时间戳

## 依赖库
本项目使用 CDN 加载以下库：
- [Forge.js](https://github.com/digitalbazaar/forge)
- [CryptoJS](https://github.com/brix/crypto-js)
- [JSZip](https://github.com/Stuk/jszip)

---
License: MIT
