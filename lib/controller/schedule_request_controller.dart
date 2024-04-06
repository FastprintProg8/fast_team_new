import 'package:Fast_Team/server/network/schedule_request_net_utils.dart';
import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:get/get.dart';

class ScheduleRequestController {
  ScheduleRequestNetUtils scheduleRequestNetUtils = Get.put(ScheduleRequestNetUtils());

  retrieveLeaveOption() async {
    var result = await scheduleRequestNetUtils.retrieveLeaveOption();

    return ResponseHelper().jsonResponse(result);
  }

  insertAbsentSubmission(Map<String, dynamic> bodyParams) async {
    var result = await scheduleRequestNetUtils.insertAbsentSubmission(bodyParams);

    return ResponseHelper().jsonResponse(result);
  }

  insertLeaveSubmission(Map<String, dynamic> bodyParams, file) async {
    var result = await scheduleRequestNetUtils.insertLeaveSubmission(bodyParams, file);

    return result;
  }

  insertOvertimeSubmission(Map<String, dynamic> bodyParams) async {
    var result = await scheduleRequestNetUtils.insertOvertimeSubmission(bodyParams);

    return ResponseHelper().jsonResponse(result);
  }
}