import "dart:convert";
import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:Fast_Team/server/network/payroll_net_utils.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayrollController {
  PayrollNetUtils payrollNetUtils = Get.put(PayrollNetUtils());
  retrivePayroll( date) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
    var userEmployeeId = prefs.getInt('user-employee_id');
    var result = await payrollNetUtils.requestPayroll(userEmployeeId, date);
    return ResponseHelper().jsonResponse(result);
  }

  retriveDetailPayroll(payroll_id)async{
    var result = await payrollNetUtils.requestDetailPayroll(payroll_id);
    return  ResponseHelper().jsonResponse(result);
  }
}
