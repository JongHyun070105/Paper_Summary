class PaperModel {
  final String id;
  final String title;
  final String content;
  final String? filePath;
  final String? url;
  final DateTime uploadedAt;
  final String userId;
  final List<String> authors;
  final String? abstract;
  final int pageCount;

  PaperModel({
    required this.id,
    required this.title,
    required this.content,
    this.filePath,
    this.url,
    required this.uploadedAt,
    required this.userId,
    this.authors = const [],
    this.abstract,
    this.pageCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'filePath': filePath,
      'url': url,
      'uploadedAt': uploadedAt.toIso8601String(),
      'userId': userId,
      'authors': authors,
      'abstract': abstract,
      'pageCount': pageCount,
    };
  }

  factory PaperModel.fromJson(Map<String, dynamic> json) {
    return PaperModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      filePath: json['filePath'],
      url: json['url'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      userId: json['userId'],
      authors: List<String>.from(json['authors'] ?? []),
      abstract: json['abstract'],
      pageCount: json['pageCount'] ?? 0,
    );
  }
}
