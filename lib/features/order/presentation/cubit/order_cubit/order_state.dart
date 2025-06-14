part of 'order_cubit.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

// New state to hold both current and past orders
class OrderAllLoaded extends OrderState {
  final Orders? currentOrder;
  final List<Orders> pastOrders;

  const OrderAllLoaded({this.currentOrder, required this.pastOrders});

  @override
  List<Object?> get props => [currentOrder, pastOrders];
}


class OrderHistoryLoaded extends OrderState {
  final List<Orders> orders;

  const OrderHistoryLoaded({required this.orders});

  @override
  List<Object> get props => [orders];
}

class OrderPlacedSuccess extends OrderState {
  final Orders placedOrder;

  const OrderPlacedSuccess({required this.placedOrder});

  @override
  List<Object> get props => [placedOrder];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object> get props => [message];
}
