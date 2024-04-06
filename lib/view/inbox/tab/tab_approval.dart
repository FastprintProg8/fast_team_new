import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fast_Team/view/inbox/approval/approval_attendance_page.dart';
import 'package:Fast_Team/view/inbox/approval/approval_leave_page.dart';
import 'package:Fast_Team/view/inbox/approval/approval_overtime_page.dart';
import 'package:get/get.dart';

class TabApprovalPage extends StatefulWidget {
  const TabApprovalPage({super.key});

  @override
  State<TabApprovalPage> createState() => _TabApprovalPageState();
}

class _TabApprovalPageState extends State<TabApprovalPage> with AutomaticKeepAliveClientMixin {
  int userId = 0;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userId = sharedPreferences.getInt('user-id_user') ?? 0;
    });
  }

  showSnackBar(message) {
    snackbar() => SnackBar(
      content: Text(
        message,
        style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: Colors.white,
        ),
      ),
      backgroundColor: Colors.red,
      duration: const Duration(milliseconds: 2000),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar());
  } 

  void showCustomDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  ListTile menuItems(text, color, icon, VoidCallback onTapCallback) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        text,
        style: TextStyle(color: Colors.black),
      ),
      trailing: const Icon(
        Icons.keyboard_arrow_right,
        color: Colors.blue,
      ),
      tileColor: Colors.transparent,
      onTap: onTapCallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Column(
        children: <Widget>[
          menuItems(
            'Attendance', 
            Colors.blue, 
            Icons.access_time, 
            () { 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApprovalAttendancePage(),
                ),
              );
            }
          ),
          menuItems(
            'Leave', 
            Colors.green, 
            Icons.event_note, 
            () { 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApprovalLeavePage(),
                ),
              );
            }
          ),
          menuItems(
            'Overtime', 
            Colors.orange, 
            Icons.access_alarm, 
            () { 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ApprovalOvertimePage(),
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}