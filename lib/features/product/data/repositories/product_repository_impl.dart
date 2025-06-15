import 'package:injectable/injectable.dart';
import 'package:shop_trendy/core/utils/extensions/product/product_model_extension.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/domain/repositories/product_repository.dart';
import 'package:shop_trendy/features/product/data/datasources/product_remote_datasource.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final productModels = await _remoteDataSource.getAllProducts();
      return productModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow; // Re-throw exceptions from data source
    }
  }


  @override
  Future<Product> getProductDetails(int id) async {
    try {
      final productModel = await _remoteDataSource.getProductDetails(id);
      return productModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final productModels = await _remoteDataSource.getProductsByCategory(category);
      return productModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}