// 工具配置数据
export const homeConfig = {
  title: "常用工具面板",
  description: "工具丰富齐全，快速访问使用。",
  searchPlaceholder: "搜索工具...",
  quickAccessTitle: "⚡ 快捷入口",
  noResultsTitle: "未找到相关工具",
  noResultsText: "试试其他关键词吧",
  quickAccessRating: 0,
  quickAccessLimit: 0
}

export const categories = {
  dev: "开发工具",
  image: "图片工具",
  text: "文本工具",
  converter: "转换工具",
  life: "生活工具",
  entertainment: "娱乐工具"
}

export const toolsData = {
  tools: [
    {
      id: "liars_dice",
      icon: "🎲",
      title: "大话骰子 (Liar's Dice)",
      desc: "3D 模拟大话骰子游戏，支持摇骰子、开盅、重摇等操作，聚会娱乐必备。",
      keywords: ["骰子", "大话骰", "liar's dice", "game", "游戏", "3d", "dice"],
      href: "/tools/entertainment/liars_dice",
      category: "entertainment",
      rating: 5,
      minUserMode: 'normal'
    },
    {
      id: "truth_bottle",
      icon: "🍾",
      title: "3D 真心话转瓶",
      desc: "经典的聚会游戏，旋转精致的 3D 瓶子决定谁是幸运儿，真实物理惯性。",
      keywords: ["真心话", "大冒险", "转瓶子", "bottle", "spin", "party", "聚会"],
      href: "/tools/entertainment/truth_bottle",
      category: "entertainment",
      rating: 5,
      minUserMode: 'normal'
    },
    {
      id: "reaction_challenge",
      icon: "🎯",
      title: "3D 反应力训练",
      desc: "专业级 FPS 练枪与反应力训练工具，包含网格射击、追踪训练、精准度挑战等多种模式。",
      keywords: ["反应", "fps", "aim", "shoot", "challenge", "3d", "训练", "aimlab"],
      href: "/tools/entertainment/reaction_challenge",
      category: "entertainment",
      rating: 5,
      minUserMode: 'normal'
    },
    {
      id: "keystore_generator",
      icon: "🔑",
      title: "Android 签名文件生成工具",
      desc: "根据包名生成 .jks 并提取指纹与公钥信息，支持历史记录导入导出。",
      keywords: ["android", "安卓", "签名", "keystore", "jks", "证书", "指纹", "公钥", "密钥"],
      href: "/tools/developer/keystore_generator",
      category: "dev",
      rating: 5,
      minUserMode: 'code'
    },
    {
      id: "apk_analyzer",
      icon: "📦",
      title: "APK 信息提取工具",
      desc: "解析 APK，读取包名与证书指纹等信息，支持拖拽上传与结果复制。",
      keywords: ["apk", "应用", "包", "解析", "包名", "证书", "指纹", "信息"],
      href: "/tools/analyzer/apk_analyzer",
      category: "dev",
      rating: 5,
      minUserMode: 'code'
    },
    {
      id: "api_debugger",
      icon: "🌐",
      title: "API 调试工具",
      desc: "支持 HTTP 请求和 WebSocket (WSS) 连接调试，类似 APIFOX，包含请求历史记录。",
      keywords: ["api", "调试", "请求", "websocket", "http", "wss", "接口", "测试"],
      href: "/tools/analyzer/api_debugger",
      category: "dev",
      rating: 5,
      minUserMode: 'code'
    },
    {
      id: "json_formatter",
      icon: "📋",
      title: "JSON 格式化工具",
      desc: "JSON 格式化、压缩、验证和可视化预览，支持语法高亮和实时验证。",
      keywords: ["json", "格式化", "压缩", "验证", "预览", "语法高亮"],
      href: "/tools/formatter/json_formatter",
      category: "dev",
      rating: 5,
      minUserMode: 'code'
    },
    {
      id: "json_to_model",
      icon: "💻",
      title: "JSON 转 Model 工具",
      desc: "支持多语言模型类生成：Swift、OC、Vue、Dart、Kotlin、Java、PHP、Go 等。",
      keywords: ["json", "model", "模型", "swift", "kotlin", "java", "dart", "php", "go", "vue", "代码生成"],
      href: "/tools/formatter/json_to_model",
      category: "dev",
      rating: 5,
      minUserMode: 'code'
    },
    {
      id: "markdown",
      icon: "📖",
      title: "Markdown 编辑器",
      desc: "支持导入文件或粘贴文本，提供编辑、预览、历史记录与 Markdown/HTML 导出。",
      keywords: ["markdown", "编辑器", "预览", "编译", "历史", "导入", "md", "文档"],
      href: "/tools/text/markdown",
      category: "text",
      rating: 5,
      minUserMode: 'code'
    },
    {
      id: "device_preview",
      icon: "📱",
      title: "机型预览信息工具",
      desc: "查看主流手机机型详细信息，支持模糊搜索，包含最新iPhone 17系列。",
      keywords: ["device", "机型", "手机", "iphone", "android", "预览", "信息", "屏幕"],
      href: "/tools/developer/device_preview",
      category: "dev",
      rating: 4,
      minUserMode: 'code'
    },
    {
      id: "image_compressor",
      icon: "🗜️",
      title: "图片压缩工具",
      desc: "智能压缩图片，保持比例与清晰度，支持预览对比与多格式导出。",
      keywords: ["image", "图片", "压缩", "compress", "png", "jpg", "jpeg", "优化"],
      href: "/tools/image/image_compressor",
      category: "image",
      rating: 5,
      minUserMode: 'normal'
    },
    {
      id: "image_tinter",
      icon: "🎨",
      title: "图片/图标变色工具",
      desc: "主要对纯色图标或图片进行着色（TintColor），支持自定义颜色与实时预览导出。",
      keywords: ["image", "icon", "tint", "color", "变色", "着色", "图标", "图片"],
      href: "/tools/image/image_tinter",
      category: "image",
      rating: 5,
      minUserMode: 'normal'
    },
    {
      id: "launch_image_generator",
      icon: "🚀",
      title: "启动图生成工具",
      desc: "为 iOS 与 Android 批量生成多尺寸启动图，支持背景与Logo配置。",
      keywords: ["launch", "启动", "启动图", "ios", "android", "splash", "logo"],
      href: "/tools/image/launch_image_generator",
      category: "image",
      rating: 5,
      minUserMode: 'normal'
    },
    {
      id: "icon_factory",
      icon: "🎨",
      title: "图标工厂",
      desc: "上传一个图标，一键生成 iOS 与 Android 标准尺寸及文件夹结构，包含标准命名。",
      keywords: ["icon", "图标", "工厂", "ios", "android", "尺寸", "生成"],
      href: "/tools/image/icon_factory",
      category: "image",
      rating: 5,
      minUserMode: 'normal'
    },
    {
      id: "svg_converter",
      icon: "🔄",
      title: "SVG 互转 PNG/JPG/JPEG",
      desc: "支持 SVG 与位图的双向转换，设置尺寸与比例并下载。",
      keywords: ["svg", "png", "jpg", "jpeg", "转换", "位图", "矢量图"],
      href: "/tools/image/svg_converter",
      category: "image",
      rating: 4,
      minUserMode: 'normal'
    },
    {
      id: "text_image_generator",
      icon: "✍️",
      title: "文字图片生成工具",
      desc: "输入文本快速生成图片素材，适用于占位图、标签图等场景。",
      keywords: ["text", "文字", "图片", "生成", "占位图", "标签"],
      href: "/tools/image/text_image_generator",
      category: "image",
      rating: 4,
      minUserMode: 'normal'
    },
    {
      id: "qrcode_generator",
      icon: "📷",
      title: "二维码/条形码生成工具",
      desc: "支持自定义样式、颜色和中心图标，生成高质量二维码和多种格式条形码。",
      keywords: ["qrcode", "二维码", "条形码", "barcode", "生成", "扫描"],
      href: "/tools/image/qrcode_generator",
      category: "image",
      rating: 4,
      minUserMode: 'normal'
    },
    {
      id: "color_converter",
      icon: "🎨",
      title: "RGB 颜色互转工具",
      desc: "支持 RGB、HEX、HSL 颜色格式互转，提供主流颜色预设卡片，条状展示。",
      keywords: ["color", "颜色", "rgb", "hex", "hsl", "转换", "色彩"],
      href: "/tools/image/color_converter",
      category: "image",
      rating: 4,
      minUserMode: 'normal'
    },
    {
      id: "bead_pixel_art",
      icon: "🧩",
      title: "拼豆像素图工具",
      desc: "上传图片生成拼豆/像素风格图，可限制色板、调节像素数量并导出 PNG。",
      keywords: ["拼豆", "像素", "pixel", "perler", "bead", "图片", "生成"],
      href: "/tools/image/bead_pixel_art",
      category: "image",
      rating: 4,
      minUserMode: 'normal'
    },
    {
      id: "string_encryptor",
      icon: "🔐",
      title: "字符串加解密工具",
      desc: "支持 Base64、URL、Hex、Unicode、摩斯密码等编码，以及 MD5、SHA、AES、凯撒密码等加解密。",
      keywords: ["string", "字符串", "加密", "解密", "base64", "md5", "sha", "aes", "编码"],
      href: "/tools/text/string_encryptor",
      category: "text",
      rating: 5,
      minUserMode: 'code'
    },
    {
      id: "html_editor",
      icon: "📝",
      title: "HTML 富文本编辑器",
      desc: "支持 HTML 编辑、实时预览和去除 HTML 转义标签功能，提供内联和 iframe 两种预览模式。",
      keywords: ["html", "富文本", "编辑器", "预览", "转义", "unescape", "wysiwyg", "html编辑"],
      href: "/tools/text/html_editor",
      category: "text",
      rating: 5,
      minUserMode: 'code'
    },
    {
      id: "timestamp_converter",
      icon: "⏰",
      title: "时间戳转换工具",
      desc: "支持秒级和毫秒级时间戳与日期时间互转，自动识别时间戳类型。",
      keywords: ["timestamp", "时间戳", "时间", "日期", "转换", "datetime"],
      href: "/tools/converter/timestamp_converter",
      category: "converter",
      rating: 4,
      minUserMode: 'code'
    },
    {
      id: "string_generator",
      icon: "🔤",
      title: "多种字符串生成器",
      desc: "生成标准银行卡号、UDID、包名、UUID、MAC地址、IP地址、邮箱等常用字符串。",
      keywords: ["generator", "生成器", "生成", "uuid", "mac", "ip", "邮箱", "银行卡"],
      href: "/tools/text/string_generator",
      category: "text",
      rating: 3,
      minUserMode: 'code'
    },
    {
      id: "unit_converter",
      icon: "📐",
      title: "单位转换工具",
      desc: "支持长度、重量、温度、面积、体积、时间、速度、数据、角度、压力等多种单位转换，界面美观，分组展示。",
      keywords: ["unit", "单位", "转换", "converter", "长度", "重量", "温度", "面积", "体积", "时间", "速度", "数据", "角度", "压力", "米", "千克", "摄氏度"],
      href: "/tools/converter/unit_converter",
      category: "converter",
      rating: 5,
      minUserMode: 'code'
    },
    {
      id: "currency_converter",
      icon: "💱",
      title: "汇率转换工具",
      desc: "实时汇率查询与转换，支持全球主要货币，包含汇率换算工具和实时汇率列表，支持搜索功能。",
      keywords: ["currency", "汇率", "货币", "转换", "实时", "汇率查询", "人民币", "美元", "欧元", "汇率列表"],
      href: "/tools/converter/currency_converter",
      category: "converter",
      rating: 5,
      minUserMode: 'code'
    },
    {
      id: "ip_query",
      icon: "🌍",
      title: "IP地址查询工具",
      desc: "查询当前IP和输入IP的归属地信息，包括国家、城市、ISP、时区等详细信息。",
      keywords: ["ip", "ip地址", "归属地", "地理位置", "isp", "时区", "查询", "定位"],
      href: "/tools/life/ip_query",
      category: "life",
      rating: 4,
      minUserMode: 'normal'
    },
    {
      id: "speed_test",
      icon: "🚀",
      title: "网络测速工具",
      desc: "测试网络延迟、下载速度和上传速度，类似 Speedtest，实时显示测试进度和结果。",
      keywords: ["网络", "测速", "speedtest", "网速", "延迟", "ping", "下载", "上传", "带宽"],
      href: "/tools/life/speed_test",
      category: "life",
      rating: 5,
      minUserMode: 'normal'
    },
    {
      id: "pomodoro_timer",
      icon: "⏱️",
      title: "专注时钟",
      desc: "番茄工作法计时器，支持专注、短休息、长休息三种模式，帮助提高工作效率。",
      keywords: ["番茄钟", "专注", "计时器", "pomodoro", "工作", "效率", "时间管理", "休息"],
      href: "/tools/life/pomodoro_timer",
      category: "life",
      rating: 5,
      minUserMode: 'normal'
    },
    {
      id: "decision_wheel",
      icon: "🎯",
      title: "决定转盘",
      desc: "添加选项，转动转盘帮你做决定，支持自定义选项列表，让选择变得有趣。",
      keywords: ["决定", "转盘", "选择", "随机", "decision", "wheel", "spinner", "抽签"],
      href: "/tools/life/decision_wheel",
      category: "life",
      rating: 4,
      minUserMode: 'normal'
    },
    {
      id: "mbti_test",
      icon: "🧠",
      title: "MBTI 性格测试",
      desc: "探索您的性格类型，了解您的优势与盲点，只需几分钟，即可获得详细的性格分析报告。",
      keywords: ["mbti", "性格", "测试", "心理", "人格", "分析", "16型人格"],
      href: "/tools/life/mbti_test",
      category: "life",
      rating: 5,
      minUserMode: 'normal'
    },
    {
      id: "sbti_test",
      icon: "🎭",
      title: "SBTI 人格测试",
      desc: "娱乐向十五维度人格测试，含「饮酒」分支题与多种人格海报。仅供娱乐，请勿替代专业心理评估。",
      keywords: ["sbti", "人格", "测试", "性格", "娱乐", "十五维度", "拿捏者"],
      href: "/tools/life/sbti_test",
      category: "life",
      rating: 5,
      minUserMode: 'normal'
    },
    {
      id: "chinese_calendar",
      icon: "📅",
      title: "中国日历",
      desc: "查看农历日期、节气、节日、宜忌和历史上的今天，了解传统文化和重要事件。",
      keywords: ["日历", "农历", "节气", "节日", "宜忌", "历史上的今天", "传统", "农历日期"],
      href: "/tools/life/chinese_calendar",
      category: "life",
      rating: 5,
      minUserMode: 'normal'
    }
  ]
}

// 创建工具 ID 映射表，用于快速查找
export const toolsMap = new Map()
toolsData.tools.forEach(tool => {
  toolsMap.set(tool.id, tool)
})

// 创建工具 href 映射表，用于通过 href 快速查找
export const toolsHrefMap = new Map()
toolsData.tools.forEach(tool => {
  toolsHrefMap.set(tool.href, tool)
})
