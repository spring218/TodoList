import 'package:flutter/material.dart';
import 'package:todolist/const/colors.dart';
import 'package:todolist/data/firestore.dart';
import 'package:todolist/models/notes_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import để sử dụng Timestamp
import 'package:todolist/services/notification_service.dart'; // Import NotificationService
import 'package:todolist/services/permission_service.dart'; // Đường dẫn tùy vào project
import 'package:flutter/services.dart';

class Edit_Screen extends StatefulWidget {
  final Note _note;
  const Edit_Screen(this._note, {super.key});

  @override
  State<Edit_Screen> createState() => _Edit_ScreenState();
}

class _Edit_ScreenState extends State<Edit_Screen> {
  TextEditingController? title;
  TextEditingController? subtitle;

  FocusNode _focusNode1 = FocusNode();
  FocusNode _focusNode2 = FocusNode();

  int indexx = 0;
  DateTime? _selectedReminderDateTime; // Variable to store selected reminder date and time

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget._note.title);
    subtitle = TextEditingController(text: widget._note.subtitle);
    indexx = widget._note.image; // Initialize indexx from the current task image

    // Initialize _selectedReminderDateTime from existing data
    if (widget._note.reminderDateTime != null) {
      _selectedReminderDateTime = widget._note.reminderDateTime!.toDate();
    }

    _focusNode1.addListener(() {
      setState(() {});
    });
    _focusNode2.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    title!.dispose(); // Dispose controllers
    subtitle!.dispose(); // Dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      appBar: AppBar(
        title: const Text(
          "Edit Task",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: custom_green,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(title!, _focusNode1, "Title"),
                const SizedBox(height: 20),
                _buildTextField(subtitle!, _focusNode2, "Subtitle", maxLines: 3),
                const SizedBox(height: 30),
                _buildImageSelector(),
                const SizedBox(height: 30),
                _buildReminderPicker(), // Reminder picker widget
                const SizedBox(height: 30),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, FocusNode focusNode, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        itemCount: 6,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                indexx = index;
              });
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: indexx == index ? custom_green : Colors.grey,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'images/$index.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder Time:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: _selectedReminderDateTime ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: custom_green,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: custom_green,
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (pickedDate != null) {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_selectedReminderDateTime ?? DateTime.now()),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: custom_green,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: custom_green,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedTime != null) {
                setState(() {
                  _selectedReminderDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedReminderDateTime == null
                      ? 'Select reminder date and time'
                      : '${_selectedReminderDateTime!.day}/${_selectedReminderDateTime!.month}/${_selectedReminderDateTime!.year} ${_selectedReminderDateTime!.hour}:${_selectedReminderDateTime!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedReminderDateTime == null ? Colors.grey : Colors.black87,
                  ),
                ),
                Icon(Icons.access_time, color: custom_green),
              ],
            ),
          ),
        ),
        if (_selectedReminderDateTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedReminderDateTime = null;
                  });
                },
                child: Text(
                  'Remove reminder',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _customButton("Save", custom_green, () async {
          if (title!.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please enter the title."),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            // Cancel old notification if any
            if (widget._note.reminderDateTime != null) {
              await NotificationService().cancelNotification(
                widget._note.reminderDateTime!.hashCode,
              );
            }

            Timestamp? reminderTimestamp = _selectedReminderDateTime != null
                ? Timestamp.fromDate(_selectedReminderDateTime!)
                : null;

            bool success = await Firestore_Datasource().Update_Note(
              widget._note.id,
              indexx,
              title!.text,
              subtitle!.text,
              reminderTimestamp,
            );

            if (success) {
              if (_selectedReminderDateTime != null) {
                try {
                  await NotificationService().scheduleNotification(
                    id: reminderTimestamp.hashCode,
                    title: 'Task Reminder: ${title!.text}',
                    body: subtitle!.text.isNotEmpty
                        ? 'Content: ${subtitle!.text}'
                        : 'You have a task to do.',
                    scheduledDateTime: _selectedReminderDateTime!,
                    payload: title!.text,
                  );
                } on PlatformException catch (e) {
                  if (e.code == 'exact_alarms_not_permitted') {
                    await PermissionService.requestExactAlarmPermission();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please enable exact alarm permission in Android settings'),
                      ),
                    );
                  } else {
                    rethrow;
                  }
                }
              }
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Failed to update task. Please try again."),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }),
        _customButton("Cancel", Colors.red, () {
          Navigator.pop(context);
        }),
      ],
    );
  }

  Widget _customButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(150, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        foregroundColor: Colors.white,
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
