import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shop_trendy/features/order/domain/entities/product_order.dart';

part 'order.freezed.dart';

@freezed
class Orders with _$Orders {
  const factory Orders({
    int? id,
    required int userId,
    required DateTime date,
    required List<ProductInOrder> products,
  }) = _Orders;
}
