import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../repositories/auth_repository.dart';

@LazySingleton()
class SignInWithEmailPasswordUseCase {
  final AuthRepository _repository;

  SignInWithEmailPasswordUseCase(this._repository);

  Future<UserCredential> call(String email, String password) async {
    return await _repository.signInWithEmailPassword(email, password);
  }
}
