import 'package:flutter/material.dart';
import 'package:Fast_Team/view/request/schedule/absent_page.dart';
import 'package:Fast_Team/view/request/schedule/leave_page.dart';
import 'package:Fast_Team/view/request/schedule/overtime_page.dart';

class ScheduleRequestPage extends StatefulWidget {
  const ScheduleRequestPage({Key? key}) : super(key: key);

  @override
  State<ScheduleRequestPage> createState() => _ScheduleRequestPageState();
}

class _ScheduleRequestPageState extends State<ScheduleRequestPage> {
  
  List<Map<String, dynamic>> listRequestTab = [
    {'title': 'Absent', 'icon': Icons.access_time},
    {'title': 'Leave', 'icon': Icons.camera_alt},
    {'title': 'Overtime', 'icon': Icons.note},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: const Text(
            'Request Form',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white30,
            indicatorColor: Colors.white,
            tabs: listRequestTab.map((option) {
                return Tab(
                  icon: Icon(option['icon']),
                  text: option['title'],
                );
              }).toList(),
          ),
        ),
        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            AbsentPage(),
            LeavePage(),
            OvertimePage(),
          ],
        ),
      ),
    );
  }
}