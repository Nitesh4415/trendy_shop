import 'package:injectable/injectable.dart';

import '../../domain/repositories/stripe_payment_repository.dart';
import '../datasources/stripe_payment_datasource.dart';

@LazySingleton(as: StripePaymentRepository)
class StripePaymentRepositoryImpl implements StripePaymentRepository {
  final StripePaymentRemoteDataSource _remoteDataSource;

  StripePaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> createPaymentIntent(double amount, String currency) async {
    try {
      return await _remoteDataSource.createPaymentIntent(amount, currency);
    } catch (e) {
      rethrow;
    }
  }
}
