import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/auth/data/datasources/auth_remote_datasource_impl.dart';

// Generate mocks for the Firebase and Google dependencies
@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  UserCredential,
  User,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
import 'auth_remote_datasource_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthRemoteDataSourceImpl dataSource;

  // Mocks for return values
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    dataSource = AuthRemoteDataSourceImpl(mockFirebaseAuth);
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();

    // Stub the UserCredential to return a mock User
    when(mockUserCredential.user).thenReturn(mockUser);
  });

  group('AuthRemoteDataSourceImpl', () {
    group('signInWithEmailPassword', () {
      test('should return UserCredential when sign in is successful', () async {
        // Arrange
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await dataSource.signInWithEmailPassword(
          tEmail,
          tPassword,
        );

        // Assert
        expect(result, equals(mockUserCredential));
        verify(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        );
      });

      test('should throw an Exception when sign in fails', () async {
        // Arrange
        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found',
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.signInWithEmailPassword(tEmail, tPassword),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signUpWithEmailPassword', () {
      test('should return UserCredential when sign up is successful', () async {
        // Arrange
        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await dataSource.signUpWithEmailPassword(
          tEmail,
          tPassword,
        );

        // Assert
        expect(result, equals(mockUserCredential));
        verify(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        );
      });

      test('should throw an Exception when sign up fails', () async {
        // Arrange
        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: tEmail,
            password: tPassword,
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email already in use',
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.signUpWithEmailPassword(tEmail, tPassword),
          throwsA(isA<Exception>()),
        );
      });
    });

    // Note: To test GoogleSignIn, we need to mock the GoogleSignIn instance inside the method.
    // This is a common pattern when a dependency is not injected.
    group('signInWithGoogle', () {
      // This test is more complex due to the chained calls.
      // A cleaner approach in real code would be to inject GoogleSignIn.
      // However, we can test the existing code by mocking the static call.
      // This part of the test is more for demonstration and might be brittle.
      // For a robust test, consider refactoring to inject GoogleSignIn.
    });

    group('signOut', () {
      test(
        'should complete successfully when sign out is successful',
        () async {
          // Arrange
          when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

          // Act
          await dataSource.signOut();

          // Assert
          verify(mockFirebaseAuth.signOut()).called(1);
        },
      );

      test('should throw an Exception when sign out fails', () async {
        // Arrange
        when(
          mockFirebaseAuth.signOut(),
        ).thenThrow(FirebaseAuthException(code: 'error'));

        // Act & Assert
        expect(() => dataSource.signOut(), throwsA(isA<Exception>()));
      });
    });

    group('authStateChanges', () {
      test('should return a stream of User? from FirebaseAuth', () {
        // Arrange
        final userStream = Stream.fromIterable([mockUser, null]);
        when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => userStream);

        // Act
        final result = dataSource.authStateChanges;

        // Assert
        expect(result, isA<Stream<User?>>());
        expect(result, emitsInOrder([mockUser, null]));
      });
    });
  });
}
