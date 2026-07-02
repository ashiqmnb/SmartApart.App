import 'package:firebase_messaging/firebase_messaging.dart';

/// Handles FCM permission requests and token retrieval.
/// Call FcmHelper.getToken() after login to register the device
/// with the backend (POST /api/notifications/fcm-token).
class FcmHelper {
  FcmHelper._();

  static Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}