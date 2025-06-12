
import '../../../../features/order/domain/entities/order.dart';
import '../../../../features/order/data/models/order_model.dart';
import '../../../../features/order/domain/entities/product_order.dart';

extension OrderModelX on OrderModel{
  Orders toEntity() {
    return Orders(
      id: id,
      userId: userId,
      date: date,
      products: products.map((e) => ProductInOrder(productId: e.productId, quantity: e.quantity)).toList(),
    );
  }
}
