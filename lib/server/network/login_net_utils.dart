import 'dart:convert';
import 'package:Fast_Team/server/base_server.dart';
import 'package:http/http.dart' as http;

class LoginNetUtils {
  requestLoginUser(email, password) async {
    Map<String, dynamic> bodyParams = {
      'email': email,
      'password': password,
    };

    var response = await http
        .post(
          Uri.parse("${BaseServer.serverUrl}/api_absensi/user-login/"),
          body: bodyParams,
        )
        .timeout(BaseServer.durationlimit);

    return response;
  }

  requestResetPassword(email) async {
    Map<String, dynamic> bodyParams = {
      'email': email,
    };

    var response = await http.post(
      Uri.parse("${BaseServer.serverUrl}/api_absensi/user/reset_password/"),
      body: bodyParams,
      // headers: {
      //   "Authorization": "Bearer $token",
      // },
    ).timeout(BaseServer.durationlimit);

    return response;
  }

  requestChangePassword(token, id_user, password) async {
    Map<String, dynamic> bodyParams = {
      'id_user': "$id_user",
      'password': password,
    };
     var body = json.encode(bodyParams);
     print(body);
     var response = await http.post(
      Uri.parse("${BaseServer.serverUrl}/api_absensi/change-password/"),
      body: body,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $token",
      },
     ).timeout(BaseServer.durationlimit);
     return response;
  }
}
