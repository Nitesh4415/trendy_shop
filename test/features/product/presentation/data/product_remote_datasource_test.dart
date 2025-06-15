import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/core/constants/api_constants.dart';
import 'package:shop_trendy/core/error/exceptions.dart';
import 'package:shop_trendy/core/network/api_client.dart';
import 'package:shop_trendy/features/product/data/datasources/product_remote_datasource.dart';
import 'package:shop_trendy/features/product/data/datasources/product_remote_datasource_impl.dart';
import 'package:shop_trendy/features/product/data/models/product_model.dart';

// Import the generated mock file
import 'product_remote_datasource_test.mocks.dart';

// Fixture reader for loading JSON data from files
import '../../../../fixtures/fixture_reader.dart';

// Generate mocks for ApiClient
@GenerateMocks([ApiClient])
void main() {
  late ProductRemoteDataSource dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = ProductRemoteDataSourceImpl(mockApiClient);
  });

  group('getAllProducts', () {
    // Load the dummy JSON data from a fixture file
    final tProductListJson =
        json.decode(fixture('product/products.json')) as List;
    final tProductModels = tProductListJson
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();

    test(
      'should return List<ProductModel> when the API call is successful',
      () async {
        // Arrange: Configure the mock to return a successful response.
        when(
          mockApiClient.get(ApiConstants.products),
        ).thenAnswer((_) async => tProductListJson);

        // Act: Call the method under test.
        final result = await dataSource.getAllProducts();

        // Assert: Verify the result matches the expected models.
        expect(result, equals(tProductModels));
        verify(mockApiClient.get(ApiConstants.products));
        verifyNoMoreInteractions(mockApiClient);
      },
    );

    test(
      'should throw a ServerException when the API call is unsuccessful',
      () async {
        // Arrange: Configure the mock to throw a ServerException.
        when(
          mockApiClient.get(ApiConstants.products),
        ).thenThrow(ServerException());

        // Act: The actual method call.
        final call = dataSource.getAllProducts;

        // Assert: Verify that the call throws the expected exception.
        expect(() => call(), throwsA(isA<ServerException>()));
        verify(mockApiClient.get(ApiConstants.products));
        verifyNoMoreInteractions(mockApiClient);
      },
    );
  });

  group('getProductDetails', () {
    const tId = 1;
    // Load dummy JSON from a fixture file.
    final tProductJson =
        json.decode(fixture('product/product.json')) as Map<String, dynamic>;
    final tProductModel = ProductModel.fromJson(tProductJson);

    test(
      'should return ProductModel when the API call is successful',
      () async {
        // Arrange
        when(
          mockApiClient.get('${ApiConstants.products}/$tId'),
        ).thenAnswer((_) async => tProductJson);

        // Act
        final result = await dataSource.getProductDetails(tId);

        // Assert
        expect(result, equals(tProductModel));
        verify(mockApiClient.get('${ApiConstants.products}/$tId'));
        verifyNoMoreInteractions(mockApiClient);
      },
    );

    test(
      'should throw a ServerException when the API call is unsuccessful',
      () async {
        // Arrange
        when(
          mockApiClient.get('${ApiConstants.products}/$tId'),
        ).thenThrow(ServerException());

        // Act
        final call = dataSource.getProductDetails;

        // Assert
        expect(() => call(tId), throwsA(isA<ServerException>()));
        verify(mockApiClient.get('${ApiConstants.products}/$tId'));
        verifyNoMoreInteractions(mockApiClient);
      },
    );
  });

  group('getProductsByCategory', () {
    const tCategory = 'electronics';
    // Load dummy JSON from a fixture file.
    final tProductListJson =
        json.decode(fixture('product/products_by_category.json')) as List;
    final tProductModels = tProductListJson
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();

    test(
      'should return List<ProductModel> for a category when the API call is successful',
      () async {
        // Arrange
        when(
          mockApiClient.get('${ApiConstants.products}/category/$tCategory'),
        ).thenAnswer((_) async => tProductListJson);

        // Act
        final result = await dataSource.getProductsByCategory(tCategory);

        // Assert
        expect(result, equals(tProductModels));
        verify(
          mockApiClient.get('${ApiConstants.products}/category/$tCategory'),
        );
        verifyNoMoreInteractions(mockApiClient);
      },
    );

    test(
      'should throw a ServerException when the API call is unsuccessful',
      () async {
        // Arrange
        when(
          mockApiClient.get('${ApiConstants.products}/category/$tCategory'),
        ).thenThrow(ServerException());

        // Act
        final call = dataSource.getProductsByCategory;

        // Assert
        expect(() => call(tCategory), throwsA(isA<ServerException>()));
        verify(
          mockApiClient.get('${ApiConstants.products}/category/$tCategory'),
        );
        verifyNoMoreInteractions(mockApiClient);
      },
    );
  });
}
