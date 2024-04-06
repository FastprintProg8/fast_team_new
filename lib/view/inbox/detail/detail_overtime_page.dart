import 'package:Fast_Team/style/color_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OvertimeDetailPage extends StatefulWidget {
  const OvertimeDetailPage({super.key});

  @override
  State<OvertimeDetailPage> createState() => _OvertimeDetailPageState();
}

class _OvertimeDetailPageState extends State<OvertimeDetailPage> {
  String? tanggal;
  int? status;
  String? nama;
  String? photo;
  String? start_time;
  String? end_time;
  String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approved';
      case 2:
        return 'Rejected';
      default:
        return 'Tidak Diketahui';
    }
  }

  String formatDateString(String dateString) {
    // Parse the original date string
    DateTime originalDate = DateTime.parse(dateString);

    // Define the date format
    DateFormat formatter = DateFormat('dd MMMM yyyy');

    // Format the date to the desired format
    String formattedDate = formatter.format(originalDate);

    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? routeArguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (routeArguments != null) {
      tanggal = formatDateString(routeArguments['tanggal']);
      status = routeArguments['status'];
      nama = routeArguments['nama'];
      start_time = DateFormat('HH:mm')
          .format(DateFormat.Hms().parse(routeArguments['start_time']));
      end_time = DateFormat('HH:mm')
          .format(DateFormat.Hms().parse(routeArguments['end_time']));
      photo = routeArguments['photo'];
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Detail Overtime',
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
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20.w),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          child: CircleAvatar(
                        radius: 30.r,
                        backgroundImage: NetworkImage(
                            "http://103.29.214.154:9002/assets/imgUserProfile/${photo!}"),
                      )),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              nama!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              tanggal!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ]),
                    ]),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your approval for overtime work on ${tanggal}, with start in ${start_time} and end in ${end_time} , has ${getStatusText(status!)} status.",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Detail Overtime :\nDate : ${tanggal} \nStart time : ${start_time} \nEnd time : ${end_time} \nStatus : ${getStatusText(status!)} ",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
