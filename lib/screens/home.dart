import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:todolist/const/colors.dart';
import 'package:todolist/screens/add_task_screen.dart';
import 'package:todolist/widgets/stream_note.dart';
import 'package:todolist/screens/login.dart';
class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  bool showFab = true;

  Future<void> _handleLogout() async {
    print('sign out');
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LogIN_Screen(() {
          // Callback, để trống nếu không xử lý gì
        }),
      ),
    );
  }


  void _handleSettings() {
    // TODO: chuyển tới màn hình cài đặt nếu có
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Chuyển đến Cài đặt")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F5F9), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.forward) {
                setState(() => showFab = true);
              } else if (notification.direction == ScrollDirection.reverse) {
                setState(() => showFab = false);
              }
              return true;
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.task, color: Colors.black87, size: 30),
                        SizedBox(width: 10),
                        Text(
                          'My Tasks',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    // Menu actions
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'settings') {
                          _handleSettings();
                        } else if (value == 'logout') {
                          _handleLogout();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'settings',
                          child: ListTile(
                            leading: Icon(Icons.settings),
                            title: Text('Cài đặt'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout),
                            title: Text('Đăng xuất'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Icon(Icons.pending_actions, color: custom_green, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'To Do',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stream_note(false),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.grey.shade600, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stream_note(true),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
      // FAB
      floatingActionButton: AnimatedSlide(
        offset: showFab ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 300),
        child: AnimatedOpacity(
          opacity: showFab ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton(
            backgroundColor: custom_green,
            elevation: 10,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Add_Screen()),
              );
            },
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ),
    );
  }
}
