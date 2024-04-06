import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class globalVariable {
  static const String baseUrl = 'http://103.29.214.154:9002/api_absensi';
}

class LoginUser {
  // static const String apiUrl =
  // 'https://sys.fastprint.co.id/absensi/api/user/login_user';
  String apiUrl = '${globalVariable.baseUrl}/user-login/';
  String apiCsrf = 'http://103.29.214.154:9002/admin/login/?next=/admin/';
  Future<bool> validateUser(String username, String password) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'email': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final dataBody = json.decode(response.body);
      if (dataBody['status'] == 'success') {
        final data = dataBody['data'];
        print(data);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user-id_user', data['id_user']);
        await prefs.setInt('user-id_divisi', data['divisi_id']);
        await prefs.setString('user-email', data['email']);
        await prefs.setString('user-nama', data['nama']);
        // Rawait prefs.setString('user-divisi', data['divisi']);
        await prefs.setString('user-img_prof', data['img_prof']);
        await prefs.setString('user-img_url', data['img_url']);
        await prefs.setString('user-kantor', data['shift']['name']);
        await prefs.setString('user-masuk_awal', data['clock_in']['min']);
        await prefs.setString('user-masuk_akhir', data['clock_in']['max']);
        await prefs.setString('user-keluar_awal', data['clock_out']['min']);
        await prefs.setString('user-keluar_akhir', data['clock_out']['max']);
        // print(data['clock_in']['min']);
        // Format clock_in_time and clock_out_time to "H:mm" format
        final clockInTime = data['shift']['clock_in_time'] != null
            ? formatTime(data['shift']['clock_in_time'])
            : '';
        final clockOutTime = data['shift']['clock_out_time'] != null
            ? formatTime(data['shift']['clock_out_time'])
            : '';
        // print(clockInTime);
        await prefs.setString('user-shift', '$clockInTime - $clockOutTime');
        return true;
      } else {
        return false;
      }
    } else {
      throw Exception('Failed to validate user');
    }
  }
}

String formatTime(String time) {
  // Assuming the input time format is "H:i:s"
  final parts = time.split(':');
  if (parts.length >= 2) {
    return '${parts[0]}:${parts[1]}';
  }
  return time; // Return the original value if it couldn't be formatted
}

Future<List<Map<String, dynamic>>> getListBelumAbsen(
    String tanggal, int idDivisi) async {
  var api_url = '';
  if (idDivisi > 0) {
    api_url = '${globalVariable.baseUrl}/user-absen/${tanggal}/${idDivisi}';
  } else {
    api_url = '${globalVariable.baseUrl}/user-absen/';
  }
  print(api_url);
  final response = await http.get(Uri.parse(api_url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['data']);
  } else {
    throw Exception('Failed to load data from API');
  }
}

Future<List<Map<String, dynamic>>> listDivisi() async {
  var api_url = '${globalVariable.baseUrl}/divisi/';
  final response = await http.get(Uri.parse(api_url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data);
  } else {
    throw Exception('Failed to load data from API');
  }
}

Future<List<Map<String, dynamic>>> getLogAbsenSkrg(int idDivisi) async {
  var api_url = '${globalVariable.baseUrl}/user-absenSkrg/';
  // final response = await http.get(
  //     Uri.parse(api_url));
  final response = await http.post(
    Uri.parse(api_url),
    body: {'id_user': idDivisi.toString()},
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data['data']);
    return List<Map<String, dynamic>>.from(data['data']);
  } else {
    throw Exception('Failed to load data from API');
  }
}

Future<List<Map<String, dynamic>>> fetchAbsensiData(
    int idUser, String blnThn) async {
  var api_url = '${globalVariable.baseUrl}/user-logAbsenBlnThn/';
  final response = await http.post(
    Uri.parse(api_url),
    body: {'idUser': idUser.toString(), 'blnThn': blnThn},
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return List<Map<String, dynamic>>.from(data['data']);
  } else {
    List<Map<String, dynamic>> sampleData = [
      {
        'tanggal': '',
        'jamMasuk': '',
        'jamKeluar': '',
      },
    ];

    return sampleData;
  }
}
