import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:shop_trendy/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shop_trendy/features/cart/domain/entities/cart_item.dart';
import 'package:shop_trendy/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';

// Generate a mock for CartLocalDataSource
@GenerateMocks([CartLocalDataSource])
import 'cart_repository_test.mocks.dart';

void main() {
  late MockCartLocalDataSource mockLocalDataSource;
  late CartRepository repository;

  // Test data
  const tEmailId = 'test@example.com';
  final tProduct = Product(
    id: 1,
    title: 'Test Product',
    price: 100,
    description: '',
    category: '',
    image: '',
    rating: Rating(rate: 4, count: 10),
  );
  final tCartItem = CartItem(id: '1', product: tProduct, quantity: 1);
  final List<CartItem> tCartItems = [tCartItem];

  setUp(() {
    mockLocalDataSource = MockCartLocalDataSource();
    repository = CartRepositoryImpl(mockLocalDataSource);
  });

  group('CartRepositoryImpl', () {
    group('getCartItems', () {
      test(
        'should return list of CartItem when call to local data source is successful',
        () async {
          // Arrange
          when(
            mockLocalDataSource.getCartItems(any),
          ).thenAnswer((_) async => tCartItems);
          // Act
          final result = await repository.getCartItems(tEmailId);
          // Assert
          expect(result, tCartItems);
          verify(mockLocalDataSource.getCartItems(tEmailId));
          verifyNoMoreInteractions(mockLocalDataSource);
        },
      );
    });

    group('addToCart', () {
      test('should call saveCartItem on the local data source', () async {
        // Arrange
        when(mockLocalDataSource.saveCartItem(any, any)).thenAnswer((_) async {
          return;
        });
        // Act
        await repository.addToCart(tCartItem, tEmailId);
        // Assert
        verify(mockLocalDataSource.saveCartItem(tCartItem, tEmailId));
        verifyNoMoreInteractions(mockLocalDataSource);
      });
    });

    group('removeFromCart', () {
      const tItemId = '1';
      test('should call deleteCartItem on the local data source', () async {
        // Arrange
        when(mockLocalDataSource.deleteCartItem(any, any)).thenAnswer((
          _,
        ) async {
          return;
        });
        // Act
        await repository.removeFromCart(tItemId, tEmailId);
        // Assert
        verify(mockLocalDataSource.deleteCartItem(tItemId, tEmailId));
        verifyNoMoreInteractions(mockLocalDataSource);
      });
    });

    group('updateCartItemQuantity', () {
      const tItemId = '1';
      const tQuantity = 5;
      test('should update item quantity in the local data source', () async {
        // Arrange
        when(
          mockLocalDataSource.getCartItems(any),
        ).thenAnswer((_) async => tCartItems);
        when(mockLocalDataSource.updateCartItem(any, any)).thenAnswer((
          _,
        ) async {
          return;
        });

        // Act
        await repository.updateCartItemQuantity(tItemId, tQuantity, tEmailId);

        // Assert
        // Verify that the updated item is passed to the data source
        final expectedUpdatedItem = tCartItem.copyWith(quantity: tQuantity);
        verify(mockLocalDataSource.getCartItems(tEmailId));
        verify(
          mockLocalDataSource.updateCartItem(expectedUpdatedItem, tEmailId),
        );
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test(
        'should throw an exception if item to update is not found',
        () async {
          // Arrange
          when(
            mockLocalDataSource.getCartItems(any),
          ).thenAnswer((_) async => []); // Return empty list

          // Act
          final call = repository.updateCartItemQuantity;

          // Assert
          expect(
            () => call('non_existent_id', tQuantity, tEmailId),
            throwsA(isA<StateError>()),
          );
        },
      );
    });

    group('clearCart', () {
      test('should call clearCart on the local data source', () async {
        // Arrange
        when(mockLocalDataSource.clearCart(any)).thenAnswer((_) async {
          return;
        });
        // Act
        await repository.clearCart(tEmailId);
        // Assert
        verify(mockLocalDataSource.clearCart(tEmailId));
        verifyNoMoreInteractions(mockLocalDataSource);
      });
    });
  });
}
