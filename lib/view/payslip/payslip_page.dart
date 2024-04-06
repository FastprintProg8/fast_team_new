import 'dart:io';

import 'package:Fast_Team/controller/account_controller.dart';
import 'package:Fast_Team/controller/payroll_controller.dart';
import 'package:Fast_Team/model/account_information_model.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PayslipPage extends StatefulWidget {
  const PayslipPage({super.key});

  @override
  State<PayslipPage> createState() => _PayslipPageState();
}

class _PayslipPageState extends State<PayslipPage> {
  var nama;
  var posisi;
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
    setState(() {
      nama = accountModel.fullName;
      posisi = accountModel.posisiPekerjaan;
      imgUrl = accountModel.imgProfUrl;
      basic_salary = salaryResult['details']['basic_salary'];
      net_salary = salaryResult['details']['take_home_pay'];
      detail_payroll = salaryDetail['details'];
      deduction = calculateTotalDeductionAmount(detail_payroll, 'deduction');
      allowance = calculateTotalDeductionAmount(detail_payroll, 'allowance')+basic_salary;
    });
    // print(allowance + basic_salary);
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
          print(date);
        });
        // await _loadDataForSelectedMonth();
      }
    });
  }

  Future<void> createPDF() async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text("Hello World", style: pw.TextStyle(fontSize: 40)),
        ); // Misalnya, ini merupakan tampilan yang akan disertakan di PDF
      },
    ));

    final Directory? documentDirectory =
        await getApplicationDocumentsDirectory();

    print(documentDirectory?.path);
    // final file = File("${directory.path}/example.pdf");
    // await file.writeAsBytes(await pdf.save());
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
              SchedulerBinding.instance.addPostFrameCallback((_) {
                var snackbar = SnackBar(
                  content: Text('Error: ${snapshot.error}',
                      style: alertErrorTextStyle),
                  backgroundColor: ColorsTheme.lightRed,
                  behavior: SnackBarBehavior.floating,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              });
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              return _bodyContent(context, formattedDate);
            } else {
              return _bodyContent(context, formattedDate);
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

  Widget _bodyContent(BuildContext context, String formattedDate) {
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
                        createPDF().then((_) {
                          print('PDF created!');
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
          )
        ],
      ),
    );
  }

  Widget _salarySlipCard(BuildContext context) {
    return Card(
      child: ExpansionTile(
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
                            "Allowance",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorsTheme.lightGrey,
                            ),
                          ),
                          Text(
                            "Basic Salary",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (detail_payroll.isEmpty) // Cek apakah data kosong
                            Text("") // Jika kosong, kembalikan Text kosong
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(""),
                          Text(
                            "Rp ${formatCurrency(basic_salary)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (detail_payroll.isEmpty) // Cek apakah data kosong
                            Text("") // Jika kosong, kembalikan Text kosong
                          else
                            ...detail_payroll
                                .where((item) => item["type"] == "allowance")
                                .map((item) {
                              int amount = item["amount"];
                              String formattedAmount = formatCurrency(amount);
                              return Text(
                                "Rp $formattedAmount",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                          Text(""),
                          if (detail_payroll.isEmpty) // Cek apakah data kosong
                            Text("") // Jika kosong, kembalikan Text kosong
                          else
                            ...detail_payroll
                                .where((item) => item["type"] == "deduction")
                                .map((item) {
                              int amount = item["amount"];
                              String formattedAmount = formatCurrency(amount);
                              return Text(
                                "Rp $formattedAmount",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
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
                        children: [
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
                      Column(
                        children: [
                          Text(
                            "Rp ${formatCurrency(allowance)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Rp ${formatCurrency(deduction)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
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
                  Text("Total Net Pay"),
                  Text("Rp ${formatCurrency(net_salary)}"),
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
                        "Salary",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: ColorsTheme.white,
                        ),
                      ),
                      // Display salary only if showSalary is true
                      Text(
                        (showSalary)
                            ? "Rp ${formatCurrency(net_salary)}"
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
