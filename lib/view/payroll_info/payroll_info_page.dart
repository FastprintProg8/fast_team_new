import 'package:Fast_Team/controller/account_controller.dart';
import 'package:Fast_Team/model/account_information_model.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/view/account/submission_page.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PayrollInfo extends StatefulWidget {
  const PayrollInfo({super.key});

  @override
  State<PayrollInfo> createState() => _PayrollInfoState();
}

class _PayrollInfoState extends State<PayrollInfo> {
  Future? _loadData;
  TextStyle alertErrorTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: ColorsTheme.white,
  );
  @override
  Future refreshItem() async {
    setState(() {
      _loadData = initializeState();
    });
  }

  Future<void> initializeState() async {
    await retriveAccountInformation();
  }

  retriveAccountInformation() async {
    AccountController accountController = Get.put(AccountController());
    var result = await accountController.retriveAccountInformation();
    // print(result['details']['data']);
    AccountInformationModel accountModel =
        AccountInformationModel.fromJson(result['details']['data']);

    print(accountModel);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payroll Info',
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
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SubmissionPage()));
              },
              icon: Icon(Icons.edit_square))
        ],
      ),
      body: RefreshWidget(
        onRefresh: refreshItem,
        child: body(),
      ),
    );
  }

  Widget body() {
    return FutureBuilder(
      future: _loadData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return contentBody(false);
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
          return contentBody(false);
        } else if (snapshot.hasData) {
          return contentBody(true);
        } else {
          return contentBody(true);
        }
      },
    );
  }

  Widget contentBody(bool isLoaded) {
    return Container();
  }
}
