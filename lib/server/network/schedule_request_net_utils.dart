import 'package:Fast_Team/server/base_server.dart';
import 'package:http/http.dart' as http;
import 'dart:io'; 
import 'package:http_parser/http_parser.dart';

class ScheduleRequestNetUtils {

  retrieveLeaveOption() async {
    
    var response = await http
      .get(
        Uri.parse("${BaseServer.serverUrl}/api/cuti/opsi/")
      )
      .timeout(BaseServer.durationlimit);

    return response;
  }

  insertAbsentSubmission(Map<String, dynamic> bodyParams) async {
    print(bodyParams);
    var response = await http
      .post(
        Uri.parse("${BaseServer.serverUrl}/api_absensi/user-pengajuanAbsensi/"),
        body: bodyParams,
      )
      .timeout(BaseServer.durationlimit);

    return response;
  }

   insertOvertimeSubmission(Map<String, dynamic> bodyParams) async {
    
    var response = await http
      .post(
        Uri.parse("${BaseServer.serverUrl}/api/lembur/"),
        body: bodyParams,
      )
      .timeout(BaseServer.durationlimit);

    return response;
  }

  insertLeaveSubmission(Map<String, dynamic> bodyParams, file) async {
    
    var response = http
      .MultipartRequest(
        'POST',
        Uri.parse("${BaseServer.serverUrl}/api/cuti/"),
      );

    response.headers['Content-Type'] = 'application/json';
    response.fields['user'] = bodyParams['userId'];
    response.fields['cuti_id'] = bodyParams['cuti_id'];
    response.fields['tanggal'] = bodyParams['tanggal'];
    response.fields['time'] = bodyParams['time'] + ':00';
    response.fields['note'] = bodyParams['note'];

    if (file != null) {
      final multipartFile = http.MultipartFile(
        'bukti',
        file!.readAsBytes().asStream(),
        file!.lengthSync(),
        filename: 'image.jpg', // Nama file yang sesuai
        contentType: MediaType('image', 'jpeg'), // Sesuaikan dengan jenis gambar yang diunggah
      );
      response.files.add(multipartFile);
    }

    return response.send();
  }
}