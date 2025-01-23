import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:networking_flutter_dio/core/helper/typedefs.dart';
import 'package:networking_flutter_dio/core/local/key_value_storage_base.dart';
import 'package:networking_flutter_dio/core/local/variables.dart';

class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({
    required Dio dioClient,
    this.urlTokenRefreshServer,
  }) : _dio = dioClient;
  final String? urlTokenRefreshServer;

  final Dio _dio;

  String get tokenExpiredException => 'TokenExpiredError';
  KeyValueStorageBase keyValueStorageBase = KeyValueStorageBase();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {

    if (err.response != null) {
      var responseData = err.response?.data;
      JSON? data;

      // Intenta parsear la respuesta como JSON si es una cadena
      if (responseData is String) {
        try {
          data = json.decode(responseData) as JSON?;
        } catch (e) {
          // Si no es JSON válido, maneja el error aquí
          return super.onError(err, handler);
        }
      } else if (responseData is Map<String, dynamic>) {
        data = responseData;
      } else {
        return super.onError(err, handler);
      }

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
              method: err.requestOptions.method,
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
      final responseData = response.data as JSON;
      final body = responseData['body'] as JSON;
      final token = body['token'] as String;
       setAuthToken(token);
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
      final dataMap = keyValueStorageBase.sharedPrefs.getString(GlobalVariables.authUserKey );
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
      var token =
           keyValueStorageBase.sharedPrefs.getString( GlobalVariables.authTokenRefreshKey ) ?? "NO_TOKEN";

      
      return token;
    } catch (e) {
      return null;
    }
  }

  void setAuthToken(String tokenNew)  {
     keyValueStorageBase.sharedPrefs.setString( GlobalVariables.authTokenKey ,  tokenNew);
  }
}
