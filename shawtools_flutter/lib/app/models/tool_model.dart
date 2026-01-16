class ToolModel {
  final String icon;
  final String titleZh;
  final String titleEn;
  final String descZh;
  final String descEn;
  final List<String> keywordsZh;
  final List<String> keywordsEn;
  final String route;
  final String category;
  final int rating;

  ToolModel({
    required this.icon,
    required this.titleZh,
    required this.titleEn,
    required this.descZh,
    required this.descEn,
    required this.keywordsZh,
    required this.keywordsEn,
    required this.route,
    required this.category,
    required this.rating,
  });

  String getTitle(String lang) => lang == 'en' ? titleEn : titleZh;
  String getDesc(String lang) => lang == 'en' ? descEn : descZh;
  List<String> getKeywords(String lang) =>
      lang == 'en' ? keywordsEn : keywordsZh;
}

class ToolCategory {
  final String key;
  final String nameZh;
  final String nameEn;

  ToolCategory({required this.key, required this.nameZh, required this.nameEn});

  String getName(String lang) => lang == 'en' ? nameEn : nameZh;
}
