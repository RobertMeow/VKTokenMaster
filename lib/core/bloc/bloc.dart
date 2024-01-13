import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:token_master/core/api/api.dart';
import 'package:equatable/equatable.dart';
import 'package:token_master/core/api/model.dart';

part 'event.dart';
part 'state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Api api = Api();

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      String response = await api.login(event.login, event.password, event.code ?? '', event.typeAuth);
      if (response == "captcha") {
        return emit(AuthCaptcha());
      }

      if (response == "code") {
        return emit(AuthNeedCode(typeAuth: event.typeAuth));
      }

      if (response.length < 100) {
        return emit(AuthError(message: response));
      }

      emit(AuthAuthenticated(accessToken: response));
    } catch (e) {
      emit(AuthError(message: '$e'));
    }
  }
}
