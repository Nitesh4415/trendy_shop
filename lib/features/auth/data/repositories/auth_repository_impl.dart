import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

// Implementation of the AuthRepository.
@LazySingleton(as: AuthRepository) // Register as a lazy singleton
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  // Constructor with remote data source dependency.
  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _remoteDataSource.signInWithEmailPassword(email, password);
    } catch (e) {
      rethrow; // Re-throw exceptions from data source
    }
  }

  @override
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      return await _remoteDataSource.signUpWithEmailPassword(email, password);
    } catch (e) {
      rethrow; // Re-throw exceptions from data source
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      return await _remoteDataSource.signInWithGoogle();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;
}
