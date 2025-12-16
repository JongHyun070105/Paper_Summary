/// 앱에서 사용하는 커스텀 예외 클래스들
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

class FileException extends AppException {
  const FileException(super.message, [super.code]);
}

class PdfProcessingException extends AppException {
  const PdfProcessingException(super.message, [super.code]);
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message, [super.code]);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// 예외 처리 유틸리티
class ExceptionHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error.toString().contains('TimeoutException')) {
      return '요청 시간이 초과되었습니다.';
    }

    if (error.toString().contains('SocketException')) {
      return '네트워크 연결을 확인해주세요.';
    }

    if (error.toString().contains('FormatException')) {
      return '잘못된 데이터 형식입니다.';
    }

    return '알 수 없는 오류가 발생했습니다: ${error.toString()}';
  }

  static bool isNetworkError(dynamic error) {
    return error is NetworkException ||
        error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException');
  }
}
