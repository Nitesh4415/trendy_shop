import 'package:injectable/injectable.dart';

import '../repositories/cart_repository.dart';

@LazySingleton()
class RemoveFromCartUseCase {
  final CartRepository _repository;

  RemoveFromCartUseCase(this._repository);

  Future<void> call(String itemId) async {
    await _repository.removeFromCart(itemId);
  }
}