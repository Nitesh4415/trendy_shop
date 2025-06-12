import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop_trendy/core/error/failures.dart';
import 'package:shop_trendy/core/error/exceptions.dart'; // Import for PaymentException

part 'payment_state.dart';
part 'payment_cubit.freezed.dart';

@injectable
class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(const PaymentState.initial());

  Future<void> processPayment(double amount, String currency) async {
    emit(const PaymentState.loading());
    try {
      // 1. Create a PaymentIntent on your backend (simulated)
      // In a real app, make an HTTP request to your backend.
      // The backend would interact with Stripe to create a PaymentIntent and return its client_secret.
      // For this example, we'll simulate a successful client_secret retrieval.

      // Simulate network delay for backend call
      await Future.delayed(const Duration(seconds: 1));

      // Dummy client secret - DO NOT USE IN PRODUCTION
      // This client secret would typically come from your backend after creating a PaymentIntent.
      const String dummyClientSecret = 'pi_3P6f1lKFmY3Lh3G70e6t0Q0J_secret_abcdef1234567890'; // Replace with actual logic

      if (dummyClientSecret.isEmpty) {
        throw PaymentException('Failed to retrieve client secret from backend.');
      }

      // 2. Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: dummyClientSecret,
          merchantDisplayName: 'E-commerce App',
          //  pass customer information if available
          // customerEphemeralKey: '...',
          // customerId: '...',
        ),
      );

      // 3. Present the Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      emit(const PaymentState.success('Payment successful!'));
    } on StripeException catch (e) {
      String errorMessage = 'Stripe Payment Failed: ${e.error.code} - ${e.error.message}';
      if (e.error.message == 'Canceled') {
        errorMessage = 'Payment was cancelled.';
      }
      emit(PaymentState.error(PaymentFailure(errorMessage)));
    } on PaymentException catch (e) {
      emit(PaymentState.error(PaymentFailure(e.message)));
    } catch (e) {
      emit(PaymentState.error(PaymentFailure('An unexpected error occurred: ${e.toString()}')));
    }
  }
}
