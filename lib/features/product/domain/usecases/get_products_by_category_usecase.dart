import 'package:injectable/injectable.dart';
import 'package:shop_trendy/features/product/domain/entities/product.dart';
import 'package:shop_trendy/features/product/domain/repositories/product_repository.dart';

@LazySingleton()
class GetProductsByCategoryUseCase {
  final ProductRepository _repository;

  GetProductsByCategoryUseCase(this._repository);

  Future<List<Product>> call(String category) async {
    return await _repository.getProductsByCategory(category);
  }
}
