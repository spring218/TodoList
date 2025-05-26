import "package:flutter/material.dart";
import "package:todolist/const/colors.dart";
import "package:todolist/data/firestore.dart";
import "package:todolist/models/notes_model.dart";
import "package:todolist/screens/edit_screen.dart";
import "package:todolist/services/notification_service.dart";

class Task_Widget extends StatefulWidget {
  final Note _note;
  Task_Widget(this._note, {super.key});

  @override
  State<Task_Widget> createState() => _Task_WidgetState();
}

class _Task_WidgetState extends State<Task_Widget> {
  late bool isDone;

  @override
  void initState() {
    super.initState();
    isDone = widget._note.isDone; // Khởi tạo trạng thái isDone từ dữ liệu Note
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 140, maxHeight: 160),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageee(),
              SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + Edit button (top right corner)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            widget._note.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        // Ẩn nút Edit nếu task đã hoàn thành
                        if (!isDone)
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Edit_Screen(widget._note),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color(0xffE2F6F1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  Image.asset('images/icon_edit.png',
                                      width: 18, height: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6),

                    // Subtitle
                    Text(
                      widget._note.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    Spacer(),

                    // Reminder + Checkbox at the bottom
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: _buildReminderWidget()),

                        // Ẩn checkbox nếu task đã hoàn thành
                        isDone
                            ? SizedBox.shrink()
                            : Checkbox(
                          activeColor: custom_green,
                          value: isDone,
                          onChanged: (value) async {
                            setState(() {
                              isDone = value!;
                            });

                            await Firestore_Datasource().isdone(
                              widget._note.id,
                              isDone,
                            );

                            final notificationId =
                                widget._note.id.hashCode;

                            if (isDone) {
                              await NotificationService()
                                  .cancelNotification(notificationId);
                            } else {
                              final scheduledTime =
                              _parseTime(widget._note.time);
                              if (scheduledTime != null &&
                                  scheduledTime.isAfter(DateTime.now())) {
                                await NotificationService()
                                    .scheduleNotification(
                                  id: notificationId,
                                  title: '📌 Task Reminder',
                                  body: widget._note.title,
                                  scheduledDateTime: scheduledTime,
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderWidget() {
    DateTime? remindTime = widget._note.reminderDateTime?.toDate();

    final formattedDateTime = remindTime != null
        ? "${remindTime.day.toString().padLeft(2, '0')}/"
        "${remindTime.month.toString().padLeft(2, '0')} "
        "${remindTime.hour.toString().padLeft(2, '0')}:"
        "${remindTime.minute.toString().padLeft(2, '0')}"
        : "No reminder set";

    return Container(
      constraints: BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: custom_green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('images/icon_time.png', width: 16, height: 16),
          SizedBox(width: 6),
          Flexible(
            child: Tooltip(
              message: formattedDateTime,
              child: Text(
                formattedDateTime,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget imageee() {
    return Container(
      height: 130,
      width: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage('images/${widget._note.image}.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  DateTime? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }
}
