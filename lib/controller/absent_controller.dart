import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:Fast_Team/server/local/local_session.dart';
import 'package:Fast_Team/server/network/absent_net_utils.dart';
import 'package:Fast_Team/server/network/employee_net_utils.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsentController extends GetxController {
  LocalSession localSession = Get.put(LocalSession());
  EmployeeNetUtils employeeNetUtils = Get.put(EmployeeNetUtils());
  AbsentNetUtils absentNetUtils = Get.put(AbsentNetUtils());

  storeCoordinateUser(lat, long) async {
    await localSession.storeCoordinateUser(lat, long);
  }

  retriveCoordinateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('user-id_user');
    var userInfo = await employeeNetUtils.retrieveEmployeeInfo(userId);
    double? savedLatitude = prefs.getDouble('user-position_lat');
    double? savedLongitude = prefs.getDouble('user-position_long');

    var imgProf = userInfo['details']['img_prof_url'];
    var kantor = userInfo['details']['lokasi_group']['name'];
    var shift = '08.00 -16.00';
  }

  retriveTotalData(_selectedDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userId = prefs.getInt('user-id_user');
    var date =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}";

    var totalData = await absentNetUtils.retriveTotalData(userId, date);
    return ResponseHelper().jsonResponse(totalData);
  }

  retriveAbsentData(_selectedDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userId = prefs.getInt('user-id_user');
    var date =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}";
    var absentData = await absentNetUtils.retriveAbsentData(userId, date);
    var result = ResponseHelper().jsonResponse(absentData);

    if (result['status'] == 200) {
      final List<dynamic> jsonData = result['details'];
      return jsonData.map((data) {
        final String rawTimeMasuk = data['clock_in']['jam_absen'];
        DateTime? dateTimeMasuk;

        if (rawTimeMasuk != null &&
            RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$')
                .hasMatch(rawTimeMasuk)) {
          dateTimeMasuk = DateTime.parse(rawTimeMasuk).toLocal();
        }

        final String jamMasuk = dateTimeMasuk != null
            ? DateFormat.Hm().format(dateTimeMasuk)
            : '--:--';

        final String rawTimeKeluar = data['clock_out']['jam_absen'];
        DateTime? dateTimeKeluar;

        if (rawTimeKeluar != null &&
            RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$')
                .hasMatch(rawTimeKeluar)) {
          dateTimeKeluar = DateTime.parse(rawTimeKeluar).toLocal();
        }

        final String jamKeluar = dateTimeKeluar != null
            ? DateFormat.Hm().format(dateTimeKeluar)
            : '--:--';

        final DateTime tanggal = DateTime.parse(data['tanggal']);
        final String dateText =
            '${tanggal.day} ${DateFormat.MMM().format(tanggal)}';

        return {
          'dateText': dateText,
          'dateColor': tanggal.weekday == DateTime.sunday
              ? ColorsTheme.lightRed
              : ColorsTheme.black,
          'id_masuk': data['clock_in']['id_absen'] != null
              ? data['clock_in']['id_absen']
              : null,
          'id_keluar': data['clock_out']['id_absen'] != null
              ? data['clock_out']['id_absen']
              : null,
          'jamMasuk': jamMasuk,
          'jamKeluar': jamKeluar,
          'isSunday': tanggal.weekday == DateTime.sunday,
        };
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
    
  }
  retriveDetailAbsenst(userId)async{

    var detailAbsenst = await absentNetUtils.retriveDetailAbsensi(userId);
    return ResponseHelper().jsonResponse(detailAbsenst);
  
  }
}
