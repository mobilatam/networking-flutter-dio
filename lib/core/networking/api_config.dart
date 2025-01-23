import 'package:dio/dio.dart';
import 'package:networking_flutter_dio/core/networking/api_service.dart';
import 'package:networking_flutter_dio/core/networking/dio_service.dart';
import 'package:networking_flutter_dio/core/networking/interceptors/api_interceptor.dart';
import 'package:networking_flutter_dio/core/networking/interceptors/logging_interceptor.dart';
import 'package:networking_flutter_dio/core/networking/interceptors/refresh_token_interceptor.dart';

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
    String language = 'es-ES',
    bool refreshTokenInterceptor = false,
    String? authUserKey,
  }) async {
    final baseOptions = BaseOptions(
      persistentConnection: true,
      headers: {
        'Accept-Language': language
      },
      baseUrl: apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );
    final dio = Dio(baseOptions);
    final interceptors = <Interceptor>[
      ApiInterceptor(
      ),
      if (refreshTokenInterceptor)
        RefreshTokenInterceptor(
          dioClient: dio,
          urlTokenRefreshServer: '$apiUrl/auth/refresh-token',
        ),
      LoggingInterceptor(),
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
