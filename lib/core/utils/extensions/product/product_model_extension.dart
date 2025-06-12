import 'package:shop_trendy/features/product/data/models/product_model.dart';

import '../../../../features/product/domain/entities/product.dart';

extension ProductModelX on ProductModel {
  Product toEntity() {
    return Product(
      id: id,
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
      rating: Rating(
        rate: rating.rate,
        count: rating.count,
      ),
    );
  }
}