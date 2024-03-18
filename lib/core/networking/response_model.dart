import 'package:networking_flutter_dio/core/helper/typedefs.dart';

class ResponseHeadersModel {
  const ResponseHeadersModel({
    required this.error,
    required this.message,
    this.code,
  });

  factory ResponseHeadersModel.fromJson(JSON json) {
    return ResponseHeadersModel(
      error: json['error'] as int == 1,
      message: json['message'] as String,
      code: json['code'] as String?,
    );
  }
  final bool error;
  final String message;
  final String? code;
}

class ResponseModel<T> {
  const ResponseModel({
    required this.headers,
    required this.body,
  });

  factory ResponseModel.fromJson(JSON json) {
    return ResponseModel(
      headers: json['headers'] == null
          ? null
          : ResponseHeadersModel.fromJson(
              json['headers'] as JSON,
            ),
      body: json['body'] == null ? json as T : json['body'] as T,
    );
  }
  final ResponseHeadersModel? headers;
  final T body;
}
