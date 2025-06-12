import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias to avoid conflict
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_trendy/features/auth/domain/repositories/auth_repository.dart';
import 'package:shop_trendy/features/auth/domain/usecases/login_usecase/sign_in_with_email_password_usecase.dart';
import 'package:shop_trendy/features/auth/domain/usecases/sign_up_usecase/sign_up_with_email_password_usecase.dart';
import 'package:shop_trendy/features/auth/domain/usecases/login_usecase/sign_in_with_google_usecase.dart';
import 'package:shop_trendy/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:shop_trendy/features/auth/domain/entities/user.dart' as app_user; // Alias for our app's User entity
import 'package:shop_trendy/features/auth/domain/usecases/user_usecase/get_user_by_email_usecase.dart';
import 'package:shop_trendy/features/auth/domain/usecases/user_usecase/create_user_usecase.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart'; // For generating UUID for FakeStoreAPI user ID

part 'auth_state.dart';

@LazySingleton()
class AuthCubit extends Cubit<AuthState> {
  final SignInWithEmailPasswordUseCase _signInWithEmailPassword;
  final SignUpWithEmailPasswordUseCase _signUpWithEmailPassword;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;
  final AuthRepository _authRepository;
  final GetUserByEmailUseCase _getUserByEmail;
  final CreateUserUseCase _createUser;

  AuthCubit(
      this._signInWithEmailPassword,
      this._signUpWithEmailPassword,
      this._signInWithGoogle,
      this._signOut,
      this._authRepository,
      this._getUserByEmail,
      this._createUser,
      ) : super(AuthInitial()) {
    // Listen to Firebase auth state changes. This is the primary source of truth for auth.
    _authRepository.authStateChanges.listen((firebaseUser) async {
      // Pass the Firebase user, but no password here as it's from auth state change.
      await _handleUserAuthentication(firebaseUser);
    });
  }

  Future<void> _handleUserAuthentication(firebase_auth.User? firebaseUser, {String? password}) async {
    if (firebaseUser != null) {
      emit(AuthLoading());
      try {
        app_user.User? appUser;
        if (firebaseUser.email == null) {
          emit(AuthError('Firebase user has no email. Cannot synchronize with FakeStoreAPI.'));
          return;
        }

        try {
          final users = await _getUserByEmail(firebaseUser.email!);
          if (users.isNotEmpty) {
            appUser = users.first;
            if (kDebugMode) {
              print('User found in FakeStoreAPI: ${appUser.username} with ID ${appUser.id}');
            }
          }
        } on NotFoundException catch (_) {
          if (kDebugMode) {
            print('User not found in FakeStoreAPI, creating new user.');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error during _getUserByEmail for ${firebaseUser.email}: $e');
          }
        }

        if (appUser == null) {

          final generatedId = const Uuid().v4().hashCode; // A simple way to get an int ID
          final username = firebaseUser.email!.split('@')[0]; // Simple username from email
          final newUser = app_user.User(
            id: generatedId, // Pass a dummy ID
            username: username,
            email: firebaseUser.email!,
            password: password ?? '', // Pass password if provided, else empty string
          );
          appUser = await _createUser(newUser);
          if (kDebugMode) {
            print('New user created in FakeStoreAPI: ${appUser.username} with ID ${appUser.id}');
          }
        }
        emit(AuthAuthenticated(user: firebaseUser, appUser: appUser));
      } catch (e) {
        emit(AuthError('Failed to synchronize user data with FakeStoreAPI: ${e.toString()}'));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      // This will return UserCredential from Firebase Auth
      final userCredential = await _signInWithEmailPassword(email, password);
      // Pass the Firebase user and the password to _handleUserAuthentication
      await _handleUserAuthentication(userCredential.user, password: password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUpWithEmailPassword(String email, String password) async {
    emit(AuthLoading());
    try {
      // This will return UserCredential from Firebase Auth
      final userCredential = await _signUpWithEmailPassword(email, password);
      // Pass the Firebase user and the password to _handleUserAuthentication
      await _handleUserAuthentication(userCredential.user, password: password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      // This will return UserCredential from Firebase Auth
      final userCredential = await _signInWithGoogle();
      // For Google sign-in, pass an empty string for password as per requirement
      await _handleUserAuthentication(userCredential.user, password: '');
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _signOut();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void checkAuthStatus() {
    // The constructor's stream listener already handles initial auth status.
    // No explicit action needed here.
  }
}