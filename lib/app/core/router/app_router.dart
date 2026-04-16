import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../modules/auth/auth_bloc.dart';
import '../../modules/auth/sign_in/sign_in_cubit.dart';
import '../../modules/auth/sign_up/sign_up_cubit.dart';
import '../../modules/auth/forgot_password/forgot_password_cubit.dart';
import '../../modules/auth/reset_password/reset_password_cubit.dart';
import '../../modules/auth/verify_email/verify_email_cubit.dart';
import '../../modules/auth/two_factor/two_factor_cubit.dart';
import '../../modules/auth/magic_link/magic_link_cubit.dart';
import '../../modules/auth/magic_link/magic_link_view.dart';
import '../../modules/profile/profile_cubit.dart';
import '../../modules/settings/settings_cubit.dart';
import '../../modules/splash/splash_view.dart';
import '../../modules/auth/sign_in/sign_in_view.dart';
import '../../modules/auth/sign_up/sign_up_view.dart';
import '../../modules/auth/forgot_password/forgot_password_view.dart';
import '../../modules/auth/reset_password/reset_password_view.dart';
import '../../modules/auth/verify_email/verify_email_view.dart';
import '../../modules/auth/two_factor/two_factor_view.dart';
import '../../modules/home/home_view.dart';
import '../../modules/profile/profile_view.dart';
import '../../modules/settings/settings_view.dart';
import '../../data/repositories/auth.repository.dart';
import '../../data/repositories/user.repository.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';

GoRouter createRouter({
  required AuthBloc authBloc,
  required AuthRepository authRepository,
  required UserRepository userRepository,
  required AuthService authService,
  required SharedPreferences prefs,
}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _BlocChangeNotifier(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.uri.toString();

      final isLoading = authState is AuthInitial || authState is AuthLoading;
      final isAuthenticated = authState is AuthAuthenticated;

      // Still hydrating — stay on splash.
      if (isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      final isOnAuthRoute = _authRoutes.contains(location) ||
          location.startsWith(AppRoutes.resetPassword) ||
          location.startsWith(AppRoutes.verifyEmail);

      if (!isAuthenticated && !isOnAuthRoute) return AppRoutes.signIn;
      if (isAuthenticated && isOnAuthRoute) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashView(),
      ),

      // ── Auth routes (guest-only) ──────────────────────────────────────────
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, _) => BlocProvider(
          create: (_) => SignInCubit(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const SignInView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, _) => BlocProvider(
          create: (_) => SignUpCubit(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const SignUpView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, _) => BlocProvider(
          create: (_) => ForgotPasswordCubit(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const ForgotPasswordView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return BlocProvider(
            create: (_) => ResetPasswordCubit(
              authRepository: context.read<AuthRepository>(),
            ),
            child: ResetPasswordView(token: token),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return BlocProvider(
            create: (_) => VerifyEmailCubit(
              authRepository: context.read<AuthRepository>(),
            ),
            child: VerifyEmailView(token: token),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.twoFactor,
        builder: (context, _) => BlocProvider(
          create: (_) => TwoFactorCubit(
            authRepository: context.read<AuthRepository>(),
          ),
          child: const TwoFactorView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.magicLink,
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return BlocProvider(
            create: (_) => MagicLinkCubit(
              authRepository: context.read<AuthRepository>(),
            ),
            child: MagicLinkView(token: token),
          );
        },
      ),

      // ── Protected routes (auth-required) ─────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, _) => BlocProvider(
          create: (_) => ProfileCubit(
            userRepository: context.read<UserRepository>(),
            authBloc: context.read<AuthBloc>(),
          )..loadFromAuthBloc(),
          child: const ProfileView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, _) => BlocProvider(
          create: (_) => SettingsCubit(
            authRepository: context.read<AuthRepository>(),
            authService: context.read<AuthService>(),
            authBloc: context.read<AuthBloc>(),
            prefs: prefs,
          ),
          child: const SettingsView(),
        ),
      ),
    ],
  );
}

/// Auth routes that unauthenticated users are allowed to visit.
const _authRoutes = {
  AppRoutes.signIn,
  AppRoutes.signUp,
  AppRoutes.forgotPassword,
  AppRoutes.twoFactor,
  AppRoutes.magicLink,
};

/// Bridges a BLoC [Stream] to [ChangeNotifier] so GoRouter's
/// [refreshListenable] re-evaluates redirects on every auth state change.
class _BlocChangeNotifier extends ChangeNotifier {
  _BlocChangeNotifier(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
