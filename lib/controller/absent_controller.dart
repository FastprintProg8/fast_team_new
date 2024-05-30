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
    prefs.getInt('user-id_user');
    prefs.getDouble('user-position_lat');
    prefs.getDouble('user-position_long');

  }

  retriveTotalData(selectedDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userId = prefs.getInt('user-id_user');
    var token = prefs.getString('token');

    var date =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}";

    var totalData = await absentNetUtils.retriveTotalData(token, userId, date);
    return ResponseHelper().jsonResponse(totalData);
  }

  retriveAbsentData(selectedDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var userId = prefs.getInt('user-id_user');
    var token = prefs.getString('token');
    var date =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}";
    var absentData =
        await absentNetUtils.retriveAbsentData(token, userId, date);
    var result = ResponseHelper().jsonResponse(absentData);
    
    if (result['status'] == 200) {
      final List<dynamic> jsonData = result['details'];
      return jsonData.map((data) {
        List<dynamic> clock_in = data['clock_in'];
        List<dynamic> clock_out = data['clock_out'];
        

        clock_in.asMap().forEach((index, item) {
          DateTime? dateTimeMasuk;
          final String rawTimeMasuk = item['jam_absen'];
          if (RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$')
                  .hasMatch(rawTimeMasuk) || RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\Z$')
                  .hasMatch(rawTimeMasuk)) {
            dateTimeMasuk = DateTime.parse(rawTimeMasuk).toLocal();
          }
          print(dateTimeMasuk);
          final String jamMasuk = dateTimeMasuk != null
              ? DateFormat.Hm().format(dateTimeMasuk)
              : '--:--';
          clock_in[index]['jam_absen'] = jamMasuk;
          
        });

        clock_out.asMap().forEach((index, item) {
          DateTime? dateTimeKeluar;
          final String rawTimeKeluar = item['jam_absen'];

          if (RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$')
                  .hasMatch(rawTimeKeluar) || RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\Z$')
                  .hasMatch(rawTimeKeluar)) {
            dateTimeKeluar = DateTime.parse(rawTimeKeluar).toLocal();
          }
          final String jamKeluar = dateTimeKeluar != null
              ? DateFormat.Hm().format(dateTimeKeluar)
              : '--:--';
          clock_out[index]['jam_absen'] = jamKeluar;
        });
          // print(clock_out);

        // final String rawTimeKeluar = data['clock_out'][0]['jam_absen'];
        // DateTime? dateTimeKeluar;

        // if (rawTimeKeluar != null &&
        //     RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$')
        //         .hasMatch(rawTimeKeluar)) {
        //   dateTimeKeluar = DateTime.parse(rawTimeKeluar).toLocal();
        // }

        // final String jamKeluar = dateTimeKeluar != null
        //     ? DateFormat.Hm().format(dateTimeKeluar)
        //     : '--:--';

        final DateTime tanggal = DateTime.parse(data['tanggal']);
        final String dateText =
            '${tanggal.day} ${DateFormat.MMM().format(tanggal)}';

        return {
          'dateText': dateText,
          'dateColor': tanggal.weekday == DateTime.sunday
              ? ColorsTheme.lightRed
              : ColorsTheme.black,
          'id_masuk': data['clock_in'][0]['id_absen'],
          'id_keluar': data['clock_out'][0]['id_absen'],
          'jamMasuk': clock_in,
          'jamKeluar': clock_out,
          'isSunday': tanggal.weekday == DateTime.sunday,
        };
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  retriveDetailAbsenst(userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var detailAbsenst =
        await absentNetUtils.retriveDetailAbsensi(token, userId);
    return ResponseHelper().jsonResponse(detailAbsenst);
  }
}
