import 'package:Fast_Team/style/color_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class LeaveDetailPage extends StatefulWidget {
  const LeaveDetailPage({super.key});

  @override
  State<LeaveDetailPage> createState() => _LeaveDetailPageState();
}

class _LeaveDetailPageState extends State<LeaveDetailPage> {
  String? tanggal;
  int? status;
  String? bukti;
  String? alasan;
  String? nama;
  String? photo;
  String? time;
  String? cuti;
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

  void showImage(BuildContext context, String image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Evidence Picture'),
          content: Image.network(
            'http://103.29.214.154:9002/static/bukti/$image',
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              height: 150.0,
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.photo,
                    size: 100.0,
                  ),
                  Text('Image Not Found'),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
      bukti = routeArguments['bukti'];
      alasan = routeArguments['alasan'];
      nama = routeArguments['nama'];
      time = DateFormat('HH:mm').format(routeArguments['time']);
      photo = routeArguments['photo'];
      cuti = routeArguments['cuti'];
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Detail Leave',
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
                      CircleAvatar(
                        radius: 30.r,
                        backgroundImage: NetworkImage(
                            "http://103.29.214.154:9002/assets/imgUserProfile/${photo!}"),
                      ),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your approval for $cuti on $tanggal at $time, with reason $alasan, has ${getStatusText(status!)} status.",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Detail Leave :\nDate : $tanggal \nTime : $time \nStatus : ${getStatusText(status!)} \nReason : $alasan ",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Evidance : ',
                            style: TextStyle(color: ColorsTheme.black),
                            children: <TextSpan>[
                              (bukti!.isNotEmpty)
                                  ? TextSpan(
                                      text: 'Tap for show picture',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          color: ColorsTheme.lightDark),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          showImage(context, bukti!);
                                        },
                                    )
                                  : TextSpan(
                                      text: 'Not have evidence',
                                      style:
                                          TextStyle(color: ColorsTheme.black),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
