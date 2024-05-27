import 'package:Fast_Team/server/network/schedule_request_net_utils.dart';
import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleRequestController {
  ScheduleRequestNetUtils scheduleRequestNetUtils =
      Get.put(ScheduleRequestNetUtils());

  retrieveLeaveOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await scheduleRequestNetUtils.retrieveLeaveOption(token);

    return ResponseHelper().jsonResponse(result);
  }

  insertAbsentSubmission(Map<String, dynamic> bodyParams) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result =
        await scheduleRequestNetUtils.insertAbsentSubmission(bodyParams, token);

    return ResponseHelper().jsonResponse(result);
  }

  insertLeaveSubmission(Map<String, dynamic> bodyParams, file) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await scheduleRequestNetUtils.insertLeaveSubmission(
        bodyParams, file, token);

    return result;
  }

  insertOvertimeSubmission(Map<String, dynamic> bodyParams) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await scheduleRequestNetUtils.insertOvertimeSubmission(
        bodyParams, token);

    return ResponseHelper().jsonResponse(result);
  }
}
