import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import 'auth_remote_datasource.dart';

// Implementation of AuthRemoteDataSource using FirebaseAuth.
@LazySingleton(as: AuthRemoteDataSource) // Register as a lazy singleton
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  // Constructor with FirebaseAuth dependency.
  AuthRemoteDataSourceImpl(this._firebaseAuth);

  @override
  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message); // Re-throw FirebaseAuth exceptions
    } catch (e) {
      throw Exception('An unknown error occurred during sign in.');
    }
  }

  @override
  Future<UserCredential> signUpWithEmailPassword(
      String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message); // Re-throw FirebaseAuth exceptions
    } catch (e) {
      throw Exception('An unknown error occurred during sign up.');
    }
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled the Google sign-in process
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Sign in with Firebase using the Google credential
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Handle Firebase specific errors
      throw Exception(e.message);
    } catch (e) {
      // Handle any other unexpected errors during Google sign in
      throw Exception('An unknown error occurred during Google sign in: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unknown error occurred during sign out.');
    }
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
