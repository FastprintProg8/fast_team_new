import 'package:Fast_Team/server/base_server.dart';
import 'package:http/http.dart' as http;

class AbsentNetUtils {
  retriveTotalData(token, userId, date) async {
    var path =
        "${BaseServer.serverUrl}/api_absensi/log-absen/detail-total/$userId/$date/";
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http
        .get(Uri.parse(path), headers: headers)
        .timeout(BaseServer.durationlimit);

    return response;
  }

  retriveAbsentData(token, userId, date) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var path = "${BaseServer.serverUrl}/api_absensi/log-absen/$userId/$date/";

    var response = await http
        .get(Uri.parse(path), headers: headers)
        .timeout(BaseServer.durationlimit);
    
    return response;
  }

  retriveDetailAbsensi(token, userId) async {
    var path = "${BaseServer.serverUrl}/api_absensi/log-absen/detail/$userId/";
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http
        .get(Uri.parse(path), headers: headers)
        .timeout(BaseServer.durationlimit);

    return response;
  }

  retriveUserAbsenOnly(token) async {
    var path = '${BaseServer.serverUrl}/api_absensi/user-absen/';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http
        .get(Uri.parse(path), headers: headers)
        .timeout(BaseServer.durationlimit);
    // print("ini response $response");
    return response;
  }

  retriveUserAbsenDateDevisi(token, tanggal, idDivisi) async {
    var path =
        '${BaseServer.serverUrl}/api_absensi/user-absen/${tanggal}/${idDivisi}/';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = http
        .get(Uri.parse(path), headers: headers)
        .timeout(BaseServer.durationlimit);
    return response;
  }
}
