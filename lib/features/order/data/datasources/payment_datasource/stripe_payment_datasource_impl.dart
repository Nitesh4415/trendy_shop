import 'package:dio/dio.dart'; // Import Dio
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop_trendy/features/order/data/datasources/payment_datasource/stripe_payment_datasource.dart';

@LazySingleton(as: StripePaymentDataSource)
class StripePaymentDataSourceImpl implements StripePaymentDataSource {
  final Dio dio; // Change to Dio

  StripePaymentDataSourceImpl(this.dio); // Update constructor

  @override
  Future<String> createPaymentIntent(double amount, String currency) async {


    if (kDebugMode) {
      print(
        'Simulating Stripe Payment Intent creation for amount: $amount, currency: $currency');
    }

    try {

      const String dummyClientSecret =
          'pi_3P6f1D2e3f4g5h6i7j8k9l0_secret_ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      return Future.value(dummyClientSecret); // Simulate success
    } catch (e) {
      // Dio errors are typically DioError
      if (e is DioException) {
        throw PaymentException(
            'Failed to create payment intent: ${e.response?.data ?? e.message}');
      }
      throw PaymentException(
          'Failed to create payment intent: ${e.toString()}');
    }
  }

  @override
  Future<void> confirmPayment(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'My Trendy Shop',
          // customerId: 'CUSTOMER_ID', // Optional: if available
          // customerEphemeralKeySecret: 'EPHEMERAL_KEY', // Optional
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      // Payment successful
    } on StripeException catch (e) {
      if (e.error.message == "Canceled") {
        throw PaymentException("Payment cancelled by user.");
      } else {
        throw PaymentException(
            "Payment failed: ${e.error.localizedMessage ?? 'Unknown error'}");
      }
    } catch (e) {
      throw PaymentException(
          "An unexpected error occurred during payment: ${e.toString()}");
    }
  }
}