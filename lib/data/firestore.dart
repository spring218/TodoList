import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Giữ lại cho AsyncSnapshot
import 'package:todolist/models/notes_model.dart';
import 'package:uuid/uuid.dart';

class Firestore_Datasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hàm tạo người dùng
  Future<bool> CreateUser(String email) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "id": _auth.currentUser!.uid,
        "email": email,
      });
      return true;
    } catch (e) {
      print("Error creating user: $e");
      return false;
    }
  }

  // Hàm thêm ghi chú
  Future<bool> AddNote(
      String subtitle,
      String title,
      int image,
      Timestamp? reminderDateTime,
      ) async {
    try {
      var uuid = Uuid().v4();
      DateTime data = DateTime.now();
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .set({
        'id': uuid,
        'subtitle': subtitle,
        'isDone': false,
        'image': image,
        'time': '${data.hour}:${data.minute}',
        'title': title,
        'reminderDateTime': reminderDateTime,
      });
      return true;
    } catch (e) {
      print("Error adding note: $e");
      return false;
    }
  }

  // Hàm lấy danh sách ghi chú
  List<Note> getNotes(AsyncSnapshot snapshot) {
    try {
      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
        final notesList = snapshot.data!.docs.map<Note>((doc) {
          return Note.fromFirestore(doc); // Ép kiểu <Note>
        }).toList();
        return notesList;
      }
      return [];
    } catch (e) {
      print("Error getting notes: $e");
      return [];
    }
  }

  // Stream lấy ghi chú theo trạng thái isDone
  Stream<QuerySnapshot> stream(bool isDone) {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('notes')
        .where('isDone', isEqualTo: isDone) // ĐÃ SỬA isDon -> isDone
        .snapshots();
  }

  // Cập nhật trạng thái isDone
  Future<bool> isdone(String uuid, bool isDone) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .update({'isDone': isDone}); // ĐÃ SỬA isDon -> isDone
      return true;
    } catch (e) {
      print("Error updating isDone status: $e");
      return false;
    }
  }

  // Cập nhật ghi chú
  Future<bool> Update_Note(
      String uuid,
      int image,
      String title,
      String subtitle,
      Timestamp? reminderDateTime,
      ) async {
    try {
      DateTime data = DateTime.now();
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .update({
        'time': '${data.hour}:${data.minute}',
        'subtitle': subtitle,
        'title': title,
        'image': image,
        'reminderDateTime': reminderDateTime,
      });
      return true;
    } catch (e) {
      print("Error updating note: $e");
      return false;
    }
  }

  // Xóa ghi chú
  Future<bool> delet_note(String uuid) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('notes')
          .doc(uuid)
          .delete();
      return true;
    } catch (e) {
      print("Error deleting note: $e");
      return false;
    }
  }
}
