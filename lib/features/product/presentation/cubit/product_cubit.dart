import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/domain/usecases/get_products_by_category_usecase.dart';
import 'package:shop_trendy/features/product/domain/usecases/get_products_usecase.dart';
import 'package:shop_trendy/features/product/domain/usecases/get_product_details_usecase.dart';

part 'product_state.dart';

@LazySingleton()
class ProductCubit extends Cubit<ProductState> {
  final GetProductsUseCase _getAllProducts;
  final GetProductDetailsUseCase _getProductDetails;
  final GetProductsByCategoryUseCase _getProductsByCategory;

  static const int _productsPerPage = 6;

  // This will store all products fetched from the API one time.
  List<Product> _allFetchedProducts = [];
  bool _isLoadingMore = false;

  // Cache for restoring product list state
  List<Product> _lastKnownProductList = [];
  bool _lastKnownHasMore = true;

  ProductCubit(
    this._getAllProducts,
    this._getProductDetails,
    this._getProductsByCategory,
  ) : super(ProductInitial());

  bool get isLoadingMore => _isLoadingMore;

  List<Product> get currentProducts {
    final s = state;
    if (s is ProductLoaded) return s.products;
    if (s is ProductLoadingMore) return s.products;
    return [];
  }

  bool get hasMoreProducts {
    final s = state;
    if (s is ProductLoaded) return s.hasMore;
    if (s is ProductLoadingMore) return true;
    return false;
  }

  Future<bool> fetchAllProducts({bool isInitialLoad = false}) async {
    if (_isLoadingMore) return false;

    final currentState = state;
    if (currentState is ProductLoaded &&
        !currentState.hasMore &&
        !isInitialLoad) {
      return false;
    }

    _isLoadingMore = true;

    try {
      if (_allFetchedProducts.isEmpty) {
        emit(
          ProductLoading(),
        ); // Full screen loader only for the very first time.
        // Call the use case without pagination parameters.
        _allFetchedProducts = await _getAllProducts();
      }

      // Implement local pagination from the cached list.
      List<Product> productsToShow = [];
      if (currentState is ProductLoaded) {
        productsToShow = List.from(currentState.products);
      } else if (currentState is ProductLoadingMore) {
        productsToShow = List.from(currentState.products);
      }

      // On initial load, start with an empty list to build upon.
      if (isInitialLoad) {
        productsToShow = [];
      }

      // Show loading more indicator for pagination
      if (!isInitialLoad) {
        emit(ProductLoadingMore(products: productsToShow));
        // Add a small delay to allow the UI to show the loading indicator
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final currentLength = productsToShow.length;
      final remaining = _allFetchedProducts.length - currentLength;

      // Determine how many new items to add for the next "page".
      final nextPageSize = remaining > _productsPerPage
          ? _productsPerPage
          : remaining;
      List<Product> newItems = [];
      if (nextPageSize > 0) {
        newItems = _allFetchedProducts.sublist(
          currentLength,
          currentLength + nextPageSize,
        );
        productsToShow.addAll(newItems);
      }

      // Check if there are still more items to load in subsequent pages.
      final hasMore = productsToShow.length < _allFetchedProducts.length;

      emit(
        ProductLoaded(products: List.from(productsToShow), hasMore: hasMore),
      );

      // Return true if we successfully added new items to the list.
      return newItems.isNotEmpty;
    } catch (e) {
      emit(ProductError(e.toString()));
      return false;
    } finally {
      _isLoadingMore = false;
    }
  }

  void restoreProductListState() {
    if (_lastKnownProductList.isNotEmpty) {
      emit(
        ProductLoaded(
          products: List.from(_lastKnownProductList),
          hasMore: _lastKnownHasMore,
        ),
      );
    } else {
      fetchAllProducts(isInitialLoad: true);
    }
  }

  Future<void> fetchProductDetails(int id) async {
    // Cache the current product list before changing state
    final currentState = state;
    if (currentState is ProductLoaded) {
      _lastKnownProductList = currentState.products;
      _lastKnownHasMore = currentState.hasMore;
    }

    emit(ProductLoading());

    try {
      final product = await _getProductDetails(id);
      List<Product> relatedProducts = [];
      if (product.category.isNotEmpty) {
        relatedProducts = await _getProductsByCategory(product.category);
        relatedProducts.removeWhere((p) => p.id == product.id);
        if (relatedProducts.length > 4) {
          relatedProducts = relatedProducts.sublist(0, 5);
        }
      }
      emit(
        ProductDetailLoaded(product: product, relatedProducts: relatedProducts),
      );
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<Product> fetchProductDetailsInternal(int id) async {
    return await _getProductDetails(id);
  }
}
