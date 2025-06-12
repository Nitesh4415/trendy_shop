import 'package:injectable/injectable.dart';

import '../repositories/cart_repository.dart';

@LazySingleton()
class UpdateCartItemQuantityUseCase {
  final CartRepository _repository;

  UpdateCartItemQuantityUseCase(this._repository);

  Future<void> call(String itemId, int quantity) async {
    await _repository.updateCartItemQuantity(itemId, quantity);
  }
}