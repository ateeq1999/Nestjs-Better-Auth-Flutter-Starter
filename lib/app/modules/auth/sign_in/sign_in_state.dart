part of 'sign_in_cubit.dart';

sealed class SignInState {
  const SignInState();
}

final class SignInInitial extends SignInState {
  const SignInInitial();
}

final class SignInLoading extends SignInState {
  const SignInLoading();
}

final class SignInSuccess extends SignInState {
  const SignInSuccess({required this.token, required this.user});
  final String token;
  final User user;
}

final class SignInFailure extends SignInState {
  const SignInFailure(this.message);
  final String message;
}
