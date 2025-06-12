import '../../../../features/cart/data/model/cart_item_model.dart';
import '../../../../features/cart/domain/entities/cart_item.dart';
import '../../../../features/product/data/models/product_model.dart';

extension CartItemX on CartItem {
  CartItemModel toModel() {
    return CartItemModel(
      id: id,
      product: ProductModel(
        id: product.id,
        title: product.title,
        price: product.price,
        description: product.description,
        category: product.category,
        image: product.image,
        rating: RatingModel(
          rate: product.rating.rate,
          count: product.rating.count,
        ),
      ), // Convert Product entity to ProductModel
      quantity: quantity,
    );
  }
}
