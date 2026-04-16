import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/providers/user.provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final _localNotifications = FlutterLocalNotificationsPlugin();

  final onMessage = StreamController<RemoteMessage>.broadcast();
  StreamSubscription<RemoteMessage>? _onMessageSubscription;

  Future<NotificationService> init() async {
    await _initLocalNotifications();
    await _requestPermission();
    await _setupMessageHandlers();
    return this;
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notification permission granted');
    }
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);

    _onMessageSubscription = FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
      onMessage.add(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Channel',
          channelDescription: 'Default notification channel',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      _handleNotificationDeepLink(payload);
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    final data = message.data;
    if (data.containsKey('screen')) {
      final screen = data['screen'];
      if (screen == 'profile') {
        Get.toNamed('/profile');
      } else if (screen == 'settings') {
        Get.toNamed('/settings');
      }
    }
  }

  void _handleNotificationDeepLink(String payload) {
    try {
      final uri = Uri.parse(payload);
      final screen = uri.queryParameters['screen'];
      if (screen == 'profile') {
        Get.toNamed('/profile');
      } else if (screen == 'settings') {
        Get.toNamed('/settings');
      }
    } catch (_) {}
  }

  Future<void> _onTokenRefresh(String token) async {
    try {
      await UserProvider().registerDeviceToken(
        token: token,
        platform: Platform.isAndroid ? 'android' : 'ios',
      );
    } catch (_) {}
  }

  Future<String?> getToken() async {
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> registerDeviceToken() async {
    final token = await getToken();
    if (token == null) return;

    try {
      await UserProvider().registerDeviceToken(
        token: token,
        platform: Platform.isAndroid ? 'android' : 'ios',
      );
    } catch (_) {}
  }

  @override
  void onClose() {
    _onMessageSubscription?.cancel();
    onMessage.close();
    super.onClose();
  }
}
