import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Fast_Team/user/controllerApi.dart';
import 'package:Fast_Team/utils/bottom_navigation_bar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;
import 'package:shimmer/shimmer.dart';
import 'package:sticky_headers/sticky_headers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences sharedPreferences;
  int idUser = 0;
  String email = '';
  int idDivisi = 0;
  String nama = '';
  String divisi = '';
  double posLong = 0;
  double posLat = 0;
  String imgProf = '';
  double lat = 0;
  double long = 0;
  String kantor = '';
  String masukAwal = '00:00:00';
  String masukAkhir = '';
  String keluarAwal = '';
  String keluarAkhir = '';

  int _currentIndex = 0;
  bool isLoading = true;

  String _selectedFilter = 'All';
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<Map<String, dynamic>> divisiList = [];

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
    getCurrentLocation();
    loadData();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    print(permission);
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      lat = position.latitude;
      long = position.longitude;
    });
  }

  Future<void> loadSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences.setDouble('user-position_lat', lat);
      sharedPreferences.setDouble('user-position_long', long);

      idUser = sharedPreferences.getInt('user-id_user') ?? 0;
      idDivisi = sharedPreferences.getInt('user-id_divisi') ?? 0;
      email = sharedPreferences.getString('user-email') ?? '';
      nama = sharedPreferences.getString('user-nama') ?? '';
      divisi = sharedPreferences.getString('user-divisi') ?? '';
      posLat = sharedPreferences.getDouble('user-position_lat') ?? 0;
      posLong = sharedPreferences.getDouble('user-position_long') ?? 0;
      imgProf = sharedPreferences.getString('user-img_prof') ?? '';
      kantor = sharedPreferences.getString('user-kantor') ?? '';
      masukAwal = sharedPreferences.getString('user-masuk_awal') ?? '00:00:00';
      masukAkhir = sharedPreferences.getString('user-masuk_akhir') ?? '00:00:00';
      keluarAwal = sharedPreferences.getString('user-keluar_awal') ?? '';
      keluarAkhir = sharedPreferences.getString('user-keluar_akhir') ?? '';

      print("shared");
      print(sharedPreferences.getString('user-masuk_akhir'));
    });
  }

  Future<void> loadData() async {
    try {
      // Ambil data divisi
      List<Map<String, dynamic>> divisiData = await listDivisi();
      setState(() {
        divisiList = divisiData;
      });

      // Ambil data absensi
      List<Map<String, dynamic>> data = await _fetchData();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchData() async {
    try {
      if (_selectedFilter == 'All') {
        // Panggil getListBelumAbsen tanpa parameter jika "Semua" dipilih
        return await getListBelumAbsen('', 0);
      } else {
        // Panggil getListBelumAbsen dengan parameter sesuai pilihan
        return await getListBelumAbsen(currentDate, int.parse(_selectedFilter));
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> _reloadData() async {
    // Tampilkan loading indicator ketika data sedang dimuat ulang
    setState(() {
      isLoading = true;
    });

    try {
      // Panggil fungsi untuk memuat ulang data
      List<Map<String, dynamic>> data = await _fetchData();

      // Hentikan loading indicator dan perbarui tabel dengan data yang baru
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      // Tangani kesalahan jika terjadi
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clockIn() {
    Navigator.pushNamed(context, '/map', arguments: 'in');
  }

  void _clockOut() {
    Navigator.pushNamed(context, '/map', arguments: 'out');
  }

  String getGreeting() {
    var now = DateTime.now();
    var currentHour = now.hour;

    if (currentHour >= 0 && currentHour < 11) {
      return 'Good Morning, ';
    } else if (currentHour >= 11 && currentHour < 14) {
      return 'Good Afternoon, ';
    } else if (currentHour >= 14 && currentHour < 17) {
      return 'Good Evening, ';
    } else {
      return 'Good Night, ';
    }
  }

  String getCurrentDay() {
    var now = DateTime.now();
    var days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    return days[now.weekday];
  }

  bool isTimeInRange(DateTime time, DateTime start, DateTime end) {
    return time.isAfter(start) && time.isBefore(end);
  }

  @override
  Widget build(BuildContext context) {
    tz.initializeTimeZones();
    final indonesia = tz.getLocation("Asia/Jakarta");
    var now = tz.TZDateTime.now(indonesia);
    String currentDate = DateFormat('yyyy-MM-dd').format(now);
    print("awal $currentDate $masukAwal");
    print("akhir $currentDate $masukAkhir");
    DateTime masukAwalDateTime =
        tz.TZDateTime.parse(indonesia, "$currentDate $masukAwal");
    DateTime masukAkhirDateTime =
        tz.TZDateTime.parse(indonesia, "$currentDate $masukAkhir");
    DateTime keluarAwalDateTime =
        tz.TZDateTime.parse(indonesia, "$currentDate $keluarAwal");
    DateTime keluarAkhirDateTime =
        tz.TZDateTime.parse(indonesia, "$currentDate $keluarAkhir");
    bool canClockIn =
        now.isAfter(masukAwalDateTime) && now.isBefore(masukAkhirDateTime);
    bool canClockOut =
        now.isAfter(keluarAwalDateTime) && now.isBefore(keluarAkhirDateTime);

    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: null,
        body: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            // Wrap the sticky part with StickyHeader widget
            StickyHeader(
              header: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                ),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          text: getGreeting(),
                          style: TextStyle(fontSize: 16),
                          children: <TextSpan>[
                            TextSpan(
                              text: '\n$nama\n',
                              style: TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: "\nDon't forget absent today bruh !!!\n",
                              style: TextStyle(fontSize: 16),
                            ),
                            TextSpan(text: '', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                      Container(
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
                                  bottom: BorderSide(
                                      color: Color.fromARGB(255, 2, 65, 128)),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      '${kantor} ${getCurrentDay()}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.sticky_note_2_outlined,
                                          size: 20,
                                        ),
                                        Text(
                                          ' ${DateFormat('d MMM yyyy (HH:mm)').format(now)}',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: canClockIn ? _clockIn : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: canClockIn
                                          ? Color.fromARGB(255, 2, 65, 128)
                                          : Colors.grey,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.input),
                                        Text(' Clock In'),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: canClockOut ? _clockOut : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: canClockOut
                                          ? Color.fromARGB(255, 2, 65, 128)
                                          : Colors.grey,
                                    ),
                                    child: Row(
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
              content: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildMenuItems(),
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Color.fromARGB(255, 2, 65, 128),
                                  width: 3.0),
                            ),
                          ),
                          padding: EdgeInsets.all(8),
                          child: RichText(
                            text: TextSpan(
                              text: 'List',
                              style: TextStyle(
                                fontSize: 24,
                                color: Color.fromARGB(255, 2, 65, 128),
                                fontWeight: FontWeight.bold,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: ' Absent',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _reloadData,
                          child: Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedFilter,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedFilter = newValue!;
                          });
                          // Panggil loadData untuk mengambil data sesuai pilihan
                          loadData();
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: 'All',
                            child: Text(
                              'All',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ...divisiList.map<DropdownMenuItem<String>>(
                              (Map<String, dynamic> divisi) {
                            return DropdownMenuItem<String>(
                              value: divisi['id'].toString(),
                              child: Text(
                                divisi['name'],
                                style: TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        List<Map<String, dynamic>> data = snapshot.data!;
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 20,
                              headingRowHeight: 40,
                              dataRowHeight: 100,
                              columns: [
                                DataColumn(
                                  label: Text('Photo',
                                      style: TextStyle(fontSize: 20)),
                                ),
                                DataColumn(
                                  label: Text('Name',
                                      style: TextStyle(fontSize: 20)),
                                ),
                                DataColumn(
                                  label: Text('Division',
                                      style: TextStyle(fontSize: 20)),
                                ),
                                DataColumn(
                                  label: Text('Status',
                                      style: TextStyle(fontSize: 20)),
                                ),
                              ],
                              rows: data.map((rowData) {
                                String imageUrl = rowData['image'] != ''
                                    ? rowData['image']
                                    : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEPPiaQhO0spbCu9tuFuG3QsKNOjMuplRr2A&usqp=CAU';
                                Color clockInColor = rowData['clock_in'] > 0
                                    ? Color.fromARGB(255, 2, 65, 128)
                                    : Colors.grey;
                                Color clockOutColor = rowData['clock_out'] > 0
                                    ? Color.fromARGB(255, 2, 65, 128)
                                    : Colors.grey;
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Image.network(
                                        imageUrl,
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        width:
                                            100, // Sesuaikan lebar kolom "Nama" sesuai dengan kebutuhan Anda
                                        child: Text(
                                          '${rowData['nama']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text('${rowData['divisi']}'),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          Icon(Icons.input,
                                              color: clockInColor),
                                          SizedBox(width: 8),
                                          Icon(Icons.output,
                                              color: clockOutColor),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      } else {
                        return Text('No data available');
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTabTapped: (index) {
            if (index == 4) {
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
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.list_alt,
        'title': 'Attendance Log',
        'color': Colors.blue,
        'link': '/daftarAbsensi'
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Attendance List',
        'color': Colors.purple,
        'link': '/daftarKehadiran'
      },
      {
        'icon': Icons.attach_money,
        'title': 'My Payslip',
        'color': Colors.pink,
        'link': ''
      },
      {
        'icon': Icons.history,
        'title': 'Job History',
        'color': Colors.amber,
        'link': '/history'
      },
    ];

    return [
      GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
        ),
        itemCount: menuItems.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              String link = menuItems[index]['link'];
              if (link.isNotEmpty) {
                Navigator.pushNamed(context, link);
              }
            },
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.grey[300], // Warna abu-abu latar belakang
                borderRadius: BorderRadius.circular(10), // Sudut melengkung
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    menuItems[index]['icon'],
                    color: menuItems[index]['color'],
                    size: 24, // Ukuran ikon
                  ),
                  SizedBox(height: 6), // Jarak antara ikon dan teks
                  Text(
                    menuItems[index]['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12), // Ukuran font
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
