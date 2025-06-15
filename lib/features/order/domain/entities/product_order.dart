import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_order.freezed.dart';

@freezed
class ProductInOrder with _$ProductInOrder {
  const factory ProductInOrder({
    required int productId,
    required int quantity,
  }) = _ProductInOrder;
}
