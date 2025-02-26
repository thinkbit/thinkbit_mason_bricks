import 'package:dio/dio.dart';

/// The response from an API request.
class APIResponse extends Response<dynamic> {
  APIResponse({
    required this.response,
    this.errorMessage,
    this.status = ResponseStatus.unknown,
  }) : super(
          data: response.data,
          requestOptions: response.requestOptions,
          extra: response.extra,
          headers: response.headers,
          statusCode: response.statusCode,
          statusMessage: response.statusMessage,
          redirects: response.redirects,
          isRedirect: response.isRedirect,
        ) {
    errorMessage = APIExceptionMessageHandler.parseResponseBody(
        result: super.data as Map<String, dynamic>);
    status =
        APIStatusHandler.parseStatusCode(statusCode: super.statusCode);
  }

  final Response<dynamic> response;
  String? errorMessage;
  ResponseStatus status;

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
    } else if (statusCode < 200 || statusCode >= 300) {
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
