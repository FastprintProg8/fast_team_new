import 'package:Fast_Team/server/base_server.dart';
import 'package:http/http.dart' as http;

class InboxNetUtils {

  retrieveAttendanceList(userId,token) async {
     Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api_absensi/pengajuan-absensi/list/$userId/"),headers: headers)
        .timeout(BaseServer.durationlimit);

    return response;
  }

  retrieveOvertimeList(userId,token) async {
     Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api_absensi/lembur/list/$userId/"),headers: headers)
        .timeout(BaseServer.durationlimit);

    return response;
  }
  
  retrieveLeaveList(userId,token) async {
     Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api_absensi/izin/list/$userId/"),headers: headers)
        .timeout(BaseServer.durationlimit);

    return response;
  }
  
  retrieveNotificationList(userId,token) async {
     Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api_absensi/notification/$userId/"),headers: headers)
        .timeout(BaseServer.durationlimit);

    return response;
  }
  
  retrieveNotificationDetail(notifId,token) async {
     Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api_absensi/notification/detail/$notifId/"),headers: headers)
        .timeout(BaseServer.durationlimit);

    return response;
  }

  requestReadAllNotification(userId,token) async {
     Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> bodyParams = {
      'user_id': userId
    };

    var response = await http
      .post(
        Uri.parse("${BaseServer.serverUrl}/api_absensi/notification/read-all/"),
        headers: headers,
        body: bodyParams,
      )
      .timeout(BaseServer.durationlimit);

    return response;
  }
}