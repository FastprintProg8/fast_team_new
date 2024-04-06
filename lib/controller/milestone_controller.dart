import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:Fast_Team/server/network/job_net_utils.dart';
import 'package:get/get.dart';

class MilestoneController {
  JobNetUtils jobNetUtils = Get.put(JobNetUtils());

  retrieveJobHistory(userId) async {
    var result = await jobNetUtils.retriveJobHistory(userId);
   
    return ResponseHelper().jsonResponse(result);
  }
}
