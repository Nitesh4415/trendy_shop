import 'package:injectable/injectable.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

@LazySingleton()
class AddToCartUseCase {
  final CartRepository _repository;

  AddToCartUseCase(this._repository);

  Future<void> call(CartItem item, String emailId) async {
    await _repository.addToCart(item, emailId);
  }
}