import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:todolist/const/colors.dart';
import 'package:todolist/screens/add_task_screen.dart';
import 'package:todolist/widgets/stream_note.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  bool showFab = true;

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Optionally navigate to login screen after logout
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
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
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.task, color: Colors.black87, size: 30),
                          const SizedBox(width: 10),
                          Flexible(
                            fit: FlexFit.tight,
                            child: const Text(
                              'My Tasks',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'logout') {
                          _handleLogout();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.logout),
                            title: Text('Logout'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // Section for 'To Do' tasks
                Row(
                  children: [
                    Icon(Icons.pending_actions, color: custom_green, size: 22),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'To Do',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Stream_note(false),
                ),
                const SizedBox(height: 30),
                // Section for 'Completed' tasks
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.grey.shade600, size: 22),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Stream_note(true),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: showFab ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 300),
        child: AnimatedOpacity(
          opacity: showFab ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton(
            backgroundColor: custom_green,
            elevation: 10,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Add_Screen()),
              );
              setState(() {});
            },
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ),
    );
  }
}
