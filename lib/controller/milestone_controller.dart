import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:Fast_Team/server/network/job_net_utils.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MilestoneController {
  JobNetUtils jobNetUtils = Get.put(JobNetUtils());

  retrieveJobHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var userId = prefs.getInt('user-id_user');
    var result = await jobNetUtils.retriveJobHistory(userId,token);
   
    return ResponseHelper().jsonResponse(result);
  }
}
