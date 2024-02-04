import 'package:dirihome/dashboard.dart';
import 'package:dirihome/firebase_options.dart';
import 'package:dirihome/notifications/app_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  AppNotification appNotification = AppNotification();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  appNotification.requestNotificationPermissions(FirebaseMessaging.instance);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await appNotification.initializeNotificationServicesForDefault();
  runApp(const MainPage());
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DashBoard(), debugShowCheckedModeBanner: false);
  }
}
