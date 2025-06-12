import '../../../../features/auth/data/model/user_model.dart';
import '../../../../features/auth/domain/entities/user.dart';

extension UserX on User {
  UserModel toModel() {
    return UserModel(
      id: id,
      email: email,
      username: username,
      password: password,
    );
  }}