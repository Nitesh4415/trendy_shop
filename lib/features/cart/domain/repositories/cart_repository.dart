import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Future<void> addToCart(CartItem item);
  Future<void> removeFromCart(String itemId);
  Future<void> updateCartItemQuantity(String itemId, int quantity);
  Future<void> clearCart();
}