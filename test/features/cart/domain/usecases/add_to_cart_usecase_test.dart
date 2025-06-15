import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/cart/domain/entities/cart_item.dart';
import 'package:shop_trendy/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_trendy/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';

// Generate a mock for CartRepository
@GenerateMocks([CartRepository])
import 'add_to_cart_usecase_test.mocks.dart';

void main() {
  late MockCartRepository mockCartRepository;
  late AddToCartUseCase usecase;

  // Test data
  const tEmailId = 'user@example.com';
  final tProduct = Product(
    id: 1,
    title: 'Sample Product',
    price: 123.45,
    description: '',
    category: '',
    image: '',
    rating: Rating(rate: 4, count: 10),
  );
  final tCartItem = CartItem(id: 'item-1', product: tProduct, quantity: 1);

  setUp(() {
    mockCartRepository = MockCartRepository();
    usecase = AddToCartUseCase(mockCartRepository);
  });

  group('AddToCartUseCase', () {
    test(
      'should call addToCart on the repository with the correct parameters',
      () async {
        // Arrange
        // Stub the repository method to complete successfully.
        when(mockCartRepository.addToCart(any, any)).thenAnswer((_) async {
          return null;
        });

        // Act
        // Execute the use case.
        await usecase(tCartItem, tEmailId);

        // Assert
        // Verify that the repository's addToCart method was called exactly once
        // with the correct cart item and email ID.
        verify(mockCartRepository.addToCart(tCartItem, tEmailId));
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockCartRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when adding to cart fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final testException = ServerException();
        when(mockCartRepository.addToCart(any, any)).thenThrow(testException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(
          () => call(tCartItem, tEmailId),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
