import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../product/data/models/product_model.dart';
part 'cart_item_model.freezed.dart';
part 'cart_item_model.g.dart';

@freezed // Annotation for freezed to generate immutable data classes
class CartItemModel with _$CartItemModel {
  const factory CartItemModel({
    required String id,
    required ProductModel product, // Reference ProductModel here
    required int quantity,
  }) = _CartItemModel;

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
}
