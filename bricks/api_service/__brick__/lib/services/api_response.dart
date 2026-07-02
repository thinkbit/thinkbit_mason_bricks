import 'package:dio/dio.dart';

/// The response from an API request.
class APIResponse {
  final Response<dynamic>? response;
  final String? errorMessage;
  final ResponseStatus status;

  APIResponse({
    this.response,
    this.errorMessage,
    this.status = ResponseStatus.unknown,
  });

  /// Factory constructor to create an [APIResponse] from a Dio [Response].
  factory APIResponse.fromResponse(Response<dynamic> response) {
    final status = APIStatusHandler.parseStatusCode(statusCode: response.statusCode);
    String? error;
    
    if (status != ResponseStatus.success && response.data is Map<String, dynamic>) {
       error = APIExceptionMessageHandler.parseResponseBody(
        result: response.data as Map<String, dynamic>);
    }

    return APIResponse(
      response: response,
      errorMessage: error,
      status: status,
    );
  }

  /// Helper to get the response data.
  dynamic get data => response?.data;

  /// Helper to get the status code.
  int? get statusCode => response?.statusCode;

  /// Returns true if the request was successful.
  bool isSuccess() => status == ResponseStatus.success;
}

class APIExceptionMessageHandler {
  static String? parseResponseBody({required Map<String, dynamic> result}) {
    final errorMessage =
        result['message'] as String? ?? result['error'] as String?;

    return errorMessage;
  }
}

class APIStatusHandler {
  static ResponseStatus parseStatusCode({required int? statusCode}) {
    if (statusCode == null) return ResponseStatus.unknown;

    if (statusCode >= 200 && statusCode < 300) {
      return ResponseStatus.success;
    } else if (statusCode == 401) {
      return ResponseStatus.unauthorized;
    } else if (statusCode == 404) {
      return ResponseStatus.notFound;
    } else if (statusCode < 200 || statusCode >= 400) {
      return ResponseStatus.forbidden;
    } else {
      return ResponseStatus.error;
    }
  }
}

enum ResponseStatus {
  success,
  error,
  unauthorized,
  notFound,
  forbidden,
  unknown,
}
