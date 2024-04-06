import 'package:Fast_Team/server/network/inbox_net_utils.dart';
import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:get/get.dart';

class InboxController {
  InboxNetUtils inboxNetUtils = Get.put(InboxNetUtils());

  retrieveAttendanceList(userId) async {
    var result = await inboxNetUtils.retrieveAttendanceList(userId);

    return ResponseHelper().jsonResponse(result);
  }

  retrieveOvertimeList(userId) async {
    var result = await inboxNetUtils.retrieveOvertimeList(userId);

    return ResponseHelper().jsonResponse(result);
  }
  
  retrieveLeaveList(userId) async {
    var result = await inboxNetUtils.retrieveLeaveList(userId);

    return ResponseHelper().jsonResponse(result);
  }
  
  retrieveNotificationList(userId) async {
    var result = await inboxNetUtils.retrieveNotificationList(userId);

    return ResponseHelper().jsonResponse(result);
  }
  
  retrieveNotificationDetail(notifId) async {
    var result = await inboxNetUtils.retrieveNotificationDetail(notifId);

    return ResponseHelper().jsonResponse(result);
  }

  requestReadAllNotification(userId) async {
    var result = await inboxNetUtils.requestReadAllNotification(userId);

    return ResponseHelper().jsonResponse(result);
  }

}