import 'package:injectable/injectable.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

@LazySingleton()
class GetProductDetailsUseCase {
  final ProductRepository _repository;

  GetProductDetailsUseCase(this._repository);

  Future<Product> call(int id) async {
    return await _repository.getProductDetails(id);
  }
}
