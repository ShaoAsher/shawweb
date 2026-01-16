import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/toast_utils.dart';

class ColorPreset {
  final String name;
  final String hex;

  const ColorPreset({
    required this.name,
    required this.hex,
  });
}

class ColorPresetGroup {
  final String title;
  final List<ColorPreset> colors;

  const ColorPresetGroup({
    required this.title,
    required this.colors,
  });
}

class HslColorValue {
  final int h;
  final int s;
  final int l;

  const HslColorValue(this.h, this.s, this.l);
}

class ColorConverterController extends GetxController {
  final hexController = TextEditingController(text: '#667EEA');
  final rController = TextEditingController(text: '102');
  final gController = TextEditingController(text: '126');
  final bController = TextEditingController(text: '234');

  final previewColor = const Color(0xFF667EEA).obs;
  final resultText = ''.obs;

  final List<ColorPresetGroup> presetGroups = const [
    ColorPresetGroup(
      title: '基础颜色',
      colors: [
        ColorPreset(name: '红色', hex: '#FF0000'),
        ColorPreset(name: '绿色', hex: '#00FF00'),
        ColorPreset(name: '蓝色', hex: '#0000FF'),
        ColorPreset(name: '黄色', hex: '#FFFF00'),
        ColorPreset(name: '紫色', hex: '#800080'),
        ColorPreset(name: '青色', hex: '#00FFFF'),
        ColorPreset(name: '橙色', hex: '#FFA500'),
        ColorPreset(name: '粉色', hex: '#FFC0CB'),
        ColorPreset(name: '黑色', hex: '#000000'),
        ColorPreset(name: '白色', hex: '#FFFFFF'),
        ColorPreset(name: '灰色', hex: '#808080'),
      ],
    ),
    ColorPresetGroup(
      title: '主流 App 颜色',
      colors: [
        ColorPreset(name: '微信绿', hex: '#07C160'),
        ColorPreset(name: '支付宝蓝', hex: '#1677FF'),
        ColorPreset(name: '抖音红', hex: '#FF0050'),
        ColorPreset(name: '微博橙', hex: '#FF6600'),
        ColorPreset(name: 'QQ蓝', hex: '#12B7F5'),
        ColorPreset(name: '淘宝橙', hex: '#FF5000'),
        ColorPreset(name: '京东红', hex: '#E1251B'),
        ColorPreset(name: '美团黄', hex: '#FFC300'),
        ColorPreset(name: '饿了么蓝', hex: '#0096FF'),
        ColorPreset(name: '小红书红', hex: '#FF2442'),
        ColorPreset(name: 'B站粉', hex: '#FB7299'),
        ColorPreset(name: '知乎蓝', hex: '#0084FF'),
        ColorPreset(name: '豆瓣绿', hex: '#42BD56'),
        ColorPreset(name: '网易云红', hex: '#E83C3C'),
        ColorPreset(name: 'QQ音乐绿', hex: '#31C27C'),
        ColorPreset(name: '酷狗蓝', hex: '#00A0E9'),
        ColorPreset(name: '爱奇艺粉', hex: '#FF6B9D'),
        ColorPreset(name: '腾讯视频蓝', hex: '#002FA7'),
        ColorPreset(name: '优酷蓝', hex: '#00A8E6'),
        ColorPreset(name: '百度红', hex: '#2932E1'),
        ColorPreset(name: '高德蓝', hex: '#0091FF'),
        ColorPreset(name: '滴滴橙', hex: '#FF6600'),
        ColorPreset(name: '携程蓝', hex: '#1BA9BA'),
        ColorPreset(name: '飞猪橙', hex: '#FF6A00'),
      ],
    ),
    ColorPresetGroup(
      title: '国际品牌色',
      colors: [
        ColorPreset(name: '苹果黑', hex: '#000000'),
        ColorPreset(name: '苹果灰', hex: '#86868B'),
        ColorPreset(name: '谷歌蓝', hex: '#4285F4'),
        ColorPreset(name: '谷歌红', hex: '#EA4335'),
        ColorPreset(name: '谷歌黄', hex: '#FBBC05'),
        ColorPreset(name: '谷歌绿', hex: '#34A853'),
        ColorPreset(name: 'Facebook蓝', hex: '#1877F2'),
        ColorPreset(name: 'Twitter蓝', hex: '#1DA1F2'),
        ColorPreset(name: 'Instagram紫', hex: '#E4405F'),
        ColorPreset(name: 'YouTube红', hex: '#FF0000'),
        ColorPreset(name: 'LinkedIn蓝', hex: '#0077B5'),
        ColorPreset(name: 'GitHub黑', hex: '#24292E'),
        ColorPreset(name: 'GitHub紫', hex: '#6F42C1'),
        ColorPreset(name: 'Spotify绿', hex: '#1DB954'),
        ColorPreset(name: 'Netflix红', hex: '#E50914'),
        ColorPreset(name: 'Amazon橙', hex: '#FF9900'),
        ColorPreset(name: 'Microsoft蓝', hex: '#0078D4'),
        ColorPreset(name: 'Adobe红', hex: '#FF0000'),
        ColorPreset(name: 'PayPal蓝', hex: '#003087'),
        ColorPreset(name: 'Stripe蓝', hex: '#635BFF'),
        ColorPreset(name: 'Airbnb红', hex: '#FF5A5F'),
        ColorPreset(name: 'Uber黑', hex: '#000000'),
        ColorPreset(name: 'Tesla红', hex: '#E31937'),
        ColorPreset(name: 'Coca-Cola红', hex: '#F40009'),
        ColorPreset(name: 'Pepsi蓝', hex: '#004B93'),
        ColorPreset(name: 'Starbucks绿', hex: '#00704A'),
        ColorPreset(name: 'McDonald\'s金', hex: '#FFC72C'),
        ColorPreset(name: 'McDonald\'s红', hex: '#DA291C'),
      ],
    ),
    ColorPresetGroup(
      title: '其他常用颜色',
      colors: [
        ColorPreset(name: '深红', hex: '#8B0000'),
        ColorPreset(name: '深绿', hex: '#006400'),
        ColorPreset(name: '深蓝', hex: '#00008B'),
        ColorPreset(name: '浅蓝', hex: '#87CEEB'),
        ColorPreset(name: '浅绿', hex: '#90EE90'),
        ColorPreset(name: '浅红', hex: '#FFB6C1'),
        ColorPreset(name: '金色', hex: '#FFD700'),
        ColorPreset(name: '银色', hex: '#C0C0C0'),
        ColorPreset(name: '棕色', hex: '#A52A2A'),
        ColorPreset(name: '橄榄色', hex: '#808000'),
        ColorPreset(name: '海军蓝', hex: '#000080'),
        ColorPreset(name: '青绿色', hex: '#40E0D0'),
        ColorPreset(name: '珊瑚色', hex: '#FF7F50'),
        ColorPreset(name: '番茄色', hex: '#FF6347'),
        ColorPreset(name: '紫罗兰', hex: '#8A2BE2'),
        ColorPreset(name: '深紫色', hex: '#4B0082'),
        ColorPreset(name: '深粉色', hex: '#FF1493'),
        ColorPreset(name: '薄荷绿', hex: '#00CED1'),
      ],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    convert();
  }

  @override
  void onClose() {
    hexController.dispose();
    rController.dispose();
    gController.dispose();
    bController.dispose();
    super.onClose();
  }

  void convertFromHex() {
    final hex = hexController.text.trim();
    if (hex.isEmpty) {
      return;
    }
    try {
      final rgb = _hexToRgb(hex);
      rController.text = rgb.$1.toString();
      gController.text = rgb.$2.toString();
      bController.text = rgb.$3.toString();
      _updatePreviewAndResult(rgb.$1, rgb.$2, rgb.$3);
    } catch (_) {
      ToastUtils.showError('请输入正确的 HEX 颜色值，例如 #FF5733 或 FF5733');
    }
  }

  void convertFromRgb() {
    int r = int.tryParse(rController.text) ?? 0;
    int g = int.tryParse(gController.text) ?? 0;
    int b = int.tryParse(bController.text) ?? 0;
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);
    rController.text = r.toString();
    gController.text = g.toString();
    bController.text = b.toString();
    hexController.text = _rgbToHex(r, g, b);
    _updatePreviewAndResult(r, g, b);
  }

