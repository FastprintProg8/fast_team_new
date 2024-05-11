import 'package:Fast_Team/server/network/inbox_net_utils.dart';
import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InboxController {
  InboxNetUtils inboxNetUtils = Get.put(InboxNetUtils());

  retrieveAttendanceList(userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await inboxNetUtils.retrieveAttendanceList(userId, token);

    return ResponseHelper().jsonResponse(result);
  }

  retrieveOvertimeList(userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await inboxNetUtils.retrieveOvertimeList(userId, token);

    return ResponseHelper().jsonResponse(result);
  }

  retrieveLeaveList(userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await inboxNetUtils.retrieveLeaveList(userId, token);

    return ResponseHelper().jsonResponse(result);
  }

  retrieveNotificationList(userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await inboxNetUtils.retrieveNotificationList(userId, token);

    return ResponseHelper().jsonResponse(result);
  }

  retrieveNotificationDetail(notifId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await inboxNetUtils.retrieveNotificationDetail(notifId, token);

    return ResponseHelper().jsonResponse(result);
  }

  requestReadAllNotification(userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await inboxNetUtils.requestReadAllNotification(userId, token);

    return ResponseHelper().jsonResponse(result);
  }
}
