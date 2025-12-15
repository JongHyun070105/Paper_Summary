import 'dart:math';

class PaperChunkService {
  static const int maxChunkSize = 2000; // 문자 수 기준
  static const int overlapSize = 200; // 청크 간 중복 문자 수

  /// 논문 텍스트를 의미 단위 청크로 분할
  static List<Map<String, dynamic>> splitIntoChunks(String fullText) {
    final chunks = <Map<String, dynamic>>[];

    // 1. 섹션별로 먼저 분할 (Abstract, Introduction, Methods 등)
    final sections = _splitBySections(fullText);

    int chunkIndex = 0;
    for (final section in sections) {
      final sectionChunks = _splitSectionIntoChunks(
        section['content'] as String,
        section['title'] as String,
        chunkIndex,
      );
      chunks.addAll(sectionChunks);
      chunkIndex += sectionChunks.length;
    }

    return chunks;
  }

  /// 섹션별로 텍스트 분할
  static List<Map<String, String>> _splitBySections(String text) {
    final sections = <Map<String, String>>[];

    // 일반적인 논문 섹션 패턴
    final sectionPatterns = [
      RegExp(r'\n\s*(Abstract|초록)\s*\n', caseSensitive: false),
      RegExp(r'\n\s*(\d+\.?\s*)?(Introduction|서론)\s*\n', caseSensitive: false),
      RegExp(r'\n\s*(\d+\.?\s*)?(Methods?|방법론?)\s*\n', caseSensitive: false),
      RegExp(r'\n\s*(\d+\.?\s*)?(Results?|결과)\s*\n', caseSensitive: false),
      RegExp(r'\n\s*(\d+\.?\s*)?(Discussion|토론)\s*\n', caseSensitive: false),
      RegExp(r'\n\s*(\d+\.?\s*)?(Conclusion|결론)\s*\n', caseSensitive: false),
      RegExp(r'\n\s*(\d+\.?\s*)?(References?|참고문헌)\s*\n', caseSensitive: false),
    ];

    int lastIndex = 0;
    String currentTitle = 'Introduction';

    for (final pattern in sectionPatterns) {
      final match = pattern.firstMatch(text.substring(lastIndex));
      if (match != null) {
        final matchIndex = lastIndex + match.start;

        // 이전 섹션 추가
        if (lastIndex < matchIndex) {
          sections.add({
            'title': currentTitle,
            'content': text.substring(lastIndex, matchIndex).trim(),
          });
        }

        currentTitle = match.group(0)?.trim() ?? 'Unknown';
        lastIndex = matchIndex;
      }
    }

    // 마지막 섹션 추가
    if (lastIndex < text.length) {
      sections.add({
        'title': currentTitle,
        'content': text.substring(lastIndex).trim(),
      });
    }

    return sections;
  }

  /// 섹션을 적절한 크기의 청크로 분할
  static List<Map<String, dynamic>> _splitSectionIntoChunks(
    String sectionText,
    String sectionTitle,
    int startIndex,
  ) {
    final chunks = <Map<String, dynamic>>[];

    if (sectionText.length <= maxChunkSize) {
      // 섹션이 충분히 작으면 그대로 사용
      chunks.add({
        'index': startIndex,
        'section': sectionTitle,
        'content': sectionText,
        'startChar': 0,
        'endChar': sectionText.length,
      });
      return chunks;
    }

    // 문장 단위로 분할
    final sentences = _splitIntoSentences(sectionText);

    String currentChunk = '';
    int chunkStartChar = 0;
    int currentChar = 0;
    int chunkIndex = startIndex;

    for (final sentence in sentences) {
      // 현재 청크에 문장을 추가했을 때 크기 확인
      final potentialChunk = currentChunk.isEmpty
          ? sentence
          : '$currentChunk $sentence';

      if (potentialChunk.length > maxChunkSize && currentChunk.isNotEmpty) {
        // 현재 청크 저장
        chunks.add({
          'index': chunkIndex++,
          'section': sectionTitle,
          'content': currentChunk.trim(),
          'startChar': chunkStartChar,
          'endChar': currentChar,
        });

        // 새 청크 시작 (오버랩 고려)
        final overlapText = _getOverlapText(currentChunk, overlapSize);
        currentChunk = overlapText.isEmpty
            ? sentence
            : '$overlapText $sentence';
        chunkStartChar = max(0, currentChar - overlapText.length);
      } else {
        currentChunk = potentialChunk;
      }

      currentChar += sentence.length + 1; // +1 for space
    }

    // 마지막 청크 추가
    if (currentChunk.isNotEmpty) {
      chunks.add({
        'index': chunkIndex,
        'section': sectionTitle,
        'content': currentChunk.trim(),
        'startChar': chunkStartChar,
        'endChar': currentChar,
      });
    }

    return chunks;
  }

  /// 문장 단위로 텍스트 분할
  static List<String> _splitIntoSentences(String text) {
    // 문장 끝 패턴 (마침표, 느낌표, 물음표)
    final sentencePattern = RegExp(r'[.!?]+\s+');
    final sentences = <String>[];

    int lastIndex = 0;
    for (final match in sentencePattern.allMatches(text)) {
      final sentence = text.substring(lastIndex, match.end).trim();
      if (sentence.isNotEmpty) {
        sentences.add(sentence);
      }
      lastIndex = match.end;
    }

    // 마지막 문장 추가
    if (lastIndex < text.length) {
      final lastSentence = text.substring(lastIndex).trim();
      if (lastSentence.isNotEmpty) {
        sentences.add(lastSentence);
      }
    }

    return sentences;
  }

  /// 청크 간 오버랩 텍스트 생성
  static String _getOverlapText(String text, int overlapSize) {
    if (text.length <= overlapSize) return text;

    final startIndex = text.length - overlapSize;
    final overlapText = text.substring(startIndex);

    // 단어 경계에서 자르기
    final spaceIndex = overlapText.indexOf(' ');
    if (spaceIndex > 0) {
      return overlapText.substring(spaceIndex + 1);
    }

    return overlapText;
  }

  /// 청크들을 다시 합치기 (필요시)
  static String reconstructText(List<Map<String, dynamic>> chunks) {
    return chunks.map((chunk) => chunk['content']).join('\n\n');
  }
}
