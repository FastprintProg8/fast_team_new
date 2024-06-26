// ignore_for_file: depend_on_referenced_packages, prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'package:Fast_Team/controller/account_controller.dart';
import 'package:Fast_Team/controller/home_controller.dart';
import 'package:Fast_Team/model/account_information_model.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/widget/header_background_home.dart';
import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:Fast_Team/user/controllerApi.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences sharedPreferences;
  var idUser;
  var email;
  int? idDivisi;
  int? id_level;
  var nama;
  var fullNama;
  var divisi;
  var posLong;
  var posLat;
  var imgProf;
  var imgUrl;
  var lat;
  var long;
  var kantor;
  var masukAwal;
  var masukAkhir;
  var keluarAwal;
  var keluarAkhir;
  var avatarImageUrl;
  var shift;

  int endList = 5;

  int startList = 0;

  TextStyle alertErrorTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: ColorsTheme.white,
  );
  TextStyle headerStyle(isSubHeader) => TextStyle(
        fontFamily: 'Poppins',
        fontSize: (isSubHeader) ? 12.sp : 15.sp,
        fontWeight: (isSubHeader) ? FontWeight.w500 : FontWeight.w700,
        color: ColorsTheme.white,
      );
  TextStyle employeeStyle(isSubHeader) => TextStyle(
        fontFamily: 'Poppins',
        fontSize: (isSubHeader) ? 10.sp : 12.sp,
        fontWeight: (isSubHeader) ? FontWeight.w500 : FontWeight.w700,
        color: ColorsTheme.black,
      );
  TextStyle contentStyle2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: ColorsTheme.black,
  );
  bool isLoading = true;
  bool moreData = true;

  String _selectedFilter = 'All';
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var now;

  bool? canClockIn;
  bool? canClockOut;

  DateTime? masukAwalDateTime;
  DateTime? masukAkhirDateTime;
  DateTime? keluarAwalDateTime;
  DateTime? keluarAkhirDateTime;
  List<Map<String, dynamic>> divisiList = [];
  List<dynamic> ListDataMember = [];
  List<dynamic> ListDataEmployee = [];
  List<dynamic> memberData = [];
  bool hasInternet = false;

  HomeController? homeController;
  final listViewController = ScrollController();

  Future? _loadData;
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  @override
  void dispose() {
    listViewController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void checkInternetConnection() async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result != true) {
     ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet Connection'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() {
        hasInternet = true;
      });
      listViewController.addListener(() {
        if (listViewController.position.pixels ==
            listViewController.position.maxScrollExtent) {
          if (moreData) {
            addItems();
          }
        }
      });
      initConstructor();
      initData();
      initializeState();

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  initConstructor() async {
    homeController = Get.put(HomeController());

    idUser = 0.obs;
    email = ''.obs;
    idDivisi = 0;
    id_level = 0;
    nama = ''.obs;
    fullNama = ''.obs;
    divisi = ''.obs;
    posLong = 0.obs;
    posLat = 0.obs;
    imgProf = ''.obs;
    imgUrl = ''.obs;
    lat = 0.0.obs;
    long = 0.0.obs;
    kantor = ''.obs;
    masukAwal = ''.obs;
    masukAkhir = ''.obs;
    keluarAwal = ''.obs;
    keluarAkhir = ''.obs;
    avatarImageUrl = ''.obs;
    shift = ''.obs;

    now = Rxn<DateTime>();
  }

  Future<void> initializeState() async {
    setState(() {
      _loadData = loadData();
    });
  }

  Future<void> initData() async {
    AccountController accountController = Get.put(AccountController());
    var result = await accountController.retriveAccountInformation();
    AccountInformationModel accountModel =
        AccountInformationModel.fromJson(result['details']['data']);
    idUser = accountModel.id;
    nama = accountModel.fullName;
    divisi = accountModel.divisi;
    idDivisi = accountModel.id_divisi;
    id_level = accountModel.id_level;
    imgUrl = accountModel.imgProfUrl;
    kantor = accountModel.cabang;
    masukAwal = accountModel.masukAwal;
    masukAkhir = accountModel.masukAkhir;
    keluarAwal = accountModel.keluarAwal;
    keluarAkhir = accountModel.keluarAkhir;
    shift = accountModel.shift;

    if (accountModel.id != null) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future refreshItem() async {
    homeController = Get.put(HomeController());
    try {
      // Ambil data divisi
      checkInternetConnection();
      var divisiData = await homeController!.listDivisi();
      ListDataEmployee = ListDataEmployee.sublist(0, 5);

      setState(() {
        _loadData = loadData();
        divisiList = List.from(divisiData['details']);
        moreData = true;
        startList = 0;
        endList = 5;
      });

      setState(() {
        isLoading = true;
      });
    } catch (e) {
      bool result = await InternetConnection().hasInternetAccess;
      if (result != true) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet Connection'),
          backgroundColor: Colors.red,
        ),
      );
      }
      print(e);
    }
  }

  bool canAbsent(clockIn) {
    tz.initializeTimeZones();
    final indonesia = tz.getLocation("Asia/Jakarta");
    now = tz.TZDateTime.now(indonesia);
    if (masukAwal != null) {
      masukAwalDateTime =
          tz.TZDateTime.parse(indonesia, "$currentDate $masukAwal");
    }

    if (masukAkhir != null) {
      masukAkhirDateTime =
          tz.TZDateTime.parse(indonesia, "$currentDate $masukAkhir");
    }

    if (keluarAwal != null) {
      keluarAwalDateTime =
          tz.TZDateTime.parse(indonesia, "$currentDate $keluarAwal");
    }

    if (keluarAkhir != null) {
      keluarAkhirDateTime =
          tz.TZDateTime.parse(indonesia, "$currentDate $keluarAkhir");
    }
    var result;
    if (clockIn) {
      result = masukAwalDateTime != null &&
          masukAkhirDateTime != null &&
          now.isAfter(masukAwalDateTime!) &&
          now.isBefore(masukAkhirDateTime!);
    } else {
      result = keluarAwalDateTime != null &&
          keluarAkhirDateTime != null &&
          now.isAfter(keluarAwalDateTime!) &&
          now.isBefore(keluarAkhirDateTime!);
    }

    return result;
  }

  Future<void> loadData() async {
    homeController = Get.put(HomeController());
    try {
      var divisiData = await homeController!.listDivisi();
      var fetch = await _fetchData();
      var resultMember = await _fetchMemberData();

      setState(() {
        ListDataEmployee = fetch;
        divisiList = List.from(divisiData['details']);
        moreData = true;
      });
      setState(() {
        isLoading = false;
        memberData = resultMember;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<List<dynamic>> _fetchMemberData() async {
    Map<String, dynamic> result =
        await homeController!.getListBelumAbsen(currentDate, idDivisi!);
    List<dynamic> listMemberData = result['details']['data'];

    return listMemberData;
  }

  Future<List<dynamic>> _fetchData() async {
    homeController = Get.put(HomeController());
    try {
      if (_selectedFilter == 'All') {
        // Panggil getListBelumAbsen tanpa parameter jika "Semua" dipilih
        Map<String, dynamic> result =
            await homeController!.getListBelumAbsen('', 0);
        List<dynamic> listData = result['details']['data'];

        // if (listData.length > 5) {
        //   listData = listData.sublist(startList, endList);
        // } else {
        listData = listData.sublist(0, 5);
        // }

        return listData;
      } else {
        Map<String, dynamic> result = await homeController!
            .getListBelumAbsen(currentDate, int.parse(_selectedFilter));
        List<dynamic> listData = result['details']['data'];
        if (listData.length > 5) {
          listData = listData.sublist(0, 5);
        } else {
          listData = listData.sublist(0, listData.length);
        }

        // setState(() {
        // ListDataEmployee = listData;
        // });
        return listData;
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return [];
    }
  }

  Future<int> lengthEmployeeData() async {
    homeController = Get.put(HomeController());
    Map<String, dynamic> result =
        await homeController!.getListBelumAbsen('', 0);
    List<dynamic> listData = result['details']['data'];
    return listData.length;
  }

  void _clockIn(BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi ditolak oleh pengguna.'),
        ),
      );
    } else {
      Navigator.pushNamed(context, '/map', arguments: 'in');
    }
  }

  void _clockOut(BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi ditolak oleh pengguna.'),
        ),
      );
    } else {
      Navigator.pushNamed(context, '/map', arguments: 'out');
    }
  }

  String getGreeting() {
    var now = DateTime.now();
    var currentHour = now.hour;

    if (currentHour >= 0 && currentHour < 11) {
      return 'Good Morning, ';
    } else if (currentHour >= 11 && currentHour < 14) {
      return 'Good Afternoon, ';
    } else if (currentHour >= 14 && currentHour < 17) {
      return 'Good Evening, ';
    } else {
      return 'Good Night, ';
    }
  }

  String getCurrentDay() {
    var now = DateTime.now();
    var days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    return days[now.weekday];
  }

  bool isTimeInRange(DateTime time, DateTime start, DateTime end) {
    return time.isAfter(start) && time.isBefore(end);
  }

  Future addItems() async {
    setState(() {
      startList = startList + 5;
      endList = endList + 5;
    });
    if (_selectedFilter == 'All') {
      Map<String, dynamic> result =
          await homeController!.getListBelumAbsen('', 0);
      List<dynamic> listData = result['details']['data'];
      
      // ListDataEmployee.addAll(listData);
      // if ((ListDataEmployee.length + 5) < listData.length) {
      //   listData = listData.sublist(startList, endList);
      // } else {
      //   if(listData.length <= 0){
      //     setState(() {
      //       moreData = true;
      //     });
      //   }else{
      //     listData = listData.sublist(startList, listData.length);
      //   }
      // }
      setState(() {
        if (listData.length < 5) {
          moreData = false;
        }
        ListDataEmployee.addAll(listData);
      });
    } else {
      Map<String, dynamic> result = await homeController!
          .getListBelumAbsen(currentDate, int.parse(_selectedFilter));
      List<dynamic> listData = result['details']['data'];

      if (startList > listData.length) {
        setState(() {
          moreData = false;
        });
      } else {
        if ((ListDataEmployee.length + 5) < listData.length) {
          listData = listData.sublist(startList, endList);
        } else {
          // listData = listData.sublist(startList, endList);
          listData = listData.sublist(startList, listData.length);
        }
        setState(() {
          ListDataEmployee.addAll(listData);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget headerBackground() => const HeaderCircle(diameter: 500);
    Widget Headers() {
      return headerBackground();
    }

    Widget loadingData(statusComponent) => Shimmer.fromColors(
        baseColor: ColorsTheme.secondary!,
        highlightColor: ColorsTheme.lightGrey2!,
        child: Container(
          width: (statusComponent == 1)
              ? 100.w
              : (statusComponent == 2)
                  ? 70.w
                  : (statusComponent == 3)
                      ? 200.w
                      : 50.w,
          height: (statusComponent == 3) ? 20.h : 15.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.r),
            color: ColorsTheme.white,
          ),
        ));

    Widget CardClock(statusLoading) {
      Widget absnetButtonLoading() => Shimmer.fromColors(
          baseColor: ColorsTheme.secondary!,
          highlightColor: ColorsTheme.lightGrey2!,
          child: Container(
            width: 120.w,
            height: 35.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.r),
              color: ColorsTheme.white,
            ),
          ));
      Widget absnetButton(name, status, clockIn) => ElevatedButton(
            onPressed: status
                ? (clockIn ? () => _clockIn(context) : () => _clockOut(context))
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  status ? const Color.fromARGB(255, 2, 65, 128) : Colors.grey,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  name,
                  style: TextStyle(
                      color: status
                          ? ColorsTheme.whiteCream
                          : ColorsTheme.lightGrey),
                ),
              ],
            ),
          );

      return Container(
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        padding: const EdgeInsets.only(bottom: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorsTheme.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color.fromARGB(255, 2, 65, 128)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: (statusLoading || !hasInternet)
                      ? loadingData(1)
                      : Text(
                          '$kantor ${getCurrentDay()}',
                          style: TextStyle(color: ColorsTheme.secondary),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Row(
                    children: (statusLoading || !hasInternet)
                        ? [loadingData(3)]
                        : [
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 20.sp,
                            ),
                            Text(
                              ' ${DateFormat('d MMM yyyy').format(DateTime.now())}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              ' ($shift)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                (statusLoading || !hasInternet)
                    ? absnetButtonLoading()
                    : absnetButton('Clock In', canAbsent(true), true),
                (statusLoading || !hasInternet)
                    ? absnetButtonLoading()
                    : absnetButton('Clock Out', canAbsent(false), false),
              ],
            ),
          ),
        ]),
      );
    }

    Widget headerUsername(statusLoading) {
      Widget loadingAvatar() => Shimmer.fromColors(
            baseColor: ColorsTheme.secondary!,
            highlightColor: ColorsTheme.lightGrey2!,
            child:
                CircleAvatar(backgroundColor: ColorsTheme.black, radius: 100.r),
          );

      return SizedBox(
        width: ScreenUtil().screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    getGreeting(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsTheme.white,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (!statusLoading || !hasInternet)
                            ? [
                                loadingData(2),
                                SizedBox(height: 5.h),
                                loadingData(1),
                              ]
                            : [
                                SizedBox(
                                  width: 200.w,
                                  child:
                                      Text('$nama', style: headerStyle(false)),
                                ),
                                SizedBox(height: 5.h),
                                Text('$divisi', style: headerStyle(true)),
                              ],
                      ),
                      SizedBox(
                        width: 60.w,
                        height: 60.h,
                        child: (!statusLoading || !hasInternet)
                            ? loadingAvatar()
                            : CachedNetworkImage(
                                imageUrl: '$imgUrl',
                                imageBuilder: (context, imageProvider) =>
                                    ClipRRect(
                                  borderRadius: BorderRadius.circular(30.r),
                                  child: CircleAvatar(
                                    radius: 30.r,
                                    backgroundImage: imageProvider,
                                  ),
                                ),
                                placeholder: (context, url) => loadingAvatar(),
                              ),
                      ),
                    ],
                  ),
                  CardClock(!statusLoading),
                ]),
          ],
        ),
      );
    }

    Widget contentIcon(status) => Column(
          children: [
            Container(
                width: 45.w,
                height: 45.h,
                decoration: BoxDecoration(
                  color: ColorsTheme.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: (status == "Attendance")
                    ? const Icon(
                        Icons.list_alt,
                        color: Colors.blue,
                        size: 30, // Ukuran ikon
                      )
                    : (status == "Module")
                        ? Icon(
                            Icons.folder,
                            color: Colors.yellow[600],
                            size: 30, // Ukuran ikon
                          )
                        : (status == "Payslip")
                            ? const Icon(
                                Icons.attach_money,
                                color: Colors.pink,
                                size: 30, // Ukuran ikon
                              )
                            : const Icon(
                                Icons.history,
                                color: Colors.amber,
                                size: 30, // Ukuran ikon
                              )),
            SizedBox(height: 5.w),
            Text(
              (status == "Attendance")
                  ? 'Attendance\nLog'
                  : (status == "Module")
                      ? 'Module'
                      : (status == "Payslip")
                          ? 'My Payslip'
                          : 'Milestone',
              style: contentStyle2,
              textAlign: TextAlign.center,
            ),
          ],
        );
    Widget iconMenu(status, isLoading) => InkWell(
        onTap: () => (isLoading)
            ? {}
            : (status == "Attendance")
                ? Navigator.pushNamed(context, '/daftarAbsensi')
                : (status == "Payslip")
                    ? Navigator.pushNamed(context, '/verifPayslip')
                    : (status == "Milestone")
                        ? Navigator.pushNamed(context, '/milestone')
                        : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Menu masih belum tersedia",
                                style: alertErrorTextStyle),
                            backgroundColor: ColorsTheme.lightRed,
                            behavior: SnackBarBehavior.floating,
                          )),
        child: contentIcon(status));

    Widget Menu() {
      return Container(
        padding: EdgeInsets.only(top: 50.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconMenu("Attendance", isLoading),
            iconMenu("Module", isLoading),
            iconMenu("Payslip", isLoading),
            iconMenu("Milestone", isLoading),
          ],
        ),
      );
    }

    Widget ListEmployee(datalist, loading) {
      Widget loadingAvatar() => Shimmer.fromColors(
            baseColor: ColorsTheme.secondary!,
            highlightColor: ColorsTheme.lightGrey2!,
            child:
                CircleAvatar(backgroundColor: ColorsTheme.black, radius: 30.r),
          );
      Widget loadingData(statusComponent) => Shimmer.fromColors(
          baseColor: ColorsTheme.secondary!,
          highlightColor: ColorsTheme.lightGrey2!,
          child: Container(
            width: (statusComponent == 1)
                ? 100.w
                : (statusComponent == 2)
                    ? 70.w
                    : (statusComponent == 3)
                        ? 40.w
                        : 50.w,
            height: 15.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.r),
              color: ColorsTheme.white,
            ),
          ));
      return Container(
          margin: EdgeInsets.only(left: 8.w, bottom: 5.h),
          // height: 100.h,
          decoration: BoxDecoration(
            color: ColorsTheme.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  margin:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                  child: CircleAvatar(
                    radius: 21.r,
                    backgroundColor: ColorsTheme.lightGrey3,
                    child: (loading)
                        ? loadingAvatar()
                        : CircleAvatar(
                            radius: 20.r,
                            child: CachedNetworkImage(
                              imageUrl: datalist['image'],
                              imageBuilder: (context, imageProvider) =>
                                  ClipRRect(
                                borderRadius: BorderRadius.circular(30.r),
                                child: CircleAvatar(
                                  radius: 30.r,
                                  backgroundImage: imageProvider,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (loading)
                      ? [
                          loadingData(1),
                          SizedBox(
                            height: 5.h,
                          ),
                          loadingData(2)
                        ]
                      : [
                          SizedBox(
                            width: 150.w,
                            child: Text(
                              datalist['nama'],
                              style: employeeStyle(false),
                            ),
                          ),
                          Text(datalist['divisi'], style: employeeStyle(true)),
                        ],
                ),
              ]),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    // Text('${datalist['clock_in']}')
                    Icon(Icons.input,
                        color: (datalist['clock_in'] == 1)
                            ? ColorsTheme.lightGreen
                            : ColorsTheme.lightGrey),
                    SizedBox(width: 8.w),
                    Icon(Icons.output,
                        color: (datalist['clock_out'] == 1)
                            ? ColorsTheme.lightRed
                            : ColorsTheme.lightGrey),
                  ],
                ),
              ),
            ],
          ));
    }

    Widget ListAbsens() {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Color.fromARGB(255, 2, 65, 128), width: 3.0),
                      ),
                    ),
                    padding: EdgeInsets.all(8.w),
                    child: RichText(
                      text: const TextSpan(
                        text: 'List',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 2, 65, 128),
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' Absent',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Container(
                padding: EdgeInsets.only(left: 10.w, right: 10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedFilter,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedFilter = newValue!;
                      startList = 0;
                      endList = 5;
                    });
                    // Panggil loadData untuk mengambil data sesuai pilihan
                    loadData();
                  },
                  items: [
                    DropdownMenuItem<String>(
                      value: 'All',
                      child: Text(
                        'All',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    ...divisiList.map<DropdownMenuItem<String>>(
                        (Map<String, dynamic> divisi) {
                      return DropdownMenuItem<String>(
                        value: divisi['id'].toString(),
                        child: Text(
                          divisi['name'],
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 10.w),
                itemCount: ListDataEmployee.length + 1,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index < ListDataEmployee.length) {
                    return ListEmployee(ListDataEmployee[index], false);
                  } else {
                    return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.w),
                        child: Center(
                          child: (moreData)
                              ? const CircularProgressIndicator()
                              : const Text('No more data'),
                        ));
                  }
                })
            // return Text('No data available');
          ],
        ),
      );
    }

    Widget contentLoadedData(statusLoading) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Headers(),
                  Positioned(
                    top: 2.h,
                    left: 20.w,
                    right: 20.w,
                    child: Column(
                      children: [
                        headerUsername(statusLoading),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

    Widget body() {
      return FutureBuilder(
          future: _loadData,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return contentLoadedData(false);
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
              return contentLoadedData(false);
            } else if (snapshot.hasData) {
              return contentLoadedData(true);
            } else {
              return contentLoadedData(true);
            }
          });
    }

    Widget ListMemberAbsens() {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Color.fromARGB(255, 2, 65, 128), width: 3.0),
                      ),
                    ),
                    padding: EdgeInsets.all(8.w),
                    child: RichText(
                      text: TextSpan(
                        text: 'List',
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: const Color.fromARGB(255, 2, 65, 128),
                          fontWeight: FontWeight.bold,
                        ),
                        children: const <TextSpan>[
                          TextSpan(
                            text: ' Member Division',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: InkWell(
                onTap: () async {
                  Navigator.pushNamed(context, '/listMember',
                      arguments: idDivisi);
                },
                child: Container(
                    child: (isLoading || !hasInternet)
                        ? Container(
                            height: 70.w,
                            decoration: BoxDecoration(
                              color: ColorsTheme.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: ColorsTheme.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 10.w),
                                    child: Row(
                                      children: List.generate(
                                        (memberData.length <= 3)
                                            ? memberData.length
                                            : 3,
                                        (index) => Align(
                                          child: CircleAvatar(
                                            radius: 25.r,
                                            backgroundColor:
                                                ColorsTheme.lightGrey2,
                                            child: CircleAvatar(
                                              radius: 23.r,
                                              backgroundImage: NetworkImage(
                                                  memberData[index]['image']),
                                            ),
                                          ),
                                        ),
                                      )..addAll(
                                          (memberData.length > 3)
                                              ? [
                                                  Align(
                                                    child: CircleAvatar(
                                                      radius: 25.r,
                                                      backgroundColor:
                                                          ColorsTheme
                                                              .lightGrey2,
                                                      child: CircleAvatar(
                                                        radius: 23.r,
                                                        backgroundColor: ColorsTheme
                                                            .white, // Set grey background
                                                        child: Text(
                                                          '+${memberData.length - 3}',
                                                          style: TextStyle(
                                                              color: ColorsTheme
                                                                  .black),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                    )),
                                Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 10.w),
                                    child: const Icon(Icons.arrow_forward_ios)),
                              ],
                            ),
                          )),
                // child: Container(
                //   child: FutureBuilder<List<dynamic>>(
                //     future: _fetchMemberData(),
                //     builder: (context, snapshot) {
                //       // print(snapshot.data);
                //       if (snapshot.connectionState == ConnectionState.waiting) {
                // return Container(
                //   height: 70.w,
                //   decoration: BoxDecoration(
                //     color: ColorsTheme.white,
                //     borderRadius: BorderRadius.circular(8),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.withOpacity(0.2),
                //         spreadRadius: 5,
                //         blurRadius: 7,
                //         offset:
                //             Offset(0, 3), // changes position of shadow
                //       ),
                //     ],
                //   ),
                // );
                //       } else if (snapshot.hasError) {
                //         return Text('Error: ${snapshot.error}');
                //       } else if (snapshot.hasData) {
                //         List<dynamic> data = snapshot.data!;
                // return Container(
                //   decoration: BoxDecoration(
                //     color: ColorsTheme.white,
                //     borderRadius: BorderRadius.circular(8),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.withOpacity(0.2),
                //         spreadRadius: 5,
                //         blurRadius: 7,
                //         offset:
                //             Offset(0, 3), // changes position of shadow
                //       ),
                //     ],
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Container(
                //           margin: EdgeInsets.symmetric(
                //               horizontal: 20.w, vertical: 10.w),
                //           child: Row(
                //             children: List.generate(
                //               (data.length <= 3) ? data.length : 3,
                //               (index) => Align(
                //                 child: CircleAvatar(
                //                   radius: 25.r,
                //                   backgroundColor:
                //                       ColorsTheme.lightGrey2,
                //                   child: CircleAvatar(
                //                     radius: 23.r,
                //                     backgroundImage: NetworkImage(
                //                         data[index]['image']),
                //                   ),
                //                 ),
                //               ),
                //             )..addAll(
                //                 (data.length > 3)
                //                     ? [
                //                         Align(
                //                           child: CircleAvatar(
                //                             radius: 25.r,
                //                             backgroundColor:
                //                                 ColorsTheme.lightGrey2,
                //                             child: CircleAvatar(
                //                               radius: 23.r,
                //                               backgroundColor: ColorsTheme
                //                                   .white, // Set grey background
                //                               child: Text(
                //                                 '+${data.length - 3}',
                //                                 style: TextStyle(
                //                                     color: ColorsTheme
                //                                         .black),
                //                               ),
                //                             ),
                //                           ),
                //                         ),
                //                       ]
                //                     : [],
                //               ),
                //           )),
                //       Container(
                //           margin: EdgeInsets.symmetric(
                //               horizontal: 20.w, vertical: 10.w),
                //           child: Icon(Icons.arrow_forward_ios)),
                //     ],
                //   ),
                // );
                //       } else {
                //         return Text('No data available');
                //       }
                //     },
                //   ),
                // ),
              ),
            )
          ],
        ),
      );
    }

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
          appBar: null,
          body: RefreshWidget(
            onRefresh: refreshItem,
            child: ListView(
              controller: listViewController,
              scrollDirection: Axis.vertical,
              children: <Widget>[
                // Wrap the sticky part with StickyHeader widget
                body(),
                Menu(),
                (id_level != 1 || id_level != 2 || id_level != 3)
                    ? ListMemberAbsens()
                    : Container(),
                ListAbsens(),
              ],
            ),
          )),
    );
  }

  void showFilterDropdown(BuildContext context) async {
    final result = await showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(0, 0, 0, 0),
      items: [
        const PopupMenuItem<String>(
          value: 'All',
          child: Text('All', style: TextStyle(fontSize: 16)),
        ),
        ...divisiList.map<PopupMenuItem<String>>(
          (Map<String, dynamic> divisi) {
            return PopupMenuItem<String>(
              value: divisi['id'].toString(),
              child: Text(divisi['name'], style: const TextStyle(fontSize: 16)),
            );
          },
        ),
      ],
      elevation: 8.0,
    );

    if (result != null) {
      setState(() {
        _selectedFilter = result;
      });

      // Call loadData to fetch data based on the selected filter
      loadData();
    }
  }

  void onTabTapped(int index) {
    setState(() {});
  }
}
