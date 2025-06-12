import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({int? limit, String? sort, int? skip});
  Future<Product> getProductDetails(int id);
  Future<List<Product>> getProductsByCategory(String category);
}