import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

// Đảm bảo import đúng đường dẫn tới main.dart của bạn để sử dụng `flutterLocalNotificationsPlugin`
// Nếu main.dart của bạn nằm ở thư mục `lib`, thì đường dẫn là `../main.dart`
// Nếu main.dart của bạn nằm ở một thư mục khác, ví dụ `lib/app/main.dart`, thì đường dẫn sẽ là `../../main.dart`
import 'package:todolist/main.dart'; // Ví dụ: Giả sử main.dart nằm ở lib/main.dart

class NotificationService {
  // Hàm lên lịch thông báo
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    // Kiểm tra nếu thời gian đã chọn là trong quá khứ thì không lên lịch
    if (scheduledDateTime.isBefore(DateTime.now())) {
      print('Scheduled time is in the past, skipping notification for ID: $id.');
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id', // ID kênh thông báo. Phải khớp với ID bạn định nghĩa trong main.dart
      'Kênh nhắc nhở công việc', // Tên kênh hiển thị cho người dùng
      channelDescription: 'Kênh thông báo cho các công việc cần làm của ToDoList',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher', // Sử dụng icon của app bạn (ví dụ: ic_launcher)
    );
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true, // Hiển thị cảnh báo
      presentBadge: true, // Hiển thị số badge trên icon app
      presentSound: true, // Phát âm thanh
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Chuyển đổi DateTime sang TZDateTime (thời gian theo múi giờ địa phương)
    final tz.TZDateTime scheduledTZDateTime =
    tz.TZDateTime.from(scheduledDateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, // ID duy nhất cho thông báo này
      title,
      body,
      scheduledTZDateTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Chế độ lên lịch chính xác ngay cả khi thiết bị ở chế độ nhàn rỗi
      matchDateTimeComponents: DateTimeComponents.dateAndTime, // Để thông báo chỉ kích hoạt vào ngày và giờ cụ thể
      payload: payload, // Dữ liệu đính kèm khi thông báo được chạm vào
    );
    print('Notification scheduled for ID: $id at $scheduledTZDateTime with title: $title');
  }

  // Hàm hủy thông báo theo ID
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('Notification cancelled for ID: $id');
  }

  // Hàm hủy tất cả thông báo
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('All notifications cancelled.');
  }
}