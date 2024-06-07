import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show debugPrint;

class LoggingInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    debugPrint('--> ERROR');
    final httpMethod = err.requestOptions.method.toUpperCase();
    final url = err.requestOptions.baseUrl + err.requestOptions.path;

    debugPrint('\tMETHOD: $httpMethod \tURL: $url'); // GET
    if (err.response != null) {
      debugPrint('\tStatus code: ${err.response!.statusCode}');

      debugPrint('${err.response!.data}');
    } else if (err.error is SocketException) {
      const message = 'No internet connectivity';
      debugPrint('\tException: FetchDataException');
      debugPrint('\tMessage: $message');
    } else {
      debugPrint('\tUnknown Error');
    }

    debugPrint('<-- END ERROR');

    super.onError(err, handler);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final httpMethod = options.method.toUpperCase();
    final url = options.baseUrl + options.path;

    debugPrint('--> $httpMethod $url'); //GET www.example.com/mock_path/all

    debugPrint('\tHeaders:');
    options.headers.forEach(
      (k, Object? v) => debugPrint('\t\t$k: $v'),
    );

    if (options.queryParameters.isNotEmpty) {
      debugPrint('\tqueryParams:');
      options.queryParameters.forEach(
        (k, Object? v) => debugPrint('\t\t$k: $v'),
      );
    }

    if (options.data != null && options.contentType !="multipart/form-data") {
      debugPrint('\tBody: ${jsonEncode(options.data)}');
    }

    debugPrint('--> END $httpMethod');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint('<-- RESPONSE');

    debugPrint('\tStatus code: ${response.statusCode}');

    if (response.statusCode == 304) {
      debugPrint('\tSource: Cache');
    } else {
      debugPrint('\tSource: Network');
    }

    debugPrint('\tResponse: ${jsonEncode(response.data)}');

    debugPrint('<-- END HTTP');

    super.onResponse(response, handler);
  }
}
