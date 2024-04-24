import 'package:Fast_Team/controller/milestone_controller.dart';
import 'package:Fast_Team/server/network/job_net_utils.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/widget/bottom_nav_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stepper_list_view/stepper_list_view.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';

class MilestonePage extends StatefulWidget {
  const MilestonePage({super.key});

  @override
  State<MilestonePage> createState() => _MilestonePageState();
}

class _MilestonePageState extends State<MilestonePage> {
  MilestoneController? milestoneController;
  List<dynamic> arrayData = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    milestoneController = Get.put(MilestoneController());
    var result = await milestoneController!.retrieveJobHistory(1);
    print(result);
    // setState(() {
    //   arrayData = result['details'];
    // });
  }

  List<Color> colors = [Colors.purple, Colors.red, Colors.yellow, Colors.green];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    String getMonthYear(DateTime dateTime) {
      final DateFormat formatter = DateFormat('MMMM yyyy');
      return formatter.format(dateTime);
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Milestone',
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w),
        child: arrayData.isEmpty
            ? _noNotifications()
            : ListView.builder(
                shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                itemCount: arrayData.length,
                itemBuilder: (context, index) {
                  DateTime dateTime =
                      DateTime.parse(arrayData[index]['start_date'].toString());
                  DateFormat formatter = DateFormat('dd MMMM yyyy');
                  String formattedMonthYear = formatter.format(dateTime);
                  Color color = colors[index % colors.length];
                  return Column(
                    children: [
                      (index % 2 == 0)
                          ? _leftMilestone(
                              (index == arrayData.length - 1) ? true : false,
                              (index == 0) ? true : false,
                              formattedMonthYear,
                              arrayData[index]['pegawai']['nama_lengkap'],
                              arrayData[index]['title'],
                              arrayData[index]['job_level']['name'],
                              arrayData[index]['position']['name'],
                              arrayData[index]['salary'],
                              color)
                          : _rightMilestone(
                              (index == arrayData.length) ? true : false,
                              formattedMonthYear,
                              arrayData[index]['pegawai']['nama_lengkap'],
                              arrayData[index]['title'],
                              arrayData[index]['job_level']['name'],
                              arrayData[index]['position']['name'],
                              arrayData[index]['salary'],
                              color),
                    ],
                  );
                }),
      ),
      bottomNavigationBar: bottomNavBar(context: context),
    );
  }

  Widget _rightMilestone(
      last, date, name, title, job, position, salary, Color colors) {
    return Column(
      children: [
        SizedBox(
          height: 180.w,
          child: TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.9,
            beforeLineStyle: LineStyle(
              color: colors,
              thickness: 6,
            ),
            isLast: last,
            startChild: Container(
                margin: EdgeInsets.only(
                    top: 10.w, bottom: 10.w, left: 10.w, right: 5.w),
                decoration: BoxDecoration(
                  color: ColorsTheme.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          date,
                        ),
                      ),
                      SizedBox(height: 5.w),
                      Text(
                        name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        title ?? 'null',
                      ),
                      SizedBox(
                        height: 10.w,
                      ),
                      Row(children: [
                        Container(
                          child: Column(
                            children: [
                              Icon(Icons.work),
                              SizedBox(height: 2.w),
                              Icon(MdiIcons.sitemap),
                              SizedBox(height: 2.w),
                              Icon(MdiIcons.cashMultiple),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(job),
                              SizedBox(height: 5.w),
                              Text(position),
                              SizedBox(height: 5.w),
                              Text(salary),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                )),
            indicatorStyle: IndicatorStyle(
              width: 20.w,
              color: colors,
            ),
          ),
        ),
        (!last)
            ? TimelineDivider(
                begin: 0.1,
                end: 0.9,
                thickness: 6,
                color: colors,
              )
            : Container(),
      ],
    );
  }

  Widget _leftMilestone(
      last, first, date, name, title, job, position, salary, Color colors) {
    return Column(
      children: [
        SizedBox(
          height: 180.w,
          child: TimelineTile(
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            isFirst: first,
            isLast: last,
            indicatorStyle: IndicatorStyle(
              width: 20.w,
              color: colors,
            ),
            endChild: Container(
                margin: EdgeInsets.only(
                    top: 10.w, bottom: 10.w, right: 10.w, left: 5.w),
                decoration: BoxDecoration(
                  color: ColorsTheme.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          date,
                        ),
                      ),
                      SizedBox(height: 5.w),
                      Text(
                        name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        title ?? 'null',
                      ),
                      SizedBox(
                        height: 10.w,
                      ),
                      Row(children: [
                        Container(
                          child: Column(
                            children: [
                              Icon(Icons.work),
                              SizedBox(height: 2.w),
                              Icon(MdiIcons.sitemap),
                              SizedBox(height: 2.w),
                              Icon(MdiIcons.cashMultiple),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(job),
                              SizedBox(height: 5.w),
                              Text(position),
                              SizedBox(height: 5.w),
                              Text(salary),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                )),
            beforeLineStyle: LineStyle(
              color: colors,
              thickness: 6,
            ),
          ),
        ),
        (!last)
            ? TimelineDivider(
                begin: 0.1,
                end: 0.9,
                thickness: 6,
                color: colors,
              )
            : Container(),
      ],
    );
  }

  Widget _noNotifications() {
    return Center(
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
}
