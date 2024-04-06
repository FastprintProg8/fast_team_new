import 'dart:convert';
import 'dart:io';

import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:Fast_Team/server/base_server.dart';
import 'package:http/http.dart' as http;

class AbsentNetUtils {
  retriveTotalData(userId, date) async {
    var path =
        "${BaseServer.serverUrl}/api_absensi/log-absen/detail-total/$userId/$date/";

    var response =
        await http.get(Uri.parse(path)).timeout(BaseServer.durationlimit);

    return response;
  }

  retriveAbsentData(userId, date) async {
    var path = "${BaseServer.serverUrl}/api_absensi/log-absen/$userId/$date/";

    var response =
        await http.get(Uri.parse(path)).timeout(BaseServer.durationlimit);

    return response;
  }

  retriveDetailAbsensi(userId) async {
    var path = "${BaseServer.serverUrl}/api_absensi/log-absen/detail/$userId/";

    var response =
        await http.get(Uri.parse(path)).timeout(BaseServer.durationlimit);

    return response;
  }

  retriveUserAbsenOnly() async {
    var path = '${BaseServer.serverUrl}/api_absensi/user-absen/';
    var response =
        await http.get(Uri.parse(path)).timeout(BaseServer.durationlimit);
    // print("ini response $response");
    return response;
  }

  retriveUserAbsenDateDevisi(tanggal, idDivisi) async {
    var path =
        '${BaseServer.serverUrl}/api_absensi/user-absen/${tanggal}/${idDivisi}';
    var response = http.get(Uri.parse(path)).timeout(BaseServer.durationlimit);
    return response;
  }
}
