part of 'product_cubit.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool hasMore;

  const ProductLoaded({required this.products, this.hasMore = true});

  @override
  List<Object> get props => [products, hasMore];
}

class ProductDetailLoaded extends ProductState {
  final Product product;
  final List<Product> relatedProducts;

  const ProductDetailLoaded({
    required this.product,
    required this.relatedProducts,
  });

  @override
  List<Object> get props => [product, relatedProducts];
}

class ProductLoadingMore extends ProductState {
  final List<Product> products;

  const ProductLoadingMore({required this.products});

  @override
  List<Object> get props => [products];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}
