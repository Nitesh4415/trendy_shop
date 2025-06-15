import 'package:injectable/injectable.dart';

import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

@LazySingleton()
class GetCartItemsUseCase {
  final CartRepository _repository;

  GetCartItemsUseCase(this._repository);

  Future<List<CartItem>> call(String emailId) async {
    return await _repository.getCartItems(emailId);
  }
}