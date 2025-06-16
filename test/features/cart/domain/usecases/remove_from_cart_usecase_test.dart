import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_trendy/features/cart/domain/usecases/remove_from_cart_usecase.dart';

// Generate a mock for CartRepository
@GenerateMocks([CartRepository])
import 'remove_from_cart_usecase_test.mocks.dart';

void main() {
  late MockCartRepository mockCartRepository;
  late RemoveFromCartUseCase usecase;

  // Test data
  const tItemId = 'item-to-remove';
  const tEmailId = 'user@example.com';

  setUp(() {
    mockCartRepository = MockCartRepository();
    usecase = RemoveFromCartUseCase(mockCartRepository);
  });

  group('RemoveFromCartUseCase', () {
    test(
      'should call removeFromCart on the repository with the correct parameters',
      () async {
        // Arrange
        // Stub the repository method to complete successfully.
        when(mockCartRepository.removeFromCart(any, any)).thenAnswer((_) async {
          return;
        });

        // Act
        // Execute the use case.
        await usecase(tItemId, tEmailId);

        // Assert
        // Verify that the repository's removeFromCart method was called exactly once
        // with the correct item ID and email ID.
        verify(mockCartRepository.removeFromCart(tItemId, tEmailId));
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockCartRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when removing from cart fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final testException = ServerException();
        when(
          mockCartRepository.removeFromCart(any, any),
        ).thenThrow(testException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(() => call(tItemId, tEmailId), throwsA(isA<ServerException>()));
      },
    );
  });
}
