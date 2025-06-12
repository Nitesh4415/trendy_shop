import 'package:shop_trendy/core/utils/extensions/product/product_model_extension.dart';
import '../../../../features/cart/domain/entities/cart_item.dart';
import '../../../../features/cart/data/model/cart_item_model.dart';

extension CartItemModelX on CartItemModel {
  CartItem toEntity() {
    return CartItem(
      id: id,
      product: product.toEntity(), // Convert ProductModel to Product entity
      quantity: quantity,
    );
  }
}