import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todolist/main.dart';
import 'package:todolist/models/notes_model.dart'; // Đảm bảo đúng đường dẫn đến file Note

class NotificationService {
  // Schedules a one-time notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    if (scheduledDateTime.isBefore(DateTime.now())) {
      print('Scheduled time is in the past, skipping notification for ID: $id.');
      return;
    }

    final tz.TZDateTime scheduledTZDateTime =
    tz.TZDateTime.from(scheduledDateTime, tz.local);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'Task Reminder Channel',
      channelDescription: 'Notification channel for ToDoList tasks',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDateTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    print('Notification scheduled for ID: $id at $scheduledTZDateTime with title: $title');
  }

  // Schedules notification for a Note object if valid
  Future<void> scheduleNotificationForNote(Note note) async {
    if (note.reminderDateTime != null) {
      DateTime reminderTime = note.reminderDateTime!.toDate();

      if (reminderTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: note.id.hashCode,
          title: note.title,
          body: note.subtitle,
          scheduledDateTime: reminderTime,
          payload: note.id,
        );
      } else {
        print("⏰ Reminder for note '${note.title}' is in the past. Skipped.");
      }
    }
  }

  // Cancels a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('Notification cancelled for ID: $id');
  }

  // Cancels all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('All notifications cancelled.');
  }
}
