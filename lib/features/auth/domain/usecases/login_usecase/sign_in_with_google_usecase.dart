import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../repositories/auth_repository.dart';

@LazySingleton()
class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<UserCredential> call() async {
    return await _repository.signInWithGoogle();
  }
}
