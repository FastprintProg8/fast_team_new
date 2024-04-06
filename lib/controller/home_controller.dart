import 'dart:convert';

import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:Fast_Team/server/local/local_session.dart';
import 'package:Fast_Team/server/network/absent_net_utils.dart';
import 'package:Fast_Team/server/network/employee_net_utils.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  LocalSession localSession = Get.put(LocalSession());
  EmployeeNetUtils employeeNetUtils = Get.put(EmployeeNetUtils());
  AbsentNetUtils absentNetUtils = Get.put(AbsentNetUtils());

  retriveListEmployee() async {
    var result = await employeeNetUtils.retriveListEmployee();
    return ResponseHelper().jsonResponse(result);
  }

  getListBelumAbsen(String tanggal, int idDivisi) async {
    final response;
    if (idDivisi > 0) {
      response =
          await absentNetUtils.retriveUserAbsenDateDevisi(tanggal, idDivisi);
    } else {
      response = await absentNetUtils.retriveUserAbsenOnly();
    }
    var result = ResponseHelper().jsonResponse(response);
    if (result['status'] == 200) {
      return result;
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  listDivisi() async {
    final response = await employeeNetUtils.retriveListEmployee();
    var result = ResponseHelper().jsonResponse(response);
    // print(result);
    if (result['status'] == 200) {
      return result;
    } else {
      throw Exception('Failed to load data from API');
    }
  }
}
