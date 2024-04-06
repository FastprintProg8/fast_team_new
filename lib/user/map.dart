import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late SharedPreferences sharedPreferences;
  int idUser = 0;
  String imgProf = '';
  String kantor = '';
  String aksi = '';
  String shift = '';

  double lat = 0;
  double long = 0;

  late MapController _mapController;
  double _latitude = 0;
  double _longitude = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    loadSharedPreferences();
    _loadLocation();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    aksi = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Title(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Text(aksi == 'in' ? 'Clock In' : 'Clock Out')],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
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

  Future<void> _loadLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? savedLatitude = prefs.getDouble('user-position_lat');
    double? savedLongitude = prefs.getDouble('user-position_long');
    if (savedLatitude != null && savedLongitude != null) {
      setState(() {
        _latitude = savedLatitude;
        _longitude = savedLongitude;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    double latitude = position.latitude;
    double longitude = position.longitude;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('user-position_lat', latitude);
    await prefs.setDouble('user-position_long', longitude);

    setState(() {
      _latitude = latitude;
      _longitude = longitude;
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _mapController.move(LatLng(latitude, longitude), 18.0);
    });
  }

  Future<void> loadSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      idUser = sharedPreferences.getInt('user-id_user') ?? 0;
      imgProf = sharedPreferences.getString('user-img_url') ??
          ''; // Menggunakan user-img_url
      long = sharedPreferences.getDouble('user-position_long') ?? 0;
      lat = sharedPreferences.getDouble('user-position_lat') ?? 0;
      kantor = sharedPreferences.getString('user-kantor') ?? '';
      shift = sharedPreferences.getString('user-shift') ?? '';
    });
  }

  void _reloadMap() {
    _loadLocation();
    _getCurrentLocation();
  }

  void cek_lokasi() {
    final List<String> imgProfParts =
        imgProf.split('/'); // Memecah string berdasarkan karakter "/"
    final String imgProfLastPart = imgProfParts.isNotEmpty
        ? imgProfParts.last
        : ''; // Mengambil bagian terakhir, atau string kosong jika tidak ada bagian
    Navigator.pushNamed(context, '/kamera', arguments: {
      'idUser': idUser,
      'long': _longitude,
      'lat': _latitude,
      'imgProf': imgProfLastPart, // Menggunakan bagian terakhir dari imgProf
      'aksi': aksi,
      'kantor': kantor,
      'shift': shift,
    });
  }
}
