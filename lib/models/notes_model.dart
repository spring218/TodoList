import 'package:cloud_firestore/cloud_firestore.dart'; // Import để sử dụng Timestamp

class Note {
  String id;
  String title;
  String subtitle;
  String time;
  int image;
  bool isDone;
  Timestamp? reminderDateTime;

  Note(
      this.id,
      this.title,
      this.subtitle,
      this.time,
      this.image,
      this.isDone,
      this.reminderDateTime,
      );

  factory Note.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Note(
      doc.id,
      data['title'] ?? '',
      data['subtitle'] ?? '',
      data['time'] ?? '',
      (data['image'] as num?)?.toInt() ?? 0,
      data['isDone'] ?? false, // <-- tên trường đúng
      data['reminderDateTime'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'time': time,
      'image': image,
      'isDone': isDone, // <-- tên trường đúng
      'reminderDateTime': reminderDateTime,
    };
  }
}
