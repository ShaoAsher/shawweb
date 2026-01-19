part of 'app_pages.dart';

/// 应用路由配置
abstract class Routes {
  /// 首页
  static const home = '/home';

  // ==================== 工具路由 ====================

  /// JSON 格式化工具
  static const json = '/tools/json';

  /// JSON 转 Model 工具
  static const jsonModel = '/tools/json-model';

  /// 设备预览工具
  static const device = '/tools/device';

  /// 图片压缩工具
  static const imageCompress = '/tools/image-compress';

  /// 文字转图片工具
  static const textImage = '/tools/text-image';

  /// 二维码生成工具
  static const qrcode = '/tools/qrcode';

  /// 颜色转换工具
  static const color = '/tools/color';

  /// 字符串加密工具
  static const stringEncrypt = '/tools/string-encrypt';

  /// 时间戳转换工具
  static const timestamp = '/tools/timestamp';

  /// 字符串生成工具
  static const stringGen = '/tools/string-gen';

  /// 单位转换工具
  static const unit = '/tools/unit';

  /// 货币转换工具
  static const currency = '/tools/currency';

  /// IP 查询工具
  static const ip = '/tools/ip';

  /// 网速测试工具
  static const speed = '/tools/speed';

  // ==================== 写作助手 ====================

  /// 写作助手 - 书架首页
  static const writing = '/tools/writing';

  /// 写作助手 - 书籍详情（带参数）
  static const writingBookDetail = '/tools/writing/book/:bookId';

  /// 写作助手 - 章节编辑器
  static const writingChapterEditor = '/tools/writing/chapter';
}
