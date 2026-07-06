import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fortune_fiesta/app/core/logger/app_logger.dart';
import 'package:fortune_fiesta/app/data/values/constants.dart';
import 'package:fortune_fiesta/app/data/values/env.dart';
import 'package:fortune_fiesta/utils/helper/exception_handler.dart';

class NetworkRequester {
  late Dio _dio;

  NetworkRequester() {
    prepareRequest();
  }

  void prepareRequest() {
    BaseOptions dioOptions = BaseOptions(
      connectTimeout: const Duration(milliseconds: Timeouts.connectTimeout),
      receiveTimeout: const Duration(milliseconds: Timeouts.receiveTimeout),
      baseUrl: Env.baseURL,
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.json,
      headers: {'Accept': Headers.jsonContentType},
    );

    _dio = Dio(dioOptions);

    _dio.interceptors.clear();

    if (!kReleaseMode) {
      _dio.interceptors.add(LogInterceptor(
        error: true,
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: true,
        logPrint: _printLog,
      ));
    } else {
      _dio.interceptors.add(LogInterceptor(
        error: true,
        request: false,
        requestBody: false,
        requestHeader: false,
        responseBody: false,
        responseHeader: false,
        logPrint: _printLog,
      ));
    }
  }

  void _printLog(Object object) =>
      AppLogger.d(object.toString(), tag: 'NetworkRequester');

  Future<dynamic> get({
    required String path,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: query);
      return response.data;
    } on Exception catch (exception) {
      return ExceptionHandler.handleError(exception);
    }
  }

  Future<dynamic> post({
    required String path,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(
        path,
        queryParameters: query,
        data: data,
      );
      return response.data;
    } on Exception catch (error) {
      return ExceptionHandler.handleError(error);
    }
  }

  Future<dynamic> put({
    required String path,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put(path, queryParameters: query, data: data);
      return response.data;
    } on Exception catch (error) {
      return ExceptionHandler.handleError(error);
    }
  }

  Future<dynamic> patch({
    required String path,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response =
          await _dio.patch(path, queryParameters: query, data: data);
      return response.data;
    } on Exception catch (error) {
      return ExceptionHandler.handleError(error);
    }
  }

  Future<dynamic> delete({
    required String path,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response =
          await _dio.delete(path, queryParameters: query, data: data);
      return response.data;
    } on Exception catch (error) {
      return ExceptionHandler.handleError(error);
    }
  }
}
