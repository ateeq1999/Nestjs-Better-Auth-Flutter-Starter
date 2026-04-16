# Flutter Starter

Cross-platform mobile app (iOS + Android) using Flutter + GetX. Authenticates against the NestJS Better-Auth API using Bearer tokens. Firebase handles push notifications and optional analytics.

---

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Framework | Flutter 3.x (stable channel) | Dart 3 with null safety |
| State / DI / Nav | GetX | All-in-one: state, routing, dependency injection |
| HTTP | Dio + `dio_cache_interceptor` | Interceptors for Bearer token, refresh, logging |
| Secure Storage | `flutter_secure_storage` | iOS Keychain / Android Keystore |
| Local Storage | `get_storage` | Non-sensitive prefs (theme, locale) |
| Forms | `flutter_form_builder` + `form_builder_validators` | Consistent form UX |
| Images | `cached_network_image` | Profile avatars with memory + disk cache |
| File Upload | `image_picker` + Dio `FormData` | Avatar upload (JPEG/PNG/WebP) |
| Push Notifications | Firebase Cloud Messaging (`firebase_messaging`) | FCM on Android; APNs via FCM on iOS |
| Analytics | `firebase_analytics` (optional) | Screen tracking, custom events |
| Deep Links | `app_links` | OAuth callback: `myapp://auth/callback` |
| Env Config | `flutter_dotenv` | `.env` → `String.fromEnvironment` alternative |
| Code Gen | `build_runner` + `freezed` + `json_serializable` | Immutable models, JSON serialization |
| Routing | GetX named routes + middleware | Guard unauthenticated pages |
| Testing | `flutter_test` + `mocktail` | Unit + widget + integration |
| Linting | `flutter_lints` + custom analysis options | Strict rules |

---

## Architecture (GetX Clean)

GetX is used as the full application framework — not just state management. The project follows a feature-first structure with each feature having its own `controller`, `view`, and `binding`.

```
lib/
├── app/
│   ├── core/
│   │   ├── di/
│   │   │   └── initial_bindings.dart       # Root GetX bindings (registered at startup)
│   │   ├── errors/
│   │   │   └── app_exception.dart          # Typed exceptions (ApiException, AuthException)
│   │   ├── middleware/
│   │   │   ├── auth_middleware.dart         # Redirect to /sign-in if no token
│   │   │   └── guest_middleware.dart        # Redirect to /home if already signed in
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
│   │   │   ├── splash_binding.dart
│   │   │   ├── splash_controller.dart      # Check token → route to home or sign-in
│   │   │   └── splash_view.dart
│   │   ├── auth/
│   │   │   ├── sign_in/
│   │   │   │   ├── sign_in_binding.dart
│   │   │   │   ├── sign_in_controller.dart
│   │   │   │   └── sign_in_view.dart
│   │   │   ├── sign_up/
│   │   │   ├── forgot_password/
│   │   │   ├── reset_password/
│   │   │   ├── verify_email/
│   │   │   └── two_factor/                 # TOTP entry screen
│   │   ├── home/
│   │   │   ├── home_binding.dart
│   │   │   ├── home_controller.dart
│   │   │   └── home_view.dart
│   │   ├── profile/
│   │   │   ├── profile_binding.dart
│   │   │   ├── profile_controller.dart     # Avatar upload, display name edit
│   │   │   └── profile_view.dart
│   │   └── settings/
│   │       ├── settings_binding.dart
│   │       ├── settings_controller.dart    # Change password, 2FA toggle, sign-out
│   │       └── settings_view.dart
│   ├── routes/
│   │   ├── app_pages.dart                  # GetPage list with bindings + middleware
│   │   └── app_routes.dart                 # Route name constants
│   └── services/
│       ├── auth_service.dart               # GetxService: token storage, current user Rx
│       ├── dio_service.dart                # Dio instance, interceptors
│       └── notification_service.dart       # FCM init, token registration
├── firebase_options.dart                   # FlutterFire CLI generated
└── main.dart                               # runApp + DotEnv.load + Firebase.initializeApp
```

---

## Auth Flow

### Sign-In

```dart
// sign_in_controller.dart
Future<void> signIn() async {
  final response = await _authRepo.signIn(
    email: emailController.text,
    password: passwordController.text,
  );
  // Store Bearer token securely
  await _authService.saveToken(response.token);
  await _authService.setCurrentUser(response.user);
  // Register FCM token
  await _notificationService.registerDeviceToken();
  Get.offAllNamed(AppRoutes.home);
}
```

### Dio Interceptor (Bearer + Refresh)

```dart
// dio_service.dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AuthService.to.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await AuthService.to.refreshToken();
      if (refreshed) {
        // Retry original request with new token
        final retryResponse = await _dio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      }
      // Refresh failed — force sign out
      await AuthService.to.signOut();
      Get.offAllNamed(AppRoutes.signIn);
    }
    handler.next(err);
  }
}
```

---

## Route Guards (GetX Middleware)

```dart
// app_pages.dart
GetPage(
  name: AppRoutes.home,
  page: () => const HomeView(),
  binding: HomeBinding(),
  middlewares: [AuthMiddleware()],   // Redirects to /sign-in if no token
),
GetPage(
  name: AppRoutes.signIn,
  page: () => const SignInView(),
  binding: SignInBinding(),
  middlewares: [GuestMiddleware()],  // Redirects to /home if already signed in
),
```

---

## Firebase Setup

### Push Notifications

```dart
// notification_service.dart
class NotificationService extends GetxService {
  Future<NotificationService> init() async {
    await FirebaseMessaging.instance.requestPermission();

    // Foreground notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    // Background / terminated tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    return this;
  }

  Future<void> registerDeviceToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    await UserProvider.to.registerDeviceToken(
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
void _initDeepLinks() {
  AppLinks().uriLinkStream.listen((uri) {
    if (uri.scheme == 'myapp' && uri.host == 'auth') {
      final token = uri.queryParameters['token'];
      if (token != null) {
        AuthService.to.saveToken(token);
        Get.offAllNamed(AppRoutes.home);
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
flutter pub add get get_storage flutter_secure_storage dio \
  flutter_dotenv image_picker cached_network_image \
  flutter_form_builder form_builder_validators \
  app_links firebase_core firebase_messaging firebase_analytics

flutter pub add --dev freezed json_serializable build_runner \
  mocktail flutter_lints

# FlutterFire CLI
dart pub global activate flutterfire_cli
flutterfire configure

# Run
flutter run
```

---

## Best Practices

- **Never** store the Bearer token in `get_storage` — always use `flutter_secure_storage`
- **ObxValue** or **Obx** widgets only wrap the smallest subtree that needs to react
- **GetxService** (not `GetxController`) for long-lived services: `AuthService`, `DioService`, `NotificationService`
- All API calls in **providers**, business logic in **repositories**, UI logic in **controllers**
- Use **`ever()`** and **`debounce()`** for reactive side effects, not `StreamBuilder`
- Platform check (`Platform.isAndroid`) in services, never in widgets
- All `async` Dio calls are wrapped in `try/catch (DioException)`; map to typed `AppException`
- Deep links tested on real devices — emulators may not handle custom schemes correctly
