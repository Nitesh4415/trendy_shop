import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_trendy/core/constants/api_constants.dart';
import 'dart:io';
import 'package:shop_trendy/core/error/exceptions.dart';

@lazySingleton
class ApiClient {
  final Dio dio;
  final String baseUrl;

  ApiClient({
    required this.dio,
    @Named('fakeStoreApiUrl') required this.baseUrl,
  }) {
    if (kDebugMode) {
      print('ApiClient initialized with baseUrl: $baseUrl');
    } // ADDED FOR DEBUGGING
    dio.options.baseUrl = baseUrl; // Ensure the correct base URL is set here
    dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (dio.options.baseUrl == 'http://10.0.2.2:3000') {
        dio.options.baseUrl = ApiConstants.fakeStoreApiUrl;
      }
      final response = await dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(); // Generic server exception for unexpected errors
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final response = await dio.post(path, data: body);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException();
    }
  }

  dynamic _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      throw ServerException(); // Or more specific exception based on status code
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(); // Custom network exception for timeouts
      case DioExceptionType.badResponse:
        if (e.response != null) {
          switch (e.response!.statusCode) {
            case 400:
              throw BadRequestException(e.response!.data.toString());
            case 401:
              throw UnauthorizedException(e.response!.data.toString());
            case 403:
              throw ForbiddenException(e.response!.data.toString());
            case 404:
              throw NotFoundException(e.response!.data.toString());
            case 500:
              throw ServerException(); // Generic server error
            default:
              throw ServerException(); // Fallback for other bad responses
          }
        }
        throw ServerException(); // Fallback if response is null but type is badResponse
      case DioExceptionType.cancel:
        throw OperationCanceledException();
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          // No internet connection
          throw NetworkException();
        }
        throw ServerException(); // Generic for other unknown errors
      case DioExceptionType.badCertificate:
        throw ServerException(); // Certificate issues
      case DioExceptionType.connectionError:
        throw NetworkException(); // Connection issues
    }
  }
}
