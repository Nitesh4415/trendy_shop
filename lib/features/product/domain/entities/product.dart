import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required int id,
    required String title,
    required double price,
    required String description,
    required String category,
    required String image,
    required Rating rating, // Nested entity for rating
  }) = _Product;
}

// Immutable data class for a Rating entity.
@freezed
class Rating with _$Rating {
  const factory Rating({required double rate, required int count}) = _Rating;
}
