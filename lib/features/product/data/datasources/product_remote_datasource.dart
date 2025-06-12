import '../models/product_model.dart';

// Abstract class for remote product data operations.
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getAllProducts({int? limit, String? sort, int? skip}); // Added pagination parameters
  Future<ProductModel> getProductDetails(int id);
  Future<List<ProductModel>> getProductsByCategory(String category);
}