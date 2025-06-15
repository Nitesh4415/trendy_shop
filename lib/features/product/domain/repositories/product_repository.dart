import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProductDetails(int id);
  Future<List<Product>> getProductsByCategory(String category);
}