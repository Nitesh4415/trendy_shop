import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../product/domain/entities/product.dart';

part 'cart_item.freezed.dart';

@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String id,
    required Product product,
    required int quantity,
  }) = _CartItem;
}
