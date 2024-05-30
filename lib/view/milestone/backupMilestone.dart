import 'package:Fast_Team/controller/milestone_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stepper_list_view/stepper_list_view.dart';


class MilestonePage extends StatefulWidget {
  const MilestonePage({super.key});

  @override
  State<MilestonePage> createState() => _MilestonePageState();
}

class _MilestonePageState extends State<MilestonePage> {
  MilestoneController? milestoneController;
  List<dynamic> arrayData = [];
  List<StepperItemData> _stepperData = [];
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    milestoneController = Get.put(MilestoneController());
    var result = await milestoneController!.retrieveJobHistory();

    arrayData = result['details'];
    setState(() {
      _stepperData = _stepperDataFromDynamicList(arrayData);
    });
    // print(_stepperData);
  }

  List<StepperItemData> _stepperDataFromDynamicList(List<dynamic> arrayData) {
    return arrayData.map((data) {
      DateTime dateTime = DateTime.parse(data['start_date'].toString());
      DateFormat formatter = DateFormat('MMMM yyyy');
      String formattedMonthYear = formatter.format(dateTime);

      return StepperItemData(
        id: data['id'].toString(), // Assuming 'id' is present in data
        content: {
          'name': data['pegawai']['nama_lengkap'].toString(),
          'title': data['title'].toString(),
          'job_level': data['job_level']['name'].toString(),
          'position': data['position']['name'].toString(),
          'salary': data['salary'].toString(),
          'start_date': formattedMonthYear.replaceAll(' ', '\n'),
        },
      );
    }).toList(); // Convert Iterable to List
  }

  @override
  Widget build(BuildContext context) {
    String getMonthYear(DateTime dateTime) {
      // Format tanggal sesuai yang Anda inginkan
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
        padding: const EdgeInsets.all(20.0),
        child: StepperListView(
          showStepperInLast: true,
          stepperData: _stepperData,
          stepAvatar: (_, data) {
            return PreferredSize(
              preferredSize: Size.fromRadius(15.r),
              child: Container(
                child: CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 15.r,
                ),
              ),
            );
          },
          stepWidget: (_, data) {
            final stepData = data as StepperItemData;
            return PreferredSize(
              preferredSize: const Size.fromWidth(30),
              child: Text(
                stepData.content['start_date'] ?? '',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
          stepContentWidget: (_, data) {
            final stepData = data as StepperItemData;
            return Container(
              margin: EdgeInsets.only(
                top: 5.w,
              ),
              padding: EdgeInsets.all(
                5.w,
              ),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stepData.content['name'] ?? '',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      stepData.content['title'] ?? '',
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.w300),
                    )
                  ],
                ),
                subtitle: Row(children: [
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
                        Text(stepData.content['job_level'] ?? ''),
                        SizedBox(height: 5.w),
                        Text(stepData.content['position'] ?? ''),
                        SizedBox(height: 5.w),
                        Text(stepData.content['salary'] ?? ''),
                      ],
                    ),
                  ),
                ]),
                // subtitle: Column(
                //   mainAxisSize: MainAxisSize.min,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const SizedBox(
                //       height: 10,
                //     ),
                //     Row(
                //       children: [
                //         const Expanded(
                //           child: Icon(Icons.work),
                //         ),
                //         Expanded(
                //           flex: 5,
                //           child: Text(stepData.content['job_level'] ?? ''),
                //         ),
                //       ],
                //     ),
                //     const SizedBox(
                //       height: 10,
                //     ),
                //     Row(
                //       children: [
                //         Expanded(
                //           flex: 3,
                //           child: Icon(MdiIcons.sitemap),
                //         ),
                //         Expanded(
                //           flex: 7,
                //           child: Text(stepData.content['position'] ?? ''),
                //         ),
                //       ],
                //     ),
                //     const SizedBox(
                //       height: 10,
                //     ),
                //     Row(
                //       children: [
                //         Expanded(
                //           flex: 3,
                //           child: Icon(MdiIcons.cashMultiple),
                //         ),
                //         Expanded(
                //           flex: 7,
                //           child: Text(stepData.content['salary'] ?? ''),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: theme.dividerColor,
                    width: 0.8,
                  ),
                ),
              ),
            );
          },
          stepperThemeData: StepperThemeData(
            lineColor: theme.primaryColor,
            lineWidth: 5,
          ),
          physics: const BouncingScrollPhysics(),
        ),
      ),
    );
  }
}
