/// 텍스트 처리 관련 유틸리티 함수들
class TextUtils {
  /// 텍스트를 지정된 길이로 자르기
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// 문자 수를 읽기 쉬운 형태로 변환
  static String formatCharacterCount(int count) {
    if (count < 1000) return '$count자';
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K자';
    return '${(count / 1000000).toStringAsFixed(1)}M자';
  }

  /// 단어 수 계산
  static int countWords(String text) {
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
  }

  /// 읽기 시간 추정 (분 단위)
  static int estimateReadingTime(String text, {int wordsPerMinute = 200}) {
    final wordCount = countWords(text);
    return (wordCount / wordsPerMinute).ceil();
  }

  /// 텍스트에서 이메일 추출
  static List<String> extractEmails(String text) {
    final emailRegex = RegExp(
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    );
    return emailRegex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  /// 텍스트에서 URL 추출
  static List<String> extractUrls(String text) {
    final urlRegex = RegExp(r'https?://[^\s]+');
    return urlRegex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  /// 텍스트 정리 (불필요한 공백, 줄바꿈 제거)
  static String cleanText(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ') // 연속된 공백을 하나로
        .replaceAll(RegExp(r'\n\s*\n'), '\n\n') // 연속된 줄바꿈을 두 개로
        .trim();
  }

  /// 하이라이트된 텍스트 생성
  static List<TextSpan> highlightText(
    String text,
    String query, {
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  }) {
    if (query.isEmpty) {
      return [TextSpan(text: text, style: normalStyle)];
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // 하이라이트 이전 텍스트
      if (index > start) {
        spans.add(
          TextSpan(text: text.substring(start, index), style: normalStyle),
        );
      }

      // 하이라이트된 텍스트
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: highlightStyle,
        ),
      );

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // 남은 텍스트
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: normalStyle));
    }

    return spans;
  }
}
