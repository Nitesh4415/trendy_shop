import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems(String emailId);
  Future<void> addToCart(CartItem item, String emailId);
  Future<void> removeFromCart(String itemId, String emailId);
  Future<void> updateCartItemQuantity(
    String itemId,
    int quantity,
    String emailId,
  );
  Future<void> clearCart(String emailId);
}
