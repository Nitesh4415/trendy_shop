import 'package:injectable/injectable.dart';
import 'package:shop_trendy/core/constants/api_constants.dart';
import 'package:shop_trendy/features/auth/data/datasources/user_remote_datasource.dart';

import '../../../../core/network/api_client.dart';
import '../model/user_model.dart';

@LazySingleton(as: UserRemoteDataSource)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient _apiClient;

  UserRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<UserModel>> getAllUsers() async {
    final responseData = await _apiClient.get(ApiConstants.users);
    return (responseData as List)
        .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserModel> createUser(UserModel user) async {
    final responseData = await _apiClient.post(
      ApiConstants.users,
      user.toJson(),
    );
    return UserModel.fromJson(responseData as Map<String, dynamic>);
  }
}
