import 'dart:convert';
import 'package:Fast_Team/server/base_server.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PayrollNetUtils {
  requestPayroll(token, userId, date) async {
    var path = "${BaseServer.serverUrl}/api_absensi/header-slip-gaji/";
    var id = userId;
    Map<String, dynamic> bodyParams = {
      "employee_id": '$id',
      "periode": '${date}'
    };
    var body = json.encode(bodyParams);
    var response = await http.post(
      Uri.parse(path),
      body: body,
      headers: {
        "content-type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    return response;
  }

  requestDetailPayroll(token, payroll_id) async {
    var path = "${BaseServer.serverUrl}/api_absensi/detail-slip-gaji/";
    Map<String, dynamic> bodyParams = {
      "payroll_id": '${payroll_id}',
    };
    var body = json.encode(bodyParams);
    var response = await http.post(
      Uri.parse(path),
      body: body,
      headers: {
        "content-type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    return response;
  }
  requestLinkDownloadPayslip(token, payroll_id) async{
    var path = "${BaseServer.serverUrl}/api_absensi/generate-slip-gaji/";
    Map<String, dynamic> bodyParams = {
      "payroll_id": '${payroll_id}',
    };
    var body = json.encode(bodyParams);

    var response = await http.post(
      Uri.parse(path),
      body: body,
      headers: {
        "content-type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    
    return response;
  }
}
