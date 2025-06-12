import 'package:injectable/injectable.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignOutUseCase {
  final AuthRepository _repository;
  SignOutUseCase(this._repository);

  Future<void> call() async {
    await _repository.signOut();
  }
}
