import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/domain/usecases/get_product_details_usecase.dart';
import 'package:shop_trendy/features/product/domain/usecases/get_products_by_category_usecase.dart';
import 'package:shop_trendy/features/product/domain/usecases/get_products_usecase.dart';
import 'package:shop_trendy/features/product/presentation/cubit/product_cubit.dart';

// Import the generated mocks
import 'product_cubit_test.mocks.dart';

// Annotation to generate mock classes
@GenerateMocks([
  GetProductsUseCase,
  GetProductDetailsUseCase,
  GetProductsByCategoryUseCase,
])
void main() {
  // Late variables for our mocks and the cubit instance
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockGetProductDetailsUseCase mockGetProductDetailsUseCase;
  late MockGetProductsByCategoryUseCase mockGetProductsByCategoryUseCase;
  late ProductCubit productCubit;

  // Dummy product data for testing
  final tProducts = List.generate(
    20,
    (i) => Product(
      id: i + 1,
      title: 'Product ${i + 1}',
      price: (i + 1) * 10.0,
      description: 'Description for product ${i + 1}',
      category: 'Category ${i % 3}',
      image: 'image_url_${i + 1}.png',
      rating: Rating(rate: 4.2, count: 4),
    ),
  );

  final tSingleProduct = Product(
    id: 1,
    title: 'Product 1',
    price: 10.0,
    description: 'A test product',
    category: 'Test Category',
    image: 'image.png',
    rating: Rating(rate: 4.2, count: 4),
  );

  final tRelatedProducts = [
    Product(
      id: 2,
      title: 'Related 1',
      price: 20.0,
      description: '',
      category: 'Test Category',
      image: '',
      rating: Rating(rate: 4.2, count: 4),
    ),
    Product(
      id: 3,
      title: 'Related 2',
      price: 30.0,
      description: '',
      category: 'Test Category',
      image: '',
      rating: Rating(rate: 4.2, count: 4),
    ),
  ];

  // setUp is called before each test
  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockGetProductDetailsUseCase = MockGetProductDetailsUseCase();
    mockGetProductsByCategoryUseCase = MockGetProductsByCategoryUseCase();
    productCubit = ProductCubit(
      mockGetProductsUseCase,
      mockGetProductDetailsUseCase,
      mockGetProductsByCategoryUseCase,
    );
  });

  // tearDown is called after each test
  tearDown(() {
    productCubit.close();
  });

  // Test group for the initial state of the Cubit
  group('Initial State', () {
    test('should have an initial state of ProductInitial', () {
      expect(productCubit.state, equals(ProductInitial()));
    });
  });

  // Test group for the fetchAllProducts functionality
  group('fetchAllProducts', () {
    // This test ensures that on the very first load, the cubit correctly fetches all products,
    // emits the correct loading and loaded states, and paginates the first set of items.
    blocTest<ProductCubit, ProductState>(
      'emits [ProductLoading, ProductLoaded] on initial successful fetch',
      build: () {
        // Arrange: When the use case is called, return our full list of dummy products.
        when(mockGetProductsUseCase.call()).thenAnswer((_) async => tProducts);
        return productCubit;
      },
      act: (cubit) => cubit.fetchAllProducts(isInitialLoad: true),
      expect: () => [
        ProductLoading(),
        ProductLoaded(products: tProducts.sublist(0, 6), hasMore: true),
      ],
      // Verify that the use case was indeed called once.
      verify: (_) {
        verify(mockGetProductsUseCase.call()).called(1);
      },
    );

    // This test simulates loading the "next page" of products by first doing an initial
    // load and then a subsequent load, verifying the correct states are emitted for the second load.
    blocTest<ProductCubit, ProductState>(
      'emits [ProductLoadingMore, ProductLoaded] when loading more products',
      build: () {
        when(mockGetProductsUseCase.call()).thenAnswer((_) async => tProducts);
        return productCubit;
      },
      act: (cubit) async {
        await cubit.fetchAllProducts(
          isInitialLoad: true,
        ); // First load to populate cache
        await cubit.fetchAllProducts(); // Second load (the one under test)
      },
      skip:
          2, // Skip the [ProductLoading, ProductLoaded] states from the initial fetch
      expect: () => [
        ProductLoadingMore(products: tProducts.sublist(0, 12)),
        ProductLoaded(products: tProducts.sublist(0, 12), hasMore: true),
      ],
      verify: (_) {
        // Verify the use case is only called ONCE, proving the cache is working.
        verify(mockGetProductsUseCase.call()).called(1);
      },
    );

    // This test ensures that when the final page is loaded, the `hasMore` flag is set to false.
    // It simulates loading all pages to get to the final state.
    blocTest<ProductCubit, ProductState>(
      'sets hasMore to false when all products are loaded',
      build: () {
        when(mockGetProductsUseCase.call()).thenAnswer((_) async => tProducts);
        return productCubit;
      },
      act: (cubit) async {
        await cubit.fetchAllProducts(isInitialLoad: true); // -> 6 items
        await cubit.fetchAllProducts(); // -> 12 items
        await cubit.fetchAllProducts(); // -> 18 items
        await cubit.fetchAllProducts(); // -> 20 items (final load)
      },
      skip: 6, // Skip the 6 states from the first three fetches
      expect: () => [
        // NOTE: This test also accounts for the list mutation bug.
        ProductLoadingMore(products: tProducts),
        // The final state has all 20 products and hasMore is false
        ProductLoaded(products: tProducts, hasMore: false),
      ],
      verify: (_) {
        // Verify the cache is used and API is not called again.
        verify(mockGetProductsUseCase.call()).called(1);
      },
    );

    // This test checks the behavior when fetchAllProducts is called but there are no more items to load.
    blocTest<ProductCubit, ProductState>(
      'does not emit new states if hasMore is false',
      build: () => productCubit,
      // Seed with a state where loading is complete.
      seed: () => ProductLoaded(products: tProducts, hasMore: false),
      act: (cubit) => cubit.fetchAllProducts(),
      // Expect no state changes.
      expect: () => [],
    );

    // This test handles the scenario where the API call fails.
    blocTest<ProductCubit, ProductState>(
      'emits [ProductLoading, ProductError] when fetching fails',
      build: () {
        // Arrange: Make the use case throw an error.
        when(mockGetProductsUseCase.call()).thenThrow(Exception('API Error'));
        return productCubit;
      },
      act: (cubit) => cubit.fetchAllProducts(isInitialLoad: true),
      expect: () => [ProductLoading(), ProductError('Exception: API Error')],
    );
  });

  // Test group for the fetchProductDetails functionality
  group('fetchProductDetails', () {
    // This tests the happy path for fetching a single product's details.
    blocTest<ProductCubit, ProductState>(
      'emits [ProductLoading, ProductDetailLoaded] on successful detail fetch',
      build: () {
        // Arrange: Mock the responses for getting details and related products.
        when(
          mockGetProductDetailsUseCase.call(any),
        ).thenAnswer((_) async => tSingleProduct);
        when(
          mockGetProductsByCategoryUseCase.call(any),
        ).thenAnswer((_) async => tRelatedProducts);
        return productCubit;
      },
      // Seed with an initial product list, which should be cached.
      seed: () =>
          ProductLoaded(products: tProducts.sublist(0, 6), hasMore: true),
      act: (cubit) => cubit.fetchProductDetails(1),
      expect: () => [
        ProductLoading(),
        ProductDetailLoaded(
          product: tSingleProduct,
          relatedProducts: tRelatedProducts,
        ),
      ],
      verify: (_) {
        verify(mockGetProductDetailsUseCase.call(1)).called(1);
        verify(
          mockGetProductsByCategoryUseCase.call('Test Category'),
        ).called(1);
      },
    );

    // This tests the failure scenario for fetching product details.
    blocTest<ProductCubit, ProductState>(
      'emits [ProductLoading, ProductError] when detail fetch fails',
      build: () {
        // Arrange: Make the details use case throw an error.
        when(
          mockGetProductDetailsUseCase.call(any),
        ).thenThrow(Exception('Product not found'));
        return productCubit;
      },
      act: (cubit) => cubit.fetchProductDetails(1),
      expect: () => [
        ProductLoading(),
        ProductError('Exception: Product not found'),
      ],
    );
  });

  // Test group for restoring the product list state
  group('restoreProductListState', () {
    // This test simulates going back from a detail page to the list page.
    // It verifies that the previously viewed list state is correctly restored from cache.
    blocTest<ProductCubit, ProductState>(
      'emits [ProductLoaded] with cached data when restoring state',
      build: () {
        // Arrange: First, fetch details to cache the main list state.
        when(
          mockGetProductDetailsUseCase.call(any),
        ).thenAnswer((_) async => tSingleProduct);
        when(
          mockGetProductsByCategoryUseCase.call(any),
        ).thenAnswer((_) async => []);
        return productCubit;
      },
      // Start with a loaded product list.
      seed: () =>
          ProductLoaded(products: tProducts.sublist(0, 6), hasMore: true),
      act: (cubit) async {
        // First fetch details, which will cache the seeded state.
        await cubit.fetchProductDetails(1);
        // Then, restore the list.
        cubit.restoreProductListState();
      },
      // We skip the states from fetchProductDetails and only check the final restore state.
      skip: 2,
      expect: () => [
        // The state should be restored to exactly what it was before fetching details.
        ProductLoaded(products: tProducts.sublist(0, 6), hasMore: true),
      ],
    );

    // This test covers the case where there is no cached state to restore.
    blocTest<ProductCubit, ProductState>(
      'triggers a new fetch when restoring state with no cache',
      build: () {
        // Arrange: When the fetchAllProducts is triggered, return the first page.
        when(mockGetProductsUseCase.call()).thenAnswer((_) async => tProducts);
        return productCubit;
      },
      // Act: Call restore when the cubit is in its initial state (no cache).
      act: (cubit) => cubit.restoreProductListState(),
      // Expect: The cubit should behave just like an initial load.
      expect: () => [
        ProductLoading(),
        ProductLoaded(products: tProducts.sublist(0, 6), hasMore: true),
      ],
      verify: (_) {
        // Verify that the network call was made because the cache was empty.
        verify(mockGetProductsUseCase.call()).called(1);
      },
    );
  });
}
