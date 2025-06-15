abstract class StripePaymentRemoteDataSource {
  Future<String> createPaymentIntent(double amount, String currency);
}
