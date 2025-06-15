import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/auth/domain/entities/user.dart';
import 'package:shop_trendy/features/auth/domain/repositories/user_repository.dart';
import 'package:shop_trendy/features/auth/domain/usecases/user_usecase/create_user_usecase.dart';

// Generate a mock for UserRepository
@GenerateMocks([UserRepository])
import 'create_user_usecase_test.mocks.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late CreateUserUseCase usecase;

  // Test data: a user object to be created
  const userToCreate = User(
    id: null, // ID is null before creation
    username: 'newuser',
    email: 'newuser@example.com',
    password: 'password123',
  );

  // Test data: the user object after it has been created (e.g., with an ID from the backend)
  const createdUser = User(
    id: 1, // ID assigned after creation
    username: 'newuser',
    email: 'newuser@example.com',
    password: 'password123',
  );

  setUp(() {
    mockUserRepository = MockUserRepository();
    usecase = CreateUserUseCase(mockUserRepository);
  });

  group('CreateUserUseCase', () {
    test(
      'should return a User object from the repository when creation is successful',
      () async {
        // Arrange
        // Stub the repository method to return the created user.
        when(
          mockUserRepository.createUser(any),
        ).thenAnswer((_) async => createdUser);

        // Act
        // Execute the use case with the user data.
        final result = await usecase(userToCreate);

        // Assert
        // Expect that the result from the use case matches the one from the repository.
        expect(result, createdUser);
        // Verify that the repository method was called with the correct user data.
        verify(mockUserRepository.createUser(userToCreate));
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockUserRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when user creation fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final testException = Exception('User already exists');
        when(mockUserRepository.createUser(any)).thenThrow(testException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(() => call(userToCreate), throwsA(isA<Exception>()));
      },
    );
  });
}
