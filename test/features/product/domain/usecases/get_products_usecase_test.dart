import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/domain/repositories/product_repository.dart';
import 'package:shop_trendy/features/product/domain/usecases/get_products_usecase.dart';

// Generate a mock for ProductRepository
@GenerateMocks([ProductRepository])
import 'get_products_usecase_test.mocks.dart';

void main() {
  late MockProductRepository mockProductRepository;
  late GetProductsUseCase usecase;

  // Test data
  final tProductList = [
    Product(
      id: 1,
      title: 'Product A',
      price: 100.00,
      description: 'Description A',
      category: 'Category 1',
      image: 'imageA.jpg',
      rating: Rating(rate: 4.8, count: 150),
    ),
    Product(
      id: 2,
      title: 'Product B',
      price: 200.00,
      description: 'Description B',
      category: 'Category 2',
      image: 'imageB.jpg',
      rating: Rating(rate: 4.2, count: 200),
    ),
  ];

  setUp(() {
    mockProductRepository = MockProductRepository();
    usecase = GetProductsUseCase(mockProductRepository);
  });

  group('GetProductsUseCase', () {
    test('should get a list of all products from the repository', () async {
      // Arrange
      // Stub the repository method to return a successful result.
      when(
        mockProductRepository.getProducts(),
      ).thenAnswer((_) async => tProductList);

      // Act
      // Execute the use case.
      final result = await usecase();

      // Assert
      // Expect that the result from the use case matches the one from the repository.
      expect(result, tProductList);
      // Verify that the repository method was called.
      verify(mockProductRepository.getProducts());
      // Ensure no other methods were called on the repository.
      verifyNoMoreInteractions(mockProductRepository);
    });

    test(
      'should re-throw the exception from the repository when getting products fails',
      () async {
        // Arrange
        // Stub the repository method to throw an exception.
        final serverException = ServerException();
        when(mockProductRepository.getProducts()).thenThrow(serverException);

        // Act
        // Define the call to the use case.
        final call = usecase;

        // Assert
        // Expect that calling the use case throws the same exception.
        expect(() => call(), throwsA(isA<ServerException>()));
      },
    );
  });
}
