import 'package:injectable/injectable.dart';

import '../repositories/cart_repository.dart';

@LazySingleton()
class ClearCartUseCase {
  final CartRepository _repository;

  ClearCartUseCase(this._repository);

  Future<void> call(String emailId) async {
    await _repository.clearCart(emailId);
  }
}