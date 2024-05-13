import 'dart:async';
import 'package:Fast_Team/server/base_server.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KameraPage extends StatefulWidget {
  const KameraPage({super.key});

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
    final size = MediaQuery.of(context).size;
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Office: $kantor',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // Space between "Kantor" and "Masuk"
            Text(
              'Shift: $shift',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true, // Set this to true
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                Transform.scale(
                  scale: size.aspectRatio * 2.1,
                  child: FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_controller);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Positioned(
                  bottom: 0, // Adjust the positioning as needed
                  left: 0, // Adjust the positioning as needed
                  right: 0, // Expand the Positioned widget to full width
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: TextFormField(
                            decoration: const InputDecoration(
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
                            minimumSize: const Size(double.infinity,
                                50), // Set the width to fill the screen
                          ),
                          child: const Text('Take Picture'),
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
        return const AlertDialog(
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
      var respBody = jsonDecode(resp);
      // ignore: use_build_context_synchronously
      Navigator.pop(context); 
      if (respBody['status'] == true) {
        // _controller.dispose();
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              imageFile: imageFile,
              resp: respBody,
              aksi: aksi, // Kirim nilai aksi
              kantor: kantor, // Kirim nilai kantor
            ),
          ),
        );
      } else {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Your Face Not Detected, Who Are You?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .primaryColor, // Gunakan warna utama dari tema aplikasi Anda
                    minimumSize:
                        const Size(double.infinity, 50), // Atur lebar tombol ke penuh
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(color: ColorsTheme.white),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<String> kirimCekGambar(File imageFile) async {
    http.MultipartRequest request = await storeImageAbsent(imageFile);

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      return responseBody;
    } else {
      var responseBody = await response.stream.bytesToString();
      return responseBody;
    }
  }

  Future<http.MultipartRequest> storeImageAbsent(File imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseServer.serverUrl}/api_absensi/compare-image/'),
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
      'note': note,
    });
    request.headers.addAll({
    HttpHeaders.authorizationHeader: 'Bearer $token',
  });
    return request;
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

  const ResultScreen({super.key, 
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

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/navigation');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            title: const Text(
              'Result',
              style: TextStyle(
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
            )),
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
                      padding: EdgeInsets.only(top: 40.w),
                      child: Image.asset(
                        'assets/img/logopanjang.png',
                        width: 250.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 5.w),
                      child: Image.asset(
                        imageAsset, // Gunakan imageAsset yang sesuai dengan status
                        width: 230.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  'Clock $aksi',
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                    color: timeColor, // Ganti warna teks currentTime
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  '$kantor - $day',
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900),
                ),
                Text(
                  '08:00 - 16:00',
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900),
                ),
                Text(
                  currentDate,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w300),
                ),
                SizedBox(height: 10.h),
                Text(
                  currentTime,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: timeColor, // Ganti warna teks currentTime
                  ),
                ),
                SizedBox(height: 16.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/navigation');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Back To Home'),
                      ),
                      SizedBox(height: 5.w),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/daftarAbsensi');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Show Log Attendance',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16.w,
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
