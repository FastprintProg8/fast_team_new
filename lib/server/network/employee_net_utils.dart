import 'package:Fast_Team/server/base_server.dart';
import 'package:http/http.dart' as http;

class EmployeeNetUtils {
  retriveListEmployee(token) async {
    var path = "${BaseServer.serverUrl}/api_absensi/divisi/";
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var response = await http.get(Uri.parse(path), headers: {
      "Accept": "*/*",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    }).timeout(BaseServer.durationlimit);
    return response;
  }

  retrieveEmployeeInfo(userId) async {
    var response = await http
        .get(Uri.parse(
            "${BaseServer.serverUrl}/api_absensi/personal-info/$userId/"))
        .timeout(BaseServer.durationlimit);

    return response;
  }

  retrieveEmployeeList(token) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api_absensi/user-absen/"),
            headers: headers)
        .timeout(BaseServer.durationlimit);

    return response;
  }

  retrieveEmployeeBank() async {
    var url = "${BaseServer.serverUrl}/api_absensi/bank/";
    var response =
        await http.get(Uri.parse(url)).timeout(BaseServer.durationlimit);
    return response;
  }
}
