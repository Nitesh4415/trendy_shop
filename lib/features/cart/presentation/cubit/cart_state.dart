part of 'cart_cubit.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;

  const CartLoaded({this.items = const []});

  @override
  List<Object> get props => [items];
}

class CartPaymentSuccess extends CartState {
  const CartPaymentSuccess();

  @override
  List<Object> get props => [];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}