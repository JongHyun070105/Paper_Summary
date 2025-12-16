/// 앱 전체에서 사용되는 상수들
class AppConstants {
  // 청크 관련 설정
  static const int maxChunkSize = 2000;
  static const int overlapSize = 200;
  static const int defaultPageSize = 3;

  // 파일 크기 제한
  static const int maxFileSizeBytes = 100 * 1024 * 1024; // 100MB

  // 네트워크 타임아웃
  static const Duration networkTimeout = Duration(seconds: 30);

  // UI 관련 상수
  static const double defaultBorderRadius = 16.0;
  static const double cardElevation = 2.0;
  static const double defaultPadding = 16.0;

  // 논문 섹션 패턴
  static const List<String> paperSections = [
    'Abstract',
    'Introduction',
    'Methods',
    'Results',
    'Discussion',
    'Conclusion',
    'References',
  ];

  // 지원 언어
  static const List<String> supportedLanguages = ['en', 'ko'];

  // 관심사 카테고리
  static const List<String> interestCategories = [
    '전체',
    '인공지능',
    '머신러닝',
    '딥러닝',
    '컴퓨터 비전',
    '자연어 처리',
    '로보틱스',
  ];
}
