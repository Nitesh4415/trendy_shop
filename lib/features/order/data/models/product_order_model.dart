import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_order_model.freezed.dart';
part 'product_order_model.g.dart';

@freezed
class ProductInOrderModel with _$ProductInOrderModel {
  const factory ProductInOrderModel({
    required int productId,
    required int quantity,
  }) = _ProductInOrderModel;

  factory ProductInOrderModel.fromJson(Map<String, dynamic> json) => _$ProductInOrderModelFromJson(json);
}