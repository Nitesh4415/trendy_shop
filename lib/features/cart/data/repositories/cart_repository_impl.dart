import 'package:injectable/injectable.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';

// Implementation of the CartRepository.
@LazySingleton(as: CartRepository)
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _localDataSource;

  CartRepositoryImpl(this._localDataSource);

  @override
  Future<void> addToCart(CartItem item, String emailId) async {
    try {
      // Convert domain entity to data model for passing to data source
      await _localDataSource.saveCartItem(item, emailId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearCart(String emailId) async {
    try {
      await _localDataSource.clearCart(emailId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CartItem>> getCartItems(String emailId) async {
    try {
      // Get entities directly from data source
      final cartItems = await _localDataSource.getCartItems(emailId);
      return cartItems;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeFromCart(String itemId, String emailId) async {
    try {
      await _localDataSource.deleteCartItem(itemId, emailId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCartItemQuantity(
    String itemId,
    int quantity,
    String emailId,
  ) async {
    try {
      final currentItems = await _localDataSource.getCartItems(emailId);
      final itemToUpdate = currentItems.firstWhere((item) => item.id == itemId);
      await _localDataSource.updateCartItem(
        itemToUpdate.copyWith(quantity: quantity),
        emailId,
      );
    } catch (e) {
      rethrow;
    }
  }
}
