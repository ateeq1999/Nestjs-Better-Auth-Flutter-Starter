# Flutter Starter

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Tests](https://img.shields.io/badge/Tests-25%20passing-brightgreen)

Cross-platform mobile app (iOS + Android) using Flutter + **flutter_bloc**. Authenticates against the NestJS Better-Auth API using Bearer tokens. Firebase handles push notifications and optional analytics.

> **State Management Migration:** This project is migrating from GetX to `flutter_bloc` + `go_router`. GetX is no longer actively maintained. All new features must use BLoC/Cubit. See [FL11 in todo.md](./todo.md#fl11--bloc-migration-getx--flutter_bloc) for the migration task list.

---

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Framework | Flutter 3.x (stable channel) | Dart 3 with null safety |
| State Management | `flutter_bloc` + `equatable` | BLoC/Cubit pattern; replaces GetX |
| Navigation | `go_router` | Declarative routing with `redirect` guard; replaces GetX routes |
| HTTP | Dio + `dio_cache_interceptor` | Interceptors for Bearer token, refresh, logging |
| Secure Storage | `flutter_secure_storage` | iOS Keychain / Android Keystore |
| Local Storage | `shared_preferences` | Non-sensitive prefs (theme, locale) |
| State Persistence | `hydrated_bloc` | Persists `AuthBloc` + `ThemeCubit` across restarts |
| Forms | `flutter_form_builder` + `form_builder_validators` | Consistent form UX |
| Images | `cached_network_image` | Profile avatars with memory + disk cache |
| File Upload | `image_picker` + Dio `FormData` | Avatar upload (JPEG/PNG/WebP) |
| Push Notifications | Firebase Cloud Messaging (`firebase_messaging`) | FCM on Android; APNs via FCM on iOS |
| Analytics | `firebase_analytics` (optional) | Screen tracking, custom events |
| Deep Links | `app_links` | OAuth callback: `myapp://auth/callback` |
| Env Config | `flutter_dotenv` | `.env` → `String.fromEnvironment` alternative |
| Code Gen | `build_runner` + `freezed` + `json_serializable` | Immutable models, JSON serialization |
| Testing | `flutter_test` + `mocktail` + `bloc_test` | Unit + widget + integration |
| Linting | `flutter_lints` + custom analysis options | Strict rules |

---

## Architecture (BLoC Clean)

The project follows a feature-first structure. Each feature has its own **Cubit/BLoC**, **View**, and injects its dependencies via `BlocProvider` / `RepositoryProvider`.

```
lib/
├── app/
│   ├── core/
│   │   ├── errors/
│   │   │   └── app_exception.dart          # Typed exceptions (ApiException, AuthException)
│   │   ├── router/
│   │   │   └── app_router.dart             # GoRouter with redirect auth guard
│   │   └── utils/
│   │       └── snackbar_helper.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── user.model.dart             # @freezed User, @JsonSerializable
│   │   │   ├── session.model.dart
│   │   │   └── auth_response.model.dart
│   │   ├── providers/
│   │   │   ├── auth.provider.dart          # Raw Dio calls to /api/auth/*
│   │   │   └── user.provider.dart          # Raw Dio calls to /api/users/*
│   │   └── repositories/
│   │       ├── auth.repository.dart        # Business logic layer over providers
│   │       └── user.repository.dart
│   ├── modules/
│   │   ├── splash/
│   │   │   └── splash_view.dart
│   │   ├── auth/
│   │   │   ├── auth_bloc.dart              # AuthBloc: AuthStarted, SignIn, SignOut events
│   │   │   ├── auth_event.dart
│   │   │   ├── auth_state.dart
│   │   │   ├── sign_in/
│   │   │   │   ├── sign_in_cubit.dart
│   │   │   │   ├── sign_in_state.dart
│   │   │   │   └── sign_in_view.dart
│   │   │   ├── sign_up/
│   │   │   ├── forgot_password/
│   │   │   ├── reset_password/
│   │   │   ├── verify_email/
│   │   │   └── two_factor/
│   │   ├── home/
│   │   │   └── home_view.dart
│   │   ├── profile/
│   │   │   ├── profile_cubit.dart
│   │   │   ├── profile_state.dart
│   │   │   └── profile_view.dart
│   │   └── settings/
│   │       ├── settings_cubit.dart
│   │       ├── settings_state.dart
│   │       └── settings_view.dart
│   └── services/
│       ├── dio_service.dart                # Dio instance, AuthInterceptor (Bearer + refresh)
│       └── notification_service.dart       # FCM init, token registration
├── firebase_options.dart                   # FlutterFire CLI generated
└── main.dart                               # runApp + DotEnv.load + Firebase.initializeApp
```

---

## BLoC Pattern

### AuthBloc (root-level)

`AuthBloc` lives at the top of the widget tree and drives the router redirect. All authentication state flows through it.

```dart
// auth_state.dart
sealed class AuthState extends Equatable {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  final String token;
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
}
```

```dart
// auth_bloc.dart
class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository, this._storage) : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignIn>(_onSignIn);
    on<AuthSignOut>(_onSignOut);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      // Optionally verify session here
      emit(AuthAuthenticated(user: cachedUser, token: token));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
```

### Feature Cubits

Each screen owns a lightweight Cubit for its local UI state.

```dart
// sign_in_cubit.dart
class SignInCubit extends Cubit<SignInState> {
  SignInCubit(this._authRepository) : super(SignInInitial());

  Future<void> signIn(String email, String password) async {
    emit(SignInLoading());
    try {
      final response = await _authRepository.signIn(email: email, password: password);
      emit(SignInSuccess(response));
    } on ApiException catch (e) {
      emit(SignInFailure(e.message));
    }
  }
}
```

### BlocListener for Side Effects

Navigation and snackbars are side effects — they live in the view, not the BLoC.

```dart
// sign_in_view.dart
BlocListener<SignInCubit, SignInState>(
  listener: (context, state) {
    if (state is SignInSuccess) {
      // AuthBloc handles global auth state
      context.read<AuthBloc>().add(AuthSignIn(response: state.response));
      context.go(AppRoutes.home);
    }
    if (state is SignInFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: SignInForm(),
)
```

---

## Routing (go_router)

Route guards are implemented as a `redirect` callback on `GoRouter` that reads `AuthBloc` state. The router refreshes automatically on auth state changes.

```dart
// app_router.dart
GoRouter appRouter(AuthBloc authBloc) => GoRouter(
  refreshListenable: GoRouterRefreshStream(authBloc.stream),
  redirect: (context, state) {
    final authState = authBloc.state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isOnAuthRoute = state.matchedLocation.startsWith('/sign-in')
        || state.matchedLocation.startsWith('/sign-up');

    if (!isAuthenticated && !isOnAuthRoute) return '/sign-in';
    if (isAuthenticated && isOnAuthRoute) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/splash',        builder: (_, __) => const SplashView()),
    GoRoute(path: '/sign-in',       builder: (_, __) => const SignInView()),
    GoRoute(path: '/sign-up',       builder: (_, __) => const SignUpView()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordView()),
    GoRoute(
      path: '/reset-password',
      builder: (_, state) => ResetPasswordView(
        token: state.uri.queryParameters['token'] ?? '',
      ),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (_, state) => VerifyEmailView(
        token: state.uri.queryParameters['token'] ?? '',
      ),
    ),
    GoRoute(path: '/two-factor',    builder: (_, __) => const TwoFactorView()),
    GoRoute(path: '/home',          builder: (_, __) => const HomeView()),
    GoRoute(path: '/profile',       builder: (_, __) => const ProfileView()),
    GoRoute(path: '/settings',      builder: (_, __) => const SettingsView()),
  ],
);
```

---

## DI (RepositoryProvider + BlocProvider)

Dependencies are provided top-down using the `flutter_bloc` provider tree. No service locator.

```dart
// main.dart
MultiBlocProvider(
  providers: [
    RepositoryProvider(create: (_) => DioService()),
    RepositoryProvider(create: (ctx) => AuthRepository(ctx.read<DioService>())),
    RepositoryProvider(create: (ctx) => UserRepository(ctx.read<DioService>())),
    BlocProvider(
      create: (ctx) => AuthBloc(ctx.read<AuthRepository>())..add(AuthStarted()),
    ),
  ],
  child: MaterialApp.router(
    routerConfig: appRouter(/* AuthBloc from context */),
  ),
)
```

---

## Dio Interceptor (Bearer + Refresh)

```dart
// dio_service.dart
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final newToken = await _refreshToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retryResponse = await _dio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        // Refresh failed — AuthBloc will handle sign-out
      }
    }
    handler.next(err);
  }
}
```

---

## Auth Flow

### Sign-In

```dart
// sign_in_cubit.dart
Future<void> signIn(String email, String password) async {
  emit(SignInLoading());
  try {
    final response = await _authRepository.signIn(email: email, password: password);
    emit(SignInSuccess(response));
  } on ApiException catch (e) {
    emit(SignInFailure(e.message));
  }
}

// sign_in_view.dart — BlocListener reacts to success
if (state is SignInSuccess) {
  context.read<AuthBloc>().add(AuthSignIn(response: state.response));
  await _notificationService.registerDeviceToken();
  context.go(AppRoutes.home);
}
```

---

## Firebase Setup

### Push Notifications

```dart
// notification_service.dart
class NotificationService {
  Future<void> init() async {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> registerDeviceToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    await _userRepository.registerDeviceToken(
      token: token,
      platform: Platform.isAndroid ? 'android' : 'ios',
    );
  }
}
```

### Firebase Files Required

- `google-services.json` → `android/app/`
- `GoogleService-Info.plist` → `ios/Runner/`
- Run `flutterfire configure` after setting up Firebase project

---

## OAuth Deep Links

```dart
// main.dart — listen for deep links
void _initDeepLinks(AuthBloc authBloc) {
  AppLinks().uriLinkStream.listen((uri) {
    if (uri.scheme == 'myapp' && uri.host == 'auth') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        authBloc.add(AuthTokenReceived(token: token));
      }
    }
  });
}
```

Android `AndroidManifest.xml`:
```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="myapp" android:host="auth"/>
</intent-filter>
```

iOS `Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array><string>myapp</string></array>
  </dict>
</array>
```

---

## Environment Variables

```env
# .env (git-ignored)
API_URL=http://10.0.2.2:5555     # Android emulator → host machine
# API_URL=http://localhost:5555  # iOS simulator
```

```dart
// main.dart
await dotenv.load(fileName: '.env');
final apiUrl = dotenv.env['API_URL']!;
```

---

## Models Pattern (Freezed + JSON)

```dart
// user.model.dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? name,
    String? image,
    @JsonKey(name: 'emailVerified') required bool emailVerified,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

Generate: `flutter pub run build_runner build --delete-conflicting-outputs`

---

## Setup

```bash
# Create project
flutter create --org com.yourcompany --platforms ios,android myapp
cd myapp

# Install dependencies
flutter pub add flutter_bloc bloc equatable hydrated_bloc go_router \
  flutter_secure_storage dio flutter_dotenv image_picker \
  cached_network_image flutter_form_builder form_builder_validators \
  app_links firebase_core firebase_messaging firebase_analytics

flutter pub add --dev bloc_test freezed json_serializable build_runner \
  mocktail flutter_lints

# FlutterFire CLI
dart pub global activate flutterfire_cli
flutterfire configure

# Run
flutter run
```

---

## Known Bugs

The following bugs were identified during the initial audit and are tracked in [todo.md](./todo.md#fl0--bug-registry).

| ID | Severity | Description |
|----|----------|-------------|
| BUG-01 | Critical | `DioService` interceptor is a no-op — Bearer token never attached to requests |
| BUG-02 | Critical | `AuthService.refreshToken()` always returns `false` — stub, never calls refresh endpoint |
| BUG-03 | Critical | `InitialBindings` missing `AuthRepository`, `UserRepository`, `AuthProvider`, `UserProvider`, `NotificationService` |
| BUG-04 | Critical | `AuthService.setCurrentUser()` serialises User as URL query string — fragile, size-limited |
| BUG-05 | High | `TwoFactorController.verify()` always succeeds without calling any API |
| BUG-06 | High | `ProfileView` `CircleAvatar` never renders the user's image URL |
| BUG-07 | High | No token-refresh-on-401 in `DioService` — users silently signed out on expiry |
| BUG-08 | High | `AuthService.signOut()` uses hard-coded route string instead of `AppRoutes.signIn` |
| BUG-09 | Medium | `ApiException.fieldErrors` never read — API field validation errors silently dropped |
| BUG-10 | Medium | Controllers use `e.toString()` for errors instead of `ApiException.message` |

---

## Best Practices

- **Never** store the Bearer token in `shared_preferences` — always use `flutter_secure_storage`
- **BlocBuilder** wraps only the smallest subtree that needs to re-render
- **BlocListener** handles all side effects (navigation, snackbars) — never inside a BLoC
- **AuthBloc** is the single source of truth for authentication state; Cubits own only local UI state
- All API calls in **providers**, business logic in **repositories**, UI state in **cubits/blocs**
- `GoRouter.redirect` is the single place for auth-based route guards — no per-route middleware
- Platform check (`Platform.isAndroid`) in services, never in widgets
- All `async` Dio calls wrapped in `try/catch (DioException)`; mapped to typed `AppException`
- Deep links tested on real devices — emulators may not handle custom schemes correctly

---

## Quick Reference

### Common Commands

```bash
# Install dependencies
flutter pub get

# Generate freezed / json_serializable code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build iOS (requires macOS)
flutter build ios --release

# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Clean and rebuild
flutter clean && flutter pub get
```

### Directory Structure

| Directory | Purpose |
|-----------|---------|
| `lib/app/core/` | Core utilities, router, errors |
| `lib/app/data/` | Models, providers, repositories |
| `lib/app/modules/` | Feature modules — each contains a Cubit/BLoC, state, and view |
| `lib/app/services/` | Long-lived singletons (Dio, notifications) |
| `test/` | Unit and widget tests |
| `integration_test/` | Integration tests |

### API Endpoints Expected

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/sign-in/email` | Sign in with email/password |
| POST | `/api/auth/sign-up/email` | Create new account |
| POST | `/api/auth/sign-out` | Sign out |
| POST | `/api/auth/forgot-password` | Request password reset |
| POST | `/api/auth/reset-password` | Reset password with token |
| POST | `/api/auth/change-password` | Change password |
| POST | `/api/auth/verify-email` | Verify email address |
| POST | `/api/auth/token/refresh` | Refresh access token |
| GET | `/api/users/me` | Get current user |
| PATCH | `/api/users/me` | Update user profile |
| POST | `/api/users/me/avatar` | Upload avatar |
| POST | `/api/users/device-tokens` | Register FCM token |

---

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for development guidelines.

## License

MIT License - see [LICENSE](./LICENSE) for details.
