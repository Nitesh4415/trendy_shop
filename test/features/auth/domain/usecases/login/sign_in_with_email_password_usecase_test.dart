import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/auth/domain/repositories/auth_repository.dart';
import 'package:shop_trendy/features/auth/domain/usecases/login_usecase/sign_in_with_email_password_usecase.dart';

// Generate a mock for AuthRepository and its return types
@GenerateMocks([AuthRepository, UserCredential])
import 'sign_in_with_email_password_usecase_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignInWithEmailPasswordUseCase usecase;
  late MockUserCredential mockUserCredential;

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInWithEmailPasswordUseCase(mockAuthRepository);
    mockUserCredential = MockUserCredential();
  });

  group('SignInWithEmailPasswordUseCase', () {
    test(
      'should get UserCredential from the repository when sign in is successful',
      () async {
        // Arrange
        // Stub the repository method to return a successful result.
        when(
          mockAuthRepository.signInWithEmailPassword(any, any),
        ).thenAnswer((_) async => mockUserCredential);

        // Act
        // Execute the use case with test credentials.
        final result = await usecase(tEmail, tPassword);

        // Assert
        // Expect that the result from the use case matches the one from the repository.
        expect(result, mockUserCredential);
        // Verify that the repository method was called with the correct email and password.
        verify(mockAuthRepository.signInWithEmailPassword(tEmail, tPassword));
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when sign in fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final testException = Exception('Sign in failed');
        when(
          mockAuthRepository.signInWithEmailPassword(any, any),
        ).thenThrow(testException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(() => call(tEmail, tPassword), throwsA(isA<Exception>()));
      },
    );
  });
}
