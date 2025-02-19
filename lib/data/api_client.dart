import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/constants.dart';

/// API客户端异常
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// API响应模型
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T? Function(dynamic) fromJson) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'] as String?,
      statusCode: json['status_code'] as int? ?? 200,
    );
  }
}

/// API客户端
/// 负责处理与后端服务器的所有HTTP通信
class ApiClient {
  final http.Client _client;
  final String baseUrl;
  final Duration timeout;
  final Map<String, String> defaultHeaders;

  ApiClient({
    http.Client? client,
    this.baseUrl = ApiConstants.baseUrl,
    this.timeout = const Duration(milliseconds: ApiConstants.timeout),
    Map<String, String>? defaultHeaders,
  }) : _client = client ?? http.Client(),
       defaultHeaders = defaultHeaders ?? {
         'Content-Type': 'application/json',
         'Accept': 'application/json',
       };

  /// 发送GET请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    T? Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _client
          .get(uri, headers: _mergeHeaders(headers))
          .timeout(timeout);
      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 发送POST请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    T? Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _client
          .post(
            uri,
            headers: _mergeHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);
      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 发送PUT请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    T? Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _client
          .put(
            uri,
            headers: _mergeHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);
      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 发送DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
    T? Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _client
          .delete(
            uri,
            headers: _mergeHeaders(headers),
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);
      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 上传文件
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    List<http.MultipartFile> files, {
    Map<String, String>? fields,
    Map<String, String>? headers,
    T? Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(path);
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_mergeHeaders(headers, includeContentType: false))
        ..files.addAll(files);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 构建请求URI
  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    var uri = Uri.parse('$baseUrl/$path');
    if (queryParameters != null) {
      uri = uri.replace(
        queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return uri;
  }

  /// 合并请求头
  Map<String, String> _mergeHeaders(
    Map<String, String>? headers, {
    bool includeContentType = true,
  }) {
    final mergedHeaders = Map<String, String>.from(
      includeContentType ? defaultHeaders : {},
    );
    if (headers != null) {
      mergedHeaders.addAll(headers);
    }
    return mergedHeaders;
  }

  /// 处理响应
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T? Function(dynamic)? fromJson,
  ) {
    final statusCode = response.statusCode;
    final body = _parseResponseBody(response);

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse<T>(
        success: true,
        data: fromJson != null && body != null ? fromJson(body) : null,
        message: body?['message'] as String?,
        statusCode: statusCode,
      );
    } else {
      throw ApiException(
        body?['message'] ?? 'Request failed',
        statusCode: statusCode,
        data: body,
      );
    }
  }

  /// 解析响应体
  dynamic _parseResponseBody(http.Response response) {
    try {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } catch (e) {
      throw ApiException('Failed to parse response: ${e.toString()}');
    }
  }

  /// 处理错误
  Exception _handleError(dynamic error) {
    if (error is TimeoutException) {
      return ApiException(AppStrings.timeoutError);
    } else if (error is ApiException) {
      return error;
    } else {
      return ApiException(error.toString());
    }
  }

  /// 关闭客户端
  void dispose() {
    _client.close();
  }
}
