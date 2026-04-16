import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:app_links/app_links.dart';

import 'firebase_options.dart';
import 'app/core/di/initial_bindings.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/auth_service.dart';

final _appLinks = AppLinks();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  await GetStorage.init();

  _initDeepLinks();

  runApp(const MyApp());
}

void _initDeepLinks() {
  _appLinks.uriLinkStream.listen(
    (uri) {
      _handleDeepLink(uri);
    },
    onError: (err) {
      debugPrint('Deep link error: $err');
    },
  );
}

void _handleDeepLink(Uri uri) {
  final scheme = uri.scheme;
  if (scheme == dotenv.env['APP_SCHEME'] || scheme == 'myapp') {
    final host = uri.host;
    final params = uri.queryParameters;

    if (host == 'auth') {
      if (uri.path == '/callback' && params.containsKey('token')) {
        _handleAuthCallback(params['token']!);
      } else if (uri.path == '/verify-email' && params.containsKey('token')) {
        Get.toNamed(
          AppRoutes.verifyEmail,
          arguments: {'token': params['token']},
        );
      } else if (uri.path == '/reset-password' && params.containsKey('token')) {
        Get.toNamed(
          AppRoutes.resetPassword,
          arguments: {'token': params['token']},
        );
      }
    }
  }
}

void _handleAuthCallback(String token) {
  if (Get.isRegistered<AuthService>()) {
    final authService = Get.find<AuthService>();
    authService.saveToken(token);
    Get.offAllNamed(AppRoutes.home);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Starter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      themeMode: ThemeMode.system,
      initialBinding: InitialBindings(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
