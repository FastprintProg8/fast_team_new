import 'package:Fast_Team/server/network/login_net_utils.dart';
import 'package:Fast_Team/server/network/employee_net_utils.dart';
import 'package:Fast_Team/server/local/local_session.dart';
import 'package:Fast_Team/helpers/response_helper.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  LoginNetUtils loginNetUtils = Get.put(LoginNetUtils());
  EmployeeNetUtils employeeNetUtils = Get.put(EmployeeNetUtils());
  LocalSession localSession = Get.put(LocalSession());

  static var idUser = 0.obs;
  static var idDivisi = 0.obs;
  static var email = "".obs;
  static var nama = "".obs;
  static var fullNama = "".obs;
  static var divisi = "".obs;
  static var posLat = 0.0.obs;
  static var posLong = 0.0.obs;
  static var imgProf = "".obs;
  static var imgUrl = "".obs;
  static var kantor = "".obs;
  static var masukAwal = "".obs;
  static var masukAkhir = "".obs;
  static var keluarAwal = "".obs;
  static var keluarAkhir = "".obs;
  static var statusLogin = "".obs;

  static var isLogin = "".obs;

  requestLoginUser(email, password) async {
    var result = await loginNetUtils.requestLoginUser(email, password);

    return ResponseHelper().jsonResponse(result);
  }

  requestResetPassword(email) async {
    var result = await loginNetUtils.requestResetPassword(email);

    return ResponseHelper().jsonResponse(result);
  }

  retrieveEmployeeInfo(userId) async {
    var result = await employeeNetUtils.retrieveEmployeeInfo(userId);

    return ResponseHelper().jsonResponse(result);
  }

  storeUserInfo(jsonData) async {
    await localSession.storeUserInfo(jsonData);
  }

  storeToken(jsonData) async {
    await localSession.storeUserToken(jsonData);
  }

  storeEmployeeInfo(jsonData) async {
    await localSession.storeEmployeeInfo(jsonData);
  }

  storeJsonUser(jsonData) async {
    await localSession.storeJsonUser(jsonData);
  }

  clearData() async {
    await localSession.clearData();
    idUser.value = 0;
    email.value = '';
    idDivisi.value = 0;
    nama.value = '';
    fullNama.value = '';
    divisi.value = '';
    posLong.value = 0;
    posLat.value = 0;
    imgProf.value = '';
    kantor.value = '';
    masukAwal.value = '';
    masukAkhir.value = '';
    keluarAwal.value = '';
    keluarAkhir.value = '';
  }
}
