import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  Future<void> initializeNotificationServicesForDefault() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic("door0");
    saveNotificationID(messaging);
  }

  Future<void> saveNotificationID(FirebaseMessaging messaging) async {
    
    messaging.getToken().then((value) async {
      value = value ?? "@";
      debugPrint("Notification id: $value");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("notificationid", value);
    });
  }


  Future<void> requestNotificationPermissions(FirebaseMessaging messaging) async {
    NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  
}
