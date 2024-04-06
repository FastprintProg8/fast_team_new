import 'package:Fast_Team/server/base_server.dart';
import 'package:http/http.dart' as http;

class EmployeeNetUtils {
  retriveListEmployee() async {
    var path = "${BaseServer.serverUrl}/api_absensi/divisi/";
    var response =
        await http.get(Uri.parse(path)).timeout(BaseServer.durationlimit);
    return response;
  }

  retrieveEmployeeInfo(userId) async {
    var response = await http
        .get(Uri.parse(
            "${BaseServer.serverUrl}/api_absensi/personal-info/$userId/"))
        .timeout(BaseServer.durationlimit);

    return response;
  }

  retrieveEmployeeList() async {
    var response = await http
        .get(Uri.parse(
            "${BaseServer.serverUrl}/api_absensi/user-absen/"))
        .timeout(BaseServer.durationlimit);

    return response;
  }
}
