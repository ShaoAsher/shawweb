import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// HTTP 服务类
/// 使用 Dio 封装 HTTP 请求，采用 Get 单例模式
class HttpService extends GetxService {
  static HttpService get to => Get.find();

  late Dio _dio;

  /// 默认超时时间（秒）
  static const int defaultTimeout = 10;

  /// 初始化 HTTP 服务
  static Future<HttpService> init() async {
    final service = HttpService();
    service._initDio();
    return service;
  }

  @override
  void onInit() {
    super.onInit();
  }

  /// 初始化 Dio 实例
  void _initDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: defaultTimeout),
        receiveTimeout: const Duration(seconds: defaultTimeout),
        sendTimeout: const Duration(seconds: defaultTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加请求拦截器（用于日志）
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('[HTTP] ${options.method} ${options.uri}');
          if (options.queryParameters.isNotEmpty) {
            debugPrint('[HTTP] Query: ${options.queryParameters}');
          }
          if (options.data != null) {
            debugPrint('[HTTP] Body: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            '[HTTP] Response ${response.statusCode}: ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('[HTTP] Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// GET 请求
  ///
  /// [url] 请求地址
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  /// 返回响应数据（已解析为 Map 或 List）
  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// POST 请求
  ///
  /// [url] 请求地址
  /// [data] 请求体数据
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  /// 返回响应数据（已解析为 Map 或 List）
  Future<dynamic> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// PUT 请求
  ///
  /// [url] 请求地址
  /// [data] 请求体数据
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  /// 返回响应数据（已解析为 Map 或 List）
  Future<dynamic> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// DELETE 请求
  ///
  /// [url] 请求地址
  /// [data] 请求体数据
  /// [queryParameters] 查询参数
  /// [options] 请求选项
  /// 返回响应数据（已解析为 Map 或 List）
  Future<dynamic> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// 处理错误
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        debugPrint('[HTTP] 请求超时: ${error.message}');
        break;
      case DioExceptionType.badResponse:
        debugPrint(
          '[HTTP] 响应错误: ${error.response?.statusCode} - ${error.response?.statusMessage}',
        );
        break;
      case DioExceptionType.cancel:
        debugPrint('[HTTP] 请求取消: ${error.message}');
        break;
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          debugPrint('[HTTP] 网络连接错误: ${error.message}');
        } else {
          debugPrint('[HTTP] 未知错误: ${error.message}');
        }
        break;
      case DioExceptionType.badCertificate:
        debugPrint('[HTTP] 证书错误: ${error.message}');
        break;
      case DioExceptionType.connectionError:
        debugPrint('[HTTP] 连接错误: ${error.message}');
        break;
    }
  }

  /// 获取 Dio 实例（用于高级用法）
  Dio get dio => _dio;

  /// 更新基础配置
  void updateBaseOptions({
    String? baseUrl,
    Map<String, dynamic>? headers,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    _dio.options.baseUrl = baseUrl ?? _dio.options.baseUrl;
    if (headers != null) {
      _dio.options.headers.addAll(headers);
    }
    if (connectTimeout != null) {
      _dio.options.connectTimeout = connectTimeout;
    }
    if (receiveTimeout != null) {
      _dio.options.receiveTimeout = receiveTimeout;
    }
    if (sendTimeout != null) {
      _dio.options.sendTimeout = sendTimeout;
    }
  }
}
