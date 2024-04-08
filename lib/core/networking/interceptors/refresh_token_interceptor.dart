import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:networking_flutter_dio/core/helper/typedefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({
    required Dio dioClient,
    this.urlTokenRefreshServer,
    required this.secureStorage,
    this.sharedPreferences,
    this.authUserKey,
    this.authTokenRefreshKey,
  }) : _dio = dioClient;
  final String? urlTokenRefreshServer;
  final FlutterSecureStorage secureStorage;
  final SharedPreferences? sharedPreferences;
  final String? authUserKey;
  final String? authTokenRefreshKey;
  

  final Dio _dio;

  String get tokenExpiredException => 'TokenExpiredError';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response != null) {
      final data = err.response?.data as JSON?;
      final headers = data?['errors'] as JSON?;

      final code = headers?['name'] as String?;

      if (code == tokenExpiredException) {
        var userId = getUserId();
        var token = await getToken();
        final tokenDio = Dio()..options = _dio.options;
        if (userId != null && token != null) {
          final id = userId;
          final data = {
            'username': id,
            'refreshtoken': token,
          };

          final newToken = await _refreshTokenRequest(
            dioError: err,
            handler: handler,
            tokenDio: tokenDio,
            data: data,
          );

          if (newToken == null) {
            return super.onError(err, handler);
          }

          final response = await _dio.request<JSON>(
            err.requestOptions.path,
            data: err.requestOptions.data,
            cancelToken: err.requestOptions.cancelToken,
            options: Options(
              headers: <String, Object?>{'Authorization': 'Bearer $newToken'},
            ),
          );
          return handler.resolve(response);
        }
      }
    }

    return super.onError(err, handler);
  }

  Future<String?> _refreshTokenRequest({
    required DioException dioError,
    required ErrorInterceptorHandler handler,
    required Dio tokenDio,
    required JSON data,
  }) async {
    debugPrint('--> REFRESHING TOKEN');
    try {
      debugPrint('\tBody: $data');

      final response = await tokenDio.post<JSON>(
        urlTokenRefreshServer ?? 'NO-URL-TOKEN',
        data: data,
      );

      debugPrint('\tStatus code:${response.statusCode}');
      debugPrint('\tResponse: ${response.data}');

      debugPrint('<-- END REFRESH');
      final body = data['body'] as JSON;
      var token = body['token'] as String;
      await setAuthToken(token);
      return token;
    } on Exception catch (ex) {
      debugPrint('\t--> ERROR');
      if (ex is DioException) {
        final de = ex;
        debugPrint('\t\t--> Exception: ${de.error}');
        debugPrint('\t\t--> Message: ${de.message}');
        debugPrint('\t\t--> Response: ${de.response}');
      } else {
        debugPrint('\t\t--> Exception: $ex');
      }
      debugPrint('\t<-- END ERROR');
      debugPrint('<-- END REFRESH');

      return null;
    }
  }

  String? getUserId() {
    try {
      final dataMap = sharedPreferences?.getString(authUserKey ?? 'NO-KEY');
      if (dataMap == null) {
        return null;
      }
      final data = jsonDecode(dataMap) as JSON;
      return data['username'] as String;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      var token = await secureStorage.read(key: authTokenRefreshKey ?? "NO_TOKEN");

      if (token == null) {
        return null;
      }
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<void> setAuthToken(String tokenNew) async {
    await secureStorage.write(key: authTokenRefreshKey ?? "NO_TOKEN", value: tokenNew);
  }
}
