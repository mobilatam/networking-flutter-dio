import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:networking_flutter_dio/core/helper/typedefs.dart';

class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor({
    required Dio dioClient,
    this.userId,
    this.urlTokenRefreshServer,
  }) : _dio = dioClient;
  final Future<String> Function()? userId;
  final String? urlTokenRefreshServer;

  final Dio _dio;

  String get tokenExpiredException => 'TokenExpiredException';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response != null) {
      final data = err.response?.data as JSON?;
      final headers = data?['headers'] as JSON?;

      final code = headers?['code'] as String?;
      if (code == tokenExpiredException) {
        final tokenDio = Dio()..options = _dio.options;

        _dio.close();
        if (userId != null) {
          final id = await userId!();
          final data = {
            'id': id,
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
      // Check new token success
      final headers = data['headers'] as JSON;
      final success = headers['error'] == 0;

      if (success) {
        debugPrint('<-- END REFRESH');
        final body = data['body'] as JSON;

        return body['token'] as String;
      } else {
        throw Exception(headers['message']);
      }
    } on Exception catch (ex) {
      // only caught here for logging
      // forward to try-catch in dio_service for handling
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
    } finally {
      _dio.close();
    }
  }
}
