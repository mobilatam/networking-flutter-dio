import 'dart:async';

import 'package:dio/dio.dart';
import 'package:networking_flutter_dio/core/helper/typedefs.dart';
import 'package:networking_flutter_dio/core/networking/api_interface.dart';
import 'package:networking_flutter_dio/core/networking/custom_exception.dart';
import 'package:networking_flutter_dio/core/networking/dio_service.dart';
import 'package:networking_flutter_dio/core/networking/response_model.dart';

class ApiService implements ApiInterface {
  ApiService(DioService dioService) : _dioService = dioService;

  late final DioService _dioService;

  @override
  Future<T> deleteData<T>({
    required String endpoint,
    required T Function(ResponseModel<JSON> response) converter,
    Object? data,
    bool requiresAuthToken = true,
  }) async {
    try {
      final response = await _dioService.delete(
        endpoint: endpoint,
        data: data,
        options: Options(
          extra: <String, Object?>{
            'requiresAuthToken': requiresAuthToken,
          },
        ),
      );
      if (response.body is Map) {
        return converter(response.body);
      } else {
        throw FormatException(
            'Expected Map for body, but got ${response.body.runtimeType}');
      }
    } on DioException catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    } on FormatException catch (ex) {
      throw CustomException.fromParsingException(
        ex,
      );
    } catch (ex) {
      throw CustomException.fromDioException(
        Exception(ex),
      );
    }
  }

  @override
  Future<List<T>> getCollectionData<T>({
    required String endpoint,
    required T Function(JSON responseBody) converter,
    JSON? queryParams,
    String? language = 'es',
    bool requiresAuthToken = true,
  }) async {
    List<Object?> body;
    try {
      final data = await _dioService.get(
        endpoint: endpoint,
        options: Options(
          extra: <String, Object?>{
            'requiresAuthToken': requiresAuthToken,
            'language': language,
          },
        ),
        queryParams: queryParams,
      );

      if (data.body is List) {
        body = data.body;
        return body
            .map(
              (dataMap) => converter(
                dataMap! as JSON,
              ),
            )
            .toList();
      } else {
        throw FormatException(
            'Expected List for body, but got ${data.body.runtimeType}');
      }
    } on DioException catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    } on FormatException catch (ex) {
      throw CustomException.fromParsingException(
        ex,
      );
    } catch (ex) {
      throw CustomException.fromDioException(
        Exception(ex),
      );
    }
  }

  @override
  Future<T> getDocumentData<T>({
    required String endpoint,
    required T Function(JSON response) converter,
    JSON? queryParams,
    String? language = 'es',
    bool requiresAuthToken = true,
  }) async {
    try {
      final data = await _dioService.get(
        endpoint: endpoint,
        queryParams: queryParams,
        options: Options(
          extra: <String, Object?>{
            'requiresAuthToken': requiresAuthToken,
            'language': language,
          },
        ),
      );
      if (data.body is Map) {
        return converter(data.body);
      } else {
        throw FormatException(
            'Expected MAP<> for body, but got ${data.body.runtimeType}');
      }
    } on DioException catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    } on FormatException catch (ex) {
      throw CustomException.fromParsingException(
        ex,
      );
    } catch (ex) {
      throw CustomException.fromDioException(
        Exception(ex),
      );
    }
  }

  @override
  Future<T> setData<T>({
    required String endpoint,
    required Object data,
    required T Function(ResponseModel<JSON> response) converter,
    JSON? headers,
    bool requiresAuthToken = true,
    void Function(int count, int total)? onSendProgress,
  }) async {
    try {
      final response = await _dioService.post(
        endpoint: endpoint,
        data: data,
        onSendProgress: onSendProgress,
        options: Options(
          headers: headers,
          extra: <String, Object?>{
            'requiresAuthToken': requiresAuthToken,
          },
        ),
      );

      if (response.body is Map) {
        return converter(response.body);
      } else {
        throw FormatException(
            'Expected Map for body, but got ${response.body.runtimeType}');
      }
    } on DioException catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    } on FormatException catch (ex) {
      throw CustomException.fromParsingException(
        ex,
      );
    } catch (ex) {
      throw CustomException.fromDioException(
        Exception(ex),
      );
    }
  }

  @override
  Future<T> updateData<T>({
    required String endpoint,
    required Object data,
    required T Function(ResponseModel<JSON> response) converter,
    bool requiresAuthToken = true,
  }) async {
    try {
      final response = await _dioService.put(
        endpoint: endpoint,
        data: data,
        options: Options(
          extra: <String, Object?>{
            'requiresAuthToken': requiresAuthToken,
          },
        ),
      );
      if (response.body is Map) {
        return converter(response.body);
      } else {
        throw FormatException(
            'Expected Map for body, but got ${response.body.runtimeType}');
      }
    } on DioException catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    } on FormatException catch (ex) {
      throw CustomException.fromParsingException(
        ex,
      );
    } catch (ex) {
      throw CustomException.fromDioException(
        Exception(ex),
      );
    }
  }
}
