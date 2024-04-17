import 'dart:convert';

import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:Fast_Team/server/local/local_session.dart';
import 'package:Fast_Team/server/network/absent_net_utils.dart';
import 'package:Fast_Team/server/network/employee_net_utils.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  LocalSession localSession = Get.put(LocalSession());
  EmployeeNetUtils employeeNetUtils = Get.put(EmployeeNetUtils());
  AbsentNetUtils absentNetUtils = Get.put(AbsentNetUtils());

  retriveListEmployee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    print(token);
    var result = await employeeNetUtils.retriveListEmployee(token);
    return ResponseHelper().jsonResponse(result);
  }

  getListBelumAbsen(String tanggal, int idDivisi) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    final response;
    if (idDivisi > 0) {
      response = await absentNetUtils.retriveUserAbsenDateDevisi(
          token, tanggal, idDivisi);
    } else {
      response = await absentNetUtils.retriveUserAbsenOnly(token);
    }
    var result = ResponseHelper().jsonResponse(response);
    if (result['status'] == 200) {
      return result;
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  listDivisi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    final response = await employeeNetUtils.retriveListEmployee(token);
    var result = ResponseHelper().jsonResponse(response);
    if (result['status'] == 200) {
      return result;
    } else {
      throw Exception('Failed to load data from API');
    }
  }
}
