import 'package:dio/dio.dart'; // Changed to import Dio
import 'package:injectable/injectable.dart';
import 'package:shop_trendy/core/constants/api_constants.dart';
import 'package:shop_trendy/core/error/exceptions.dart'; // Import custom exceptions

class PaymentApiClient {
  final String baseUrl;
  final Dio dio; // Changed from http.Client to Dio

  PaymentApiClient({
    @Named('paymentBackendUrl') required this.baseUrl,
    required this.dio,
  }) {
    dio.options.baseUrl = baseUrl; // Set base URL for Dio instance
  }

  Future<String> createPaymentIntent(double amount, String currency) async {
    try {
      if (dio.options.baseUrl != ApiConstants.backendBaseUrl) {
        dio.options.baseUrl = ApiConstants.backendBaseUrl;
      }
      final response = await dio.post(
        // Use dio.post
        '/create-payment-intent', // Relative path as base URL is set in Dio options
        data: {
          // Dio uses 'data' for the request body
          'amount':
              amount, // Send amount as double, backend will convert to cents
          'currency': currency,
        },
        options: Options(
          // Set headers using Dio's Options
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            response.data as Map<String, dynamic>; // Dio already parses JSON
        if (responseData.containsKey('clientSecret')) {
          return responseData['clientSecret'] as String;
        } else {
          throw PaymentException('Backend did not return clientSecret.');
        }
      } else {
        // Dio's error handling will usually catch non-2xx status codes
        // but adding this for explicit clarity if a non-DioError status is returned directly.
        throw PaymentException(
          'Failed to create payment intent on backend with status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Catch DioException
      if (e.response != null) {
        // Handle backend errors sent through Dio
        final Map<String, dynamic> errorData = e.response!.data is Map
            ? e.response!.data as Map<String, dynamic>
            : {'error': 'Unknown backend error'};
        throw PaymentException(
          errorData['error'] ?? 'Failed to create payment intent: ${e.message}',
        );
      } else {
        // Handle network errors (e.g., no internet, connection refused)
        throw PaymentException(
          'Could not connect to payment backend: ${e.message}',
        );
      }
    } catch (e) {
      throw PaymentException(
        'An unexpected error occurred while creating payment intent: ${e.toString()}',
      );
    }
  }
}
