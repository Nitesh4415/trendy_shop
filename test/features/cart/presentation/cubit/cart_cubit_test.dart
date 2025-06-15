import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/services.dart'; // Import for platform channel mocking
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/auth/domain/entities/user.dart' as app_user;
import 'package:shop_trendy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shop_trendy/features/cart/domain/entities/cart_item.dart';
import 'package:shop_trendy/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:shop_trendy/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:shop_trendy/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:shop_trendy/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:shop_trendy/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:shop_trendy/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shop_trendy/features/payment/domain/usecases/create_payment_intent_usecase.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';

// Generate mocks for all dependencies
@GenerateMocks([
  AddToCartUseCase,
  RemoveFromCartUseCase,
  UpdateCartItemQuantityUseCase,
  GetCartItemsUseCase,
  ClearCartUseCase,
  CreatePaymentIntentUseCase,
  AuthCubit,
  firebase_auth.User
])
import 'cart_cubit_test.mocks.dart';

void main() {
  // Ensure Flutter test bindings are initialized for platform channel mocking
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mocks
  late MockAddToCartUseCase mockAddToCartUseCase;
  late MockRemoveFromCartUseCase mockRemoveFromCartUseCase;
  late MockUpdateCartItemQuantityUseCase mockUpdateCartItemQuantityUseCase;
  late MockGetCartItemsUseCase mockGetCartItemsUseCase;
  late MockClearCartUseCase mockClearCartUseCase;
  late MockCreatePaymentIntentUseCase mockCreatePaymentIntentUseCase;
  late MockAuthCubit mockAuthCubit;
  late StreamController<AuthState> authStateController;

  // Test Data
  final mockFirebaseUser = MockUser();
  const testEmail = 'test@example.com';
  final testAppUser = app_user.User(id: 1, email: testEmail, username: 'test', password: 'password');
  final authenticatedState = AuthAuthenticated(user: mockFirebaseUser, appUser: testAppUser);
  final unauthenticatedState = AuthUnauthenticated();

  final product1 = Product(id: 1, title: 'Product 1', price: 10.0, description: '', category: '', image: '', rating: Rating(rate: 4.5, count: 10));
  final product2 = Product(id: 2, title: 'Product 2', price: 20.0, description: '', category: '', image: '', rating: Rating(rate: 4.0, count: 5));

  final cartItem1 = CartItem(id: 'item1', product: product1, quantity: 1);
  final cartItem2 = CartItem(id: 'item2', product: product2, quantity: 2);

  setUp(() {
    mockAddToCartUseCase = MockAddToCartUseCase();
    mockRemoveFromCartUseCase = MockRemoveFromCartUseCase();
    mockUpdateCartItemQuantityUseCase = MockUpdateCartItemQuantityUseCase();
    mockGetCartItemsUseCase = MockGetCartItemsUseCase();
    mockClearCartUseCase = MockClearCartUseCase();
    mockCreatePaymentIntentUseCase = MockCreatePaymentIntentUseCase();
    mockAuthCubit = MockAuthCubit();
    authStateController = StreamController<AuthState>.broadcast();

    // Stub the stream and state for the mock AuthCubit
    when(mockAuthCubit.stream).thenAnswer((_) => authStateController.stream);
    when(mockAuthCubit.state).thenReturn(AuthInitial()); // Default initial state

    // Stub the mock user's email
    when(mockFirebaseUser.email).thenReturn(testEmail);
  });

  tearDown(() {
    authStateController.close();
  });

  // A helper function to create the cubit and stub the initial auth state
  CartCubit createCubit({required AuthState initialAuthState}) {
    when(mockAuthCubit.state).thenReturn(initialAuthState);
    return CartCubit(
      mockAddToCartUseCase,
      mockRemoveFromCartUseCase,
      mockUpdateCartItemQuantityUseCase,
      mockGetCartItemsUseCase,
      mockClearCartUseCase,
      mockCreatePaymentIntentUseCase,
      mockAuthCubit,
    );
  }

  group('CartCubit', () {
    test('initial state is CartInitial', () {
      final cartCubit = createCubit(initialAuthState: AuthInitial());
      expect(cartCubit.state, CartInitial());
    });

    group('Authentication State Changes', () {
      blocTest<CartCubit, CartState>(
        'loads cart when user becomes authenticated',
        setUp: () {
          when(mockGetCartItemsUseCase.call(testEmail)).thenAnswer((_) async => [cartItem1]);
        },
        build: () => createCubit(initialAuthState: AuthInitial()),
        act: (cubit) {
          // Simulate the auth state change
          authStateController.add(authenticatedState);
        },
        expect: () => [
          CartLoading(),
          CartLoaded(items: [cartItem1]),
        ],
        verify: (_) {
          verify(mockGetCartItemsUseCase.call(testEmail)).called(1);
        },
      );

      blocTest<CartCubit, CartState>(
        'clears cart when user becomes unauthenticated',
        build: () => createCubit(initialAuthState: authenticatedState),
        act: (cubit) {
          // Simulate the auth state change
          authStateController.add(unauthenticatedState);
        },
        expect: () => [
          const CartLoaded(items: []),
        ],
      );
    });

    group('addItemToCart', () {
      blocTest<CartCubit, CartState>(
        'adds a new item to an empty cart',
        setUp: () {
          when(mockAddToCartUseCase.call(cartItem1, testEmail)).thenAnswer((_) async {});
        },
        build: () => createCubit(initialAuthState: authenticatedState),
        seed: () => const CartLoaded(items: []),
        act: (cubit) => cubit.addItemToCart(cartItem1),
        expect: () => [
          CartLoaded(items: [cartItem1]),
        ],
        verify: (_) {
          verify(mockAddToCartUseCase.call(cartItem1, testEmail)).called(1);
        },
      );

      blocTest<CartCubit, CartState>(
        'updates quantity if item already exists',
        setUp: () {
          // Assuming UpdateCartItemQuantityUseCase takes (id, quantity, email)
          when(mockUpdateCartItemQuantityUseCase.call(any, any, any)).thenAnswer((_) async {});
        },
        build: () => createCubit(initialAuthState: authenticatedState),
        seed: () => CartLoaded(items: [cartItem1]),
        act: (cubit) => cubit.addItemToCart(cartItem1), // Add the same item again
        expect: () => [
          CartLoaded(items: [cartItem1.copyWith(quantity: 2)]),
        ],
        verify: (_) {
          // Verify that the update use case was called with the correct parameters
          verify(mockUpdateCartItemQuantityUseCase.call(cartItem1.id, 2, testEmail)).called(1);
        },
      );

      blocTest<CartCubit, CartState>(
        'emits CartError if user is not authenticated',
        build: () => createCubit(initialAuthState: unauthenticatedState),
        act: (cubit) => cubit.addItemToCart(cartItem1),
        expect: () => [const CartError("User not logged in. Cannot modify cart.")],
      );
    });

    group('removeItemFromCart', () {
      blocTest<CartCubit, CartState>(
        'removes an item from the cart',
        setUp: () {
          when(mockRemoveFromCartUseCase.call(cartItem1.id, testEmail)).thenAnswer((_) async {});
        },
        build: () => createCubit(initialAuthState: authenticatedState),
        seed: () => CartLoaded(items: [cartItem1, cartItem2]),
        act: (cubit) => cubit.removeItemFromCart(cartItem1.id),
        expect: () => [
          CartLoaded(items: [cartItem2]),
        ],
        verify: (_) {
          verify(mockRemoveFromCartUseCase.call(cartItem1.id, testEmail)).called(1);
        },
      );
    });

    group('incrementQuantity', () {
      blocTest<CartCubit, CartState>(
        'increments quantity of an item',
        setUp: () {
          when(mockUpdateCartItemQuantityUseCase.call(any, any, any)).thenAnswer((_) async {});
        },
        build: () => createCubit(initialAuthState: authenticatedState),
        seed: () => CartLoaded(items: [cartItem1]),
        act: (cubit) => cubit.incrementQuantity(cartItem1.id),
        expect: () => [
          CartLoaded(items: [cartItem1.copyWith(quantity: 2)]),
        ],
        verify: (_) {
          verify(mockUpdateCartItemQuantityUseCase.call(cartItem1.id, 2, testEmail)).called(1);
        },
      );
    });

    group('decrementQuantity', () {
      blocTest<CartCubit, CartState>(
        'decrements quantity of an item',
        setUp: () {
          when(mockUpdateCartItemQuantityUseCase.call(cartItem2.id, 1, testEmail)).thenAnswer((_) async {});
        },
        build: () => createCubit(initialAuthState: authenticatedState),
        seed: () => CartLoaded(items: [cartItem2]),
        act: (cubit) => cubit.decrementQuantity(cartItem2.id),
        expect: () => [
          CartLoaded(items: [cartItem2.copyWith(quantity: 1)]),
        ],
      );

      blocTest<CartCubit, CartState>(
        'removes item if quantity becomes 0',
        setUp: () {
          when(mockRemoveFromCartUseCase.call(cartItem1.id, testEmail)).thenAnswer((_) async {});
        },
        build: () => createCubit(initialAuthState: authenticatedState),
        seed: () => CartLoaded(items: [cartItem1]),
        act: (cubit) => cubit.decrementQuantity(cartItem1.id),
        expect: () => [
          const CartLoaded(items: []),
        ],
      );
    });

    group('clearAllItems', () {
      blocTest<CartCubit, CartState>(
        'clears all items from the cart',
        setUp: () {
          when(mockClearCartUseCase.call(testEmail)).thenAnswer((_) async {});
        },
        build: () => createCubit(initialAuthState: authenticatedState),
        seed: () => CartLoaded(items: [cartItem1, cartItem2]),
        act: (cubit) => cubit.clearAllItems(),
        expect: () => [
          CartLoading(),
          const CartLoaded(items: []),
        ],
        verify: (_) {
          verify(mockClearCartUseCase.call(testEmail)).called(1);
        },
      );
    });

    group('initiatePayment', () {
      setUpAll(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('flutter.stripe/payments'),
              (MethodCall methodCall) async {
            if (methodCall.method == 'initPaymentSheet' || methodCall.method == 'presentPaymentSheet') {
              return {};
            }
            return null;
          },
        );
        Stripe.publishableKey = 'pk_test_dummy';
      });

      tearDownAll(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('flutter.stripe/payments'),
          null,
        );
      });
    });
  });
}
