import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todolist/widgets/task_widgets.dart';
import 'package:todolist/data/firestore.dart';
import 'package:todolist/services/notification_service.dart'; // Đảm bảo bạn có file này

class Stream_note extends StatefulWidget {
  final bool done;
  const Stream_note(this.done, {super.key});

  @override
  State<Stream_note> createState() => _Stream_noteState();
}

class _Stream_noteState extends State<Stream_note> {
  List<String> _currentNoteIds = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore_Datasource().stream(widget.done),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final noteslist = Firestore_Datasource().getNotes(snapshot);

        // Phát hiện ghi chú mới được thêm
        final newNoteIds = noteslist.map((e) => e.id).toList();
        final addedNotes = noteslist.where((note) => !_currentNoteIds.contains(note.id)).toList();

        for (final note in addedNotes) {
          // Gửi thông báo nếu task chưa hoàn thành
          if (!widget.done) {
            NotificationService().scheduleNotification(
              id: note.hashCode,
              title: '📝 Công việc mới',
              body: note.title,
              scheduledDateTime: DateTime.now().add(const Duration(seconds: 2)),
            );
          }
        }

        // Cập nhật danh sách ID hiện tại
        _currentNoteIds = newNoteIds;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: noteslist.length,
          itemBuilder: (context, index) {
            final note = noteslist[index];
            return Dismissible(
              key: UniqueKey(),
              onDismissed: (direction) {
                Firestore_Datasource().delet_note(note.id);
                NotificationService().cancelNotification(note.hashCode);
              },
              child: Task_Widget(note),
            );
          },
        );
      },
    );
  }
}
