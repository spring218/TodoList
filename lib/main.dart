import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todolist/auth/main_page.dart';

// --- THÔNG BÁO CỤC BỘ ---
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void notificationResponseBackground(NotificationResponse notificationResponse) {
  debugPrint(
      'Notification clicked in background with payload: ${notificationResponse.payload}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Timezone setup
  tz.initializeTimeZones(); // <- Đừng quên dòng này
  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));

  // Android init
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS/macOS init
  final DarwinInitializationSettings initializationSettingsDarwin =
  DarwinInitializationSettings();

  // Combine init settings
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );

  // Init plugin
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('Notification clicked with payload: ${response.payload}');
    },
    onDidReceiveBackgroundNotificationResponse: notificationResponseBackground,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Main_Page(),
    );
  }
}
