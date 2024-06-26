import 'package:Fast_Team/controller/home_controller.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;

class ListAbsentPage extends StatefulWidget {
  const ListAbsentPage({super.key});

  @override
  State<ListAbsentPage> createState() => _ListAbsentPageState();
}

class _ListAbsentPageState extends State<ListAbsentPage> {
  int? routeArguments;
  DateTime selectedDate = DateTime.now();
  HomeController? homeController;
  List<dynamic>? dataMember;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initData();
  }

  initData() async {
    setState(() {
      routeArguments = ModalRoute.of(context)?.settings.arguments as int?;
    });
    // print(routeArguments);

    var result = await _fetchMemberData();
    setState(() {
      dataMember = result;
    });
    // print(dataMember);
  }

  Future<List<dynamic>> _fetchMemberData() async {
    homeController = Get.put(HomeController());
    String dateTimeString = '$selectedDate';
    int lastIndex = dateTimeString.lastIndexOf(" ");
    String formatedDate = dateTimeString.substring(0, lastIndex);

    Map<String, dynamic> result =
        await homeController!.getListBelumAbsen(formatedDate, routeArguments!);
    List<dynamic> listMemberData = result['details']['data'];
    // print(listMemberData);
    return listMemberData;
  }

  @override
  Widget build(BuildContext context) {
    // print(selectedDate);
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Member Division',
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
      body: FutureBuilder<List<dynamic>>(
          future: _fetchMemberData(),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Menampilkan indikator loading jika data masih dimuat
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Menampilkan pesan kesalahan jika ada kesalahan dalam memuat data
              return Text('Error: ${snapshot.error}');
            } else {
              return Stack(
                fit: StackFit.expand,
                children: [
                  _calendar(),
                  _listMember(),
                ],
              );
            }
          }),
    );
  }

  Widget _listMember() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, ScrollController scrollController) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
        ),
        child: Container(
          color: ColorsTheme.whiteCream,
          child: ListView(
            controller: scrollController,
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10.w),
                    height: 3.w,
                    width: 50.w,
                    color: ColorsTheme.darkGrey,
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(top: 20.w, left: 15.w, right: 15.w),
                  //   padding: EdgeInsets.only(left: 10, right: 10),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(8),
                  //     border: Border.all(color: Colors.grey),
                  //   ),
                  //   child: DropdownButton<String>(
                  //     isExpanded: true,
                  //     value: "All Activity",
                  //     items: [
                  //       DropdownMenuItem<String>(
                  //         value: 'All Activity',
                  //         child: Text(
                  //           'All Activity | 4',
                  //           style: TextStyle(fontSize: 16),
                  //         ),
                  //       ),
                  //       DropdownMenuItem<String>(
                  //         value: 'Not Clock In',
                  //         child: Text(
                  //           'Not Clock In | 0',
                  //           style: TextStyle(fontSize: 16),
                  //         ),
                  //       ),
                  //       DropdownMenuItem<String>(
                  //         value: 'All Leave',
                  //         child: Text(
                  //           'All Leave | 0',
                  //           style: TextStyle(fontSize: 16),
                  //         ),
                  //       ),
                  //     ],
                  //     onChanged: (newValue) {},
                  //   ),
                  // ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dataMember!.length,
                itemBuilder: (context, index) {
                  final employee = dataMember![index];

                  final clockOut = !employee['jam_keluar'].isEmpty
                      ? employee['jam_keluar'].last['jam_absen']
                      : '00:00';
                  final clockIn = !employee['jam_masuk'].isEmpty
                      ? employee['jam_masuk'][0]['jam_absen']
                      : '00:00';

                  String jamClockIn = '00:00';
                  if (clockIn != '00:00') {
                    DateTime dateTimeMasuk = DateTime.parse(clockIn).toLocal();
                    jamClockIn = DateFormat.Hm().format(dateTimeMasuk).toString();
                  }

                  String jamClockOut = '00:00';
                  if (clockOut != '00:00') {
                    DateTime dateTimeKeluar = DateTime.parse(clockOut).toLocal();
                    jamClockOut = DateFormat.Hm().format(dateTimeKeluar).toString();
                  }
                 

                  return Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 5.w),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(vertical: 8.w),
                          leading: CircleAvatar(
                            radius: 23.r,
                            backgroundImage: NetworkImage(employee['image']),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employee['nama'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              Text(
                                employee['divisi'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12.sp,
                                ),
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        MdiIcons.clockTimeSevenOutline,
                                        size: 18.sp,
                                        color: ColorsTheme.lightGreen,
                                      ),
                                      Text(
                                        ' $jamClockIn',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: jamClockIn == '00:00'? ColorsTheme.lightRed : ColorsTheme.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 40.w),
                                  Row(
                                    children: [
                                      Icon(
                                        MdiIcons.clockTimeFourOutline,
                                        size: 18.sp,
                                        color: ColorsTheme.lightYellow,
                                      ),
                                      Text(
                                        ' $jamClockOut',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: jamClockOut == '00:00'? ColorsTheme.lightRed : ColorsTheme.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 1.w,
                      )
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _calendar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        children: [
          Stack(
            fit: StackFit.loose,
            children: [
              Column(
                children: [
                  Container(
                    height: 70.w,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 54, 165, 255),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    // margin: EdgeInsets.only(top: 20.w),
                    height: 365.w,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColorsTheme.white,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.r),
                          bottomRight: Radius.circular(20.r)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: CalendarCarousel(
                      onDayPressed: (DateTime date, List events) async {
                        setState(() => selectedDate = date);
                        var result = await _fetchMemberData();
                        setState(() {
                          dataMember = result;
                        });
                      },
                      locale: 'id_ID',
                      targetDateTime: selectedDate,
                      prevDaysTextStyle: TextStyle(
                        color: ColorsTheme.lightGrey3,
                      ),
                      daysTextStyle: TextStyle(
                        color: ColorsTheme.black,
                      ),
                      nextDaysTextStyle: TextStyle(
                        color: ColorsTheme.lightGrey3,
                      ),
                      weekendTextStyle: TextStyle(
                        color: ColorsTheme.black,
                      ),
                      weekdayTextStyle: TextStyle(
                        color: ColorsTheme.black,
                        fontSize: 15.sp,
                      ),
                      headerTextStyle: TextStyle(
                        color: ColorsTheme.white,
                        fontSize: 18.sp,
                      ),
                      selectedDayTextStyle: TextStyle(
                        color: ColorsTheme.primary,
                      ),
                      todayTextStyle: TextStyle(
                        color: ColorsTheme.white,
                      ),
                      todayBorderColor: const Color.fromARGB(255, 54, 165, 255),
                      todayButtonColor: const Color.fromARGB(255, 54, 165, 255),
                      selectedDayButtonColor: ColorsTheme.semiGreen!,
                      iconColor: ColorsTheme.white!,
                      thisMonthDayBorderColor: ColorsTheme.lightGrey!,
                      dayPadding: 3.w,
                      weekFormat: false,
                      height: 380.w,
                      headerTitleTouchable: true,
                      selectedDateTime: selectedDate,
                      daysHaveCircularBorder: true,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 5.w),
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              selectedDate = DateTime.now();
                            });
                            var result = await _fetchMemberData();
                            setState(() {
                              dataMember = result;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 54, 165, 255)),
                          child: Text(
                            'Today',
                            style: TextStyle(color: ColorsTheme.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
