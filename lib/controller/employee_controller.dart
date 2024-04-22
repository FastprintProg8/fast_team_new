import 'package:Fast_Team/server/network/employee_net_utils.dart';
import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeController {
  EmployeeNetUtils employeeNetUtils = Get.put(EmployeeNetUtils());

  retrieveEmployeeList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await employeeNetUtils.retrieveEmployeeList(token);
    // print(ResponseHelper().jsonResponse(result));

    return ResponseHelper().jsonResponse(result);
  }
}
