import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor({
    required this.secureStorage,
    required this.authTokenKey,
  }) : super();

  final FlutterSecureStorage secureStorage;
  final String authTokenKey;

  static final _authStreamController = StreamController<bool>();
  static Stream<bool> get verifyTokenStream => _authStreamController.stream;

  static void initStreamValue(bool initialValue) {
    _authStreamController.add(false);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _authStreamController.add(true);
    }
    return handler.next(
      err,
    );
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra.containsKey('requiresAuthToken')) {
      if (options.extra['requiresAuthToken'] == true) {
        var token = await secureStorage.read(key: authTokenKey) ?? "NO_TOKEN";
        options.headers.addAll(
          {
            'Authorization': 'Bearer $token',
            'language': options.extra['language'],
          },
        );
      } else {
        options.headers.addAll(
          {
            'language': options.extra['language'],
          },
        );
      }

      options.extra.remove('requiresAuthToken');
    } else {
      options.headers.addAll(
        {'language': options.extra['language']},
      );
    }
    return handler.next(
      options,
    );
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    return handler.next(
      response,
    );
  }
}
