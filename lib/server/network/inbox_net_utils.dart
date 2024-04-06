import 'package:Fast_Team/server/base_server.dart';
import 'package:http/http.dart' as http;

class InboxNetUtils {

  retrieveAttendanceList(userId) async {
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api/pengajuan-absensi/list/$userId/"))
        .timeout(BaseServer.durationlimit);

    return response;
  }

  retrieveOvertimeList(userId) async {
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api/lembur/list/$userId/"))
        .timeout(BaseServer.durationlimit);

    return response;
  }
  
  retrieveLeaveList(userId) async {
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api/izin/list/$userId/"))
        .timeout(BaseServer.durationlimit);

    return response;
  }
  
  retrieveNotificationList(userId) async {
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api/notification/$userId/"))
        .timeout(BaseServer.durationlimit);

    return response;
  }
  
  retrieveNotificationDetail(notifId) async {
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api/notification/detail/$notifId/"))
        .timeout(BaseServer.durationlimit);

    return response;
  }

  requestReadAllNotification(userId) async {
    Map<String, dynamic> bodyParams = {
      'user_id': userId
    };

    var response = await http
      .post(
        Uri.parse("${BaseServer.serverUrl}/api/notification/read-all/"),
        body: bodyParams,
      )
      .timeout(BaseServer.durationlimit);

    return response;
  }
}