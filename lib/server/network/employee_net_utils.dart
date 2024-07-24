import 'package:Fast_Team/server/base_server.dart';
import 'package:http/http.dart' as http;

class EmployeeNetUtils {
  retriveListEmployee(token) async {
    var path = "${BaseServer.serverUrl}/api_absensi/divisi/";
    var response = await http.get(Uri.parse(path), headers: {
      "Accept": "*/*",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    }).timeout(BaseServer.durationlimit);
    return response;
  }

  retrieveEmployeeInfo(userId) async {
   try {
    var response = await http
        .get(Uri.parse(
            "${BaseServer.serverUrl}/api_absensi/personal-info/$userId/"))
        .timeout(BaseServer.durationlimit);
    return response;
  } catch (e) {
    return {
      "status": 500,
      "details": "Terjadi gangguan ketika mengambil data. Silahkan menghubungi Administrator untuk lebih lanjut."
    };
  }
  }

  retrieveEmployeeList(token) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http
        .get(Uri.parse("${BaseServer.serverUrl}/api_absensi/user-absen/?all=1"),
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
