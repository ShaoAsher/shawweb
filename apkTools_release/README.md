# APK Tools 移动开发工具箱

一个基于 Web 的移动开发工具集合，包含 Android 签名生成、APK 分析、图片处理、加解密、颜色转换、时间戳转换等实用工具。纯前端实现，无后端依赖，安全且易于部署。

## 📁 项目结构

项目按照公共配置、功能、代码逻辑进行了文件夹分类：

```
apkTools_release/
├── assets/                    # 公共资源文件夹
│   ├── css/                   # 样式文件
│   │   └── theme.css          # 主题样式文件（CSS变量定义）
│   └── js/                    # JavaScript文件
│       ├── themes.js          # 主题配置（颜色、字体、间距等）
│       ├── theme-ui.js        # 主题UI控制（主题切换器）
│       └── tools.js           # 工具配置和逻辑（工具列表、加载逻辑）
│
├── tools/                     # 工具页面文件夹
│   ├── converter/             # 转换类工具
│   │   ├── color_converter.html          # RGB颜色互转工具
│   │   ├── currency_converter.html       # 汇率转换工具
│   │   ├── svg_converter.html            # SVG互转工具
│   │   ├── timestamp_converter.html      # 时间戳转换工具
│   │   └── unit_converter.html         # 单位转换工具
│   │
│   ├── generator/             # 生成类工具
│   │   ├── icon_factory.html             # 图标工厂
│   │   ├── launch_image_generator.html   # 启动图生成工具
│   │   ├── qrcode_generator.html         # 二维码/条形码生成工具
│   │   ├── string_generator.html         # 多种字符串生成器
│   │   └── text_image_generator.html     # 文字图片生成工具
│   │
│   ├── formatter/             # 格式化类工具
│   │   ├── json_formatter.html           # JSON格式化工具
│   │   └── json_to_model.html            # JSON转Model工具
│   │
│   ├── analyzer/              # 分析类工具
│   │   ├── api_debugger.html             # API调试工具
│   │   └── apk_analyzer.html             # APK信息提取工具
│   │
│   └── developer/             # 开发者工具
│       ├── device_preview.html           # 机型预览信息工具
│       ├── image_compressor.html         # 图片压缩工具
│       ├── ip_query.html                 # IP地址查询工具
│       ├── keystore_generator.html       # Android签名文件生成工具
│       └── string_encryptor.html         # 字符串加解密工具
│
├── index.html                 # 首页（工具管理面板）
└── README.md                  # 项目说明文档
```

## 🛠️ 包含工具

### 🔄 转换类工具 (tools/converter/)
| 工具名称 | 路径 | 描述 |
| --- | --- | --- |
| **RGB 颜色互转工具** | `tools/converter/color_converter.html` | 支持 RGB、HEX、HSL 颜色格式互转，提供主流颜色预设卡片。 |
| **汇率转换工具** | `tools/converter/currency_converter.html` | 实时汇率查询与转换，支持全球主要货币。 |
| **SVG 互转工具** | `tools/converter/svg_converter.html` | 支持 SVG 与位图（PNG/JPG/JPEG）的双向转换，设置尺寸与比例。 |
| **时间戳转换工具** | `tools/converter/timestamp_converter.html` | 支持秒级和毫秒级时间戳与日期时间互转，自动识别时间戳类型。 |
| **单位转换工具** | `tools/converter/unit_converter.html` | 支持长度、重量、温度、面积、体积、时间、速度、数据、角度、压力等多种单位转换。 |

### ✨ 生成类工具 (tools/generator/)
| 工具名称 | 路径 | 描述 |
| --- | --- | --- |
| **图标工厂** | `tools/generator/icon_factory.html` | 上传一个图标，一键生成 iOS 与 Android 标准尺寸及文件夹结构。 |
| **启动图生成工具** | `tools/generator/launch_image_generator.html` | 一键生成 iOS 和 Android 所需的各种尺寸启动图。 |
| **二维码/条形码生成工具** | `tools/generator/qrcode_generator.html` | 支持自定义样式、颜色和中心图标，生成高质量二维码和多种格式条形码。 |
| **多种字符串生成器** | `tools/generator/string_generator.html` | 生成标准银行卡号、UDID、包名、UUID、MAC地址、IP地址、邮箱等常用字符串。 |
| **文字图片生成工具** | `tools/generator/text_image_generator.html` | 将文字转换为图片，支持自定义背景、字体和样式。 |

