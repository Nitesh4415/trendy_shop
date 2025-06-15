import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/auth/domain/repositories/auth_repository.dart';
import 'package:shop_trendy/features/auth/domain/usecases/sign_out_usecase.dart';

// Generate a mock for AuthRepository
@GenerateMocks([AuthRepository])
import 'sign_out_usecase_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignOutUseCase usecase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignOutUseCase(mockAuthRepository);
  });

  group('SignOutUseCase', () {
    test(
      'should call signOut from the repository when the use case is executed',
      () async {
        // Arrange
        // Stub the repository method to return a successful Future.
        when(mockAuthRepository.signOut()).thenAnswer((_) async {});

        // Act
        // Execute the use case.
        await usecase();

        // Assert
        // Verify that the repository's signOut method was called exactly once.
        verify(mockAuthRepository.signOut());
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when sign out fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final testException = Exception('Sign out failed');
        when(mockAuthRepository.signOut()).thenThrow(testException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(() => call(), throwsA(isA<Exception>()));
      },
    );
  });
}
