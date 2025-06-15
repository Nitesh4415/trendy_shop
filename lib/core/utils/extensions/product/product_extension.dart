import '../../../../features/product/data/models/product_model.dart';
import '../../../../features/product/domain/entities/product.dart';

extension ProductX on Product {
  ProductModel toModel() {
    return ProductModel(
      id: id,
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
      rating: RatingModel(rate: rating.rate, count: rating.count),
    );
  }
}
