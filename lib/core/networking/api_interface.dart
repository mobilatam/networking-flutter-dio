import 'dart:async';

import 'package:networking_flutter_dio/core/networking/response_model.dart';
import 'package:networking_flutter_dio/core/helper/typedefs.dart';

abstract class ApiInterface {
  const ApiInterface();

  Future<T> deleteData<T>({
    required String endpoint,
    required T Function(ResponseModel<JSON> response) converter,
    Object? data,
    bool requiresAuthToken = true,
  });

  Future<List<T>> getCollectionData<T>({
    required String endpoint,
    required T Function(JSON responseBody) converter,
    JSON? queryParams,
    String? language,
    bool requiresAuthToken = true,
  });

  Future<T> getDocumentData<T>({
    required String endpoint,
    required T Function(JSON responseBody) converter,
    JSON? queryParams,
    String? language,
    bool requiresAuthToken = true,
  });

  Future<T> setData<T>({
    required String endpoint,
    required Object data,
    required T Function(ResponseModel<JSON> response) converter,
    bool requiresAuthToken = true,
    StreamController<double>? progressController
  });
  Future<T> updateData<T>({
    required String endpoint,
    required Object data,
    required T Function(ResponseModel<JSON> response) converter,
    bool requiresAuthToken = true,
    
  });
}
