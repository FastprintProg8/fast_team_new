import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Fast_Team/server/base_server.dart';
class HomeNetUtils{
  retrieveHomeDashboard(token,customerId) async {

    var path = "${BaseServer.serverUrl}/index.php?c=c_customer&m=customer_app_list&cust_id=$customerId";

    var response = await http.get(
      Uri.parse(path),
      headers: {
        "content-type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return response;
  }
}