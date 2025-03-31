import '../helper/typedefs.dart';

class ResponseHeadersModel {
  const ResponseHeadersModel({
    required this.message,
  });

  factory ResponseHeadersModel.fromJson(JSON json) {
    return ResponseHeadersModel(
      message: json['message'] as String?,
    );
  }
  final String? message;
}

class ResponseModel<T> {
  const ResponseModel({
    required this.headers,
    required this.body,
  });

  static T _parseBody<T>(dynamic body) {
    final data = body['data'];

    try {
      if (body['success'] && data == null) {
        return {'message': body['message']} as T;
      }

      return data as T;
    } catch (e) {
      rethrow;
    }
  }

  factory ResponseModel.fromJson(JSON json) {
    return ResponseModel(
      headers: json['headers'] == null
          ? null
          : ResponseHeadersModel.fromJson(
              json['headers'] as JSON,
            ),
      body: _parseBody<T>(json['body']),
    );
  }
  final ResponseHeadersModel? headers;
  final T body;
}
