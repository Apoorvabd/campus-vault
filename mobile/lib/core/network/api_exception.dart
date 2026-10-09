import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException e) {
    // 1. Server ne jawab diya -> uska "message" use karo
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return ApiException(
        data['message'] as String,
        statusCode: e.response?.statusCode,
      );
    }

    // 2. Jawab hi nahi aaya -> network ki problem
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'Server is taking too long. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'Cannot reach the server. Check your internet.',
        );
      default:
        return ApiException(
          'Something went wrong. Please try again.',
          statusCode: e.response?.statusCode,
        );
    }
  }

  @override
  String toString() => message;
}
