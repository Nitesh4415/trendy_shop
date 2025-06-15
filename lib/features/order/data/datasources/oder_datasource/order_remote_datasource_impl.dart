import 'package:shop_trendy/core/constants/api_constants.dart';
import 'package:shop_trendy/core/network/api_client.dart';
import 'package:shop_trendy/features/order/data/models/order_model.dart';
import 'package:injectable/injectable.dart';
import 'order_remote_datasource.dart'; // For jsonEncode/decode

@LazySingleton(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _apiClient;

  OrderRemoteDataSourceImpl(this._apiClient); // Constructor now takes ApiClient

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    final responseData = await _apiClient.post(
      ApiConstants.orders,
      order.toJson(),
    );
    return OrderModel.fromJson(responseData as Map<String, dynamic>);
  }

  @override
  Future<List<OrderModel>> getOrderHistory(int userId) async {
    final responseData = await _apiClient.get(
      '${ApiConstants.orders}/user/$userId',
    );
    return (responseData as List)
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
