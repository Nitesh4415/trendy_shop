import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_trendy/features/order/domain/entities/order.dart';
import 'package:shop_trendy/features/order/domain/usecases/place_order_usecase.dart';
import 'package:shop_trendy/features/order/domain/usecases/get_order_history_usecase.dart';
import 'package:injectable/injectable.dart';

part 'order_state.dart';

@LazySingleton()
class OrderCubit extends Cubit<OrderState> {
  final GetOrderHistoryUseCase _getOrderHistory;
  final PlaceOrderUseCase _placeOrder;

  OrderCubit(this._getOrderHistory, this._placeOrder) : super(OrderInitial());

  Future<void> fetchOrderHistory(int userId) async {
    // Only show full-screen loader if there's no data at all
    if (state is! OrderAllLoaded) {
      emit(OrderLoading());
    }
    try {
      final orders = await _getOrderHistory(userId);
      if (orders.isNotEmpty) {
        // Sort orders by date to ensure the latest is first
        orders.sort((a, b) => b.date.compareTo(a.date));
        final currentOrder = orders.first;
        final pastOrders = orders.sublist(1);
        emit(OrderAllLoaded(currentOrder: currentOrder, pastOrders: pastOrders));
      } else {
        emit(const OrderAllLoaded(currentOrder: null, pastOrders: []));
      }
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> createOrder(Orders order) async {
    final currentState = state;
    // Don't emit a loading state here to prevent UI flicker.
    // The checkout page will manage its own loading indicator.
    try {
      // The use case should return the final order from the backend, including the generated ID.
      final placedOrder = await _placeOrder(order);

      List<Orders> pastOrders = [];
      // If we already have a list of orders, update it.
      if (currentState is OrderAllLoaded) {
        pastOrders = List.from(currentState.pastOrders);
        // The previous 'current' order (if any) is now part of the history.
        if (currentState.currentOrder != null) {
          pastOrders.insert(0, currentState.currentOrder!);
        }
      }

      // Emit the new state with the newly placed order as 'current'.
      emit(OrderAllLoaded(currentOrder: placedOrder, pastOrders: pastOrders));

    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Orders? getOrderById(int orderId) {
    final currentState = state;
    if (currentState is OrderAllLoaded) {
      // Check the current order first
      if (currentState.currentOrder?.id == orderId) {
        return currentState.currentOrder;
      }
      // Use firstWhereOrNull to safely search the list
      return currentState.pastOrders.firstWhereOrNull((o) => o.id == orderId);
    }
    return null;
  }
}
