import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM Background message received: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _fcmToken;

  static String? get fcmToken => _fcmToken;

  /// Initialize Firebase Cloud Messaging
  static Future<void> initialize() async {
    try {
      // 1. Request notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM: User granted permission: ${settings.authorizationStatus}');

      // 2. Register background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Get device registration token
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Device Token: $_fcmToken');

      // 4. Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token refreshed: $newToken');
      });

      // 5. Handle foreground push messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground message received: ${message.notification?.title} - ${message.notification?.body}');
      });

      // 6. Automatically subscribe to regional agro-climatic alert topics
      await subscribeToRegionalOutbreaks('tamil_nadu_outbreaks');
    } catch (e) {
      debugPrint('FCM initialization error: $e');
    }
  }

  /// Subscribe to a regional outbreak or weather alert topic
  static Future<void> subscribeToRegionalOutbreaks(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('FCM: Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('FCM subscribe error: $e');
    }
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('FCM: Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('FCM unsubscribe error: $e');
    }
  }
}
