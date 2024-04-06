import 'package:Fast_Team/controller/account_controller.dart';
import 'package:Fast_Team/model/account_information_model.dart';
import 'package:Fast_Team/server/network/employee_net_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import necessary package

class UserCoordinate {
  final double? latitude;
  final double? longitude;

  UserCoordinate({
    required this.latitude,
    required this.longitude,
  });
}

Future<UserCoordinate> retriveCoordinateUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double? savedLatitude = prefs.getDouble('user-position_lat');
  double? savedLongitude = prefs.getDouble('user-position_long');

  // Create a UserInfo object with the retrieved values
  UserCoordinate userInfoObject = UserCoordinate(
    latitude: savedLatitude,
    longitude: savedLongitude,
  );

  return userInfoObject;
}
