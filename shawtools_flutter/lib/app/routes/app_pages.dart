import 'package:get/get.dart';

import '../modules/home/home_binding.dart';
import '../modules/home/home_page.dart';
import '../modules/tools/color_converter/color_converter_binding.dart';
import '../modules/tools/color_converter/color_converter_page.dart';
import '../modules/tools/currency_converter/currency_converter_binding.dart';
import '../modules/tools/currency_converter/currency_converter_page.dart';
import '../modules/tools/ip_query/ip_query_binding.dart';
import '../modules/tools/ip_query/ip_query_page.dart';
import '../modules/tools/json_formatter/json_formatter_binding.dart';
import '../modules/tools/json_formatter/json_formatter_page.dart';
import '../modules/tools/placeholder_tool_page.dart';
import '../modules/tools/qrcode_generator/qrcode_generator_binding.dart';
import '../modules/tools/qrcode_generator/qrcode_generator_page.dart';
import '../modules/tools/string_encryptor/string_encryptor_binding.dart';
import '../modules/tools/string_encryptor/string_encryptor_page.dart';
import '../modules/tools/string_generator/string_generator_binding.dart';
import '../modules/tools/string_generator/string_generator_page.dart';
import '../modules/tools/timestamp_converter/timestamp_converter_binding.dart';
import '../modules/tools/timestamp_converter/timestamp_converter_page.dart';
import '../modules/tools/unit_converter/unit_converter_binding.dart';
import '../modules/tools/unit_converter/unit_converter_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    // 开发工具
    GetPage(
      name: Routes.keystore,
      page: () => const PlaceholderToolPage(
        title: 'Android 签名文件生成工具',
        titleEn: 'Android Keystore Generator',
      ),
    ),
    GetPage(
      name: Routes.apk,
      page: () => const PlaceholderToolPage(
        title: 'APK 信息提取工具',
        titleEn: 'APK Analyzer',
      ),
    ),
    GetPage(
      name: Routes.api,
      page: () =>
          const PlaceholderToolPage(title: 'API 调试工具', titleEn: 'API Debugger'),
    ),
    GetPage(
      name: Routes.json,
      page: () => const JsonFormatterPage(),
      binding: JsonFormatterBinding(),
    ),
    GetPage(
      name: Routes.jsonModel,
      page: () => const PlaceholderToolPage(
        title: 'JSON 转 Model',
        titleEn: 'JSON to Model',
      ),
    ),
    GetPage(
      name: Routes.device,
      page: () =>
          const PlaceholderToolPage(title: '设备预览', titleEn: 'Device Preview'),
    ),
    // 图片工具
    GetPage(
      name: Routes.imageCompress,
      page: () =>
          const PlaceholderToolPage(title: '图片压缩', titleEn: 'Image Compressor'),
    ),
    GetPage(
      name: Routes.launchImage,
      page: () => const PlaceholderToolPage(
        title: '启动图生成',
        titleEn: 'Launch Image Generator',
      ),
    ),
    GetPage(
      name: Routes.iconFactory,
      page: () =>
          const PlaceholderToolPage(title: '图标工厂', titleEn: 'Icon Factory'),
    ),
    GetPage(
      name: Routes.svg,
      page: () =>
          const PlaceholderToolPage(title: 'SVG 转换', titleEn: 'SVG Converter'),
    ),
    GetPage(
      name: Routes.textImage,
      page: () => const PlaceholderToolPage(
        title: '文字图片生成',
        titleEn: 'Text Image Generator',
      ),
    ),
    GetPage(
      name: Routes.qrcode,
      page: () => const QrcodeGeneratorPage(),
      binding: QrcodeGeneratorBinding(),
    ),
    GetPage(
      name: Routes.color,
      page: () => const ColorConverterPage(),
      binding: ColorConverterBinding(),
    ),
    // 文本工具
    GetPage(
      name: Routes.stringEncrypt,
      page: () => const StringEncryptorPage(),
      binding: StringEncryptorBinding(),
    ),
    GetPage(
      name: Routes.markdown,
      page: () => const PlaceholderToolPage(
        title: 'Markdown 编辑器',
        titleEn: 'Markdown Editor',
      ),
    ),
    GetPage(
      name: Routes.stringGen,
      page: () => const StringGeneratorPage(),
      binding: StringGeneratorBinding(),
    ),
    GetPage(
      name: Routes.writing,
      page: () => const PlaceholderToolPage(
        title: '写作助手',
        titleEn: 'Writing Assistant',
      ),
    ),
    // 转换工具
    GetPage(
      name: Routes.timestamp,
      page: () => const TimestampConverterPage(),
      binding: TimestampConverterBinding(),
    ),
    GetPage(
      name: Routes.unit,
      page: () => const UnitConverterPage(),
      binding: UnitConverterBinding(),
    ),
    GetPage(
      name: Routes.currency,
      page: () => const CurrencyConverterPage(),
      binding: CurrencyConverterBinding(),
    ),
    // 生活工具
    GetPage(
      name: Routes.ip,
      page: () => const IpQueryPage(),
      binding: IpQueryBinding(),
    ),
    GetPage(
      name: Routes.speed,
      page: () => const PlaceholderToolPage(
        title: '网络测速',
        titleEn: 'Network Speed Test',
      ),
    ),
  ];
}
