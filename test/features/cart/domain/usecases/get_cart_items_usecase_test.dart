import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/cart/domain/entities/cart_item.dart';
import 'package:shop_trendy/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_trendy/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';

// Generate a mock for CartRepository
@GenerateMocks([CartRepository])
import 'get_cart_items_usecase_test.mocks.dart';

void main() {
  late MockCartRepository mockCartRepository;
  late GetCartItemsUseCase usecase;

  // Test data
  const tEmailId = 'user@example.com';
  final tCartItems = [
    CartItem(
      id: 'item-1',
      product: Product(
        id: 1,
        title: 'Sample Product 1',
        price: 10.0,
        description: '',
        category: '',
        image: '',
        rating: Rating(rate: 4.5, count: 10),
      ),
      quantity: 2,
    ),
    CartItem(
      id: 'item-2',
      product: Product(
        id: 2,
        title: 'Sample Product 2',
        price: 20.0,
        description: '',
        category: '',
        image: '',
        rating: Rating(rate: 4.0, count: 5),
      ),
      quantity: 1,
    ),
  ];

  setUp(() {
    mockCartRepository = MockCartRepository();
    usecase = GetCartItemsUseCase(mockCartRepository);
  });

  group('GetCartItemsUseCase', () {
    test(
      'should get a list of cart items from the repository for the given emailId',
      () async {
        // Arrange
        // Stub the repository method to return a successful result.
        when(
          mockCartRepository.getCartItems(any),
        ).thenAnswer((_) async => tCartItems);

        // Act
        // Execute the use case.
        final result = await usecase(tEmailId);

        // Assert
        // Expect that the result from the use case matches the one from the repository.
        expect(result, tCartItems);
        // Verify that the repository's getCartItems method was called exactly once
        // with the correct email ID.
        verify(mockCartRepository.getCartItems(tEmailId));
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockCartRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when getting cart items fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final testException = ServerException();
        when(mockCartRepository.getCartItems(any)).thenThrow(testException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(() => call(tEmailId), throwsA(isA<ServerException>()));
      },
    );
  });
}
