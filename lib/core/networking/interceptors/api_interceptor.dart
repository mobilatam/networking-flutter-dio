import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor({
    required this.secureStorage,
    required this.authTokenKey,
  }) : super();

  final FlutterSecureStorage secureStorage;
  final String authTokenKey;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
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
