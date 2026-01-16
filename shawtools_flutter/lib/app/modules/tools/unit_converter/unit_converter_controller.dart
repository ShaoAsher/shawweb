import 'package:get/get.dart';

enum TemperatureUnit {
  celsius,
  fahrenheit,
  kelvin,
}

class UnitItem {
  final String name;
  final double factor;
  final TemperatureUnit? temperatureUnit;

  const UnitItem({
    required this.name,
    required this.factor,
    this.temperatureUnit,
  });
}

class UnitGroup {
  final String title;
  final List<UnitItem> units;
  final bool isTemperature;

  const UnitGroup({
    required this.title,
    required this.units,
    this.isTemperature = false,
  });
}

class UnitConverterController extends GetxController {
  final List<UnitGroup> groups = [
    UnitGroup(
      title: '长度单位',
      units: [
        UnitItem(name: '米 (m)', factor: 1),
        UnitItem(name: '千米 (km)', factor: 0.001),
        UnitItem(name: '厘米 (cm)', factor: 100),
        UnitItem(name: '毫米 (mm)', factor: 1000),
        UnitItem(name: '微米 (μm)', factor: 1000000),
        UnitItem(name: '纳米 (nm)', factor: 1000000000),
        UnitItem(name: '英寸 (in)', factor: 39.3701),
        UnitItem(name: '英尺 (ft)', factor: 3.28084),
        UnitItem(name: '码 (yd)', factor: 1.09361),
        UnitItem(name: '英里 (mi)', factor: 0.000621371),
        UnitItem(name: '海里 (nmi)', factor: 0.000539957),
        UnitItem(name: '光年 (ly)', factor: 1.057e-16),
      ],
    ),
    UnitGroup(
      title: '重量单位',
      units: [
        UnitItem(name: '千克 (kg)', factor: 1),
        UnitItem(name: '克 (g)', factor: 1000),
        UnitItem(name: '毫克 (mg)', factor: 1000000),
        UnitItem(name: '吨 (t)', factor: 0.001),
        UnitItem(name: '磅 (lb)', factor: 2.20462),
        UnitItem(name: '盎司 (oz)', factor: 35.274),
        UnitItem(name: '英石 (st)', factor: 0.157473),
        UnitItem(name: '克拉 (ct)', factor: 5000),
      ],
    ),
    UnitGroup(
      title: '温度单位',
      units: [
        UnitItem(
          name: '摄氏度 (°C)',
          factor: 1,
          temperatureUnit: TemperatureUnit.celsius,
        ),
        UnitItem(
          name: '华氏度 (°F)',
          factor: 1,
          temperatureUnit: TemperatureUnit.fahrenheit,
        ),
        UnitItem(
          name: '开尔文 (K)',
          factor: 1,
          temperatureUnit: TemperatureUnit.kelvin,
        ),
      ],
      isTemperature: true,
    ),
    UnitGroup(
      title: '面积单位',
      units: [
        UnitItem(name: '平方米 (m²)', factor: 1),
        UnitItem(name: '平方千米 (km²)', factor: 0.000001),
        UnitItem(name: '公顷 (ha)', factor: 0.0001),
        UnitItem(name: '平方厘米 (cm²)', factor: 10000),
        UnitItem(name: '平方毫米 (mm²)', factor: 1000000),
        UnitItem(name: '平方英寸 (in²)', factor: 1550.0031),
        UnitItem(name: '平方英尺 (ft²)', factor: 10.7639),
        UnitItem(name: '平方码 (yd²)', factor: 1.19599),
        UnitItem(name: '英亩 (acre)', factor: 0.000247105),
        UnitItem(name: '平方英里 (mi²)', factor: 3.861e-7),
      ],
    ),
    UnitGroup(
      title: '体积单位',
      units: [
        UnitItem(name: '升 (L)', factor: 1),
        UnitItem(name: '毫升 (mL)', factor: 1000),
        UnitItem(name: '立方米 (m³)', factor: 0.001),
        UnitItem(name: '立方厘米 (cm³)', factor: 1000),
        UnitItem(name: '立方英寸 (in³)', factor: 61.0237),
        UnitItem(name: '立方英尺 (ft³)', factor: 0.0353147),
        UnitItem(name: '加仑 (gal)', factor: 0.264172),
        UnitItem(name: '美制加仑 (US gal)', factor: 0.264172),
        UnitItem(name: '英制加仑 (UK gal)', factor: 0.219969),
        UnitItem(name: '品脱 (pt)', factor: 2.11338),
        UnitItem(name: '夸脱 (qt)', factor: 1.05669),
        UnitItem(name: '液盎司 (fl oz)', factor: 33.814),
      ],
    ),
    UnitGroup(
      title: '时间单位',
      units: [
        UnitItem(name: '秒 (s)', factor: 1),
        UnitItem(name: '毫秒 (ms)', factor: 1000),
        UnitItem(name: '微秒 (μs)', factor: 1000000),
        UnitItem(name: '纳秒 (ns)', factor: 1000000000),
        UnitItem(name: '分钟 (min)', factor: 1 / 60),
        UnitItem(name: '小时 (h)', factor: 1 / 3600),
        UnitItem(name: '天 (d)', factor: 1 / 86400),
        UnitItem(name: '周 (week)', factor: 1 / 604800),
        UnitItem(name: '月 (month)', factor: 1 / 2592000),
        UnitItem(name: '年 (year)', factor: 1 / 31536000),
      ],
    ),
    UnitGroup(
      title: '速度单位',
      units: [
        UnitItem(name: '米/秒 (m/s)', factor: 1),
        UnitItem(name: '千米/小时 (km/h)', factor: 3.6),
        UnitItem(name: '英里/小时 (mph)', factor: 2.23694),
        UnitItem(name: '节 (kn)', factor: 1.94384),
        UnitItem(name: '英尺/秒 (ft/s)', factor: 3.28084),
        UnitItem(name: '光速 (c)', factor: 3.33564e-9),
      ],
    ),
    UnitGroup(
      title: '数据单位',
      units: [
        UnitItem(name: '字节 (B)', factor: 1),
        UnitItem(name: '千字节 (KB)', factor: 1 / 1024),
        UnitItem(name: '兆字节 (MB)', factor: 1 / 1048576),
        UnitItem(name: '吉字节 (GB)', factor: 1 / 1073741824),
        UnitItem(name: '太字节 (TB)', factor: 1 / 1099511627776),
        UnitItem(name: '拍字节 (PB)', factor: 1 / 1125899906842624),
        UnitItem(name: '位 (bit)', factor: 8),
      ],
    ),
    UnitGroup(
      title: '角度单位',
      units: [
        UnitItem(name: '度 (°)', factor: 1),
        UnitItem(name: '弧度 (rad)', factor: 3.141592653589793 / 180),
        UnitItem(name: '梯度 (grad)', factor: 200 / 180),
        UnitItem(name: '转 (rev)', factor: 1 / 360),
      ],
    ),
    UnitGroup(
      title: '压力单位',
      units: [
        UnitItem(name: '帕斯卡 (Pa)', factor: 1),
        UnitItem(name: '千帕 (kPa)', factor: 0.001),
        UnitItem(name: '兆帕 (MPa)', factor: 0.000001),
        UnitItem(name: '巴 (bar)', factor: 0.00001),
        UnitItem(name: '大气压 (atm)', factor: 9.86923e-6),
        UnitItem(name: 'PSI (psi)', factor: 0.000145038),
        UnitItem(name: '毫米汞柱 (mmHg)', factor: 0.00750062),
        UnitItem(name: '托 (Torr)', factor: 0.00750062),
      ],
    ),
  ];

  String convertTemperature(
    double value,
    TemperatureUnit from,
    TemperatureUnit to,
  ) {
    double celsius;
    if (from == TemperatureUnit.celsius) {
      celsius = value;
    } else if (from == TemperatureUnit.fahrenheit) {
      celsius = (value - 32) * 5 / 9;
    } else {
      celsius = value - 273.15;
    }

    double result;
    if (to == TemperatureUnit.celsius) {
      result = celsius;
    } else if (to == TemperatureUnit.fahrenheit) {
      result = celsius * 9 / 5 + 32;
    } else {
      result = celsius + 273.15;
    }

    return result.toStringAsFixed(2);
  }

  String formatResult(double result) {
    final abs = result.abs();
    if (abs < 0.000001 && abs > 0) {
      return result.toStringAsExponential(6);
    } else if (abs < 1) {
      return result
          .toStringAsFixed(8)
          .replaceFirst(RegExp(r'\.?0+$'), '');
    } else if (abs < 1000000) {
      return result
          .toStringAsFixed(6)
          .replaceFirst(RegExp(r'\.?0+$'), '');
    } else {
      return result.toStringAsExponential(6);
    }
  }
}

