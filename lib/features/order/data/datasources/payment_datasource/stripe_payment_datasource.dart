abstract class StripePaymentDataSource {
  Future<String> createPaymentIntent(double amount, String currency);
  Future<void> confirmPayment(String clientSecret);
}
