
import 'package:dio/dio.dart';
import 'package:networking_flutter_dio/core/helper/typedefs.dart';

class CustomException implements Exception {
  CustomException({
    required this.message,
    this.code,
    int? statusCode,
    this.exceptionType = ExceptionType.apiException,
  })  : statusCode = statusCode ?? 500,
        name = exceptionType.name;

  factory CustomException.fromDioException(Exception error) {
    try {
      if (error is DioException) {
        final responseData = error.response?.data as JSON?;
        final message = responseData?['message'] as String?;
        switch (error.type) {
          case DioExceptionType.cancel:
            return CustomException(
              exceptionType: ExceptionType.cancelException,
              statusCode: error.response?.statusCode,
              message: message ?? 'Request cancelled prematurely',
            );
          case DioExceptionType.connectionTimeout:
            return CustomException(
              exceptionType: ExceptionType.connectTimeoutException,
              statusCode: error.response?.statusCode,
              message: message ?? 'Connection not established',
            );
          case DioExceptionType.sendTimeout:
            return CustomException(
              exceptionType: ExceptionType.sendTimeoutException,
              statusCode: error.response?.statusCode,
              message: message ?? 'Failed to send',
            );
          case DioExceptionType.receiveTimeout:
            return CustomException(
              exceptionType: ExceptionType.receiveTimeoutException,
              statusCode: error.response?.statusCode,
              message: message ?? 'Failed to receive',
            );
          case DioExceptionType.badResponse:
            return CustomException(
              exceptionType: ExceptionType.badResponse,
              statusCode: error.response?.statusCode,
              message: message ?? 'An error occurred while processing the server response',
            );
          case DioExceptionType.unknown:
            return CustomException(
              exceptionType: ExceptionType.unrecognizedException,
              statusCode: error.response?.statusCode,
              message: message ?? 'An unknown error occurred',
            );

          case DioExceptionType.badCertificate:
            return CustomException(
              exceptionType: ExceptionType.unrecognizedException,
              statusCode: error.response?.statusCode,
              message: message ?? 'Bad certificate',
            );
          case DioExceptionType.connectionError:
            return CustomException(
              exceptionType: ExceptionType.connectionError,
              statusCode: error.response?.statusCode,
              message: message ?? 'Connection error',
            );
        }
      } else {
        return CustomException(
          exceptionType: ExceptionType.unrecognizedException,
          message: 'An unknown error occurred',
        );
      }
    } on FormatException catch (e) {
      return CustomException(
        exceptionType: ExceptionType.formatException,
        message: e.message,
      );
    } on Exception catch (_) {
      return CustomException(
        exceptionType: ExceptionType.unrecognizedException,
        message: 'An unknown error occurred',
      );
    }
  }

  factory CustomException.fromParsingException(Exception error) {
    return CustomException(
      exceptionType: ExceptionType.serializationException,
      message: 'An error occurred while parsing the response',
    );
  }
  final String name;
  final String message;
  final String? code;
  final int? statusCode;
  final ExceptionType exceptionType;
}

enum ExceptionType {
  tokenExpiredException,
  connectionError,
  cancelException,
  badResponse,
  connectTimeoutException,
  sendTimeoutException,
  receiveTimeoutException,
  socketException,
  fetchDataException,
  formatException,
  unrecognizedException,
  apiException,
  serializationException,
}
