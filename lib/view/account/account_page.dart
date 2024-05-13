// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'package:Fast_Team/controller/account_controller.dart';
import 'package:Fast_Team/model/account_information_model.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/view/account/personal_info_page.dart';
import 'package:Fast_Team/view/auth/login_page.dart';
import 'package:Fast_Team/view/auth/reset_password_page.dart';
import 'package:Fast_Team/view/payroll_info/payroll_info_page.dart';
import 'package:Fast_Team/view/sertificate.dart';

import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  var fullNama;
  var divisi;
  var imgUrl;
  bool isLoading = true;

  TextStyle alertErrorTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: ColorsTheme.white,
  );

  TextStyle headerStyle(isSubHeader) => TextStyle(
        fontFamily: 'Poppins',
        fontSize: (isSubHeader) ? 12.sp : 18.sp,
        fontWeight: (isSubHeader) ? FontWeight.w500 : FontWeight.w700,
        color: ColorsTheme.white,
      );

  @override
  void initState() {
    super.initState();
    initConstructor();
    initData();
  }

  initConstructor() {
    fullNama = ''.obs;
    divisi = ''.obs;
    imgUrl = ''.obs;
  }

  initData() async {
    AccountController accountController = Get.put(AccountController());
    var result = await accountController.retriveAccountInformation();
    AccountInformationModel accountModel =
        AccountInformationModel.fromJson(result['details']['data']);

    fullNama = accountModel.fullName;
    divisi = accountModel.divisi;
    imgUrl = accountModel.imgProfUrl;
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future refreshItem() async {
    AccountController accountController = Get.put(AccountController());
    var result = await accountController.retriveAccountInformation();
    AccountInformationModel accountModel =
        AccountInformationModel.fromJson(result['details']['data']);

    setState(() {
      fullNama = accountModel.fullName;
      divisi = accountModel.divisi;
      imgUrl = accountModel.imgProfUrl;
      isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget header() {
      return Container(
        width: ScreenUtil().screenWidth,
        height: 205.h,
        decoration: BoxDecoration(
          color: ColorsTheme.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.r),
            bottomRight: Radius.circular(25.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 18.h),
              child: Column(
                children: [
                  (isLoading)
                      ? loadingAvatar()
                      : CachedNetworkImage(
                          imageUrl: imgUrl,
                          imageBuilder: (context, imageProvider) => ClipRRect(
                            borderRadius: BorderRadius.circular(30.r),
                            child: CircleAvatar(
                              radius: 50.r,
                              backgroundImage: imageProvider,
                            ),
                          ),
                          placeholder: (context, url) => loadingAvatar(),
                        ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 60.w),
                    child: (isLoading)
                        ? loadingData(150.w)
                        : Text(
                            '$fullNama',
                            style: headerStyle(false),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: (isLoading)
                        ? loadingData(120.w)
                        : Text('$divisi', style: headerStyle(true)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget menu() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            menuItems('Personal Info', Colors.blue, Icons.person, () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersonalInfo(),
                ),
              );
            }),
            const Divider(),
            menuItems('Sertificate', Colors.cyan, Icons.badge, () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SertificatePage(),
                ),
              );
            }),
            const Divider(),
            menuItems(
                'Payroll Info', Colors.green, Icons.monetization_on, () {Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PayrollInfo(),
                ),
              );}),
            const Divider(),
            menuItems('Change Password', Colors.orange, Icons.lock, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResetPasswordPage(),
                ),
              );
            }),
            const Divider(),
            menuItems(
              'Logout',
              Colors.red,
              Icons.exit_to_app,
              () async {
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                await sharedPreferences.clear();

                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (Route<dynamic> route) => false);

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) => const LoginPage(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: RefreshWidget(
        onRefresh: refreshItem,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            header(),
            menu(),
          ],
        ),
      ),
    );
  }

  Widget loadingData(width) {
    return Shimmer.fromColors(
        baseColor: ColorsTheme.secondary!,
        highlightColor: ColorsTheme.lightGrey2!,
        child: Container(
          width: width,
          height: 20.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.r),
            color: ColorsTheme.white,
          ),
        ));
  }

  Widget loadingAvatar() {
    return Shimmer.fromColors(
      child: CircleAvatar(backgroundColor: ColorsTheme.black, radius: 50.r),
      baseColor: ColorsTheme.secondary!,
      highlightColor: ColorsTheme.lightGrey2!,
    );
  }

  ListTile menuItems(text, color, icon, VoidCallback onTapCallback) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        text,
        style: TextStyle(color: ColorsTheme.black),
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right,
        color: Colors.blue,
      ),
      tileColor: Colors.transparent,
      onTap: onTapCallback,
    );
  }
}
