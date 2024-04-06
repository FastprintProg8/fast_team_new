import 'package:Fast_Team/controller/absent_controller.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DaftarAbsensiPage(),
    );
  }
}

class DaftarAbsensiPage extends StatefulWidget {
  @override
  _DaftarAbsensiPageState createState() => _DaftarAbsensiPageState();
}

class _DaftarAbsensiPageState extends State<DaftarAbsensiPage> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _data = [];
  int userId = 0;
  int absenCount = 0;
  int lateClockInCount = 0;
  int earlyClockOutCount = 0;
  int noClockInCount = 0;
  int noClockOutCount = 0;

  AbsentController? absentController;

  @override
  void initState() {
    super.initState();
    _loadUserId().then((_) {
      _loadDataForSelectedMonth();
    });
  }

  Future refreshItem() async {
    await _loadDataForSelectedMonth();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user-id_user') ?? 0;
  }

  Future<void> _loadDataForSelectedMonth() async {
    absentController = Get.put(AbsentController());

    final data = await absentController!.retriveAbsentData(_selectedDate);
    final totalData = await absentController!.retriveTotalData(_selectedDate);
    setState(() {
      _data = data;
      absenCount = totalData['details']['absen'];
      lateClockInCount = totalData['details']['late_clock_in'];
      earlyClockOutCount = totalData['details']['early_clock_out'];
      noClockInCount = totalData['details']['no_clock_in'];
      noClockOutCount = totalData['details']['no_clock_out'];
    });
  }

  Future<void> _selectMonth(BuildContext context) async {
    showMonthPicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1, 1),
      lastDate: DateTime(DateTime.now().year + 1, 12),
    ).then((date) async {
      if (date != null) {
        setState(() {
          _selectedDate = date;
          print(date);
        });
        await _loadDataForSelectedMonth();
      }
    });
  }

  Widget _buildStatusItem(String title, String count, double fontSize) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          count,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMM().format(_selectedDate);
    int daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Attendence Log',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Custom back button action
              Navigator.pop(context, 'true');
            },
          )),
      body: Column(
        children: [
          SizedBox(height: 20.0),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.w),
            child: TextButton(
              onPressed: () {
                _selectMonth(context);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                backgroundColor: Colors.transparent,
                side: BorderSide(color: Colors.black, width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          size: 24,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          formattedDate,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5.w),
          cardAbsentInfo(context),
          SizedBox(height: 5.0),
          ListAbsent(daysInMonth),
        ],
      ),
    );
  }

  Widget ListAbsent(int daysInMonth) {
    return Expanded(
      child: RefreshWidget(
        onRefresh: refreshItem,
        child: ListView.separated(
          itemCount: daysInMonth,
          separatorBuilder: (BuildContext context, int index) =>
              SizedBox(height: 10), // Jarak antara setiap item
          itemBuilder: (BuildContext context, int index) {
            final Map<String, dynamic> item =
                _data.isNotEmpty ? _data[index] : {};
            String tanggal = (index + 1).toString();
            bool isSunday = item['isSunday'] ?? false;
            Color dateColor =
                item['dateColor'] ?? (isSunday ? Colors.red : Colors.black);
            String dateText = item['dateText'] ??
                (isSunday
                    ? '$tanggal ${DateFormat.MMM().format(_selectedDate)}\nHari Libur'
                    : '$tanggal ${DateFormat.MMM().format(_selectedDate)}');

            return AbsensiListItem(
              dateText: dateText,
              dateColor: dateColor,
              jamMasuk: item['jamMasuk'] ?? '--:--',
              jamKeluar: item['jamKeluar'] ?? '--:--',
              idMasuk: item['id_masuk'] ?? 0,
              idKeluar: item['id_keluar'] ?? 0,
              isSunday: isSunday,
            );
          },
        ),
      ),
    );
  }

  Widget cardAbsentInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF1976D2), Color(0xFF0D47A1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildStatusItem('Absen', '$absenCount', 14),
                  _buildStatusItem('Late Clock In', '$lateClockInCount', 14),
                  _buildStatusItem(
                      'Early Clock Out', '$earlyClockOutCount', 14),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildStatusItem('No Clock In', '$noClockInCount', 14),
                  _buildStatusItem('No Clock Out', '$noClockOutCount', 14),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AbsensiListItem extends StatefulWidget {
  final String dateText;
  final Color dateColor;
  final String jamMasuk;
  final String jamKeluar;
  final int idMasuk;
  final int idKeluar;
  final bool isSunday;

  AbsensiListItem({
    required this.dateText,
    required this.dateColor,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.idMasuk,
    required this.idKeluar,
    required this.isSunday,
  });

  @override
  _AbsensiListItemState createState() => _AbsensiListItemState();
}

class _AbsensiListItemState extends State<AbsensiListItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isSunday ? Colors.grey[200] : Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.dateText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.dateColor,
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          right: 10), // Jeda 10px di antara kedua teks
                      child: Text(
                        widget.jamMasuk,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      widget.jamKeluar,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.dateColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        isExpanded ? Icons.remove : Icons.add,
                        size: 16,
                        color: widget.dateColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: <Widget>[
                  Divider(), // Divider added here
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/detailAbsensi',
                          arguments: widget.idMasuk);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Jam Masuk:',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          widget.jamMasuk,
                          style: TextStyle(fontSize: 14),
                        ),
                        Icon(
                          Icons.arrow_right_rounded,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Divider(), // Divider added here
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/detailAbsensi',
                          arguments: widget.idKeluar);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Jam Keluar:',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          widget.jamKeluar,
                          style: TextStyle(fontSize: 14),
                        ),
                        Icon(
                          Icons.arrow_right_rounded,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
