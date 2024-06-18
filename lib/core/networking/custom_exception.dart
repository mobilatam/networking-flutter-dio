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
              message: message ?? 'Solicitud cancelada prematuramente',
            );
          case DioExceptionType.connectionTimeout:
            return CustomException(
              exceptionType: ExceptionType.connectTimeoutException,
              statusCode: error.response?.statusCode,
              message: message ?? 'No se pudo establecer la conexión. Por favor, verifique su conexión a Internet.',
            );
          case DioExceptionType.sendTimeout:
            return CustomException(
              exceptionType: ExceptionType.sendTimeoutException,
              statusCode: error.response?.statusCode,
              message: message ?? 'Error al enviar la solicitud',
            );
          case DioExceptionType.receiveTimeout:
            return CustomException(
              exceptionType: ExceptionType.receiveTimeoutException,
              statusCode: error.response?.statusCode,
              message: message ?? 'Error al recibir la respuesta',
            );
          case DioExceptionType.badResponse:
            return CustomException(
              exceptionType: ExceptionType.badResponse,
              statusCode: error.response?.statusCode,
              message: message ?? 'Se produjo un error al procesar la solicitud',
            );
          case DioExceptionType.unknown:
            return CustomException(
              exceptionType: ExceptionType.unrecognizedException,
              statusCode: error.response?.statusCode,
              message: message ?? 'Ocurrió un error desconocido',
            );
          case DioExceptionType.badCertificate:
            return CustomException(
              exceptionType: ExceptionType.unrecognizedException,
              statusCode: error.response?.statusCode,
              message: message ?? 'Problema con el certificado',
            );
          case DioExceptionType.connectionError:
            return CustomException(
              exceptionType: ExceptionType.connectionError,
              statusCode: error.response?.statusCode,
              message: message ?? 'Error de conexión. Por favor, verifique su conexión a Internet.',
            );
        }
      } else {
        return CustomException(
          exceptionType: ExceptionType.unrecognizedException,
          message: 'Ocurrió un error desconocido',
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
        message: 'Ocurrió un error desconocido',
      );
    }
  }

  factory CustomException.fromParsingException(Exception error) {
    return CustomException(
      exceptionType: ExceptionType.serializationException,
      message: 'Se produjo un error al analizar la respuesta',
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