import '../../../../features/auth/data/model/user_model.dart';
import '../../../../features/auth/domain/entities/user.dart';

extension UserModelX on UserModel {
  User toEntity() {
    return User(
      id: id,
      email: email ?? '',
      username: username ?? '',
      password: password ?? '',
    );
  }
}
