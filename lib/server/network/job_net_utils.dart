import 'package:http/http.dart' as http;
import 'package:Fast_Team/server/base_server.dart';

class JobNetUtils {
  retriveJobHistory(userId, token) async {
    var path = "${BaseServer.serverUrl}/api_absensi/job-history/${userId}/";
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var response = await http.get(
      Uri.parse(path),
      headers: headers,
    );

    return response;
  }
}