### 📋 格式化类工具 (tools/formatter/)
| 工具名称 | 路径 | 描述 |
| --- | --- | --- |
| **JSON 格式化工具** | `tools/formatter/json_formatter.html` | JSON 格式化、压缩、验证和可视化预览，支持语法高亮和实时验证。 |
| **JSON 转 Model 工具** | `tools/formatter/json_to_model.html` | 支持多语言模型类生成：Swift、OC、Vue、Dart、Kotlin、Java、PHP、Go 等。 |

### 🔍 分析类工具 (tools/analyzer/)
| 工具名称 | 路径 | 描述 |
| --- | --- | --- |
| **API 调试工具** | `tools/analyzer/api_debugger.html` | 支持 HTTP 请求和 WebSocket (WSS) 连接调试，类似 APIFOX，包含请求历史记录。 |
| **APK 信息提取工具** | `tools/analyzer/apk_analyzer.html` | 提取 APK 包名、版本号、签名指纹等信息。 |

### 👨‍💻 开发者工具 (tools/developer/)
| 工具名称 | 路径 | 描述 |
| --- | --- | --- |
| **机型预览信息工具** | `tools/developer/device_preview.html` | 查看主流手机机型详细信息，支持模糊搜索，包含最新iPhone 17系列。 |
| **图片压缩工具** | `tools/developer/image_compressor.html` | 智能压缩图片，保持画质的同时减小体积，支持多种格式。 |
| **IP地址查询工具** | `tools/developer/ip_query.html` | 查询当前IP和输入IP的归属地信息，包括国家、城市、ISP、时区等详细信息。 |
| **Android 签名生成器** | `tools/developer/keystore_generator.html` | 根据包名生成确定性签名文件，支持历史记录管理和导出。 |
| **字符串加解密工具** | `tools/developer/string_encryptor.html` | 支持 Base64、URL、Hex、Unicode、摩斯密码等编码，以及 MD5、SHA、AES、凯撒密码等加解密。 |

## 🎨 主题系统

项目内置了多主题支持系统，可以一键切换不同的视觉风格：

- **优雅紫色** (purple) - 默认主题，渐变紫色背景，优雅现代的设计风格
- **赛博朋克** (cyberpunk) - 暗黑霓虹风格，科技感强
- **清新浅色** (light) - 浅色背景，清新配色，简约现代
- **现代简约** (modern) - 暗色主题，类似 Discord/GitHub Dark

主题配置统一在 `assets/js/themes.js` 中管理，所有样式使用 CSS 变量，便于扩展和维护。

## 🚀 使用方法

本工具箱为纯静态 HTML 文件，无需安装任何环境即可运行。

1. **直接打开**：双击 `index.html` 在浏览器中打开即可使用所有工具。
2. **本地服务器**（推荐）：
   如果你想通过 HTTP 协议访问（某些功能如剪贴板、文件上传可能需要），可以在目录下运行：
   ```bash
   # Python 3
   python -m http.server 8000
   
   # 或者使用 Node.js
   npx http-server -p 8000
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

## 📦 依赖库

本项目使用 CDN 加载以下库：
- [Forge.js](https://github.com/digitalbazaar/forge) - 加密和签名相关功能
- [CryptoJS](https://github.com/brix/crypto-js) - 加密算法库
- [JSZip](https://github.com/Stuk/jszip) - ZIP 文件处理
- [QRCode.js](https://github.com/davidshimjs/qrcodejs) - 二维码生成
- [JsBarcode](https://github.com/lindell/JsBarcode) - 条形码生成

## 🔧 技术特性

- **纯前端实现**：无需后端服务器，所有处理在浏览器中完成
- **主题系统**：支持多主题切换，统一管理颜色、字体、间距等样式
- **响应式设计**：适配桌面端和移动端
- **本地存储**：主题选择自动保存到本地
- **模块化结构**：公共资源集中管理，工具页面按功能分类

## 📝 开发说明

- **公共资源**：所有公共配置（CSS、JS）统一放在 `assets/` 文件夹
- **工具页面**：按功能类型分类存放在 `tools/` 子文件夹
- **路径引用**：工具页面引用公共资源使用相对路径 `../../assets/`
- **新增工具**：按照功能类型将工具页面放入对应的 `tools/` 子文件夹，并在 `assets/js/tools.js` 中注册

## 📄 License

MIT License
