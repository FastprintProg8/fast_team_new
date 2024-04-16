import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/view/account/request_submission_page.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class SubmissionPage extends StatefulWidget {
  const SubmissionPage({super.key});

  @override
  State<SubmissionPage> createState() => _SubmissionPageState();
}

class _SubmissionPageState extends State<SubmissionPage> {
  TextStyle alertErrorTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: ColorsTheme.white,
  );
  Future? _loadData;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> listData = [];
  List<Map<String, dynamic>> listStatus = [
    {'name': 'All Status', 'value': 0},
    {'name': 'Pending', 'value': 1},
    {'name': 'Approved', 'value': 2},
    {'name': 'Rejected', 'value': 3},
    {'name': 'Canceled', 'value': 4},
  ];
  int? selectedFilter;
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    setState(() {
      selectedFilter = 0;
    });
  }

  Future refreshItem() async {
    setState(() {});
  }

  Future<void> setFilter(value) async {
    setState(() {
      selectedFilter = value;
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
        // await _loadDataForSelectedMonth();
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Data',
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
      ),
      body: RefreshWidget(onRefresh: refreshItem, child: body()),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RequestSubmissionPage()),
            );
          },
          child: Text(
            'Request Change Data',
            style: TextStyle(color: ColorsTheme.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsTheme.primary,
            padding: EdgeInsets.symmetric(horizontal: 70.h),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget body() {
    String formattedDate = DateFormat.yMMMM().format(_selectedDate);
    return FutureBuilder(
      future: _loadData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return contentBody(false, formattedDate);
        } else if (snapshot.hasError) {
          SchedulerBinding.instance!.addPostFrameCallback((_) {
            var snackbar = SnackBar(
              content:
                  Text('Error: ${snapshot.error}', style: alertErrorTextStyle),
              backgroundColor: ColorsTheme.lightRed,
              behavior: SnackBarBehavior.floating,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          });
          return contentBody(false, formattedDate);
        } else if (snapshot.hasData) {
          return contentBody(true, formattedDate);
        } else {
          return contentBody(true, formattedDate);
        }
      },
    );
  }

  Widget contentBody(isLoading, formattedDate) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              MonthPicker(formattedDate),
              IconButton(
                icon: Icon(MdiIcons.filter),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => _buildFilter(),
                  );
                },
              ),
            ],
          ),
          (!isLoading)
              ? Center(child: CircularProgressIndicator())
              : (listData.isNotEmpty)
                  ? SingleChildScrollView()
                  : _noData(),
        ],
      ),
    );
  }

  Widget _noData() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 100.h),
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
            'There is no data',
            style: TextStyle(
              fontSize: 18,
            ),
          )
        ],
      ),
    );
  }

  Widget MonthPicker(formattedDate) {
    return Container(
      margin: EdgeInsets.only(left: 15.w),
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
                  SizedBox(width: 8.w),
                  Text(
                    formattedDate,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
            SizedBox(width: 150.w),
            Icon(
              Icons.arrow_drop_down,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter() {
    return Container(
      child: Column(
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
          SizedBox(
            height: 10.w,
          ),
          ...listStatus.map((status) {
            return Column(
              children: [
                Container(
                  // margin: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.5), width: 1.0),
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        setFilter(status['value']);
                      });
                      Navigator.pop(context);
                    },
                    title: Text(
                      status['name'],
                      style: TextStyle(
                        color: ColorsTheme.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: Radio(
                      value: status['value'],
                      groupValue: selectedFilter,
                      activeColor: Color(0xFF6200EE),
                      onChanged: (value) {
                        setState(() {
                          setFilter(value);
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
