import 'dart:convert';
import 'package:Fast_Team/server/base_server.dart';
import 'package:Fast_Team/server/local/local_session.dart';
import 'package:get/get.dart';
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

  requestResetPassword(token, email) async {
    Map<String, dynamic> bodyParams = {
      'email': email,
    };

    var response = await http.post(
      Uri.parse("${BaseServer.serverUrl}/api/user/reset_password/"),
      body: bodyParams,
      headers: {
        "Authorization": "Bearer $token",
      },
    ).timeout(BaseServer.durationlimit);

    return response;
  }
}
