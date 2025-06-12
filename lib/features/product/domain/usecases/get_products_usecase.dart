import 'package:injectable/injectable.dart';

import '../entities/product.dart';
import '../repositories/product_repository.dart';

@LazySingleton()
class GetProductsUseCase {
  final ProductRepository _repository;

  GetProductsUseCase(this._repository);

  Future<List<Product>> call({int? limit, String? sort, int? skip}) async {
    // Add skip
    return await _repository.getProducts(
      limit: limit,
      sort: sort,
      skip: skip,
    ); // Pass skip
  }
}
