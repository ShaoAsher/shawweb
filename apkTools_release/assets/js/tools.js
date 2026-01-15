// 工具配置数据与加载脚本
// 支持本地 file:// 协议直接打开

(function () {
  'use strict';

  // 首页配置
  const homeConfig = {
    title: { zh: "常用工具面板", en: "Common Tools Panel" },
    description: { zh: "工具丰富齐全，快速访问使用。", en: "Rich and complete tools, quick access and use." },
    searchPlaceholder: { zh: "🔍 搜索工具...", en: "🔍 Search tools..." },
    quickAccessTitle: { zh: "⚡ 快捷入口", en: "⚡ Quick Access" },
    noResultsTitle: { zh: "未找到相关工具", en: "No tools found" },
    noResultsText: { zh: "试试其他关键词吧", en: "Try other keywords" },
    quickAccessRating: 0, // 推荐工具的评分阈值（0表示显示所有工具）
    quickAccessLimit: 0 // 快捷入口显示的工具数量（0表示显示所有工具）
  };

  // 工具配置数据
  const toolsData = {
    tools: [
      {
        icon: "🔑",
        title: { zh: "Android 签名文件生成工具", en: "Android Keystore Generator" },
        desc: { zh: "根据包名生成 .jks 并提取指纹与公钥信息，支持历史记录导入导出。", en: "Generate .jks files by package name and extract fingerprints and public key information, with import/export history support." },
        keywords: { zh: ["android", "安卓", "签名", "keystore", "jks", "证书", "指纹", "公钥", "密钥"], en: ["android", "keystore", "jks", "certificate", "fingerprint", "public key", "signature", "key"] },
        href: "./tools/developer/keystore_generator.html",
        category: "dev",
        rating: 5
      },
      {
        icon: "📦",
        title: { zh: "APK 信息提取工具", en: "APK Analyzer" },
        desc: { zh: "解析 APK，读取包名与证书指纹等信息，支持拖拽上传与结果复制。", en: "Parse APK files, read package name and certificate fingerprints, support drag-and-drop upload and result copying." },
        keywords: { zh: ["apk", "应用", "包", "解析", "包名", "证书", "指纹", "信息"], en: ["apk", "app", "package", "analyze", "package name", "certificate", "fingerprint", "info"] },
        href: "./tools/analyzer/apk_analyzer.html",
        category: "dev",
        rating: 5
      },
      {
        icon: "🌐",
        title: { zh: "API 调试工具", en: "API Debugger" },
        desc: { zh: "支持 HTTP 请求和 WebSocket (WSS) 连接调试，类似 APIFOX，包含请求历史记录。", en: "Support HTTP requests and WebSocket (WSS) connection debugging, similar to APIFOX, includes request history." },
        keywords: { zh: ["api", "调试", "请求", "websocket", "http", "wss", "接口", "测试"], en: ["api", "debug", "request", "websocket", "http", "wss", "interface", "test"] },
        href: "./tools/analyzer/api_debugger.html",
        category: "dev",
        rating: 5
      },
      {
        icon: "📋",
        title: { zh: "JSON 格式化工具", en: "JSON Formatter" },
        desc: { zh: "JSON 格式化、压缩、验证和可视化预览，支持语法高亮和实时验证。", en: "JSON formatting, compression, validation and visual preview, with syntax highlighting and real-time validation." },
        keywords: { zh: ["json", "格式化", "压缩", "验证", "预览", "语法高亮"], en: ["json", "format", "compress", "validate", "preview", "syntax highlight"] },
        href: "./tools/formatter/json_formatter.html",
        category: "dev",
        rating: 5
      },
      {
        icon: "💻",
        title: { zh: "JSON 转 Model 工具", en: "JSON to Model Converter" },
        desc: { zh: "支持多语言模型类生成：Swift、OC、Vue、Dart、Kotlin、Java、PHP、Go 等。", en: "Support multi-language model class generation: Swift, OC, Vue, Dart, Kotlin, Java, PHP, Go, etc." },
        keywords: { zh: ["json", "model", "模型", "swift", "kotlin", "java", "dart", "php", "go", "vue", "代码生成"], en: ["json", "model", "class", "swift", "kotlin", "java", "dart", "php", "go", "vue", "code generation"] },
        href: "./tools/formatter/json_to_model.html",
        category: "dev",
        rating: 5
      },
      {
        icon: "📖",
        title: { zh: "Markdown 编辑器", en: "Markdown Editor" },
        desc: {
          zh: "支持导入文件或粘贴文本，提供编辑、预览、历史记录与 Markdown/HTML 导出。",
          en: "Import or paste Markdown, then edit, preview, manage history, and export as Markdown or HTML."
        },
        keywords: {
          zh: ["markdown", "编辑器", "预览", "编译", "历史", "导入", "md", "文档"],
          en: ["markdown", "editor", "preview", "compile", "history", "import", "md", "document"]
        },
        href: "./tools/text/markdown/markdownHome.html",
        category: "text",
        rating: 5
      },
      {
        icon: "📱",
        title: { zh: "机型预览信息工具", en: "Device Preview Tool" },
        desc: { zh: "查看主流手机机型详细信息，支持模糊搜索，包含最新iPhone 17系列。", en: "View detailed information of mainstream mobile phone models, support fuzzy search, including the latest iPhone 17 series." },
        keywords: { zh: ["device", "机型", "手机", "iphone", "android", "预览", "信息", "屏幕"], en: ["device", "phone", "mobile", "iphone", "android", "preview", "info", "screen"] },
        href: "./tools/developer/device_preview.html",
        category: "dev",
        rating: 4
      },
      {
        icon: "🗜️",
        title: { zh: "图片压缩工具", en: "Image Compressor" },
        desc: { zh: "智能压缩图片，保持比例与清晰度，支持预览对比与多格式导出。", en: "Intelligent image compression, maintain aspect ratio and clarity, support preview comparison and multi-format export." },
        keywords: { zh: ["image", "图片", "压缩", "compress", "png", "jpg", "jpeg", "优化"], en: ["image", "compress", "png", "jpg", "jpeg", "optimize", "reduce size"] },
        href: "./tools/image/image_compressor.html",
        category: "image",
        rating: 5
      },
      {
        icon: "🚀",
        title: { zh: "启动图生成工具", en: "Launch Image Generator" },
        desc: { zh: "为 iOS 与 Android 批量生成多尺寸启动图，支持背景与Logo配置。", en: "Batch generate multi-size launch images for iOS and Android, support background and logo configuration." },
        keywords: { zh: ["launch", "启动", "启动图", "ios", "android", "splash", "logo"], en: ["launch", "splash", "screen", "ios", "android", "logo", "startup"] },
        href: "./tools/image/launch_image_generator.html",
        category: "image",
        rating: 5
      },
      {
        icon: "🎨",
        title: { zh: "图标工厂", en: "Icon Factory" },
        desc: { zh: "上传一个图标，一键生成 iOS 与 Android 标准尺寸及文件夹结构，包含标准命名。", en: "Upload one icon, generate iOS and Android standard sizes and folder structure with one click, including standard naming." },
        keywords: { zh: ["icon", "图标", "工厂", "ios", "android", "尺寸", "生成"], en: ["icon", "factory", "ios", "android", "size", "generate", "app icon"] },
        href: "./tools/image/icon_factory.html",
        category: "image",
        rating: 5
      },
      {
        icon: "🔄",
        title: { zh: "SVG 互转 PNG/JPG/JPEG", en: "SVG Converter" },
        desc: { zh: "支持 SVG 与位图的双向转换，设置尺寸与比例并下载。", en: "Support bidirectional conversion between SVG and bitmap, set size and ratio and download." },
        keywords: { zh: ["svg", "png", "jpg", "jpeg", "转换", "位图", "矢量图"], en: ["svg", "png", "jpg", "jpeg", "convert", "bitmap", "vector"] },
        href: "./tools/image/svg_converter.html",
        category: "image",
        rating: 4
      },
      {
        icon: "✍️",
        title: { zh: "文字图片生成工具", en: "Text Image Generator" },
        desc: { zh: "输入文本快速生成图片素材，适用于占位图、标签图等场景。", en: "Enter text to quickly generate image materials, suitable for placeholder images, label images and other scenarios." },
        keywords: { zh: ["text", "文字", "图片", "生成", "占位图", "标签"], en: ["text", "image", "generate", "placeholder", "label", "text to image"] },
        href: "./tools/image/text_image_generator.html",
        category: "image",
        rating: 4
      },
      {
        icon: "📷",
        title: { zh: "二维码/条形码生成工具", en: "QR Code / Barcode Generator" },
        desc: { zh: "支持自定义样式、颜色和中心图标，生成高质量二维码和多种格式条形码。", en: "Support custom styles, colors and center icons, generate high-quality QR codes and multiple format barcodes." },
        keywords: { zh: ["qrcode", "二维码", "条形码", "barcode", "生成", "扫描"], en: ["qrcode", "qr code", "barcode", "generate", "scan", "code"] },
        href: "./tools/image/qrcode_generator.html",
        category: "image",
        rating: 4
      },
      {
        icon: "🎨",
        title: { zh: "RGB 颜色互转工具", en: "RGB Color Converter" },
        desc: { zh: "支持 RGB、HEX、HSL 颜色格式互转，提供主流颜色预设卡片，条状展示。", en: "Support RGB, HEX, HSL color format conversion, provide mainstream color preset cards, displayed in strips." },
        keywords: { zh: ["color", "颜色", "rgb", "hex", "hsl", "转换", "色彩"], en: ["color", "rgb", "hex", "hsl", "convert", "colour", "picker"] },
        href: "./tools/image/color_converter.html",
        category: "image",
        rating: 4
      },
      {
        icon: "🔐",
        title: { zh: "字符串加解密工具", en: "String Encryptor / Decryptor" },
        desc: { zh: "支持 Base64、URL、Hex、Unicode、摩斯密码等编码，以及 MD5、SHA、AES、凯撒密码等加解密。", en: "Support Base64, URL, Hex, Unicode, Morse code encoding, and MD5, SHA, AES, Caesar cipher encryption/decryption." },
        keywords: { zh: ["string", "字符串", "加密", "解密", "base64", "md5", "sha", "aes", "编码"], en: ["string", "encrypt", "decrypt", "base64", "md5", "sha", "aes", "encode", "decode"] },
        href: "./tools/text/string_encryptor.html",
        category: "text",
        rating: 5
      },
      {
        icon: "⏰",
        title: { zh: "时间戳转换工具", en: "Timestamp Converter" },
        desc: { zh: "支持秒级和毫秒级时间戳与日期时间互转，自动识别时间戳类型。", en: "Support conversion between second-level and millisecond-level timestamps and date-time, automatically identify timestamp type." },
        keywords: { zh: ["timestamp", "时间戳", "时间", "日期", "转换", "datetime"], en: ["timestamp", "time", "date", "convert", "datetime", "unix time"] },
        href: "./tools/converter/timestamp_converter.html",
        category: "converter",
        rating: 4
      },
      {
        icon: "🔤",
        title: { zh: "多种字符串生成器", en: "String Generator" },
        desc: { zh: "生成标准银行卡号、UDID、包名、UUID、MAC地址、IP地址、邮箱等常用字符串。", en: "Generate standard bank card numbers, UDID, package names, UUID, MAC addresses, IP addresses, emails and other common strings." },
        keywords: { zh: ["generator", "生成器", "生成", "uuid", "mac", "ip", "邮箱", "银行卡"], en: ["generator", "generate", "uuid", "mac", "ip", "email", "bank card", "string"] },
        href: "./tools/text/string_generator.html",
        category: "text",
        rating: 3
      },
      {
        icon: "📐",
        title: { zh: "单位转换工具", en: "Unit Converter" },
        desc: { zh: "支持长度、重量、温度、面积、体积、时间、速度、数据、角度、压力等多种单位转换，界面美观，分组展示。", en: "Support conversion of length, weight, temperature, area, volume, time, speed, data, angle, pressure and other units, beautiful interface, grouped display." },
        keywords: { zh: ["unit", "单位", "转换", "converter", "长度", "重量", "温度", "面积", "体积", "时间", "速度", "数据", "角度", "压力", "米", "千克", "摄氏度"], en: ["unit", "converter", "length", "weight", "temperature", "area", "volume", "time", "speed", "data", "angle", "pressure", "meter", "kilogram", "celsius"] },
        href: "./tools/converter/unit_converter.html",
        category: "converter",
        rating: 5
      },
      {
        icon: "💱",
        title: { zh: "汇率转换工具", en: "Currency Converter" },
        desc: { zh: "实时汇率查询与转换，支持全球主要货币，包含汇率换算工具和实时汇率列表，支持搜索功能。", en: "Real-time exchange rate query and conversion, support major global currencies, includes currency converter and real-time exchange rate list with search function." },
        keywords: { zh: ["currency", "汇率", "货币", "转换", "实时", "汇率查询", "人民币", "美元", "欧元", "汇率列表"], en: ["currency", "exchange rate", "money", "convert", "real-time", "rate query", "CNY", "USD", "EUR", "rate list"] },
        href: "./tools/converter/currency_converter.html",
        category: "converter",
        rating: 5
      },
      {
        icon: "🌍",
        title: { zh: "IP地址查询工具", en: "IP Address Query Tool" },
        desc: { zh: "查询当前IP和输入IP的归属地信息，包括国家、城市、ISP、时区等详细信息。", en: "Query current IP and input IP location information, including country, city, ISP, timezone and other detailed information." },
        keywords: { zh: ["ip", "ip地址", "归属地", "地理位置", "isp", "时区", "查询", "定位"], en: ["ip", "ip address", "location", "geolocation", "isp", "timezone", "query", "lookup"] },
        href: "./tools/life/ip_query.html",
        category: "life",
        rating: 4
      },
      {
        icon: "🚀",
        title: { zh: "网络测速工具", en: "Network Speed Test" },
        desc: { zh: "测试网络延迟、下载速度和上传速度，类似 Speedtest，实时显示测试进度和结果。", en: "Test network latency, download speed and upload speed, similar to Speedtest, display test progress and results in real-time." },
        keywords: { zh: ["网络", "测速", "speedtest", "网速", "延迟", "ping", "下载", "上传", "带宽"], en: ["network", "speed", "speedtest", "ping", "download", "upload", "bandwidth", "latency"] },
        href: "./tools/life/speed_test.html",
        category: "life",
        rating: 5
      },
      {
        icon: "✍️",
        title: { zh: "写作助手", en: "Writing Assistant" },
        desc: { zh: "专业的写作助手系统，包含书架管理、分卷分章创作、大纲管理、人物关系图、时间线甘特图和备注区等功能。", en: "Professional writing assistant system with bookshelf management, volume/chapter creation, outline management, character relationship diagram, timeline Gantt chart and notes area." },
        keywords: { zh: ["写作", "助手", "作家", "书架", "大纲", "章节", "分卷", "关系图", "甘特图", "创作", "小说"], en: ["writing", "assistant", "author", "bookshelf", "outline", "chapter", "volume", "relationship", "gantt", "creative", "novel"] },
        href: "./tools/text/writing/bookHome.html",
        category: "text",
        rating: 5
      }
    ],
    categories: {
      dev: { zh: "开发工具", en: "Development Tools" },
      image: { zh: "图片工具", en: "Image Tools" },
      text: { zh: "文本工具", en: "Text Tools" },
      converter: { zh: "转换工具", en: "Converter Tools" },
      life: { zh: "生活工具", en: "Life Tools" }
    }
  };

  // 获取当前语言
  function getLanguage() {
    const urlParams = new URLSearchParams(window.location.search);
    const lang = urlParams.get('lang') || localStorage.getItem('preferredLang') || 'zh';
    return lang === 'en' ? 'en' : 'zh';
  }

  // 获取当前页面文件名
  function getCurrentPageName() {
    return window.location.pathname.split('/').pop() || window.location.pathname.split('\\').pop();
  }

  // 获取工具文本（支持中英文）
  function getToolText(tool, field, lang) {
    if (!tool || !tool[field]) return '';
    const value = tool[field];
    return typeof value === 'object' ? (value[lang] || value.zh || '') : value;
  }

  // 加载并应用工具配置（用于工具页面）
  function loadToolConfig() {
    const currentPath = window.location.pathname;
    const currentPage = getCurrentPageName();
    const currentLang = getLanguage();
    // 匹配工具：支持相对路径和完整路径匹配
    const tool = toolsData.tools.find(t => {
      const toolPath = t.href.replace('./', '');
      return currentPath.includes(toolPath) || currentPage === toolPath.split('/').pop();
    });

    if (!tool) return;

    const title = getToolText(tool, 'title', currentLang);
    const desc = getToolText(tool, 'desc', currentLang);

    if (title) {
      document.title = title;
      const headerH1 = document.querySelector('.header h1');
      if (headerH1) headerH1.textContent = (tool.icon || '') + ' ' + title;
    }

    const headerP = document.querySelector('.header p');
    if (headerP && desc) headerP.textContent = desc;

    const homeBtn = document.querySelector('.home-btn');
    if (homeBtn) homeBtn.setAttribute('title', currentLang === 'en' ? 'Back to Home' : '返回首页');
  }

  // 导出到全局作用域（供首页使用）
  window.toolsData = toolsData;
  window.homeConfig = homeConfig;
  window.getToolText = getToolText;
  window.getLanguage = getLanguage;

  // 页面加载完成后执行（工具页面）
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', loadToolConfig);
  } else {
    loadToolConfig();
  }
})();
