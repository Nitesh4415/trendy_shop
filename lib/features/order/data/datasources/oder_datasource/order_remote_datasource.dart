import '../../models/order_model.dart';

// Abstract class for remote order data operations.
abstract class OrderRemoteDataSource {
  Future<OrderModel> placeOrder(OrderModel order);
  Future<List<OrderModel>> getOrderHistory(
    int userId,
  ); // FakeStoreAPI returns carts for users
}
