import 'package:Fast_Team/controller/absent_controller.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/widget/bottom_nav_bar.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DaftarAbsensiPage(),
    );
  }
}

class DaftarAbsensiPage extends StatefulWidget {
  const DaftarAbsensiPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DaftarAbsensiPageState createState() => _DaftarAbsensiPageState();
}

class _DaftarAbsensiPageState extends State<DaftarAbsensiPage> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _data = [];
  Future? _loadData;
  int userId = 0;
  int absenCount = 0;
  int lateClockInCount = 0;
  int earlyClockOutCount = 0;
  int noClockInCount = 0;
  int noClockOutCount = 0;

  AbsentController? absentController;

  TextStyle alertErrorTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: ColorsTheme.white,
  );

  @override
  void initState() {
    super.initState();
    // _loadUserId().then((_) {
    //   _loadDataForSelectedMonth();
    // });
    initData();
  }

  initData() async {
    setState(() {
      _loadData = _loadDataForSelectedMonth();
    });
  }

  Future refreshItem() async {
    setState(() {
      _loadData = _loadDataForSelectedMonth();
    });
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
        const SizedBox(height: 8.0),
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
      body: FutureBuilder(
          future: _loadData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                var snackbar = SnackBar(
                  content: Text('Error: ${snapshot.error}',
                      style: alertErrorTextStyle),
                  backgroundColor: ColorsTheme.lightRed,
                  behavior: SnackBarBehavior.floating,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              });
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              return _body(context, formattedDate, daysInMonth);
            } else {
              return _body(context, formattedDate, daysInMonth);
            }
          }),
      bottomNavigationBar: bottomNavBar(context: context),
    );
  }

  Widget _body(BuildContext context, String formattedDate, int daysInMonth) {
    return Column(
      children: [
        SizedBox(height: 20.w),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15.w),
          child: TextButton(
            onPressed: () {
              _selectMonth(context);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Colors.black, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.calendar_today,
                        size: 24,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 5.w),
        cardAbsentInfo(context),
        SizedBox(height: 5.w),
        ListAbsent(daysInMonth),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget ListAbsent(int daysInMonth) {
    return Expanded(
      child: RefreshWidget(
        onRefresh: refreshItem,
        child: ListView.separated(
          itemCount: daysInMonth,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 10), // Jarak antara setiap item
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
              jamMasuk: item['jamMasuk'] ?? [],
              // jamMasuk: '--:--',
              jamKeluar: item['jamKeluar'] ?? [],
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
            gradient: const LinearGradient(
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
              const SizedBox(height: 16.0),
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
  final List<dynamic> jamMasuk;
  final List<dynamic> jamKeluar;
  final int idMasuk;
  final int idKeluar;
  final bool isSunday;

  const AbsensiListItem({super.key, 
    required this.dateText,
    required this.dateColor,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.idMasuk,
    required this.idKeluar,
    required this.isSunday,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AbsensiListItemState createState() => _AbsensiListItemState();
}

class _AbsensiListItemState extends State<AbsensiListItem> {
  bool isExpanded = false;

  // get jamMasukItem => null;
  @override
  Widget build(BuildContext context) {
    dynamic lastJamKeluar =
        widget.jamKeluar.isNotEmpty ? widget.jamKeluar.last : null;
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
                          right: 10.w), // Jeda 10px di antara kedua teks
                      child: Text(
                        (widget.jamMasuk.isEmpty)
                            ? '--:--'
                            : widget.jamMasuk[0]['jam_absen'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      (widget.jamMasuk.isEmpty)
                          ? '--:--'
                          : lastJamKeluar['jam_absen'],
                      style: TextStyle(
                        fontSize: 16.sp,
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
                  const Divider(), // Divider added here
                  const SizedBox(height: 5),
                  ...widget.jamMasuk.map((jamMasukItem) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/detailAbsensi',
                                arguments: jamMasukItem['id_absen']);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Jam Masuk:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColorsTheme.lightGreen,
                                  fontWeight: FontWeight.w900
                                ),
                              ),
                              Text(
                                (jamMasukItem['jam_absen'] == null)
                                    ? '--:--'
                                    : jamMasukItem['jam_absen'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColorsTheme.lightGreen,
                                  fontWeight: FontWeight.w900
                                ),
                              ),
                              const Icon(
                                Icons.arrow_right_rounded,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5.w),
                        const Divider(), // Divider added here
                      ],
                    );
                  }),
                  SizedBox(height: 5.w),
                  ...widget.jamKeluar.map((jamKeluarItem) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/detailAbsensi',
                                arguments: jamKeluarItem['id_absen']);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Jam Keluar:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColorsTheme.lightYellow,
                                  fontWeight: FontWeight.w900
                                ),
                              ),
                              Text(
                                (jamKeluarItem['jam_absen'] == null)
                                    ? '--:--'
                                    : jamKeluarItem['jam_absen'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColorsTheme.lightYellow,
                                  fontWeight: FontWeight.w900
                                ),
                              ),
                              const Icon(
                                Icons.arrow_right_rounded,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5.w),
                        const Divider(), // Divider added here
                      ],
                    );
                  }),
                  SizedBox(height: 10.w),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
