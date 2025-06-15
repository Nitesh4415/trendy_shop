import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/auth/domain/entities/user.dart';
import 'package:shop_trendy/features/auth/domain/repositories/user_repository.dart';
import 'package:shop_trendy/features/auth/domain/usecases/user_usecase/get_user_by_email_usecase.dart';

// Generate a mock for UserRepository
@GenerateMocks([UserRepository])
import 'get_user_by_email_usecase_test.mocks.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late GetUserByEmailUseCase usecase;

  const tEmailExists = 'existing@example.com';
  const tEmailDoesNotExist = 'nonexisting@example.com';

  // Create a list of users for testing
  final allUsers = [
    const User(
      id: 1,
      username: 'user1',
      email: 'user1@example.com',
      password: 'password1',
    ),
    const User(
      id: 2,
      username: 'user2',
      email: tEmailExists,
      password: 'password2',
    ),
    const User(
      id: 3,
      username: 'user3',
      email: 'user3@example.com',
      password: 'password3',
    ),
  ];

  setUp(() {
    mockUserRepository = MockUserRepository();
    usecase = GetUserByEmailUseCase(mockUserRepository);
  });

  group('GetUserByEmailUseCase', () {
    test(
      'should return a list with one user when a user with the given email exists',
      () async {
        // Arrange
        // Stub the repository to return the full list of users.
        when(
          mockUserRepository.getAllUsers(),
        ).thenAnswer((_) async => allUsers);

        // Act
        // Execute the use case with an email that exists.
        final result = await usecase(tEmailExists);

        // Assert
        // Expect the result to be a list containing only the matching user.
        expect(result.length, 1);
        expect(result.first.email, tEmailExists);
        // Verify that the repository's getAllUsers method was called.
        verify(mockUserRepository.getAllUsers());
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockUserRepository);
      },
    );

    test(
      'should return an empty list when no user with the given email exists',
      () async {
        // Arrange
        // Stub the repository to return the full list of users.
        when(
          mockUserRepository.getAllUsers(),
        ).thenAnswer((_) async => allUsers);

        // Act
        // Execute the use case with an email that does not exist.
        final result = await usecase(tEmailDoesNotExist);

        // Assert
        // Expect the result to be an empty list.
        expect(result, isEmpty);
        // Verify that the repository's getAllUsers method was called.
        verify(mockUserRepository.getAllUsers());
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockUserRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when fetching users fails',
      () async {
        // Arrange
        // Stub the repository to throw an exception.
        final testException = Exception('Failed to fetch users');
        when(mockUserRepository.getAllUsers()).thenThrow(testException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(() => call(tEmailExists), throwsA(isA<Exception>()));
      },
    );
  });
}
