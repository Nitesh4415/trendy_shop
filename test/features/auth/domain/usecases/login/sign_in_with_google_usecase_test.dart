import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/auth/domain/repositories/auth_repository.dart';
import 'package:shop_trendy/features/auth/domain/usecases/login_usecase/sign_in_with_google_usecase.dart';

// Generate a mock for AuthRepository and its return types
@GenerateMocks([AuthRepository, UserCredential])
import 'sign_in_with_google_usecase_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignInWithGoogleUseCase usecase;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInWithGoogleUseCase(mockAuthRepository);
    mockUserCredential = MockUserCredential();
  });

  group('SignInWithGoogleUseCase', () {
    test(
      'should get UserCredential from the repository when Google sign in is successful',
      () async {
        // Arrange
        // Stub the repository method to return a successful result.
        when(
          mockAuthRepository.signInWithGoogle(),
        ).thenAnswer((_) async => mockUserCredential);

        // Act
        // Execute the use case.
        final result = await usecase();

        // Assert
        // Expect that the result from the use case matches the one from the repository.
        expect(result, mockUserCredential);
        // Verify that the repository method was called.
        verify(mockAuthRepository.signInWithGoogle());
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockAuthRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when Google sign in fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final testException = Exception('Google sign in failed');
        when(mockAuthRepository.signInWithGoogle()).thenThrow(testException);

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
