import 'package:Fast_Team/controller/inbox_controller.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fast_Team/view/inbox/tab/notification_detail.dart';
import 'package:get/get.dart';

void main() {
  // Load time zone data
  tzdata.initializeTimeZones();

  // Set the default time zone to Asia/Jakarta
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  runApp(const MaterialApp(
    home: TabNotificationPage(),
  ));
}

class TabNotificationPage extends StatefulWidget {
  const TabNotificationPage({super.key});

  @override
  State<TabNotificationPage> createState() => _TabNotificationPageState();
}

class _TabNotificationPageState extends State<TabNotificationPage>
    with AutomaticKeepAliveClientMixin {
  int userId = 0;
  Future? _loadData;
  InboxController? inboxController;
  List<Map<String, dynamic>> notificationList = [];
  List<Map<String, dynamic>> filteredNotifications = [];
  TextStyle alertErrorTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: ColorsTheme.white,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    inboxController = Get.put(InboxController());
    initData();
  }

  initData() async {
    setState(() {
      _loadData = fetchData();
    });
  }

  Future refreshItem() async {
    setState(() {
      _loadData = fetchData();
    });
  }

  Future fetchData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userId = sharedPreferences.getInt('user-id_user') ?? 0;
    });
    var result = await inboxController!.retrieveNotificationList(userId);
    if (result['status'] == 200) {
      List<dynamic> data = result['details'];
      setState(() {
        notificationList = List<Map<String, dynamic>>.from(data);
        filteredNotifications.clear();
        filteredNotifications.addAll(notificationList);
      });
    }
  }

  Future markAllAsRead() async {
    var result =
        await inboxController!.requestReadAllNotification(userId.toString());
    if (result['status'] == 200) {
      await fetchData();
      showSnackBar('All notification is read', Colors.green);
    } else {
      showSnackBar('Failed to perform mark all as read', Colors.red);
    }
  }

  showSnackBar(message, Color color) {
    snackbar() => SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: color,
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

  String dateFormat(String date) {
    String dateString = date;
    DateTime dateData =
        DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSZ").parseUtc(dateString);
    tz.TZDateTime jakartaTime =
        tz.TZDateTime.from(dateData, tz.getLocation('Asia/Jakarta'));
    String formattedDate = DateFormat('d MMM y HH:mm').format(jakartaTime);

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FutureBuilder(
          future: _loadData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _body(false);
            } else if (snapshot.hasError) {
              SchedulerBinding.instance!.addPostFrameCallback((_) {
                var snackbar = SnackBar(
                  content: Text('Error: ${snapshot.error}',
                      style: alertErrorTextStyle),
                  backgroundColor: ColorsTheme.lightRed,
                  behavior: SnackBarBehavior.floating,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              });
              return _body(false);
            } else if (snapshot.hasData) {
              return _body(true);
            } else {
              return _body(true);
            }
          }),
    );
  }

  Widget _body(isLoading) {
    return RefreshWidget(
      onRefresh: refreshItem,
      child: (!isLoading)
          ? Center(child: CircularProgressIndicator())
          : (notificationList.isNotEmpty)
              ? ListView(
                  children: [_notificationList()],
                )
              : _noNotifications(),
    );
  }

  SingleChildScrollView _notificationList() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(bottom: 8.0)),
            GestureDetector(
              onTap: () {
                markAllAsRead();
              },
              child: Text(
                'Mark All as Read',
                style: TextStyle(
                  color: Colors.blue[900],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            Divider(
              height: 0.5,
              color: Colors.blue[900],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                String dateSend = dateFormat(notification['date_send']);
                return Column(
                  children: [
                    ListTile(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationDetailPage(
                                notificationId: notification['id']),
                          ),
                        );
                        await fetchData();
                      },
                      leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(notification['sender']['photo'])
                          // backgroundColor: const Color.fromARGB(255, 10, 106, 184),
                          // child: Text(
                          //   notification['sender']['divisi'],
                          //   style: TextStyle(color: Colors.white),
                          // ),
                          ),
                      title: Text(
                        notification['sender']['divisi'] +
                            " - " +
                            notification['sender']['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              notification['message'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 14.0),
                            ),
                            Text(
                              dateSend,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 14.0),
                            )
                          ]),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Colors.blue[900],
                      ),
                      tileColor:
                          !notification['is_read'] ? Colors.blue[100] : null,
                    ),
                    Divider(
                      height: 0.5,
                      color: Colors.blue[900],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Center _noNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 200, // Adjust width as needed
            height: 200, // Adjust height as needed
            decoration: BoxDecoration(
              color: Colors.blue[100], // Adjust color as needed
              borderRadius: BorderRadius.circular(
                  100), // Half the height for an oval shape
            ),
            child: const Center(
              child: Icon(
                Icons.update,
                size: 100.0,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(
            height: 16.0,
          ),
          const Text(
            'There is no notification',
            style: TextStyle(
              fontSize: 18,
            ),
          )
        ],
      ),
    );
  }
}
