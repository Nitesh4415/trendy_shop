import 'package:injectable/injectable.dart';
import 'package:shop_trendy/core/constants/api_constants.dart';
import 'package:shop_trendy/features/product/data/datasources/product_remote_datasource.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

@LazySingleton(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProductModel>> getAllProducts() async {
    final responseData = await _apiClient.get(ApiConstants.products);
    return (responseData as List)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProductModel> getProductDetails(int id) async {
    final responseData = await _apiClient.get(ApiConstants.productDetails(id));
    return ProductModel.fromJson(responseData as Map<String, dynamic>);
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final responseData = await _apiClient.get(
      '${ApiConstants.products}/category/$category',
    );
    return (responseData as List)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
