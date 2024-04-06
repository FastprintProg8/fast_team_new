import 'package:Fast_Team/controller/inbox_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';

void main() {
  // Load time zone data
  tzdata.initializeTimeZones();

  // Set the default time zone to Asia/Jakarta
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  runApp(MaterialApp(
    home: NotificationDetailPage(notificationId: 0),
  ));
}

class NotificationDetailPage extends StatefulWidget {
  final int notificationId; // Add this line

  // Add a constructor that accepts the notificationData
  NotificationDetailPage({required this.notificationId});

  @override
  _NotificationDetailPageState createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  int get notificationId => widget.notificationId;
  InboxController? inboxController;
  String title = '';
  String imageProf = '';
  String name = '';
  String message = '';
  String dateSend = '';

  @override
  void initState() {
    super.initState();
    inboxController = Get.put(InboxController());
    fetchData();
  }

  Future fetchData() async {
    var result =
        await inboxController!.retrieveNotificationDetail(notificationId);
    if (result['status'] == 200) {
      Map data = result['details'];
      setState(() {
        title = data['title'];
        imageProf = data['sender']['photo'];
        name = data['sender']['name'];
        message = data['message'];
        dateSend = dateFormat(data['date_send']);
      });
    }
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
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Detail Inbox',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.blue[900],
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              // Custom back button action
              Navigator.pop(context, 'true');
            },
          )),
      body:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        Padding(padding: EdgeInsets.all(8.0)),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageProf),
              )),
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dateSend,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ]),
        ]),
        Padding(padding: EdgeInsets.all(8.0)),
        // Divider(
        //   height: 0.5,
        //   color: Colors.grey,
        // ),
        Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              message,
              style: TextStyle(fontSize: 18),
            )),
      ]),
    );
  }
}
