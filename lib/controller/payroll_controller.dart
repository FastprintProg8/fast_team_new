import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:Fast_Team/server/network/payroll_net_utils.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayrollController {
  PayrollNetUtils payrollNetUtils = Get.put(PayrollNetUtils());
  retrivePayroll(date) async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
    var userEmployeeId = prefs.getInt('user-employee_id');
    var token = prefs.getString('token');
    var result = await payrollNetUtils.requestPayroll(token,userEmployeeId, date);
    
    return ResponseHelper().jsonResponse(result);
  }

  retriveDetailPayroll(payrollId)async{
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await payrollNetUtils.requestDetailPayroll(token,payrollId);
    
    return  ResponseHelper().jsonResponse(result);
  }

  retriveLinkDownloadPayslip(payroll_id)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var result = await payrollNetUtils.requestLinkDownloadPayslip(token, payroll_id);
    return ResponseHelper().jsonResponse(result);
  }
}
