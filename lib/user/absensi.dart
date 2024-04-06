import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:Fast_Team/user/controllerApi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AbsensiPage extends StatefulWidget {
  @override
  _AbsensiPageState createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  Timer? _timer;

  // Data user
  late SharedPreferences sharedPreferences;
  int idUser = 0;
  String email = '';
  int idDivisi = 0;
  String nama = '';
  String divisi = '';
  double posLong = 0;
  double posLat = 0;
  String imgProf = '';

  String currentDate = '';
  String currentTime = '';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 60), (Timer timer) {
      if (mounted) {
        // Check if the widget is still mounted before calling setState
        updateDateTime();
      }
    });
    updateDateTime();
    loadSharedPreferences();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi'),
        elevation: 0,
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Container(
            // color: Colors.blue,
            decoration: const BoxDecoration(color: Colors.blue
                // image: DecorationImage(
                //     image: AssetImage('assets/img/bgWdigetCardAbsen.jpg'),
                //     fit: BoxFit.cover)
                ),
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text(
                          currentTime,
                          style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Center(
                        child: Text(
                          currentDate,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(8))
                    ],
                  ),
                  Container(
                    // untuk container putih
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(bottom: 12),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.blue),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Head Office',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.sticky_note_2_outlined,
                                      size: 20,
                                    ),
                                    Text(
                                      ' 18 Jul 2023 (08:00 17:00)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: _clockIn,
                                child: const Row(
                                  children: <Widget>[
                                    Icon(Icons.input),
                                    Text(' Clock In'),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _clockOut,
                                child: const Row(
                                  children: <Widget>[
                                    Icon(Icons.output),
                                    Text(' Clock Out'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // return CircularProgressIndicator();
                return Text('Loading');
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                List<Map<String, dynamic>> data = snapshot.data!;
                return DataTable(
                  dataRowHeight: 60,
                  columns: [
                    DataColumn(
                      label: Expanded(
                        child: Container(
                            padding: EdgeInsets.only(top: 12),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Daftar Absensi',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/daftarAbsensi');
                                        },
                                        child: Text(
                                          'Lihat Log',
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        )),
                                  ],
                                )
                              ],
                            )),
                      ),
                    ),
                  ],
                  rows: data.map((rowData) {
                    DateTime createdAtDate =
                        DateTime.parse(rowData['created_at']);
                    var waktu = DateFormat('HH:mm').format(createdAtDate);
                    var tgl = DateFormat('dd MMM').format(createdAtDate);
                    return DataRow(cells: [
                      DataCell(
                        InkWell(
                          onTap: () {
                            // Handle the click event here
                            // Access the id from rowData and do something with it
                            // print(rowData);
                            Navigator.pushNamed(context, '/detailAbsensi',
                                arguments: {
                                  'long': rowData['long'],
                                  'lat': rowData['lat'],
                                  'imgBase64': rowData['image64'],
                                  'waktu': rowData['created_at'],
                                  'aksi': rowData['aksi']
                                });

                            print(rowData);
                            // int id = rowData['id'];
                            // print('DataCell clicked with id: $id');
                          },
                          child: Container(
                            // color: Colors.amber,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: waktu,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: '\n$tgl',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              '${rowData['aksi'] == 'in' ? 'Clock In' : 'Clock Out'}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Icon(Icons
                                                .keyboard_arrow_right_sharp),
                                          ],
                                        ))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                );
              } else {
                return Text('No data available');
              }
            },
          ),
        ],
      ),
    );
  }

  void updateDateTime() {
    DateTime now = DateTime.now();
    DateFormat formatterDate = DateFormat('EEEE, d MMMM yyyy');
    DateFormat formatterTime = DateFormat('HH:mm');
    if (mounted) {
      setState(() {
        currentDate = formatterDate.format(now);
        currentTime = formatterTime.format(now);
      });

      // Schedule the function to update time every minute
      Timer(Duration(seconds: 60 - now.second), updateDateTime);
    }
  }

  // Untuk clock in
  void _clockIn() {
    // print('clock in');
    Navigator.pushNamed(context, '/map', arguments: 'in');
  }

  // Untuk clock out
  void _clockOut() {
    // print('clock out');
    Navigator.pushNamed(context, '/map', arguments: 'out');
  }

  Future<void> loadSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      idUser = sharedPreferences.getInt('user-id_user') ?? 0;
      idDivisi = sharedPreferences.getInt('user-id_divisi') ?? 0;
      email = sharedPreferences.getString('user-email') ?? '';
      nama = sharedPreferences.getString('user-nama') ?? '';
      divisi = sharedPreferences.getString('user-divisi') ?? '';
      posLat = sharedPreferences.getDouble('user-position_lat') ?? 0;
      posLong = sharedPreferences.getDouble('user-position_long') ?? 0;
      imgProf = sharedPreferences.getString('user-img_prof') ?? '';
    });
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    try {
      List<Map<String, dynamic>> data = await getLogAbsenSkrg(idUser);
      return data;
    } catch (e) {
      // Tangani error jika ada
      // print(e);
      return [];
    }
  }
}
