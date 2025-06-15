abstract class StripePaymentRepository {
  Future<String> createPaymentIntent(double amount, String currency);
}
