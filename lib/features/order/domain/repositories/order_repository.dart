import '../entities/order.dart';

abstract class OrderRepository {
  Future<Orders> placeOrder(Orders order);
  Future<List<Orders>> getOrderHistory(int userId);
}
