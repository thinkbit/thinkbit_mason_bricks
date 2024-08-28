import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:requests_inspector/requests_inspector.dart';
import 'package:retry/retry.dart';

class Api {
  // static String baseUrl = FlavorConfig.instance!.values.baseUrl;
  static String baseUrl = 'http://127.0.0.1:8000';
  static String apiUrl = baseUrl + '/api';

  // static Duration timeoutDuration = FlavorConfig.instance!.apiTimeoutDuration;
  static Duration timeoutDuration = const Duration(minutes: 1);

  static final dioRetry = RetryOptions(maxAttempts: 3);

  static Dio dio = Dio(
    BaseOptions(
      connectTimeout: Duration(minutes: 1),
      sendTimeout: Duration(minutes: 1),
      receiveTimeout: Duration(minutes: 1),
      validateStatus: (statusCode) {
        if (statusCode == null) {
          return false;
        }
        if (statusCode == 422) {
          // server cannot process the request
          return true;
        } else if (statusCode == 401) {
          // user is not authorized
          // _forceSignOut();
          return true;
        } else {
          // check status code is successful
          return statusCode >= 200 && statusCode < 300;
        }
      },
    ),
  )..interceptors.add(
      RequestsInspectorInterceptor()
  );

  static Future<Map<String, String>> headers({required bool authorized}) async {
    Map<String, String> headers = <String, String>{
      'accept': 'application/json',
      'content-type': 'application/json',
    };

    if (authorized) {
      // String? token = await SecureStorage().read(key: Constants.authToken);
      String? token = 'auth token here';
      debugPrint('authToken: $token');

      if (token != null) {
        headers['Authorization'] = 'Bearer ${token}';
      } else {
        // await _forceSignOut();
      }
    }

    return headers;
  }

  static _getPostmanBulkEdit(String params) {
    String modifiedData = params
        .replaceAll('{', '')
        .replaceAll('}', '')
        // .replaceAll('[', '')
        // .replaceAll(']', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('MapEntry', '')
        .replaceAll(': ', ':')
        .replaceAll(', ', '\n');
    String bulkEdit = 'POSTMAN BULK EDIT:\n$modifiedData';
    return bulkEdit;
  }

