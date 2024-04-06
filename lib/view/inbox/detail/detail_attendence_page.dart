import 'package:Fast_Team/style/color_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AttendanceDetailPage extends StatefulWidget {
  const AttendanceDetailPage({super.key});

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  String? tanggal;
  int? status;
  String? bukti;
  String? jenis;
  String? nama;
  String? photo;
  String? time;
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

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? routeArguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (routeArguments != null) {
      tanggal = routeArguments['tanggal'];
      status = routeArguments['status'];
      bukti = routeArguments['bukti'];
      jenis = routeArguments['jenis'];
      nama = routeArguments['nama'];
      time = DateFormat('HH:mm').format(routeArguments['time']);
      photo = routeArguments['photo'];
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Detail Attendence',
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
                          "Your attendance on ${tanggal} at ${time}, type '${jenis!.toUpperCase()}', has ${getStatusText(status!)} status.",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Detail Attendance :\nDate : ${tanggal} \nTime : ${time} \nType : ${jenis!.toUpperCase()} \nStatus : ${getStatusText(status!)} ",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Link : ',
                            style: TextStyle(color: ColorsTheme.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: bukti!,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    color: ColorsTheme.lightDark),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    final Uri url = Uri.parse(bukti!);
                                    await launchUrl(url);
                                  },
                              ),
                            ],
                          ),
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
