import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/cart/domain/repositories/cart_repository.dart';
import 'package:shop_trendy/features/cart/domain/usecases/clear_cart_usecase.dart';

// Generate a mock for CartRepository
@GenerateMocks([CartRepository])
import 'clear_cart_usecase_test.mocks.dart';

void main() {
  late MockCartRepository mockCartRepository;
  late ClearCartUseCase usecase;

  // Test data
  const tEmailId = 'user@example.com';

  setUp(() {
    mockCartRepository = MockCartRepository();
    usecase = ClearCartUseCase(mockCartRepository);
  });

  group('ClearCartUseCase', () {
    test(
      'should call clearCart on the repository with the correct emailId',
      () async {
        // Arrange
        // Stub the repository method to complete successfully.
        when(mockCartRepository.clearCart(any)).thenAnswer((_) async {
          return null;
        });

        // Act
        // Execute the use case.
        await usecase(tEmailId);

        // Assert
        // Verify that the repository's clearCart method was called exactly once
        // with the correct email ID.
        verify(mockCartRepository.clearCart(tEmailId));
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockCartRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when clearing the cart fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final testException = ServerException();
        when(mockCartRepository.clearCart(any)).thenThrow(testException);

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
