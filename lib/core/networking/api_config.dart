import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:networking_flutter_dio/core/networking/api_service.dart';
import 'package:networking_flutter_dio/core/networking/dio_service.dart';
import 'package:networking_flutter_dio/core/networking/interceptors/api_interceptor.dart';
import 'package:networking_flutter_dio/core/networking/interceptors/logging_interceptor.dart';
import 'package:networking_flutter_dio/core/networking/interceptors/refresh_token_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiRest {
  factory ApiRest() {
    return _instance;
  }
  ApiRest._internal();
  static final ApiRest _instance = ApiRest._internal();

  late ApiService instance;

  ApiService get service => instance;

  static Future<void> initialize({
    String apiUrl = '',
    bool refreshTokenInterceptor = false,
    required FlutterSecureStorage secureStorage,
    SharedPreferences? sharedPreferences,
    required String authTokenKey,
    String? authTokenRefreshKey,
    String? authUserKey,
  }) async {
    final baseOptions = BaseOptions(
      persistentConnection: true,
      baseUrl: apiUrl,
      connectTimeout: const Duration(seconds: 20),
    );
    final dio = Dio(baseOptions);
    final interceptors = <Interceptor>[
      ApiInterceptor(
        secureStorage: secureStorage,
        authTokenKey: authTokenKey,
      ),
      if (refreshTokenInterceptor)
        RefreshTokenInterceptor(
          dioClient: dio,
          secureStorage: secureStorage,
          authTokenRefreshKey: authTokenRefreshKey,
          sharedPreferences: sharedPreferences,
          authUserKey: authUserKey,
          urlTokenRefreshServer: '$apiUrl/auth/refresh-token',
        ),
      if (kDebugMode) LoggingInterceptor(),
    ];
    dio.interceptors.addAll(interceptors);
    final dioService = DioService(
      dioClient: dio,
    );
    _instance.instance = ApiService(
      dioService,
    );
  }
}
