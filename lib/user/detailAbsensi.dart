import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/gestures.dart';
import 'package:Fast_Team/utils/bottom_navigation_bar.dart';
import 'package:Fast_Team/user/controllerApi.dart';

class DetailAbsensiPage extends StatefulWidget {
  @override
  _DetailAbsensiPageState createState() => _DetailAbsensiPageState();
}

class _DetailAbsensiPageState extends State<DetailAbsensiPage> {
  late MapController _mapController;
  int id = 0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  String? imgbase64;
  String aksi = '';
  String createdAt = '';
  String lokasi = '-';
  bool imageValid = true;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    id = ModalRoute.of(context)!.settings.arguments as int;

    initializeDateFormatting("id_ID", null).then((_) {
      fetchData(id).then((data) {
        setState(() {
          _latitude = double.parse(data['lat']);
          _longitude = double.parse(data['long']);
          aksi = data['aksi'];

          try {
            final utcDateTime = DateTime.parse(data['jam_absen']);
            final offset = Duration(hours: 7);
            final indonesiaDateTime = utcDateTime.add(offset);

            final format = DateFormat('yyyy-MM-dd HH:mm:ss', 'id_ID');
            createdAt = format.format(indonesiaDateTime);
            imgbase64 = data['image64'];
            lokasi = data['lokasi'];
          } catch (error) {
            imgbase64 = null;
            imageValid = false;
            print('Error decoding image: $error');
          }

          _isMapReady = true;
        });
      }).catchError((error) {
        print('Error: $error');
      });
    });
  }

  Future<Map<String, dynamic>> fetchData(int id) async {
    final response = await http
        .get(Uri.parse('${globalVariable.baseUrl}/log-absen/detail/$id/'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: <Widget>[
              Text('tes'),
            ],
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            height: 200,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.blue,
                    child: Center(
                      child: _isMapReady
                          ? FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                center: LatLng(_latitude, _longitude),
                                zoom: 14.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 80.0,
                                      height: 80.0,
                                      point: LatLng(_latitude, _longitude),
                                      child: Container(
                                        child: Icon(
                                          Icons.location_on,
                                          size: 35.0,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : CircularProgressIndicator(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: buildImageWidget(),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Waktu ${aksi == 'in' ? 'clock in' : 'clock out'}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '\n$createdAt',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Shift',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '\n$lokasi',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Jadwal Shift',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '\n$lokasi',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Lokasi',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '\nLihat Lokasi',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _showLocationMapDialog(context);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Catatan',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '\n -',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTabTapped: (index) {
          if (index == 0) {
            Navigator.of(context).pushNamed('/home');
          } else if (index == 4) {
            Navigator.of(context).pushNamed('/profile');
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/request');
          } else if (index == 3) {
            Navigator.of(context).pushNamed('/inbox');
          } else if (index == 1) {
            Navigator.of(context).pushNamed('/employee');
          }
        },
      ),
    );
  }

  Widget buildImageWidget() {
    if (imageValid && imgbase64 != null) {
      return ImageFromBase64(imgbase64!);
    } else {
      return Text('Invalid image data');
    }
  }

  void _showLocationMapDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            height: 500, // Atur tinggi sesuai kebutuhan
            child: FlutterMap(
              mapController: MapController(),
              options: MapOptions(
                center: LatLng(_latitude, _longitude),
                zoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 100.0,
                      height: 100.0,
                      point: LatLng(_latitude, _longitude),
                      child: Container(
                        child: Icon(
                          Icons.location_on,
                          size: 35.0,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text(
                'Tutup',
                style: TextStyle(
                  color: Colors.white, // Warna teks
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context)
                    .primaryColor, // Warna latar belakang sesuai dengan tema
              ),
            ),
          ],
        );
      },
    );
  }
}

class ImageFromBase64 extends StatelessWidget {
  final String base64String;

  ImageFromBase64(this.base64String);

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;

    try {
      bytes = base64.decode(base64String);
    } catch (e) {
      print('Error decoding image: $e');
    }

    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
      );
    } else {
      return Text('Invalid image data');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: DetailAbsensiPage(),
  ));
}