  static bool toRetry(e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError;
    }
    return e is SocketException || e is TimeoutException;
  }

  static Future<Response> get(
    String path, {
    Map<String, dynamic>? params,
    bool authorized = true,
    ResponseType? responseType,
  }) async {
    try {
      final Map<String, String> headers =
          await Api.headers(authorized: authorized);

      debugPrint('get: $apiUrl/$path');
      debugPrint('get: ${_getPostmanBulkEdit(params.toString())}');

      final response = await dioRetry.retry(
        () => dio.get(
          '$apiUrl/$path',
          queryParameters: params,
          options: Options(
            headers: headers,
            receiveTimeout: timeoutDuration,
            sendTimeout: timeoutDuration,
            responseType: responseType,
          ),
        ),
        retryIf: (e) => toRetry(e),
      );

      debugPrint('get: $path\nstatus: ${response.statusCode}\nres: $response');

      return response;
    } on DioException catch (e) {
      debugPrint('DioException catch (e.error): ${e.error}');
      debugPrint('DioException catch (e.message): ${e.message}');
      debugPrint('DioException catch (e.requestOptions): ${e.requestOptions}');
      debugPrint('DioException catch (e.response): ${e.response}');
      debugPrint('DioException catch (e.type): ${e.type}');
      throw (e);
    } catch (e) {
      debugPrint('API catch (e): $e');
      throw (e);
    }
  }

  static Future<Response> patch(
    String path, {
    Map<String, dynamic>? params,
    bool authorized = true,
  }) async {
    try {
      final Map<String, String> headers =
          await Api.headers(authorized: authorized);

      debugPrint('patch: $apiUrl/$path');
      debugPrint('patch: ${_getPostmanBulkEdit(params.toString())}');

      final response = await dioRetry.retry(
        () => dio.patch(
          '$apiUrl/$path',
          queryParameters: params,
          options: Options(
            headers: headers,
            receiveTimeout: timeoutDuration,
            sendTimeout: timeoutDuration,
          ),
        ),
        retryIf: (e) => toRetry(e),
      );

      debugPrint(
          'patch: $path\nstatus: ${response.statusCode}\nres: $response');

      return response;
    } on DioException catch (e) {
      debugPrint('DioException catch (e.error): ${e.error}');
      debugPrint('DioException catch (e.message): ${e.message}');
      debugPrint('DioException catch (e.requestOptions): ${e.requestOptions}');
      debugPrint('DioException catch (e.response): ${e.response}');
      debugPrint('DioException catch (e.type): ${e.type}');
      throw (e);
    } catch (e) {
      debugPrint('API catch (e): $e');
      throw (e);
    }
  }

  static Future<Response> put(
    String path, {
    FormData? data,
    bool authorized = true,
  }) async {
    try {
      final Map<String, String> headers =
          await Api.headers(authorized: authorized);

      debugPrint('put: $apiUrl/$path');
      debugPrint(
          'put: ${_getPostmanBulkEdit(data != null ? data.fields.toString() : '')}');

      final response = await dioRetry.retry(
        () => dio.put(
          '$apiUrl/$path',
          data: data,
          options: Options(
            headers: headers,
            receiveTimeout: timeoutDuration,
            sendTimeout: timeoutDuration,
          ),
        ),
        retryIf: (e) => toRetry(e),
      );

      debugPrint('put: $path\nstatus: ${response.statusCode}\nres: $response');

      return response;
    } on DioException catch (e) {
      debugPrint('DioException catch (e.error): ${e.error}');
      debugPrint('DioException catch (e.message): ${e.message}');
      debugPrint('DioException catch (e.requestOptions): ${e.requestOptions}');
      debugPrint('DioException catch (e.response): ${e.response}');
      debugPrint('DioException catch (e.type): ${e.type}');
      throw (e);
    } catch (e) {
      debugPrint('API catch (e): $e');
      throw (e);
    }
  }

  static Future<Response> post(
    String path, {
    Object? data,
    bool authorized = true,
  }) async {
    try {
      final Map<String, String> headers =
          await Api.headers(authorized: authorized);

      debugPrint('post: $apiUrl/$path');
      if (data != null && data is FormData) {
        debugPrint('post: ${_getPostmanBulkEdit(data.fields.toString())}');
      }

      final response = await dioRetry.retry(
        () => dio.post(
          '$apiUrl/$path',
          data: data,
          options: Options(
            headers: headers,
            receiveTimeout: timeoutDuration,
            sendTimeout: timeoutDuration,
          ),
        ),
        retryIf: (e) => toRetry(e),
      );

      debugPrint('post: $path\nstatus: ${response.statusCode}\nres: $response');

      return response;
    } on DioException catch (e) {
      debugPrint('DioException catch (e.error): ${e.error}');
      debugPrint('DioException catch (e.message): ${e.message}');
      debugPrint('DioException catch (e.requestOptions): ${e.requestOptions}');
      debugPrint('DioException catch (e.response): ${e.response}');
      debugPrint('DioException catch (e.type): ${e.type}');
      if (e.response != null) {
        return e.response!; // Added to catch error
      }
      throw (e);
    } catch (e) {
      debugPrint('API catch (e): $e');
      throw (e);
    }
  }

  static Future<Response> delete(
    String path, {
    Map<String, dynamic>? params,
    bool authorized = true,
  }) async {
    try {
      final Map<String, String> headers =
          await Api.headers(authorized: authorized);

      debugPrint('delete: $apiUrl/$path');
      debugPrint('delete: ${_getPostmanBulkEdit(params.toString())}');

      final response = await dioRetry.retry(
        () => dio.delete(
          '$apiUrl/$path',
          queryParameters: params,
          options: Options(
            headers: headers,
            receiveTimeout: timeoutDuration,
            sendTimeout: timeoutDuration,
          ),
        ),
        retryIf: (e) => toRetry(e),
      );

      debugPrint(
          'delete: $path\nstatus: ${response.statusCode}\nres: $response');

      return response;
    } on DioException catch (e) {
      debugPrint('DioException catch (e.error): ${e.error}');
      debugPrint('DioException catch (e.message): ${e.message}');
      debugPrint('DioException catch (e.requestOptions): ${e.requestOptions}');
      debugPrint('DioException catch (e.response): ${e.response}');
      debugPrint('DioException catch (e.type): ${e.type}');
      throw (e);
    } catch (e) {
      debugPrint('API catch (e): $e');
      throw (e);
    }
  }
}
