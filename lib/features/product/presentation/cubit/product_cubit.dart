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

  static const int _productsPerPage = 6; // Define pagination limit

  List<Product> _allProducts =
      []; // Local cache for all products fetched so far
  bool _isLoadingMore =
      false; // To prevent multiple simultaneous pagination calls
  bool _hasMoreProducts = true; // To track if there are more products to load

  ProductCubit(
    this._getAllProducts,
    this._getProductDetails,
    this._getProductsByCategory,
  ) : super(ProductInitial());

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreProducts => _hasMoreProducts;
  List<Product> get currentProducts =>
      _allProducts; // New getter for current products

  Future<void> fetchAllProducts({bool isInitialLoad = true}) async {
    if (_isLoadingMore || (!_hasMoreProducts && !isInitialLoad)) return;

    _isLoadingMore = true;
    if (isInitialLoad) {
      emit(ProductLoading());
      _allProducts = []; // Clear products on initial load
      _hasMoreProducts = true; // Reset hasMoreProducts for a fresh start
    } else {
      emit(
        ProductLoadingMore(products: _allProducts),
      ); // Show loading for more products
    }

    try {
      final newProducts = await _getAllProducts(
        limit: _productsPerPage,
        sort: 'asc',
        skip:
            _allProducts.length, // Pass the current count as skip for next page
      );

      if (newProducts.isEmpty || newProducts.length < _productsPerPage) {
        _hasMoreProducts = false; // No more products to load
      }

      _allProducts.addAll(newProducts);
      emit(ProductLoaded(products: _allProducts, hasMore: _hasMoreProducts));
    } catch (e) {
      emit(ProductError(e.toString()));
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> fetchProductDetails(int id) async {
    emit(ProductLoading());
    try {
      final product = await _getProductDetails(id);
      List<Product> relatedProducts = [];
      if (product.category.isNotEmpty) {
        relatedProducts = await _getProductsByCategory(product.category);
        // Filter out the current product from related products list
        relatedProducts.removeWhere((p) => p.id == product.id);
        if (relatedProducts.length > 4) {
          relatedProducts = relatedProducts.sublist(0, 5);
        }
      }
      emit(
        ProductDetailLoaded(product: product, relatedProducts: relatedProducts),
      ); // Pass related products
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  // Internal method for fetching product details without changing cubit state
  // Useful for other cubits/pages that need product data but don't drive main product state
  Future<Product> fetchProductDetailsInternal(int id) async {
    return await _getProductDetails(id);
  }
}
