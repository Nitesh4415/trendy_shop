import 'package:firebase_auth/firebase_auth.dart';


abstract class AuthRemoteDataSource {
  Future<UserCredential> signInWithEmailPassword(String email, String password);
  Future<UserCredential> signUpWithEmailPassword(String email, String password);
  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}
