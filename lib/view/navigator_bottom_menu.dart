import 'dart:io';

import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/view/account/account_page.dart';
import 'package:Fast_Team/view/employee/employee_page.dart';
import 'package:Fast_Team/view/inbox/inbox_page.dart';
import 'package:Fast_Team/view/request/schedule_request_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'home.dart';

class NavigatorBottomMenu extends StatefulWidget {
  const NavigatorBottomMenu({super.key});

  @override
  State<NavigatorBottomMenu> createState() => _NavigatorBottomMenuState();
}

class _NavigatorBottomMenuState extends State<NavigatorBottomMenu> {
  DateTime? currentBackPressedTime;
  var selectedIndex = 0.obs;
  var data = false.obs;
  Map<String, dynamic>? args;
  List<dynamic> notMainMenu = [{'data': 0}];
  moveToMenu(index) async {
    args = null;
    selectedIndex.value = index;
  }

  Future<void> onBackPressed() async {
    DateTime now = DateTime.now();
    if (currentBackPressedTime == null ||
        now.difference(currentBackPressedTime!) > const Duration(seconds: 2)) {
      //add duration of press gap
      currentBackPressedTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tekan sekali lagi untuk keluar...")));
      // ignore: void_checks
      return Future.value(false);
    } else {
      SystemNavigator.pop();
      exit(0);
    }
  }
  

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (notMainMenu.length == 1 && args != null) {
      setState(() {
        notMainMenu.add(args);
        selectedIndex.value = args!['key'];
      });
    }

    Widget navigationMenu() {
      return Obx(
        () {
          // ignore: deprecated_member_use
          var willPopScope2 = WillPopScope(
            // child:HomePage(),
            child: (selectedIndex.value == 0)
                ? const HomePage()
                : (selectedIndex.value == 1)
                    ? const EmployeePage()
                    : (selectedIndex.value == 3)
                        ? const InboxPage()
                        : (selectedIndex.value == 2)
                            ? const ScheduleRequestPage()
                            : const AccountPage(),
            onWillPop: () async {
              DateTime now = DateTime.now();
              if (currentBackPressedTime == null ||
                  now.difference(currentBackPressedTime!) >
                      const Duration(seconds: 2)) {
                //add duration of press gap
                currentBackPressedTime = now;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Tekan sekali lagi untuk keluar...")));
                return Future.value(false);
              } else {
                SystemNavigator.pop();
                exit(0);
              }
            },
          );
          var willPopScope = willPopScope2;
          return willPopScope;
        },
      );
    }

    Widget itemNavigation() => NavigationBarTheme(
          data: const NavigationBarThemeData(),
          child: NavigationBar(
            height: 50.w,
            backgroundColor: ColorsTheme.white,
            selectedIndex: selectedIndex.value,
            onDestinationSelected: (index) => setState(() {
              moveToMenu(index);
              
            }),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                label: 'Employee',
              ),
              NavigationDestination(
                icon: Icon(Icons.request_page),
                label: 'Request',
              ),
              NavigationDestination(
                icon: Icon(Icons.inbox),
                label: 'Inbox',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_circle),
                label: 'Account',
              ),
            ],
          ),
        );

    return Scaffold(
      body: navigationMenu(),
      bottomNavigationBar: itemNavigation(),
    );
  }
}
