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
  Future<void> addToCart(CartItem item) async {
    try {
      // Convert domain entity to data model for passing to data source
      await _localDataSource.saveCartItem(item);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _localDataSource.clearCart();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CartItem>> getCartItems() async {
    try {
      // Get entities directly from data source
      final cartItems = await _localDataSource.getCartItems();
      return cartItems;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeFromCart(String itemId) async {
    try {
      await _localDataSource.deleteCartItem(itemId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCartItemQuantity(String itemId, int quantity) async {
    try {
      final currentItems = await _localDataSource.getCartItems();
      final itemToUpdate = currentItems.firstWhere((item) => item.id == itemId);
      await _localDataSource.updateCartItem(
          itemToUpdate.copyWith(quantity: quantity));
    } catch (e) {
      rethrow;
    }
  }
}