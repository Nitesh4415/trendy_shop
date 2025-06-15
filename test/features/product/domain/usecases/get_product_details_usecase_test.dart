import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/domain/repositories/product_repository.dart';
import 'package:shop_trendy/features/product/domain/usecases/get_product_details_usecase.dart';

// Generate a mock for ProductRepository
@GenerateMocks([ProductRepository])
import 'get_product_details_usecase_test.mocks.dart';

void main() {
  late MockProductRepository mockProductRepository;
  late GetProductDetailsUseCase usecase;

  // Test data
  const tProductId = 1;
  final tProduct = Product(
    id: tProductId,
    title: 'Test Product',
    price: 99.99,
    description: 'A description',
    category: 'electronics',
    image: 'image.jpg',
    rating: Rating(rate: 4.5, count: 120),
  );

  setUp(() {
    mockProductRepository = MockProductRepository();
    usecase = GetProductDetailsUseCase(mockProductRepository);
  });

  group('GetProductDetailsUseCase', () {
    test('should get product details from the repository', () async {
      // Arrange
      // Stub the repository method to return a successful result.
      when(
        mockProductRepository.getProductDetails(any),
      ).thenAnswer((_) async => tProduct);

      // Act
      // Execute the use case with the test product ID.
      final result = await usecase(tProductId);

      // Assert
      // Expect that the result from the use case matches the one from the repository.
      expect(result, tProduct);
      // Verify that the repository method was called with the correct ID.
      verify(mockProductRepository.getProductDetails(tProductId));
      // Ensure no other methods were called on the repository.
      verifyNoMoreInteractions(mockProductRepository);
    });

    test(
      'should re-throw the exception from the repository when getting details fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final serverException = ServerException();
        when(
          mockProductRepository.getProductDetails(any),
        ).thenThrow(serverException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(() => call(tProductId), throwsA(isA<ServerException>()));
      },
    );
  });
}
