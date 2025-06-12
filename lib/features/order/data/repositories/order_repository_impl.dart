import 'package:injectable/injectable.dart';
import 'package:shop_trendy/core/utils/extensions/order/order_model_extension.dart';
import 'package:shop_trendy/features/order/data/datasources/oder_datasource/order_remote_datasource.dart'; // Renamed to local
import 'package:shop_trendy/features/order/domain/entities/order.dart';
import 'package:shop_trendy/features/order/domain/repositories/order_repository.dart';
import 'package:shop_trendy/features/order/data/models/order_model.dart';
import '../models/product_order_model.dart';

@LazySingleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Orders>> getOrderHistory(int userId) async {
    try {
      final orderModels = await _remoteDataSource.getOrderHistory(userId);
      return orderModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Orders> placeOrder(Orders order) async {
    try {
      final orderModel = OrderModel(
        userId: order.userId,
        date: order.date,
        products: order.products
            .map(
              (e) => ProductInOrderModel(
                productId: e.productId,
                quantity: e.quantity,
              ),
            )
            .toList(),
      );
      final placedOrderModel = await _remoteDataSource.placeOrder(orderModel);
      return placedOrderModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
