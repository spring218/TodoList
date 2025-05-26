import 'package:android_intent_plus/android_intent.dart';
import 'dart:io' show Platform;

class PermissionService {
  static Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();
    }
  }
}
