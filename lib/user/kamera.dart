import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Fast_Team/user/controllerApi.dart';
import 'dart:convert';

class KameraPage extends StatefulWidget {
  @override
  KameraPageState createState() => KameraPageState();
}

class KameraPageState extends State<KameraPage> {
  int idUser = 0;
  double lat = 0;
  double long = 0;
  String imgProf = '';
  String kantor = '';
  String aksi = '';
  String shift = '';
  double brightnessValue = 0.5;
  String note = ''; // Tambahkan variabel untuk input note
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final CameraDescription camera = const CameraDescription(
    name: '1',
    lensDirection: CameraLensDirection.front,
    sensorOrientation: 270,
  );

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? routeArguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (routeArguments != null) {
      idUser = routeArguments['idUser'];
      long = routeArguments['long'];
      lat = routeArguments['lat'];
      imgProf = routeArguments['imgProf'] ?? '';
      aksi = routeArguments['aksi'] ?? '';
      kantor = routeArguments['kantor'] ?? '';
      shift = routeArguments['shift'] ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: true, // Set this to true
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              alignment: Alignment.centerLeft, // Align text to the left
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Office: $kantor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8), // Space between "Kantor" and "Masuk"
                  Text(
                    'Shift: $shift',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 0.6,
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (_controller != null &&
                          snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_controller);
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Positioned(
                  bottom: 0, // Adjust the positioning as needed
                  left: 0, // Adjust the positioning as needed
                  right: 0, // Expand the Positioned widget to full width
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Menggunakan MainAxisAlignment.spaceBetween
                          children: [
                            Icon(Icons.wb_sunny, color: Colors.blue[900]),
                            Expanded(
                              // Menggunakan Expanded untuk Slider
                              child: Slider(
                                value: brightnessValue,
                                onChanged: (newValue) {
                                  setState(() {
                                    brightnessValue = newValue;
                                    _controller.setExposureOffset(newValue);
                                  });
                                },
                                min: -1.0,
                                max: 1.0,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Note',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                note = value;
                              });
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: cekGambar,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity,
                                50), // Set the width to fill the screen
                          ),
                          child: Text('Take Picture'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void cekGambar() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("On Process, Please Wait..."),
            ],
          ),
        );
      },
    );

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final File imageFile = File(image.path);
      // Kirim file gambar ke Django untuk perbandingan
      var resp = await kirimCekGambar(imageFile);
      var resp_body = jsonDecode(resp);
      Navigator.pop(context); // Tutup popup loading

      if (resp_body['status'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              imageFile: imageFile,
              resp: resp_body,
              aksi: aksi, // Kirim nilai aksi
              kantor: kantor, // Kirim nilai kantor
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Your Face Not Detected, Who Are You?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .primaryColor, // Gunakan warna utama dari tema aplikasi Anda
                    minimumSize:
                        Size(double.infinity, 50), // Atur lebar tombol ke penuh
                  ),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> kirimCekGambar(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${globalVariable.baseUrl}/compare-image/'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.fields.addAll({
      'url_prof': imgProf,
      'long': long.toString(),
      'lat': lat.toString(),
      'id_user': idUser.toString(),
      'aksi': aksi,
      'base_64': await imageToBase64(imageFile),
      'note': note ?? '',
    });

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      return responseBody;
    } else {
      var responseBody = await response.stream.bytesToString();
      return responseBody;
    }
  }

  Future<String> imageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }
}

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final dynamic resp;
  final String aksi;
  final String kantor;

  ResultScreen({
    required this.imageFile,
    required this.resp,
    required this.aksi,
    required this.kantor,
  });

  @override
  Widget build(BuildContext context) {
    final currentTime = DateFormat('h:mm a').format(DateTime.now());
    final currentDate = DateFormat('d MMM y').format(DateTime.now());
    final day = DateFormat('EEEE', 'en_US').format(DateTime.now());

    // Tetapkan warna dan gambar sesuai dengan status absensi
    Color timeColor;
    String imageAsset;

    if (resp['absensi']['status'] == 'late' ||
        resp['absensi']['status'] == 'to early') {
      timeColor = Colors.red;
      imageAsset = 'assets/img/telat.jpg';
    } else {
      timeColor = Theme.of(context).primaryColor;
      imageAsset = 'assets/img/centangSukses.png';
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 50),
                      child: Image.asset(
                        'assets/img/logopanjang.png',
                        width: 250,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 50),
                      child: Image.asset(
                        imageAsset, // Gunakan imageAsset yang sesuai dengan status
                        width: 250,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Clock $aksi',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: timeColor, // Ganti warna teks currentTime
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '$kantor - $day',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                Text(
                  '08:00 - 16:00',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                Text(
                  currentDate,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 40),
                Text(
                  currentTime,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: timeColor, // Ganti warna teks currentTime
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text('Back To Home'),
                    ),
                    SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/daftarAbsensi');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          side: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Show Log Attendance',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
