class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, String>? fieldErrors;

  ApiException({this.statusCode, required this.message, this.fieldErrors});

  factory ApiException.fromDioError(dynamic error) {
    if (error.response != null) {
      final data = error.response.data;
      if (data is Map && data.containsKey('message')) {
        return ApiException(
          statusCode: error.response.statusCode,
          message: data['message'] ?? 'An error occurred',
          fieldErrors: data['fieldErrors'] != null
              ? Map<String, String>.from(data['fieldErrors'])
              : null,
        );
      }
      return ApiException(
        statusCode: error.response.statusCode,
        message: 'Server error',
      );
    }
    // BUG-12 fix: differentiate timeout from no-network.
    final type = error.type?.toString() ?? '';
    if (type.contains('connectionTimeout') ||
        type.contains('sendTimeout') ||
        type.contains('receiveTimeout')) {
      return ApiException(message: 'Request timed out. Please try again.');
    }
    return ApiException(message: 'No internet connection. Please check your network.');
  }
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException({required this.message, this.statusCode});
}
