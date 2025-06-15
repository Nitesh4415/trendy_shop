import 'package:injectable/injectable.dart';
import 'package:shop_trendy/features/payment/data/datasources/stripe_payment_datasource.dart';

import '../../../../core/network/payment_api_client.dart';

@LazySingleton(as: StripePaymentRemoteDataSource)
class StripePaymentRemoteDataSourceImpl
    implements StripePaymentRemoteDataSource {
  final PaymentApiClient _apiClient;

  StripePaymentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<String> createPaymentIntent(double amount, String currency) async {
    try {
      return await _apiClient.createPaymentIntent(amount, currency);
    } catch (e) {
      rethrow; // Re-throw any exceptions from the API client
    }
  }
}
