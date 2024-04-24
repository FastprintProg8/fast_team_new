import 'package:flutter/material.dart';
import 'package:Fast_Team/view/inbox/tab/tab_approval.dart';
import 'package:Fast_Team/view/inbox/tab/tab_notification.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({Key? key}) : super(key: key);

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Inbox'),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            labelColor: Colors.blue[900],
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.blue[900],
            tabs: [
              Tab(text: 'Notification'),
              Tab(text: 'Approval'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TabNotificationPage(),
            TabApprovalPage(),
          ],
        ),
      ),
    );
  }
}