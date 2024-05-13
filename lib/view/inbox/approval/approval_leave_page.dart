import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fast_Team/controller/inbox_controller.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class ApprovalLeavePage extends StatefulWidget {
  const ApprovalLeavePage({super.key});

  @override
  State<ApprovalLeavePage> createState() => _ApprovalLeavePageState();
}

class _ApprovalLeavePageState extends State<ApprovalLeavePage> {
  InboxController? inboxController;
  List<Map<String, dynamic>> leaveList = [];
  Future? _loadData;
  int? selectedFilter;
  TextStyle alertErrorTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: ColorsTheme.white,
  );
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

  Future<void> setFilter(value) async {
    setState(() {
      selectedFilter = value;
    });
    _loadData = fetchData();
  }

  Future refreshItem() async {
    leaveList.clear();
    setState(() {
      _loadData = fetchData();
    });
  }

  Future<void> fetchData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userId = sharedPreferences.getInt('user-id_user') ?? 0;
    var result = await inboxController!.retrieveLeaveList(userId);
    if (result['status'] == 200) {
      List<dynamic> data = result['details'];
      setState(() {
        if (selectedFilter == 4) {
          leaveList = List<Map<String, dynamic>>.from(data);
        } else {
          leaveList = List<Map<String, dynamic>>.from(data)
              .where((element) => element['status'] == selectedFilter)
              .toList();
        }
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Leave List',
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
          : (leaveList.isNotEmpty)
              ? ListView.builder(
                  itemCount: leaveList.length,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final leave = leaveList[index];
                    return _attendanceTile(leave);
                  })
              : _noLeave(),
    );
  }

  Widget _noLeave() {
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
            'There is no leave',
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
           const  Divider(),
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

  Widget _attendanceTile(leave) {
    // final date = leave['tanggal'].toString().split(' ')[0];
    // DateTime parsedDate = DateTime.parse(date);
    // final DateFormat formatter = DateFormat('dd MMM yyyy');
    // final String formattedDate = formatter.format(parsedDate);
    return Column(children: <Widget>[
      InkWell(
        onTap: () async {
          Navigator.pushNamed(context, '/leaveDetail', arguments: {
            'tanggal': leave['tanggal'].toString().split(' ')[0],
            'time': DateFormat.Hms()
                .parse(leave['tanggal'].toString().split(' ')[1]),
            'status': leave['status'],
            'bukti': leave['bukti'],
            'alasan': leave['alasan'],
            'nama': leave['user']['name'],
            'photo': leave['user']['photo'],
            'cuti': leave['cuti']['name'],
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
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
                          ]),
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              formatDateString(leave['tanggal']),
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Text(
                              formatTimeString(leave['tanggal']),
                              style: const TextStyle(
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 5.w),
                  Row(
                    children: [
                      SizedBox(
                        width: 35.w,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(color: Colors.blueAccent)),
                        child: Text(
                          "Request For ${leave['cuti']['name']}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 80.w,
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: getStatusColor(leave['status']),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  getStatusText(leave['status']),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: (leave['status'] == 0)
                          ? ColorsTheme.black
                          : ColorsTheme.white),
                ),
              ),
            ],
          ),
        ),
      ),
      Divider(
        height: 0.5,
        color: Colors.grey[200],
      )
    ]);
  }

  Widget _pillDecoration(message, Color color) {
    return Container(
      padding: EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
