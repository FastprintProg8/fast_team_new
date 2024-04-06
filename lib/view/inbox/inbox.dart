import 'package:flutter/material.dart';
import 'package:Fast_Team/utils/bottom_navigation_bar.dart';

void main() {
  runApp(MaterialApp(
    home: InboxPage(),
  ));
}

class InboxPage extends StatefulWidget {
  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final List<Map<String, dynamic>> notifications = [
    {
      'dateTime': '2023-09-20 08:30 AM',
      'division': 'IT',
      'message': 'Selamat datang di perusahaan kami!',
      'read': true,
    },
    {
      'dateTime': '2023-09-20 08:30 AM',
      'division': 'HR',
      'message': 'Selamat datang di perusahaan kami!',
      'read': false,
    },
    {
      'dateTime': '2023-09-20 08:30 AM',
      'division': 'PURCHASE',
      'message': 'Selamat datang di perusahaan kami!',
      'read': true,
    },
    {
      'dateTime': '2023-09-20 08:30 AM',
      'division': 'HR',
      'message': 'Selamat datang di perusahaan kami!',
      'read': false,
    },
    {
      'dateTime': '2023-09-20 08:30 AM',
      'division': 'HR',
      'message': 'Selamat datang di perusahaan kami!',
      'read': false,
    },
  ];

  bool isAllRead = false;
  bool isSearchVisible = false;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredNotifications = [];

  @override
  void initState() {
    super.initState();
    filteredNotifications.addAll(notifications);
  }

  void markAllAsRead() {
    setState(() {
      for (final notification in filteredNotifications) {
        notification['read'] = true;
      }
      isAllRead = true;
    });
  }

  void filterNotifications(String query) {
    setState(() {
      filteredNotifications = notifications
          .where((notification) =>
              notification['division']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              notification['message']
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Inbox'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Notification'),
              Tab(text: 'Need Approval'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildTab1Content(),
            buildTab2Content(),
          ],
        ),
      ),
    );
  }

  Widget buildTab1Content() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    markAllAsRead();
                  },
                  child: Text(
                    'Mark All as Read',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              Spacer(),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: isSearchVisible ? 200 : 50,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          isSearchVisible = !isSearchVisible;
                          if (!isSearchVisible) {
                            searchController.clear();
                            filterNotifications('');
                          }
                        });
                      },
                    ),
                    if (isSearchVisible)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              filterNotifications(value);
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Divider(
          //   height: 1,
          //   color: Colors.black,
          // ),
          Divider(
            height: 1,
            color: Colors.black,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredNotifications.length,
            itemBuilder: (context, index) {
              final notification = filteredNotifications[index];
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 10, 106, 184),
                      child: Text(
                        notification['division'][0],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      notification['division'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(notification['message']),
                    trailing: Icon(Icons.arrow_forward),
                    tileColor: !notification['read']
                        ? Color.fromARGB(255, 46, 141, 185)
                        : null,
                  ),
                  Divider(
                    height: 0.5,
                    color: Colors.grey,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildTab2Content() {
    final itemData = [
      {
        'title': "Attendance",
        'icon': Icons.access_time,
        'color': Colors.blue,
        'parameter': 'pengajuan-absensi', // Tambahkan parameter yang sesuai
      },
      {
        'title': "Leave",
        'icon': Icons.event_note,
        'color': Colors.green,
        'parameter': 'izin', // Tambahkan parameter yang sesuai
      },
      {
        'title': "Overtime",
        'icon': Icons.access_alarm,
        'color': Colors.orange,
        'parameter': 'lembur', // Tambahkan parameter yang sesuai
      },
      // Add more items as needed
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          Divider(
            height: 1,
            color: Colors.black,
          ),
          Divider(
            height: 1,
            color: Colors.black,
          ),
          ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: itemData.map((item) => _buildListItem(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed('/approval', arguments: item['parameter']);
      },
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              item['icon'],
              color: item['color'],
            ),
            title: Text(
              item['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward,
              color: Colors.black,
            ),
          ),
          Divider(
            height: 0.5,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
