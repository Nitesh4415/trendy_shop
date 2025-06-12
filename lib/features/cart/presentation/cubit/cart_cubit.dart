import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop_trendy/features/cart/domain/entities/cart_item.dart';
import 'package:shop_trendy/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:shop_trendy/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:shop_trendy/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:shop_trendy/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:shop_trendy/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:shop_trendy/features/payment/domain/usecases/create_payment_intent_usecase.dart';
part 'cart_state.dart';

@LazySingleton()
class CartCubit extends Cubit<CartState> {
  final AddToCartUseCase _addToCart;
  final RemoveFromCartUseCase _removeFromCart;
  final UpdateCartItemQuantityUseCase _updateCartItemQuantity;
  final GetCartItemsUseCase _getCartItems;
  final ClearCartUseCase _clearCart;
  final CreatePaymentIntentUseCase _createPaymentIntent; // New dependency

  CartCubit(
      this._addToCart,
      this._removeFromCart,
      this._updateCartItemQuantity,
      this._getCartItems,
      this._clearCart,
      this._createPaymentIntent,
      ) : super(CartInitial());

  Future<void> loadCartItems() async {
    emit(CartLoading());
    try {
      final items = await _getCartItems();
      emit(CartLoaded(items: items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> addItemToCart(CartItem newItem) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final existingItemIndex = currentState.items.indexWhere(
            (item) => item.product.id == newItem.product.id,
      );

      if (existingItemIndex != -1) {
        // Item already in cart, update quantity
        final existingItem = currentState.items[existingItemIndex];
        final updatedQuantity = existingItem.quantity + newItem.quantity;
        if (updatedQuantity > 0) {
          final updatedItem = existingItem.copyWith(quantity: updatedQuantity);
          await _updateCartItemQuantity(updatedItem.id, updatedQuantity);
          final updatedItems = List<CartItem>.from(currentState.items);
          updatedItems[existingItemIndex] = updatedItem;
          emit(CartLoaded(items: updatedItems));
        } else {
          // If quantity becomes 0 or less, remove the item
          await _removeFromCart(existingItem.id);
          final updatedItems = List<CartItem>.from(currentState.items)
            ..removeAt(existingItemIndex);
          emit(CartLoaded(items: updatedItems));
        }
      } else {
        // Item not in cart, add new item
        await _addToCart(newItem);
        final updatedItems = List<CartItem>.from(currentState.items)..add(newItem);
        emit(CartLoaded(items: updatedItems));
      }
    } else {
      // If not CartLoaded state, just add the item
      await _addToCart(newItem);
      emit(CartLoaded(items: [newItem]));
    }
  }

  Future<void> removeItemFromCart(String itemId) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      await _removeFromCart(itemId);
      final updatedItems = List<CartItem>.from(currentState.items)
        ..removeWhere((item) => item.id == itemId);
      emit(CartLoaded(items: updatedItems));
    }
  }

  Future<void> incrementQuantity(String itemId) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final itemIndex = currentState.items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final currentItem = currentState.items[itemIndex];
        final newQuantity = currentItem.quantity + 1;
        await _updateCartItemQuantity(itemId, newQuantity);
        final updatedItems = List<CartItem>.from(currentState.items);
        updatedItems[itemIndex] = currentItem.copyWith(quantity: newQuantity);
        emit(CartLoaded(items: updatedItems));
      }
    }
  }

  Future<void> decrementQuantity(String itemId) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final itemIndex = currentState.items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final currentItem = currentState.items[itemIndex];
        final newQuantity = currentItem.quantity - 1;
        if (newQuantity > 0) {
          await _updateCartItemQuantity(itemId, newQuantity);
          final updatedItems = List<CartItem>.from(currentState.items);
          updatedItems[itemIndex] = currentItem.copyWith(quantity: newQuantity);
          emit(CartLoaded(items: updatedItems));
        } else {
          // If quantity becomes 0, remove the item
          await _removeFromCart(itemId);
          final updatedItems = List<CartItem>.from(currentState.items)
            ..removeAt(itemIndex);
          emit(CartLoaded(items: updatedItems));
        }
      }
    }
  }

  Future<void> clearAllItems() async {
    emit(CartLoading());
    try {
      await _clearCart();
      emit(const CartLoaded(items: []));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  // method for Stripe payment integration
  Future<void> initiatePayment(double amount, String currency) async {
    emit(CartLoading()); // Indicate loading state for payment process
    try {
      // backend call to create a PaymentIntent and get the clientSecret
      final clientSecret = await _createPaymentIntent(amount, currency);

      // Initialize Payment Sheet with the clientSecret from  backend
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'E-commerce App',
          customerId: null, // pass Stripe Customer ID if available
          customerEphemeralKeySecret: null, // Ephemeral key is needed if customerId is passed
          // currency: currency, // Optional, can be set here if not implied by paymentIntentClientSecret
        ),
      );

      // Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // If payment is successful, clear cart and emit success
      await _clearCart();
      emit(const CartPaymentSuccess()); //
      emit(const CartLoaded(items: [])); // Reset cart to empty after successful payment

    } on StripeException catch (e) {
      String message = 'Payment failed: ${e.error.message}';
      if (e.error.message == "Canceled") {
        message = "Payment cancelled by user.";
      }
      emit(CartError(message));
      // Re-emit previous cart state if it was loaded
      final previousState = state;
      if (previousState is CartLoaded) {
        emit(CartLoaded(items: previousState.items));
      } else {
        loadCartItems(); // Reload cart if state was not loaded
      }
    } catch (e) {
      emit(CartError('An unexpected error occurred during payment: ${e.toString()}'));
      // Re-emit previous cart state if it was loaded
      final previousState = state;
      if (previousState is CartLoaded) {
        emit(CartLoaded(items: previousState.items));
      } else {
        loadCartItems(); // Reload cart if state was not loaded
      }
    }
  }


  double get cartTotalPrice {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
    }
    return 0.0;
  }

  int get totalCartItemsCount {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.items.fold(0, (sum, item) => sum + item.quantity);
    }
    return 0;
  }
}