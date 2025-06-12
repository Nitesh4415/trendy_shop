import 'package:injectable/injectable.dart';
import 'package:shop_trendy/core/utils/extensions/user/user_extension.dart';
import 'package:shop_trendy/core/utils/extensions/user/user_model_extension.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final userModels = await _remoteDataSource.getAllUsers();
      return userModels.map((model) => model.toEntity()).toList();
    }
    catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> createUser(User user) async {
    try {
      final userModel = user.toModel();
      final createdUserModel = await _remoteDataSource.createUser(userModel);
      return createdUserModel.toEntity();
    }
    catch (e) {
      rethrow;
    }
  }
}