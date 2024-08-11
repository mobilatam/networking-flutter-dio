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
    if (body == null) {
      throw const FormatException('Body cannot be null');
    }
 if (body is List) {
      return body as T;
    } else if (body is Map) {
      return body as T;
    } else {
      throw FormatException('Expected List or Map for body, but got ${body.runtimeType}');
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
