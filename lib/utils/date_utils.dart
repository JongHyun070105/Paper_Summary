/// 날짜 처리 관련 유틸리티 함수들
class DateUtils {
  /// 상대적 시간 표시 (예: "2시간 전", "3일 전")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}주 전';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}개월 전';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}년 전';
    }
  }

  /// 날짜를 읽기 쉬운 형태로 포맷
  static String formatDate(DateTime dateTime, {bool includeTime = false}) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    if (includeTime) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$year.$month.$day $hour:$minute';
    }

    return '$year.$month.$day';
  }

  /// 오늘인지 확인
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// 이번 주인지 확인
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return dateTime.isAfter(startOfWeek) && dateTime.isBefore(endOfWeek);
  }

  /// 스마트 날짜 표시 (오늘이면 시간, 이번 주면 요일, 그 외는 날짜)
  static String getSmartDateString(DateTime dateTime) {
    if (isToday(dateTime)) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (isThisWeek(dateTime)) {
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      return '${weekdays[dateTime.weekday - 1]}요일';
    } else {
      return formatDate(dateTime);
    }
  }
}
