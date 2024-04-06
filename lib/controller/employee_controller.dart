import 'package:Fast_Team/server/network/employee_net_utils.dart';
import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:get/get.dart';

class EmployeeController {
  EmployeeNetUtils employeeNetUtils = Get.put(EmployeeNetUtils());

  retrieveEmployeeList() async {
    var result = await employeeNetUtils.retrieveEmployeeList();

    return ResponseHelper().jsonResponse(result);
  }

}