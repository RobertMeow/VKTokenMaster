part of 'bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String login;
  final String password;
  final String? code;
  final TypeAuth typeAuth;

  const LoginEvent({required this.login, required this.password, this.code, required this.typeAuth});

  @override
  List<Object?> get props => [login, password, code, typeAuth];
}
