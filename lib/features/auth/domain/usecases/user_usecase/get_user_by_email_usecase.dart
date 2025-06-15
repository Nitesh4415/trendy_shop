import 'package:injectable/injectable.dart';

import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

@LazySingleton()
class GetUserByEmailUseCase {
  final UserRepository _repository;

  GetUserByEmailUseCase(this._repository);

  Future<List<User>> call(String email) async {
    final allUsers = await _repository.getAllUsers();
    return allUsers.where((user) => user.email == email).toList();
  }
}
