abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String? message;
  final dynamic data;

  AuthSuccess({this.message, this.data});
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}
