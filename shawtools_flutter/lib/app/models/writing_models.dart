/// 写作助手数据模型

/// 书籍模型
class Book {
  final String id;
  String title;
  String author;
  String description;
  DateTime createdAt;
  DateTime updatedAt;
  List<Volume> volumes;
  String outline; // 大纲

  Book({
    required this.id,
    required this.title,
    this.author = '',
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    List<Volume>? volumes,
    this.outline = '',
  }) : volumes = volumes ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'volumes': volumes.map((v) => v.toJson()).toList(),
    'outline': outline,
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'],
    title: json['title'],
    author: json['author'] ?? '',
    description: json['description'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    volumes:
        (json['volumes'] as List?)?.map((v) => Volume.fromJson(v)).toList() ??
        [],
    outline: json['outline'] ?? '',
  );

  // 统计信息
  int get totalChapters =>
      volumes.fold(0, (sum, volume) => sum + volume.chapters.length);

  int get totalWords => volumes.fold(
    0,
    (sum, volume) => sum + volume.chapters.fold(0, (s, c) => s + c.words),
  );
}

/// 卷模型
class Volume {
  final String id;
  String title;
  int order;
  List<Chapter> chapters;

  Volume({
    required this.id,
    required this.title,
    required this.order,
    List<Chapter>? chapters,
  }) : chapters = chapters ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'order': order,
    'chapters': chapters.map((c) => c.toJson()).toList(),
  };

  factory Volume.fromJson(Map<String, dynamic> json) => Volume(
    id: json['id'],
    title: json['title'],
    order: json['order'],
    chapters:
        (json['chapters'] as List?)?.map((c) => Chapter.fromJson(c)).toList() ??
        [],
  );
}

/// 章节模型
class Chapter {
  final String id;
  String title;
  String content;
  int order;
  DateTime createdAt;
  DateTime updatedAt;
  int words;

  Chapter({
    required this.id,
    required this.title,
    this.content = '',
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    this.words = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'order': order,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'words': words,
  };

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
    id: json['id'],
    title: json['title'],
    content: json['content'] ?? '',
    order: json['order'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    words: json['words'] ?? 0,
  );

  // 更新字数
  void updateWords() {
    words = content.trim().length;
  }
}
