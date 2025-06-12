import 'package:shop_trendy/features/order/domain/entities/order.dart';
import 'package:shop_trendy/features/order/domain/repositories/order_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class PlaceOrderUseCase {
  final OrderRepository _repository;

  PlaceOrderUseCase(this._repository);

  Future<Orders> call(Orders order) async {
    return await _repository.placeOrder(order);
  }
}
