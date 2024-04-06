import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  @override
  void initState() {
    super.initState();
  }

  Future refreshItem() async {
    setState(() {});
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
          'Perubahan Data',
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
        padding: EdgeInsets.only(bottom:10.h),
        child: ElevatedButton(
          onPressed: () {
          },
          child: Text('Ajukan Perubahan Data',style: TextStyle(color: ColorsTheme.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor:ColorsTheme.primary,
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
          MonthPicker(formattedDate),
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
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
    );
  }
}
