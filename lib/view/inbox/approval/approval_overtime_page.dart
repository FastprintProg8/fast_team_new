import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fast_Team/controller/inbox_controller.dart';
import 'package:get/get.dart';

class ApprovalOvertimePage extends StatefulWidget {
  const ApprovalOvertimePage({Key? key}) : super(key: key);

  @override
  State<ApprovalOvertimePage> createState() => _ApprovalOvertimePageState();
}

class _ApprovalOvertimePageState extends State<ApprovalOvertimePage> {
  InboxController? inboxController;
  List<Map<String, dynamic>> overtimeList = [];
  Future? _loadData;
  TextStyle alertErrorTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: ColorsTheme.white,
  );

  int? selectedFilter;

  @override
  void initState() {
    super.initState();

    inboxController = Get.put(InboxController());
    initData();
  }

  initData() async {
    setState(() {
      _loadData = fetchData();
      selectedFilter = 4;
    });
  }

  Future refreshItem() async {
    setState(() {
      _loadData = fetchData();
    });
  }

  Future<void> setFilter(value) async {
    setState(() {
      selectedFilter = value;
    });
    _loadData = fetchData();
  }

  Future fetchData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userId = sharedPreferences.getInt('user-id_user') ?? 0;
    var result = await inboxController!.retrieveOvertimeList(userId);
    if (result['status'] == 200) {
      List<dynamic> data = result['details'];
      setState(() {
        if (selectedFilter == 4) {
          overtimeList = List<Map<String, dynamic>>.from(data);
        } else {
          overtimeList = List<Map<String, dynamic>>.from(data)
              .where((element) => element['status'] == selectedFilter)
              .toList();
        }
      });
      // print(overtimeList);
    }
  }

  showSnackBar(message) {
    snackbar() => SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 2000),
        );
    ScaffoldMessenger.of(context).showSnackBar(snackbar());
  }

  String formatDateString(String dateString) {
    // Parse the original date string
    DateTime originalDate = DateTime.parse(dateString);

    // Define the date format
    DateFormat formatter = DateFormat('EEEE, dd MMMM yyyy');

    // Format the date to the desired format
    String formattedDate = formatter.format(originalDate);

    return formattedDate;
  }

  String formatTimeString(String timeString) {
    // Parse the original date string
    DateTime originalTime = DateTime.parse(timeString);

    // Define the date format
    DateFormat formatter = DateFormat('HH:mm');

    // Format the date to the desired format
    String formattedTime = formatter.format(originalTime);

    return formattedTime;
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.yellow;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

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
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Overtime List',
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
          ),
          actions: [
            IconButton(
              icon: Icon(MdiIcons.filter),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildFilter(),
                );
              },
            ),
          ]),
      body: FutureBuilder(
          future: _loadData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _body(false);
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
          ? const Center(child: CircularProgressIndicator())
          : (overtimeList.isNotEmpty)?ListView.builder(
              itemCount: overtimeList.length,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                final overtime = overtimeList[index];
                return _attendanceTile(overtime);
              },
            ):_noOvertime(),
    );
  }

  Widget _noOvertime() {
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
            'There is no overtime',
            style: TextStyle(
              fontSize: 18,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 10.w, bottom: 20.w),
          child: Center(
            child: Text(
              "Filter",
              style: TextStyle(
                color: ColorsTheme.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            "Status",
            style: TextStyle(
              color: ColorsTheme.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 20.w),
        Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              child: ListTile(
                onTap: () {
                  setState(() {
                    setFilter(4);
                  });
                  Navigator.pop(context);
                },
                title: Text(
                  "All Status",
                  style: TextStyle(
                    color: ColorsTheme.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: Radio(
                  value: 4,
                  groupValue: selectedFilter,
                  activeColor: const Color(0xFF6200EE),
                  onChanged: (value) {
                    setState(() {
                      setFilter(value);
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
           const Divider(),
          ],
        ),
        Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              child: ListTile(
                onTap: () {
                  setState(() {
                    setFilter(0);
                  });
                  Navigator.pop(context);
                },
                title: Text(
                  "Pending",
                  style: TextStyle(
                    color: ColorsTheme.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: Radio(
                  value: 0,
                  groupValue: selectedFilter,
                  activeColor: const Color(0xFF6200EE),
                  onChanged: (value) {
                    setState(() {
                      setFilter(value);
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const Divider(),
          ],
        ),
        Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              child: ListTile(
                onTap: () {
                  setState(() {
                    setFilter(1);
                  });
                  Navigator.pop(context);
                },
                title: Text(
                  "Approved",
                  style: TextStyle(
                    color: ColorsTheme.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: Radio(
                  value: 1,
                  groupValue: selectedFilter,
                  activeColor: const Color(0xFF6200EE),
                  onChanged: (value) {
                    setState(() {
                      setFilter(value);
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const Divider(),
          ],
        ),
        Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              child: ListTile(
                onTap: () {
                  setState(() {
                    setFilter(2);
                  });
                  Navigator.pop(context);
                },
                title: Text(
                  "Rejected",
                  style: TextStyle(
                    color: ColorsTheme.black,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: Radio(
                  value: 2,
                  groupValue: selectedFilter,
                  activeColor: const Color(0xFF6200EE),
                  onChanged: (value) {
                    setState(() {
                      setFilter(value);
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const Divider(),
          ],
        ),
      ],
    );
  }

  Widget _attendanceTile(overtime) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/overtimeDetail', arguments: {
          'tanggal': overtime['tanggal'],
          'start_time': overtime['jam_mulai'],
          'end_time': overtime['jam_selesai'],
          'status': overtime['status'],
          'nama': overtime['user']['name'],
          'photo': overtime['user']['photo'],
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 9.w),
        child: Column(
          children: [
            SizedBox(
              height: 10.w,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    MdiIcons.calendarMonth,
                                    size: 25.sp,
                                  ),
                                  SizedBox(
                                    height: 5.w,
                                  ),
                                  Icon(
                                    MdiIcons.clockOutline,
                                    size: 25.sp,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    formatDateString(overtime['tanggal']),
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text("Start ${overtime['jam_mulai']}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 40.w,
                            ),
                            Text("End   ${overtime['jam_selesai']}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                )),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                Container(
                  width: 80.w,
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: getStatusColor(overtime['status']),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    getStatusText(overtime['status']),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: (overtime['status'] == 0)
                            ? ColorsTheme.black
                            : ColorsTheme.white),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.w,
            ),
            Divider(
              height: 0.5,
              color: Colors.grey[200],
            )
          ],
        ),
      ),
    );
  }
}
