import '../../domain/entities/cart_item.dart';

abstract class CartLocalDataSource {
  Future<List<CartItem>> getCartItems();
  Future<void> saveCartItem(CartItem item);
  Future<void> updateCartItem(CartItem item);
  Future<void> deleteCartItem(String id);
  Future<void> clearCart();
}