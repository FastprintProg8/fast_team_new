import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Fast_Team/server/base_server.dart';
class JobNetUtils{
  
  retriveJobHistory(userId) async {

    var path = "${BaseServer.serverUrl}/api_absensi/job-history/${userId}/";

    var response = await http.get(
      Uri.parse(path),
    );

    return response;
  }
}