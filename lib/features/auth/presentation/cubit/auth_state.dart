part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];

  bool get isAuthenticated => this is AuthAuthenticated;
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final firebase_auth.User user;
  final app_user.User appUser; // Our internal app user with FakeStoreAPI ID

  const AuthAuthenticated({required this.user, required this.appUser});

  @override
  List<Object> get props => [user, appUser];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}