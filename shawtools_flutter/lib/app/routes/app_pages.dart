import 'package:get/get.dart';

import '../modules/home/home_binding.dart';
import '../modules/home/home_page.dart';
import '../modules/tools/color_converter/color_converter_binding.dart';
import '../modules/tools/color_converter/color_converter_page.dart';
import '../modules/tools/currency_converter/currency_converter_binding.dart';
import '../modules/tools/currency_converter/currency_converter_page.dart';
import '../modules/tools/device_preview/device_preview_binding.dart';
import '../modules/tools/device_preview/device_preview_page.dart';
import '../modules/tools/image_compressor/image_compressor_binding.dart';
import '../modules/tools/image_compressor/image_compressor_page.dart';
import '../modules/tools/ip_query/ip_query_binding.dart';
import '../modules/tools/ip_query/ip_query_page.dart';
import '../modules/tools/json_formatter/json_formatter_binding.dart';
import '../modules/tools/json_formatter/json_formatter_page.dart';
import '../modules/tools/json_to_model/json_to_model_binding.dart';
import '../modules/tools/json_to_model/json_to_model_page.dart';
import '../modules/tools/qrcode_generator/qrcode_generator_binding.dart';
import '../modules/tools/qrcode_generator/qrcode_generator_page.dart';
import '../modules/tools/speed_test/speed_test_binding.dart';
import '../modules/tools/speed_test/speed_test_page.dart';
import '../modules/tools/string_encryptor/string_encryptor_binding.dart';
import '../modules/tools/string_encryptor/string_encryptor_page.dart';
import '../modules/tools/string_generator/string_generator_binding.dart';
import '../modules/tools/string_generator/string_generator_page.dart';
import '../modules/tools/text_image_generator/text_image_generator_binding.dart';
import '../modules/tools/text_image_generator/text_image_generator_page.dart';
import '../modules/tools/timestamp_converter/timestamp_converter_binding.dart';
import '../modules/tools/timestamp_converter/timestamp_converter_page.dart';
import '../modules/tools/unit_converter/unit_converter_binding.dart';
import '../modules/tools/unit_converter/unit_converter_page.dart';
import '../modules/tools/writing_assistant/chapter_editor/chapter_editor_binding.dart';
import '../modules/tools/writing_assistant/chapter_editor/chapter_editor_page.dart';
import '../modules/tools/writing_assistant/writing_assistant_binding.dart';
import '../modules/tools/writing_assistant/writing_assistant_page.dart';

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
      name: Routes.json,
      page: () => const JsonFormatterPage(),
      binding: JsonFormatterBinding(),
    ),
    GetPage(
      name: Routes.jsonModel,
      page: () => const JsonToModelPage(),
      binding: JsonToModelBinding(),
    ),
    // 图片工具
    GetPage(
      name: Routes.imageCompress,
      page: () => const ImageCompressorPage(),
      binding: ImageCompressorBinding(),
    ),
    GetPage(
      name: Routes.textImage,
      page: () => const TextImageGeneratorPage(),
      binding: TextImageGeneratorBinding(),
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
      name: Routes.stringGen,
      page: () => const StringGeneratorPage(),
      binding: StringGeneratorBinding(),
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
      page: () => const SpeedTestPage(),
      binding: SpeedTestBinding(),
    ),
    GetPage(
      name: Routes.device,
      page: () => const DevicePreviewPage(),
      binding: DevicePreviewBinding(),
    ),
    GetPage(
      name: Routes.writing,
      page: () => const WritingAssistantPage(),
      binding: WritingAssistantBinding(),
    ),
    GetPage(
      name: Routes.writingChapterEditor,
      page: () => const ChapterEditorPage(),
      binding: ChapterEditorBinding(),
    ),
  ];
}
