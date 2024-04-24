import 'dart:io';

import 'package:Fast_Team/controller/account_controller.dart';
import 'package:Fast_Team/controller/payroll_controller.dart';
import 'package:Fast_Team/model/account_information_model.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class PayslipPage extends StatefulWidget {
  const PayslipPage({super.key});

  @override
  State<PayslipPage> createState() => _PayslipPageState();
}

class _PayslipPageState extends State<PayslipPage> {
  double? progressDownload;
  var nama;
  var posisi;
  var divisi;
  var id_account;
  var id_payroll;
  var imgUrl;
  var basic_salary = 0;
  var net_salary = 0;
  var deduction = 0;
  var allowance = 0;
  var detail_payroll = [];
  Future? _fetchData;
  bool isOpen = false;
  DateTime _selectedDate = DateTime.now();
  bool showSalary = false;

  TextStyle alertErrorTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: ColorsTheme.white,
  );

  @override
  void initState() {
    super.initState();
    initConstructor();
  }

  Future refreshItem() async {
    setState(() {
      _fetchData = initData();
      showSalary = false;
    });
  }

  initConstructor() async {
    nama = "".obs;
    posisi = "".obs;
    imgUrl = "".obs;
    id_payroll = "".obs;

    setState(() {
      _fetchData = initData();
    });
  }

  Future<void> initData() async {
    AccountController accountController = Get.put(AccountController());
    String formattedDate = formatDate(_selectedDate);
    var result = await accountController.retriveAccountInformation();
    AccountInformationModel accountModel =
        AccountInformationModel.fromJson(result['details']['data']);
    PayrollController payrollController = Get.put(PayrollController());
    var salaryResult = await payrollController.retrivePayroll(formattedDate);
    var salaryDetail = await payrollController
        .retriveDetailPayroll(salaryResult['details']['id']);
    // print(salaryResult);
    setState(() {
      id_account = accountModel.id;
      nama = accountModel.fullName;
      posisi = accountModel.posisiPekerjaan;
      divisi = accountModel.divisi;
      imgUrl = accountModel.imgProfUrl;
      id_payroll = salaryResult['details']['id'];
      basic_salary = salaryResult['details']['basic_salary'];
      net_salary = salaryResult['details']['take_home_pay'];
      detail_payroll = salaryDetail['details'];
      deduction = calculateTotalDeductionAmount(detail_payroll, 'deduction');
      allowance = calculateTotalDeductionAmount(detail_payroll, 'allowance');
    });
    // print(salaryResult);
  }

  int calculateTotalDeductionAmount(List<dynamic> data, type) {
    int totalAmount = 0;
    for (var item in data) {
      if (item['type'] == type) {
        totalAmount += (item['amount'] as num).toInt();
      }
    }
    return totalAmount;
  }

  String formatDate(DateTime date) {
    DateFormat formatter = DateFormat('yyyy-MM');
    String formattedDate = formatter.format(date);
    return formattedDate;
  }

  String formatCurrency(int amount) {
    final formatter = NumberFormat("#,##0", "en_US");
    return formatter.format(amount).replaceAll(',', '.');
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
           _fetchData = initData();
        });
        // await _loadDataForSelectedMonth();
      }
    });
  }

  Future<void> download() async {
    PayrollController payrollController = Get.put(PayrollController());
    var result = await payrollController.retriveLinkDownloadPayslip(id_payroll);
    Map<String, dynamic> jsonData = result['details'];
    var url = Uri.parse(jsonData['message']);
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Download Failed"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMM().format(_selectedDate);

    Widget _body() {
      return FutureBuilder(
          future: _fetchData,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return  _bodyContent(context, formattedDate,true);
            } else if (snapshot.hasData) {
              return _bodyContent(context, formattedDate,false);
            } else {
              return _bodyContent(context, formattedDate,false);
            }
          });
    }

    return Scaffold(
        appBar: AppBar(
            title: const Text(
              'My Payslip',
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
        body: RefreshWidget(
          onRefresh: refreshItem,
          child: _body(),
        ));
  }

  Widget _bodyContent(BuildContext context, String formattedDate,bool isEmpty) {
    return Container(
      child: Column(
        children: [
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
          _cardInfo(context),
          SizedBox(height: 20.h),
          (!isEmpty)?
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              child: ListView(
                children: [
                  _salarySlipCard(context),
                  SizedBox(
                    height: 10.w,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        download().then((_) {
                          print('Payslip is downloaded !');
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        splashFactory: InkSplash.splashFactory,
                        minimumSize: const Size(double.infinity, 48.0),
                      ),
                      child: Text(
                        'Download Salary Slip',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
            ),
          ): _noNotifications()
        ],
      ),
    );
  }
  Widget _noNotifications() {
    return Expanded(
      child: ListView(
          children: <Widget>[
            Center(
              child: Container(
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
            ),
            const SizedBox(
              height: 16.0,
            ),
            Center(
              child: const Text(
                'There is no data',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          ],
        ),
      
    );
  }
  Widget _salarySlipCard(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text("Salary Slip"),
        children: [
          Container(
            color: ColorsTheme.white,
            width: MediaQuery.of(context).size.width,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Basic Salary",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Text(
                              "Allowance",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorsTheme.lightGrey,
                              ),
                            ),
                          ),
                          if (detail_payroll.isEmpty)
                            Text("")
                          else if (detail_payroll
                              .where((item) => item["type"] == "allowance")
                              .isEmpty)
                            Text(
                              "-",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            ...detail_payroll
                                .where((item) => item["type"] == "allowance")
                                .map((item) {
                              String jenis = item["jenis"];
                              jenis = jenis
                                  .split(' ')
                                  .map((word) =>
                                      word.substring(0, 1).toUpperCase() +
                                      word.substring(1))
                                  .join(' ');
                              return Text(
                                "$jenis",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                          Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Deductions",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ColorsTheme.lightGrey,
                                ),
                              ),
                            ),
                          ),
                          if (detail_payroll.isEmpty) // Cek apakah data kosong
                            Text("") // Jika kosong, kembalikan Text kosong
                          else if (detail_payroll
                              .where((item) => item["type"] == "deduction")
                              .isEmpty)
                            Text(
                              "-",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            ...detail_payroll
                                .where((item) => item["type"] == "deduction")
                                .map((item) {
                              String jenis = item["jenis"];
                              jenis = jenis
                                  .split(' ')
                                  .map((word) =>
                                      word.substring(0, 1).toUpperCase() +
                                      word.substring(1))
                                  .join(' ');
                              return Text(
                                "$jenis",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Rp. ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(""),
                              if (detail_payroll
                                  .isEmpty) // Cek apakah data kosong
                                Text("") // Jika kosong, kembalikan Text kosong
                              else if (detail_payroll
                                  .where((item) => item["type"] == "allowance")
                                  .isEmpty)
                                Text(
                                  "-",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                ...detail_payroll
                                    .where(
                                        (item) => item["type"] == "allowance")
                                    .map((item) {
                                  int amount = item["amount"];
                                  String formattedAmount =
                                      formatCurrency(amount);
                                  return Text(
                                    "Rp. ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList(),
                              Text(""),
                              if (detail_payroll
                                  .isEmpty) // Cek apakah data kosong
                                Text("") // Jika kosong, kembalikan Text kosong
                              else if (detail_payroll
                                  .where((item) => item["type"] == "deduction")
                                  .isEmpty)
                                Text(
                                  "-",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                ...detail_payroll
                                    .where(
                                        (item) => item["type"] == "deduction")
                                    .map((item) {
                                  int amount = item["amount"];
                                  String formattedAmount =
                                      formatCurrency(amount);
                                  return Text(
                                    "Rp. ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${formatCurrency(basic_salary)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(""),
                              if (detail_payroll
                                  .isEmpty) // Cek apakah data kosong
                                Text("") // Jika kosong, kembalikan Text kosong
                              else if (detail_payroll
                                  .where((item) => item["type"] == "allowance")
                                  .isEmpty)
                                Text(
                                  "-",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                ...detail_payroll
                                    .where(
                                        (item) => item["type"] == "allowance")
                                    .map((item) {
                                  int amount = item["amount"];
                                  String formattedAmount =
                                      formatCurrency(amount);
                                  return Text(
                                    "$formattedAmount",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList(),
                              Text(""),
                              if (detail_payroll
                                  .isEmpty) // Cek apakah data kosong
                                Text("") // Jika kosong, kembalikan Text kosong
                              else if (detail_payroll
                                  .where((item) => item["type"] == "deduction")
                                  .isEmpty)
                                Text(
                                  "-",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                ...detail_payroll
                                    .where(
                                        (item) => item["type"] == "deduction")
                                    .map((item) {
                                  int amount = item["amount"];
                                  String formattedAmount =
                                      formatCurrency(amount);
                                  return Text(
                                    "$formattedAmount",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.w),
                  Divider(),
                  SizedBox(height: 10.w),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Basic Salary",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Total Allowance",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Total Deduction",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Rp. ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Rp. ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Rp. ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${formatCurrency(basic_salary)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${formatCurrency(allowance)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${formatCurrency(deduction)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.w),
            height: 40.w,
            color: ColorsTheme.whiteCream,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Take Home Pay",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Rp ${formatCurrency(net_salary)}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
          ),
        ],
        shape: Border.all(color: Colors.transparent),
      ),
    );
  }

  Widget _cardInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      width: double.infinity,
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
            borderRadius: BorderRadius.circular(15.r),
          ),
          padding: EdgeInsets.all(16.w),
          child: Column(children: [
            Container(
              margin: EdgeInsets.only(bottom: 10.w),
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: '$imgUrl',
                    imageBuilder: (context, imageProvider) => ClipRRect(
                      borderRadius: BorderRadius.circular(30.r),
                      child: CircleAvatar(
                        radius: 30.r,
                        backgroundImage: imageProvider,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$nama",
                          style: TextStyle(
                            color: ColorsTheme.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp,
                          ),
                        ),
                        SizedBox(
                          height: 2.w,
                        ),
                        Text(
                          "$posisi",
                          style: TextStyle(
                            color: ColorsTheme.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1.w, color: ColorsTheme.white),
            SizedBox(
              height: 5.w,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  showSalary = !showSalary;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Basic Salary",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: ColorsTheme.white,
                        ),
                      ),
                      Text(
                        (showSalary)
                            ? "Rp ${formatCurrency(basic_salary)}"
                            : "********",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w500,
                          color: ColorsTheme.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.h, vertical: 10.h),
                    child: Icon(
                      showSalary ? Icons.visibility : Icons.visibility_off,
                      color: ColorsTheme.white,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
