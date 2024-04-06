import 'dart:convert';

class ResponseHelper {

  jsonResponse(result) {
    Map<String, dynamic> out = {};

    if (result == 'ReqTimeOut') {
      out = {
        "status": 1,
        "details": "Request Time Out",
      };
    } else if (result == "SocketConnProblem") {
      out = {
        "status": 1,
        "details":
            "Koneksi internet anda bermasalah. Silahkan cek jaringan anda kembali.",
      };
    } else if (result.statusCode == 200) {
      out = {
        "status": 200,
        "details": jsonDecode(result.body),
      };

    } else if (result.statusCode == 400) {
      out = {
        "status": 400,
        "details": jsonDecode(result.body),
      };

    } else if (result.statusCode == 401) {
      out = {
        "status": 401,
        "details": jsonDecode(result.body),
      };
    } else if (result.statusCode == 404) {
      out = {
        "status": 404,
        "details":
            "Data mengalami kendala. Silahkan menghubungi Administrator untuk lebih lanjut.",
      };
    } else {
      out = {
        "status": result.statusCode,
        "details":
            "Terjadi gangguan ketika mengambil data. Silahkan menghubungi Administrator untuk lebih lanjut.",
      };
    }

    return out;
  }
}