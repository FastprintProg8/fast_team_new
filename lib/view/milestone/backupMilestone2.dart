import 'package:Fast_Team/controller/milestone_controller.dart';
import 'package:Fast_Team/server/network/job_net_utils.dart';
import 'package:Fast_Team/style/color_theme.dart';
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
  List<Color> colors = [Colors.purple, Colors.red, Colors.orange, Colors.green];
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    milestoneController = Get.put(MilestoneController());
    var result = await milestoneController!.retrieveJobHistory(1);

    setState(() {
      arrayData = result['details'];
    });
  }

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
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: ListView.builder(
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
                          color,
                        )
                      : _rightMilestone(
                          (index == arrayData.length) ? true : false,
                          formattedMonthYear,
                          arrayData[index]['pegawai']['nama_lengkap'],
                          arrayData[index]['title'],
                          arrayData[index]['job_level']['name'],
                          arrayData[index]['position']['name'],
                          arrayData[index]['salary'],
                          color,
                        ),
                ],
              );
            }),
      ),
    );
  }

  Widget _rightMilestone(
      last, date, name, title, job, position, salary, Color color) {
    return TimelineTile(
      alignment: TimelineAlign.center,
      isLast: last,
      endChild: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Text(
          date,
          textAlign: TextAlign.start,
        ),
      ),
      beforeLineStyle: LineStyle(
        color: color,
        thickness: 6,
      ),
      indicatorStyle: IndicatorStyle(
        width: 20.w,
        color: color,
      ),
      startChild: Container(
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  title ?? 'null',
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
          ),
        ),
      ),
    );
  }

  Widget _leftMilestone(
      last, first, date, name, title, job, position, salary, Color color) {
    return TimelineTile(
      alignment: TimelineAlign.center,
      isFirst: first,
      isLast: last,
      startChild: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Text(
          date,
          textAlign: TextAlign.end,
        ),
      ),
      beforeLineStyle: LineStyle(
        color: color,
        thickness: 6,
      ),
      indicatorStyle: IndicatorStyle(
        width: 20.w,
        color: color,
      ),
      endChild: Container(
        child: Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  title ?? 'null',
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
          ),
        ),
      ),
    );
  }
}
