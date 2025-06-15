import 'package:injectable/injectable.dart';

import '../repositories/stripe_payment_repository.dart';

@LazySingleton()
class CreatePaymentIntentUseCase {
  final StripePaymentRepository _repository;

  CreatePaymentIntentUseCase(this._repository);

  Future<String> call(double amount, String currency) async {
    return await _repository.createPaymentIntent(amount, currency);
  }
}
