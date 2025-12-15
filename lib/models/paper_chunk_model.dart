import 'package:flutter_paper_summary/models/paper_model.dart';

class PaperChunkModel {
  final String id;
  final String paperId;
  final int index;
  final String section;
  final String originalContent; // 원본 텍스트
  final String? translatedContent; // 번역된 텍스트
  final String language; // 원본 언어 (en, ko 등)
  final int startChar;
  final int endChar;
  final DateTime createdAt;
  final DateTime? translatedAt; // 번역된 시간

  PaperChunkModel({
    required this.id,
    required this.paperId,
    required this.index,
    required this.section,
    required this.originalContent,
    this.translatedContent,
    this.language = 'en',
    required this.startChar,
    required this.endChar,
    required this.createdAt,
    this.translatedAt,
  });

  // 번역 여부 확인
  bool get isTranslated => translatedContent != null;

  // 현재 표시할 콘텐츠 (번역 모드에 따라)
  String getContent(bool showTranslation) {
    if (showTranslation && translatedContent != null) {
      return translatedContent!;
    }
    return originalContent;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paperId': paperId,
      'index': index,
      'section': section,
      'originalContent': originalContent,
      'translatedContent': translatedContent,
      'language': language,
      'startChar': startChar,
      'endChar': endChar,
      'createdAt': createdAt.toIso8601String(),
      'translatedAt': translatedAt?.toIso8601String(),
    };
  }

  factory PaperChunkModel.fromJson(Map<String, dynamic> json) {
    return PaperChunkModel(
      id: json['id'],
      paperId: json['paperId'],
      index: json['index'],
      section: json['section'],
      originalContent: json['originalContent'],
      translatedContent: json['translatedContent'],
      language: json['language'] ?? 'en',
      startChar: json['startChar'],
      endChar: json['endChar'],
      createdAt: DateTime.parse(json['createdAt']),
      translatedAt: json['translatedAt'] != null
          ? DateTime.parse(json['translatedAt'])
          : null,
    );
  }
}

class PaperWithChunks {
  final PaperModel paper;
  final List<PaperChunkModel> chunks;

  PaperWithChunks({required this.paper, required this.chunks});

  /// 특정 섹션의 청크들만 가져오기
  List<PaperChunkModel> getChunksBySection(String section) {
    return chunks.where((chunk) => chunk.section == section).toList();
  }

  /// 페이지네이션을 위한 청크 가져오기
  List<PaperChunkModel> getChunksPaginated(int page, int pageSize) {
    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, chunks.length);

    if (startIndex >= chunks.length) return [];

    return chunks.sublist(startIndex, endIndex);
  }

  /// 전체 텍스트 재구성 (필요시)
  String getFullContent({bool showTranslation = false}) {
    return chunks
        .map((chunk) => chunk.getContent(showTranslation))
        .join('\n\n');
  }

  /// 특정 범위의 텍스트 가져오기
  String getContentRange(
    int startChar,
    int endChar, {
    bool showTranslation = false,
  }) {
    final relevantChunks = chunks
        .where(
          (chunk) => chunk.startChar <= endChar && chunk.endChar >= startChar,
        )
        .toList();

    return relevantChunks
        .map((chunk) => chunk.getContent(showTranslation))
        .join(' ');
  }
}
