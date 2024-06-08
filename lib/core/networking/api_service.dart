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
    ResponseModel<JSON> response;
    try {
      response = await _dioService.delete<JSON>(
        endpoint: endpoint,
        data: data,
        options: Options(
          extra: <String, Object?>{
            'requiresAuthToken': requiresAuthToken,
          },
        ),
      );
    } on DioException catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    } on Exception catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    }

    try {
      return converter(response);
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(
        ex,
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
      final data = await _dioService.get<List<Object?>>(
        endpoint: endpoint,
        options: Options(
          extra: <String, Object?>{
            'requiresAuthToken': requiresAuthToken,
            'language': language,
          },
        ),
        queryParams: queryParams,
      );
      body = data.body;
    } on DioException catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    } on Exception catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    }

    try {
      return body
          .map(
            (dataMap) => converter(
              dataMap! as JSON,
            ),
          )
          .toList();
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(
        ex,
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
    JSON body;
    try {
      final data = await _dioService.get<JSON>(
        endpoint: endpoint,
        queryParams: queryParams,
        options: Options(
          extra: <String, Object?>{
            'requiresAuthToken': requiresAuthToken,
            'language': language,
          },
        ),
      );

      body = data.body;
    } on DioException catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    } on Exception catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    }

    try {
      return converter(body);
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(
        ex,
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
    void Function(int, int)? onSendProgress,

  }) async {
    ResponseModel<JSON> response;

    try {
      response = await _dioService.post<JSON>(
        endpoint: endpoint,
        data: data,
        onSendProgress:onSendProgress,
        options: Options(
          headers: headers,
          extra: <String, Object?>{
            'requiresAuthToken': requiresAuthToken,
          },
        ),
      );
    } on DioException catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    } on Exception catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    }
    try {
      return converter(response);
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(
        ex,
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
    ResponseModel<JSON> response;
    try {
      response = await _dioService.put<JSON>(
        endpoint: endpoint,
        data: data,
        options: Options(
          extra: <String, Object?>{
            'requiresAuthToken': requiresAuthToken,
          },
        ),
      );
    } on DioException catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    } on Exception catch (ex) {
      throw CustomException.fromDioException(
        ex,
      );
    }

    try {
      return converter(response);
    } on Exception catch (ex) {
      throw CustomException.fromParsingException(
        ex,
      );
    }
  }
}
