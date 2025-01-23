import 'dart:async';

import 'package:dio/dio.dart';
import 'package:networking_flutter_dio/core/local/key_value_storage_base.dart';
import 'package:networking_flutter_dio/core/local/variables.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor() : super();



  static final _authStreamController = StreamController<bool>.broadcast();
  static Stream<bool> get verifyTokenStream => _authStreamController.stream;
  final _keyValueStorage = KeyValueStorageBase();
  static void initialTokenStreamValue(bool initialValue) {
    _authStreamController.add(initialValue);
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
        var token =  _keyValueStorage.sharedPrefs.getString( GlobalVariables.authTokenKey) ?? "NO_TOKEN";
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
