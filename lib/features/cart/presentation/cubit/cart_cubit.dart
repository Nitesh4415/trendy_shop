import 'dart:async'; // Import for StreamSubscription
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop_trendy/features/auth/presentation/cubit/auth_cubit.dart'; // Import AuthCubit
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
  final CreatePaymentIntentUseCase _createPaymentIntent;
  final AuthCubit _authCubit; // New dependency
  late final StreamSubscription _authSubscription; // Subscription to listen for auth changes

  CartCubit(
      this._addToCart,
      this._removeFromCart,
      this._updateCartItemQuantity,
      this._getCartItems,
      this._clearCart,
      this._createPaymentIntent,
      this._authCubit, // Inject AuthCubit
      ) : super(CartInitial()) {
    // Listen to auth state changes to clear/load the cart.
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState is AuthAuthenticated) {
        // When a new user logs in, load their cart using their unique email.
        if (authState.user.email != null) {
          loadCartItems(authState.user.email!);
        }
      } else if (authState is AuthUnauthenticated) {
        // When the user logs out, clear the cart data.
        _clearCartOnSignOut();
      }
    });
  }

  // Helper to safely get the current user's email.
  String? get _currentUserEmail {
    final authState = _authCubit.state;
    if (authState is AuthAuthenticated) {
      return authState.user.email;
    }
    return null;
  }

  void _clearCartOnSignOut() {
    emit(const CartLoaded(items: []));
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

  // This method now requires the user's email to fetch the correct cart.
  Future<void> loadCartItems(String email) async {
    emit(CartLoading());
    try {
      // NOTE: This assumes your GetCartItemsUseCase has been updated to accept an email.
      // Example: final items = await _getCartItems.call(email);
      final items = await _getCartItems(email);
      emit(CartLoaded(items: items));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> addItemToCart(CartItem newItem) async {
    final email = _currentUserEmail;
    if (email == null) {
      emit(const CartError("User not logged in. Cannot modify cart."));
      return;
    }

    final currentState = state;
    // Get the current list of items, or an empty list if the cart is initial.
    List<CartItem> currentItems = [];
    if(currentState is CartLoaded) {
      currentItems = currentState.items;
    }

    final existingItemIndex = currentItems.indexWhere(
          (item) => item.product.id == newItem.product.id,
    );

    if (existingItemIndex != -1) {
      // Item already in cart, update its quantity.
      final existingItem = currentItems[existingItemIndex];
      final updatedItem = existingItem.copyWith(
          quantity: existingItem.quantity + newItem.quantity
      );
      // Call the database to update.
      await _updateCartItemQuantity(updatedItem.id,updatedItem.quantity, email);
      // Create a new list with the updated item.
      final updatedItems = List<CartItem>.from(currentItems);
      updatedItems[existingItemIndex] = updatedItem;
      // Emit the new state.
      emit(CartLoaded(items: updatedItems));
    } else {
      // Item is not in the cart, add it.
      // Call the database to add the new item.
      await _addToCart(newItem, email);
      // Create a new list with the added item.
      final updatedItems = List<CartItem>.from(currentItems)..add(newItem);
      // Emit the new state.
      emit(CartLoaded(items: updatedItems));
    }
  }

  Future<void> removeItemFromCart(String itemId) async {
    final email = _currentUserEmail;
    if (email == null) {
      emit(const CartError("User not logged in. Cannot modify cart."));
      return;
    }

    final currentState = state;
    if (currentState is CartLoaded) {
      // NOTE: This assumes your use case now accepts an email.
      await _removeFromCart(itemId, email);
      final updatedItems = List<CartItem>.from(currentState.items)
        ..removeWhere((item) => item.id == itemId);
      emit(CartLoaded(items: updatedItems));
    }
  }

  Future<void> _updateItemQuantity(String itemId, int newQuantity) async {
    final email = _currentUserEmail;
    if (email == null) {
      emit(const CartError("User not logged in. Cannot modify cart."));
      return;
    }

    final currentState = state;
    if (currentState is CartLoaded) {
      final itemIndex = currentState.items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final item = currentState.items[itemIndex];
        if (newQuantity > 0) {
          final updatedItem = item.copyWith(quantity: newQuantity);
          // NOTE: This assumes your use case now accepts an email.
          await _updateCartItemQuantity(updatedItem.id,updatedItem.quantity, email);
          final updatedItems = List<CartItem>.from(currentState.items);
          updatedItems[itemIndex] = updatedItem;
          emit(CartLoaded(items: updatedItems));
        } else {
          // If quantity is 0 or less, remove the item.
          await _removeFromCart(itemId, email);
          final updatedItems = List<CartItem>.from(currentState.items)..removeAt(itemIndex);
          emit(CartLoaded(items: updatedItems));
        }
      }
    }
  }

  Future<void> incrementQuantity(String itemId) async {
    if (state is CartLoaded) {
      final currentQuantity = (state as CartLoaded).items.firstWhere((item) => item.id == itemId).quantity;
      await _updateItemQuantity(itemId, currentQuantity + 1);
    }
  }

  Future<void> decrementQuantity(String itemId) async {
    if (state is CartLoaded) {
      final currentQuantity = (state as CartLoaded).items.firstWhere((item) => item.id == itemId).quantity;
      await _updateItemQuantity(itemId, currentQuantity - 1);
    }
  }

  Future<void> clearAllItems() async {
    final email = _currentUserEmail;
    if (email == null) {
      emit(const CartError("User not logged in. Cannot clear cart."));
      return;
    }

    emit(CartLoading());
    try {
      // NOTE: This assumes your use case now accepts an email.
      await _clearCart(email);
      emit(const CartLoaded(items: []));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> initiatePayment(double amount, String currency) async {
    final email = _currentUserEmail;
    if (email == null) {
      emit(const CartError("User not logged in. Cannot process payment."));
      return;
    }

    emit(CartLoading());
    try {
      final clientSecret = await _createPaymentIntent(amount, currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'E-commerce App',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Clear the cart for the specific user upon successful payment.
      await _clearCart(email);
      emit(const CartPaymentSuccess());
      emit(const CartLoaded(items: []));

    } on StripeException catch (e) {
      String message = 'Payment failed: ${e.error.message}';
      if (e.error.message == "Canceled") {
        message = "Payment cancelled by user.";
      }
      emit(CartError(message));
      final previousState = state;
      if (previousState is CartLoaded) {
        emit(CartLoaded(items: previousState.items));
      } else {
        loadCartItems(email); // Reload cart on failure if it wasn't loaded
      }
    } catch (e) {
      emit(CartError('An unexpected error occurred during payment: ${e.toString()}'));
      final previousState = state;
      if (previousState is CartLoaded) {
        emit(CartLoaded(items: previousState.items));
      } else {
        loadCartItems(email); // Reload cart on failure if it wasn't loaded
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
