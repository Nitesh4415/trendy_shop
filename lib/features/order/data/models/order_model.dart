import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shop_trendy/features/order/data/models/product_order_model.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    int? id,
    required int userId,
    required DateTime date,
    required List<ProductInOrderModel> products,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}
