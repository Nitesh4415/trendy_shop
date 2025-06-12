import 'package:injectable/injectable.dart';

import '../entities/order.dart';
import '../repositories/order_repository.dart';

@LazySingleton()
class GetOrderHistoryUseCase {
  final OrderRepository _repository;

  GetOrderHistoryUseCase(this._repository);

  Future<List<Orders>> call(int userId) async {
    return await _repository.getOrderHistory(userId);
  }
}