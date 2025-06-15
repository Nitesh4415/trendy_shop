import '../../domain/entities/cart_item.dart';

abstract class CartLocalDataSource {
  Future<List<CartItem>> getCartItems(String emailId);
  Future<void> saveCartItem(CartItem item, String emailId);
  Future<void> updateCartItem(CartItem item, String emailId);
  Future<void> deleteCartItem(String id, String emailId);
  Future<void> clearCart(String emailId);
}