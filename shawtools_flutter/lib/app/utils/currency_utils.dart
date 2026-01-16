/// 货币工具类
/// 提供货币相关的工具方法，方便其他模块使用
library currency_utils;

import '../data/currency_data.dart';

/// 货币工具类
///
/// 提供货币代码、名称、图标等信息的查询和转换功能
/// 可在任何需要货币信息的模块中使用
class CurrencyUtils {
  /// 获取货币图标（国旗 emoji）
  ///
  /// [code] 货币代码，如 'USD', 'CNY'
  /// 返回对应的国旗 emoji，如果不存在则返回默认图标 💱
  static String getFlag(String code) {
    return CurrencyData.flags[code.toUpperCase()] ?? '💱';
  }

  /// 获取货币中文名称
  ///
  /// [code] 货币代码，如 'USD', 'CNY'
  /// 返回对应的中文名称，如果不存在则返回货币代码本身
  static String getName(String code) {
    return CurrencyData.namesZh[code.toUpperCase()] ?? code;
  }

  /// 检查货币代码是否存在
  ///
  /// [code] 货币代码
  /// 返回 true 如果该货币代码存在于数据中
  static bool isValidCode(String code) {
    return CurrencyData.namesZh.containsKey(code.toUpperCase());
  }

  /// 获取所有可用的货币代码列表
  ///
  /// 返回所有已定义的货币代码列表，按字母顺序排序
  static List<String> getAllCodes() {
    return CurrencyData.namesZh.keys.toList()..sort();
  }

  /// 根据搜索关键词过滤货币
  ///
  /// [query] 搜索关键词，可以匹配货币代码或名称
  /// 返回匹配的货币代码列表
  static List<String> searchCurrencies(String query) {
    if (query.isEmpty) {
      return getAllCodes();
    }
    final lowerQuery = query.toLowerCase();
    return CurrencyData.namesZh.entries
        .where((entry) {
          final code = entry.key.toLowerCase();
          final name = entry.value.toLowerCase();
          return code.contains(lowerQuery) || name.contains(lowerQuery);
        })
        .map((entry) => entry.key)
        .toList()
      ..sort();
  }

  /// 获取货币的完整信息
  ///
  /// [code] 货币代码
  /// 返回包含代码、图标、名称的 Map
  static Map<String, String> getCurrencyInfo(String code) {
    final upperCode = code.toUpperCase();
    return {
      'code': upperCode,
      'flag': getFlag(upperCode),
      'name': getName(upperCode),
    };
  }

  /// 获取所有货币的元数据列表
  ///
  /// 返回所有货币的 CurrencyMeta 列表
  static List<CurrencyMeta> getAllCurrencies() {
    return CurrencyData.buildAll();
  }
}
