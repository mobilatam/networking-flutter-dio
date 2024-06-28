import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    print('--> ERROR');
    final httpMethod = err.requestOptions.method.toUpperCase();
    final url = err.requestOptions.baseUrl + err.requestOptions.path;

    print('\tMETHOD: $httpMethod \tURL: $url'); // GET
    if (err.response != null) {
      print('\tStatus code: ${err.response!.statusCode}');

      print('${err.response!.data}');
    } else if (err.error is SocketException) {
      const message = 'No internet connectivity';
      print('\tException: FetchDataException');
      print('\tMessage: $message');
    } else {
      print('\tUnknown Error');
    }

    print('<-- END ERROR');

    super.onError(err, handler);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final httpMethod = options.method.toUpperCase();
    final url = options.baseUrl + options.path;

    print('--> $httpMethod $url'); //GET www.example.com/mock_path/all

    print('\tHeaders:');
    options.headers.forEach(
      (k, Object? v) => print('\t\t$k: $v'),
    );

    if (options.queryParameters.isNotEmpty) {
      print('\tqueryParams:');
      options.queryParameters.forEach(
        (k, Object? v) => print('\t\t$k: $v'),
      );
    }

    if (options.data != null && options.contentType !="multipart/form-data") {
      print('\tBody: ${jsonEncode(options.data)}');
    }

    print('--> END $httpMethod');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    print('<-- RESPONSE');

    print('\tStatus code: ${response.statusCode}');

    if (response.statusCode == 304) {
      print('\tSource: Cache');
    } else {
      print('\tSource: Network');
    }

    print('\tResponse: ${jsonEncode(response.data)}');

    print('<-- END HTTP');

    super.onResponse(response, handler);
  }
}
