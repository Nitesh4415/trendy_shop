import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_trendy/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';

// Generate a mock for CartRepository
@GenerateMocks([CartRepository])
import 'update_cart_item_quantity_usecase_test.mocks.dart';

void main() {
  late MockCartRepository mockCartRepository;
  late UpdateCartItemQuantityUseCase usecase;

  // Test data
  const tItemId = 'item-123';
  const tQuantity = 3;
  const tEmailId = 'user@example.com';

  setUp(() {
    mockCartRepository = MockCartRepository();
    usecase = UpdateCartItemQuantityUseCase(mockCartRepository);
  });

  group('UpdateCartItemQuantityUseCase', () {
    test(
      'should call updateCartItemQuantity on the repository with the correct parameters',
      () async {
        // Arrange
        // Stub the repository method to complete successfully.
        when(
          mockCartRepository.updateCartItemQuantity(any, any, any),
        ).thenAnswer((_) async {});

        // Act
        // Execute the use case.
        await usecase(tItemId, tQuantity, tEmailId);

        // Assert
        // Verify that the repository's updateCartItemQuantity method was called exactly once
        // with the correct item ID, quantity, and email ID.
        verify(
          mockCartRepository.updateCartItemQuantity(
            tItemId,
            tQuantity,
            tEmailId,
          ),
        );
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockCartRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when updating quantity fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final testException = ServerException();
        when(
          mockCartRepository.updateCartItemQuantity(any, any, any),
        ).thenThrow(testException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(
          () => call(tItemId, tQuantity, tEmailId),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
