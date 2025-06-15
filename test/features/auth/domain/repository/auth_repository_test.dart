import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:shop_trendy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shop_trendy/features/auth/domain/repositories/auth_repository.dart';

// Generate mocks for the dependencies
@GenerateMocks([AuthRemoteDataSource, UserCredential, User])
import 'auth_repository_test.mocks.dart';

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late AuthRepository repository;

  // Mocks for return values
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockRemoteDataSource);
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
  });

  group('AuthRepositoryImpl', () {
    group('signInWithEmailPassword', () {
      test(
        'should return UserCredential when call to data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.signInWithEmailPassword(any, any),
          ).thenAnswer((_) async => mockUserCredential);
          // Act
          final result = await repository.signInWithEmailPassword(
            tEmail,
            tPassword,
          );
          // Assert
          expect(result, equals(mockUserCredential));
          verify(
            mockRemoteDataSource.signInWithEmailPassword(tEmail, tPassword),
          );
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should rethrow the exception when call to data source is unsuccessful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.signInWithEmailPassword(any, any),
          ).thenThrow(Exception('Sign in failed'));
          // Act
          final call = repository.signInWithEmailPassword;
          // Assert
          expect(() => call(tEmail, tPassword), throwsA(isA<Exception>()));
        },
      );
    });

    group('signUpWithEmailPassword', () {
      test(
        'should return UserCredential when call to data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.signUpWithEmailPassword(any, any),
          ).thenAnswer((_) async => mockUserCredential);
          // Act
          final result = await repository.signUpWithEmailPassword(
            tEmail,
            tPassword,
          );
          // Assert
          expect(result, equals(mockUserCredential));
          verify(
            mockRemoteDataSource.signUpWithEmailPassword(tEmail, tPassword),
          );
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should rethrow the exception when call to data source is unsuccessful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.signUpWithEmailPassword(any, any),
          ).thenThrow(Exception('Sign up failed'));
          // Act
          final call = repository.signUpWithEmailPassword;
          // Assert
          expect(() => call(tEmail, tPassword), throwsA(isA<Exception>()));
        },
      );
    });

    group('signInWithGoogle', () {
      test(
        'should return UserCredential when call to data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.signInWithGoogle(),
          ).thenAnswer((_) async => mockUserCredential);
          // Act
          final result = await repository.signInWithGoogle();
          // Assert
          expect(result, equals(mockUserCredential));
          verify(mockRemoteDataSource.signInWithGoogle());
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should rethrow the exception when call to data source is unsuccessful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.signInWithGoogle(),
          ).thenThrow(Exception('Google sign in failed'));
          // Act
          final call = repository.signInWithGoogle;
          // Assert
          expect(() => call(), throwsA(isA<Exception>()));
        },
      );
    });

    group('signOut', () {
      test(
        'should complete successfully when call to data source is successful',
        () async {
          // Arrange
          when(mockRemoteDataSource.signOut()).thenAnswer((_) async {});
          // Act
          await repository.signOut();
          // Assert
          verify(mockRemoteDataSource.signOut());
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should rethrow the exception when call to data source is unsuccessful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.signOut(),
          ).thenThrow(Exception('Sign out failed'));
          // Act
          final call = repository.signOut;
          // Assert
          expect(() => call(), throwsA(isA<Exception>()));
        },
      );
    });

    group('authStateChanges', () {
      test('should return a stream of User? from the data source', () {
        // Arrange
        final userStream = Stream.fromIterable([mockUser, null]);
        when(
          mockRemoteDataSource.authStateChanges,
        ).thenAnswer((_) => userStream);
        // Act
        final result = repository.authStateChanges;
        // Assert
        expect(result, isA<Stream<User?>>());
        expect(result, emitsInOrder([mockUser, null]));
        verify(mockRemoteDataSource.authStateChanges);
        verifyNoMoreInteractions(mockRemoteDataSource);
      });
    });
  });
}
