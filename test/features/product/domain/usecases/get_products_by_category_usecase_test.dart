import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/domain/repositories/product_repository.dart';
import 'package:shop_trendy/features/product/domain/usecases/get_products_by_category_usecase.dart';

// Generate a mock for ProductRepository
@GenerateMocks([ProductRepository])
import 'get_products_by_category_usecase_test.mocks.dart';

void main() {
  late MockProductRepository mockProductRepository;
  late GetProductsByCategoryUseCase usecase;

  // Test data
  const tCategory = 'electronics';
  final tProductList = [
    Product(
      id: 1,
      title: 'Laptop',
      price: 1200.00,
      description: 'A description',
      category: tCategory,
      image: 'image.jpg',
      rating: Rating(rate: 4.7, count: 250),
    ),
    Product(
      id: 2,
      title: 'Keyboard',
      price: 75.50,
      description: 'Another description',
      category: tCategory,
      image: 'image2.jpg',
      rating: Rating(rate: 4.5, count: 500),
    ),
  ];

  setUp(() {
    mockProductRepository = MockProductRepository();
    usecase = GetProductsByCategoryUseCase(mockProductRepository);
  });

  group('GetProductsByCategoryUseCase', () {
    test(
      'should get a list of products for a category from the repository',
      () async {
        // Arrange
        // Stub the repository method to return a successful result.
        when(
          mockProductRepository.getProductsByCategory(any),
        ).thenAnswer((_) async => tProductList);

        // Act
        // Execute the use case with the test category.
        final result = await usecase(tCategory);

        // Assert
        // Expect that the result from the use case matches the one from the repository.
        expect(result, tProductList);
        // Verify that the repository method was called with the correct category.
        verify(mockProductRepository.getProductsByCategory(tCategory));
        // Ensure no other methods were called on the repository.
        verifyNoMoreInteractions(mockProductRepository);
      },
    );

    test(
      'should re-throw the exception from the repository when getting products by category fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final serverException = ServerException();
        when(
          mockProductRepository.getProductsByCategory(any),
        ).thenThrow(serverException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(() => call(tCategory), throwsA(isA<ServerException>()));
      },
    );
  });
}
