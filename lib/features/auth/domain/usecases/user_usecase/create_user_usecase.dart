import 'package:injectable/injectable.dart';

import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

@LazySingleton()
class CreateUserUseCase {
  final UserRepository _repository;

  CreateUserUseCase(this._repository);

  Future<User> call(User user) async {
    return await _repository.createUser(user);
  }
}