  void convert() {
    if (hexController.text.trim().isNotEmpty) {
      convertFromHex();
    } else {
      convertFromRgb();
    }
  }

  void clear() {
    hexController.text = '';
    rController.text = '0';
    gController.text = '0';
    bController.text = '0';
    previewColor.value = Colors.grey.shade200;
    resultText.value = '';
  }

  void applyPreset(ColorPreset preset) {
    hexController.text = preset.hex;
    convertFromHex();
  }

  (int, int, int) _hexToRgb(String hex) {
    var value = hex.replaceFirst('#', '');
    if (value.length == 3) {
      value = value.split('').map((c) => '$c$c').join();
    }
    if (value.length != 6) {
      throw const FormatException();
    }
    final r = int.parse(value.substring(0, 2), radix: 16);
    final g = int.parse(value.substring(2, 4), radix: 16);
    final b = int.parse(value.substring(4, 6), radix: 16);
    return (r, g, b);
  }

  String _rgbToHex(int r, int g, int b) {
    String toHex(int x) {
      final hex = x.toRadixString(16).toUpperCase();
      return hex.length == 1 ? '0$hex' : hex;
    }

    return '#${toHex(r)}${toHex(g)}${toHex(b)}';
  }

  HslColorValue _rgbToHsl(int r, int g, int b) {
    double rd = r / 255;
    double gd = g / 255;
    double bd = b / 255;
    final max = [rd, gd, bd].reduce((a, b) => a > b ? a : b);
    final min = [rd, gd, bd].reduce((a, b) => a < b ? a : b);
    double h = 0;
    final l = (max + min) / 2;
    double s;
    if (max == min) {
      s = 0;
      h = 0;
    } else {
      final d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      if (max == rd) {
        h = ((gd - bd) / d + (gd < bd ? 6 : 0)) / 6;
      } else if (max == gd) {
        h = ((bd - rd) / d + 2) / 6;
      } else {
        h = ((rd - gd) / d + 4) / 6;
      }
    }
    return HslColorValue(
      (h * 360).round(),
      (s * 100).round(),
      (l * 100).round(),
    );
  }

  void _updatePreviewAndResult(int r, int g, int b) {
    final hex = _rgbToHex(r, g, b);
    final hsl = _rgbToHsl(r, g, b);
    previewColor.value = Color.fromARGB(255, r, g, b);
    resultText.value = [
      'HEX: $hex',
      'RGB: rgb($r, $g, $b)',
      'RGBA: rgba($r, $g, $b, 1)',
      'HSL: hsl(${hsl.h}, ${hsl.s}%, ${hsl.l}%)',
      'HSLA: hsla(${hsl.h}, ${hsl.s}%, ${hsl.l}%, 1)',
    ].join('\n');
  }
}

