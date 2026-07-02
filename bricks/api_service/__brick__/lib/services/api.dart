import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:requests_inspector/requests_inspector.dart';
import 'package:retry/retry.dart';
import 'api_response.dart';

class Api {
  Api._();
  static final Api instance = Api._();

  // static String baseUrl = FlavorConfig.instance!.values.baseUrl;
  static String baseUrl = 'http://127.0.0.1:8000';
  static String apiUrl = '$baseUrl/api';

  static Duration timeoutDuration = const Duration(minutes: 1);

  static final dioRetry = RetryOptions(maxAttempts: 3);

  static Dio dio = Dio(
    BaseOptions(
      connectTimeout: timeoutDuration,
      sendTimeout: timeoutDuration,
      receiveTimeout: timeoutDuration,
      validateStatus: (statusCode) {
        if (statusCode == null) return false;
        
        // Return true for common error codes so we can parse the response body
        if (statusCode == 422 || statusCode == 401 || statusCode == 400 || statusCode == 404) {
          return true;
        }
        
        return statusCode >= 200 && statusCode < 300;
      },
    ),
  )..interceptors.add(RequestsInspectorInterceptor());

  Future<Map<String, String>> headers({required bool authorized}) async {
    Map<String, String> headers = <String, String>{
      'accept': 'application/json',
      'content-type': 'application/json',
    };

    if (authorized) {
      // TODO: Replace with your actual token retrieval logic
      String? token = 'auth token here';
      debugPrint('authToken: $token');

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  bool _shouldRetry(Object e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError;
    }
    return e is SocketException || e is TimeoutException;
  }

  Future<APIResponse> get(
    String path, {
    Map<String, dynamic>? params,
    bool authorized = true,
    ResponseType? responseType,
  }) async {
    try {
      final headers = await this.headers(authorized: authorized);

      debugPrint('API [GET]: $apiUrl/$path');

      final response = await dioRetry.retry(
        () => dio.get(
          '$apiUrl/$path',
          queryParameters: params,
          options: Options(
            headers: headers,
            responseType: responseType,
          ),
        ),
        retryIf: _shouldRetry,
      );

      return APIResponse.fromResponse(response);
    } on DioException catch (e) {
      debugPrint('API [GET] Error: ${e.message}');
      if (e.response != null) return APIResponse.fromResponse(e.response!);
      rethrow;
    } catch (e) {
      debugPrint('API [GET] Unexpected Error: $e');
      rethrow;
    }
  }

  Future<APIResponse> post(
    String path, {
    Object? data,
    bool authorized = true,
  }) async {
    try {
      final headers = await this.headers(authorized: authorized);

      debugPrint('API [POST]: $apiUrl/$path');

      final response = await dioRetry.retry(
        () => dio.post(
          '$apiUrl/$path',
          data: data,
          options: Options(headers: headers),
        ),
        retryIf: _shouldRetry,
      );

      return APIResponse.fromResponse(response);
    } on DioException catch (e) {
      debugPrint('API [POST] Error: ${e.message}');
      if (e.response != null) return APIResponse.fromResponse(e.response!);
      rethrow;
    } catch (e) {
      debugPrint('API [POST] Unexpected Error: $e');
      rethrow;
    }
  }

  Future<APIResponse> put(
    String path, {
    Object? data,
    bool authorized = true,
  }) async {
    try {
      final headers = await this.headers(authorized: authorized);

      debugPrint('API [PUT]: $apiUrl/$path');

      final response = await dioRetry.retry(
        () => dio.put(
          '$apiUrl/$path',
          data: data,
          options: Options(headers: headers),
        ),
        retryIf: _shouldRetry,
      );

      return APIResponse.fromResponse(response);
    } on DioException catch (e) {
      debugPrint('API [PUT] Error: ${e.message}');
      if (e.response != null) return APIResponse.fromResponse(e.response!);
      rethrow;
    } catch (e) {
      debugPrint('API [PUT] Unexpected Error: $e');
      rethrow;
    }
  }

  Future<APIResponse> patch(
    String path, {
    Object? data,
    bool authorized = true,
  }) async {
    try {
      final headers = await this.headers(authorized: authorized);

      debugPrint('API [PATCH]: $apiUrl/$path');

      final response = await dioRetry.retry(
        () => dio.patch(
          '$apiUrl/$path',
          data: data,
          options: Options(headers: headers),
        ),
        retryIf: _shouldRetry,
      );

      return APIResponse.fromResponse(response);
    } on DioException catch (e) {
      debugPrint('API [PATCH] Error: ${e.message}');
      if (e.response != null) return APIResponse.fromResponse(e.response!);
      rethrow;
    } catch (e) {
      debugPrint('API [PATCH] Unexpected Error: $e');
      rethrow;
    }
  }

  Future<APIResponse> delete(
    String path, {
    Map<String, dynamic>? params,
    bool authorized = true,
  }) async {
    try {
      final headers = await this.headers(authorized: authorized);

      debugPrint('API [DELETE]: $apiUrl/$path');

      final response = await dioRetry.retry(
        () => dio.delete(
          '$apiUrl/$path',
          queryParameters: params,
          options: Options(headers: headers),
        ),
        retryIf: _shouldRetry,
      );

      return APIResponse.fromResponse(response);
    } on DioException catch (e) {
      debugPrint('API [DELETE] Error: ${e.message}');
      if (e.response != null) return APIResponse.fromResponse(e.response!);
      rethrow;
    } catch (e) {
      debugPrint('API [DELETE] Unexpected Error: $e');
      rethrow;
    }
  }
}
