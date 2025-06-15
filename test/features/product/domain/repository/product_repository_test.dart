import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/features/product/data/datasources/product_remote_datasource.dart';
import 'package:shop_trendy/features/product/data/models/product_model.dart';
import 'package:shop_trendy/features/product/data/repositories/product_repository_impl.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/domain/repositories/product_repository.dart';

// Generate a mock for ProductRemoteDataSource
@GenerateMocks([ProductRemoteDataSource])
import 'product_repository_test.mocks.dart';

void main() {
  late MockProductRemoteDataSource mockRemoteDataSource;
  late ProductRepository repository;

  // Test data - Models (as returned by the data source)
  final productModel1 = ProductModel(
    id: 1,
    title: 'Product 1',
    price: 10.0,
    description: '',
    category: 'electronics',
    image: '',
    rating: RatingModel(rate: 4.5, count: 10),
  );
  final productModel2 = ProductModel(
    id: 2,
    title: 'Product 2',
    price: 20.0,
    description: '',
    category: 'electronics',
    image: '',
    rating: RatingModel(rate: 4.0, count: 5),
  );
  final List<ProductModel> tProductModelList = [productModel1, productModel2];

  // Test data - Entities (as returned by the repository)
  final productEntity1 = Product(
    id: 1,
    title: 'Product 1',
    price: 10.0,
    description: '',
    category: 'electronics',
    image: '',
    rating: Rating(rate: 4.5, count: 10),
  );
  final productEntity2 = Product(
    id: 2,
    title: 'Product 2',
    price: 20.0,
    description: '',
    category: 'electronics',
    image: '',
    rating: Rating(rate: 4.0, count: 5),
  );
  final List<Product> tProductEntityList = [productEntity1, productEntity2];

  setUp(() {
    mockRemoteDataSource = MockProductRemoteDataSource();
    repository = ProductRepositoryImpl(mockRemoteDataSource);
  });

  group('ProductRepositoryImpl', () {
    group('getProducts', () {
      test(
        'should return a list of Product entities when the call to remote data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getAllProducts(),
          ).thenAnswer((_) async => tProductModelList);

          // Act
          final result = await repository.getProducts();

          // Assert
          expect(result, equals(tProductEntityList));
          verify(mockRemoteDataSource.getAllProducts());
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should rethrow a ServerException when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getAllProducts(),
          ).thenThrow(ServerException());

          // Act
          final call = repository.getProducts;

          // Assert
          expect(() => call(), throwsA(isA<ServerException>()));
        },
      );
    });

    group('getProductDetails', () {
      const tProductId = 1;
      test(
        'should return a Product entity when the call to remote data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getProductDetails(any),
          ).thenAnswer((_) async => productModel1);

          // Act
          final result = await repository.getProductDetails(tProductId);

          // Assert
          expect(result, equals(productEntity1));
          verify(mockRemoteDataSource.getProductDetails(tProductId));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should rethrow a ServerException when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getProductDetails(any),
          ).thenThrow(ServerException());

          // Act
          final call = repository.getProductDetails;

          // Assert
          expect(() => call(tProductId), throwsA(isA<ServerException>()));
        },
      );
    });

    group('getProductsByCategory', () {
      const tCategory = 'electronics';
      test(
        'should return a list of Product entities when the call to remote data source is successful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getProductsByCategory(any),
          ).thenAnswer((_) async => tProductModelList);

          // Act
          final result = await repository.getProductsByCategory(tCategory);

          // Assert
          expect(result, equals(tProductEntityList));
          verify(mockRemoteDataSource.getProductsByCategory(tCategory));
          verifyNoMoreInteractions(mockRemoteDataSource);
        },
      );

      test(
        'should rethrow a ServerException when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          when(
            mockRemoteDataSource.getProductsByCategory(any),
          ).thenThrow(ServerException());

          // Act
          final call = repository.getProductsByCategory;

          // Assert
          expect(() => call(tCategory), throwsA(isA<ServerException>()));
        },
      );
    });
  });
}
