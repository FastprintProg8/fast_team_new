// ignore_for_file: use_build_context_synchronously

import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:flutter/material.dart';
import 'package:Fast_Team/controller/employee_controller.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  EmployeeController? employeeController;
  final listViewController = ScrollController();

  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];
  final searchText = TextEditingController();

  int startList = 0;
  int endList = 10;
  bool moreData = true;

  Future? _fetchData;

  TextStyle alertErrorTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: ColorsTheme.white,
  );

  @override
  void initState() {
    super.initState();
    employeeController = Get.put(EmployeeController());

    listViewController.addListener(() {
      if (listViewController.position.pixels ==
          listViewController.position.maxScrollExtent) {
        if (moreData) {
          // print('test');
          _addItems();
        }
      }
    });

    initConstructor();
  }

  initConstructor() async {
    setState(() {
      _fetchData = fetchData();
    });
  }

  Future _refreshItem() async {
    setState(() {
      startList = 0;
      endList = 10;
      _fetchData = fetchData();
    });
  }

  Future _addItems() async {
    setState(() {
      startList = startList + 10;
      endList = endList + 10;
    });
    var result = await employeeController!.retrieveEmployeeList();

    if (result['status'] == 200) {
      List<dynamic> data = result['details']['data'];

      setState(() {
        employees = List<Map<String, dynamic>>.from(data);
        if (endList < employees.length) {
          filteredEmployees.addAll(employees.sublist(startList, endList));
        } else {
          if (moreData) {
            filteredEmployees
                .addAll(employees.sublist(startList, employees.length));
            moreData = false;
          }
        }
      });
      // print(employees.sublist(0, 10));
    }
  }

  Future<void> fetchData() async {
    var result = await employeeController!.retrieveEmployeeList();

    if (result['status'] == 200) {
      List<dynamic> data = result['details']['data'];

      setState(() {
        employees = List<Map<String, dynamic>>.from(data);
        filteredEmployees.addAll(employees.sublist(startList, endList));
      });
      // print(employees.sublist(0, 10));
    }
  }

  void filterEmployees(String query) {
    setState(() {
      filteredEmployees = employees.where((employee) {
        final employeeName = employee['nama'].toString().toLowerCase();
        final input = query.toLowerCase();
        return employeeName.contains(input);
      }).toList();
      moreData = true;
    });
      if(filteredEmployees.length <= 6){
        delayMoreData();
      }
  }
  Future<void> delayMoreData() async {
  await Future.delayed(const Duration(seconds: 3));
  setState(() {
    moreData = false;
  });
}

  _launchWhatsapp(phone) async {
    var whatsapp = phone;
    var whatsappAndroid =
        Uri.parse("https://api.whatsapp.com/send?phone=+62$whatsapp");
    if (!await launchUrl(whatsappAndroid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("WhatsApp is not installed on the device"),
        ),
      );
    }
  }

  _launchPhone(phone) async {
    var phoneNumber = phone;
    var phoneAndroid = Uri.parse("tel:+62$phoneNumber");
    if (!await launchUrl(phoneAndroid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phone can't open on the device"),
        ),
      );
    }
  }

  _launchMail(var email) async {
    var mailAndroid = Uri.parse("mailto:$email");
    if (!await launchUrl(mailAndroid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email is not installed on the device"),
        ),
      );
    }
  }

  @override
  void dispose() {
    listViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
      ),
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: RefreshWidget(
              onRefresh: _refreshItem,
              child: FutureBuilder(
                  future: _fetchData,
                  builder: (context, AsyncSnapshot snapshot) {
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
                      return _body();
                    } else {
                      return _body();
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return ListView.builder(
      controller: listViewController,
      itemCount: filteredEmployees.length + 1,
      itemBuilder: (context, index) {
        if (index < filteredEmployees.length) {
          final employee = filteredEmployees[index];
          return _employeeList(employee);
        } else {
          return Padding(
              padding: EdgeInsets.symmetric(vertical: 10.w),
              child: Center(
                child: (moreData)
                    ? const CircularProgressIndicator()
                    : const Text('No more data'),
              ));
        }
      },
    );
  }

  Widget _employeeList(Map<String, dynamic> employee) {
    return Column(
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
          leading: CircleAvatar(
            radius: 19.r,
            backgroundColor: ColorsTheme.lightGrey3,
            child: CircleAvatar(
              backgroundImage: NetworkImage(employee['image']),
            ),
          ),
          title: Text(
            employee['nama'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.phone, size: 24.sp, color: Colors.blue),
                onPressed: () {
                  _launchPhone(employee['wa'].toString().substring(1));
                },
              ),
              SizedBox(width: 10.w),
              IconButton(
                icon: Icon(Icons.email, size: 24.sp, color: Colors.blue),
                onPressed: () {
                  _launchMail(employee['email']);
                },
              ),
              SizedBox(width: 10.w),
              IconButton(
                icon: ImageIcon(
                  const AssetImage(
                    'assets/img/whatsapp.png',
                  ),
                  color: ColorsTheme.lightGreen,
                  size: 24,
                ),
                onPressed: () {
                  _launchWhatsapp(employee['wa'].toString().substring(1));
                },
              ),
            ],
          ),
        ),
        // Divider(
        //   thickness: 1,
        //   color: Colors.grey,
        // ),
      ],
    );
  }

  Padding _searchBar() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        controller: searchText,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(Icons.search),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(100.0)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              filterEmployees('');
              searchText.clear();
            },
          ),
        ),
        onChanged: (value) {
          filterEmployees(value);
        },
      ),
    );
  }
}
