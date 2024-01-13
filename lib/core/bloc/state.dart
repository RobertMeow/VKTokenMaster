part of 'bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String accessToken;

  const AuthAuthenticated({required this.accessToken});

  @override
  List<Object?> get props => [accessToken];
}

class AuthNeedCode extends AuthState {
  final TypeAuth typeAuth;

  const AuthNeedCode({required this.typeAuth});

  @override
  List<Object?> get props => [typeAuth];
}

class AuthCaptcha extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
