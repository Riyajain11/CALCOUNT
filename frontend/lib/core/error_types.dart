enum ScanErrorCode {
  unauthenticated,
  badImage,
  limitReached,
  noFoodDetected,
  aiUnavailable,
  network,
}

class ScanException implements Exception {
  final ScanErrorCode code;
  final String message;

  ScanException({required this.code, required this.message});

  @override
  String toString() => 'ScanException($code): $message';

  String userFacingMessage() {
    switch (code) {
      case ScanErrorCode.unauthenticated:
        return 'Please log in to continue.';
      case ScanErrorCode.badImage:
        return 'The photo could not be read. Please retake the photo.';
      case ScanErrorCode.limitReached:
        return 'Daily scan limit reached. Your quota resets at midnight IST. You can still add meals manually.';
      case ScanErrorCode.noFoodDetected:
        return 'No food was detected in this photo. Please retake the photo.';
      case ScanErrorCode.aiUnavailable:
        return 'AI analysis is temporarily unavailable. Please retry or add manually.';
      case ScanErrorCode.network:
        return 'Network connection issue. Please check your connection and retry, or add manually.';
    }
  }

  static ScanErrorCode parseCode(String codeStr) {
    switch (codeStr.toUpperCase()) {
      case 'UNAUTHENTICATED':
        return ScanErrorCode.unauthenticated;
      case 'BAD_IMAGE':
        return ScanErrorCode.badImage;
      case 'LIMIT_REACHED':
        return ScanErrorCode.limitReached;
      case 'NO_FOOD_DETECTED':
        return ScanErrorCode.noFoodDetected;
      case 'AI_UNAVAILABLE':
        return ScanErrorCode.aiUnavailable;
      case 'NETWORK':
      default:
        return ScanErrorCode.network;
    }
  }
}

