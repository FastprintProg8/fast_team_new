// ignore_for_file: prefer_typing_uninitialized_variables, deprecated_member_use

import 'package:Fast_Team/controller/absent_controller.dart';
import 'package:Fast_Team/controller/account_controller.dart';
import 'package:Fast_Team/model/account_information_model.dart';
import 'package:Fast_Team/model/coordinate_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
// ignore: depend_on_referenced_packages
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late SharedPreferences sharedPreferences;
  // ignore: duplicate_ignore
  // ignore: prefer_typing_uninitialized_variables
  var idUser;
  var imgProf;
  var kantor;
  var aksi;
  var shift;

  double lat = 0;
  double long = 0;

  late MapController _mapController;
  double _latitude = 0;
  double _longitude = 0;
  bool gpsIsActive = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    initConstructor();
    loadSharedPreferences();
    _loadLocation();
    _getCurrentLocation();
  }

  initConstructor() {
    idUser = 0.obs;
    imgProf = ''.obs;
    kantor = ''.obs;
    aksi = ''.obs;
    shift = ''.obs;
  }

  Future<void> loadSharedPreferences() async {
    AccountController accountController = Get.put(AccountController());
    var result = await accountController.retriveAccountInformation();
    AccountInformationModel accountModel =
        AccountInformationModel.fromJson(result['details']['data']);
    setState(() {
      idUser = accountModel.id;
      imgProf = accountModel.imgProfUrl;
      kantor = accountModel.cabang;
      shift = accountModel.shift;
    });
  }

  Future<void> _loadLocation() async {
    UserCoordinate coordinate = await retriveCoordinateUser();
    if (coordinate.latitude != null && coordinate.longitude != null) {
      setState(() {
        _latitude = coordinate.latitude!;
        _longitude = coordinate.longitude!;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (isLocationServiceEnabled) {
      Position position = await Geolocator.getCurrentPosition();
      AbsentController absentController = Get.put(AbsentController());
      double latitude = position.latitude;
      double longitude = position.longitude;

      await absentController.storeCoordinateUser(latitude, longitude);

      setState(() {
        _latitude = latitude;
        _longitude = longitude;
         gpsIsActive = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(latitude, longitude), 18.0);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS Not Active'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        gpsIsActive = false;
      });
    }
  }

  void _reloadMap() {
    _loadLocation();
    _getCurrentLocation();
  }

  // ignore: non_constant_identifier_names
  void cek_lokasi() {
    if (gpsIsActive) {
      final List<String> imgProfParts =
          imgProf.split('/'); // Memecah string berdasarkan karakter "/"
      final String imgProfLastPart = imgProfParts.isNotEmpty
          ? imgProfParts.last
          : ''; // Mengambil bagian terakhir, atau string kosong jika tidak ada bagian
      Navigator.pushReplacementNamed(context, '/kamera', arguments: {
        'idUser': idUser,
        'long': _longitude,
        'lat': _latitude,
        'imgProf': imgProfLastPart, // Menggunakan bagian terakhir dari imgProf
        'aksi': aksi,
        'kantor': kantor,
        'shift': shift,
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('GPS not acitve'),
            content: Text(
                'Unable to clock in, please activate navigation to absent. '),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    aksi = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          aksi == 'in' ? 'Clock In' : 'Clock Out',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Custom back button action
            Navigator.pop(context, 'true');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _reloadMap();
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: LatLng(_latitude, _longitude),
          zoom: 0.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 50.0,
                height: 50.0,
                point: LatLng(_latitude, _longitude),
                child: CircleAvatar(
                  radius: 20.0,
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(
                      '$imgProf'), // Menggunakan imgProf dari SharedPreferences
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: ElevatedButton(
          onPressed: cek_lokasi,
          child: Text('Clock $aksi'),
        ),
      ),
    );
  }
}
