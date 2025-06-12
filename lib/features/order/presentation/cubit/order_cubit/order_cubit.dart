import 'package:bloc/bloc.dart';
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
    emit(OrderLoading());
    try {
      final orders = await _getOrderHistory(userId);
      emit(OrderHistoryLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> createOrder(Orders order) async {
    emit(OrderLoading());
    try {
      final placedOrder = await _placeOrder(order);
      emit(OrderPlacedSuccess(placedOrder: placedOrder));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Orders? getOrderById(int orderId) {
    final currentState = state;
    if (currentState is OrderHistoryLoaded) {
      return currentState.orders.firstWhere((order) => order.id == orderId);
    }
    return null;
  }
}