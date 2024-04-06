import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fast_Team/user/controllerApi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DaftarAbsensiPage(),
    );
  }
}

class DaftarAbsensiPage extends StatefulWidget {
  @override
  _DaftarAbsensiPageState createState() => _DaftarAbsensiPageState();
}

class _DaftarAbsensiPageState extends State<DaftarAbsensiPage> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _data = [];
  int userId = 0;
  int absenCount = 0;
  int lateClockInCount = 0;
  int earlyClockInCount = 0;
  int noClockInCount = 0;
  int noClockOutCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId().then((_) {
      _loadDataForSelectedMonth();
    });
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user-id_user') ?? 0;
  }

  Future<void> _loadDataForSelectedMonth() async {
    final data = await fetchData(_selectedDate);
    final totalData = await fetchTotalData(userId,
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}');
    setState(() {
      _data = data;
      absenCount = totalData['absen'];
      lateClockInCount = totalData['late_clock_in'];
      earlyClockInCount = totalData['late_clock_out'];
      noClockInCount = totalData['no_clock_in'];
      noClockOutCount = totalData['no_clock_out'];
    });
  }

  // Tambahkan metode untuk memanggil API total data
  Future<Map<String, dynamic>> fetchTotalData(int userId, String date) async {
    final Uri url = Uri.parse(
        '${globalVariable.baseUrl}/log-absen/detail-total/$userId/$date/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load total data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchData(DateTime selectedDate) async {
    final Uri url = Uri.parse(
        '${globalVariable.baseUrl}/log-absen/$userId/${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) {
        final String rawTimeMasuk = data['clock_in']['jam_absen'];
        DateTime? dateTimeMasuk;

        if (rawTimeMasuk != null &&
            RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$')
                .hasMatch(rawTimeMasuk)) {
          dateTimeMasuk = DateTime.parse(rawTimeMasuk).toLocal();
        }

        final String jamMasuk = dateTimeMasuk != null
            ? DateFormat.Hm().format(dateTimeMasuk)
            : '--:--';

        final String rawTimeKeluar = data['clock_out']['jam_absen'];
        DateTime? dateTimeKeluar;

        if (rawTimeKeluar != null &&
            RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$')
                .hasMatch(rawTimeKeluar)) {
          dateTimeKeluar = DateTime.parse(rawTimeKeluar).toLocal();
        }

        final String jamKeluar = dateTimeKeluar != null
            ? DateFormat.Hm().format(dateTimeKeluar)
            : '--:--';

        final DateTime tanggal = DateTime.parse(data['tanggal']);
        final String dateText =
            '${tanggal.day} ${DateFormat.MMM().format(tanggal)}';

        return {
          'dateText': dateText,
          'dateColor':
              tanggal.weekday == DateTime.sunday ? Colors.red : Colors.black,
          'id_masuk': data['clock_in']['id_absen'] != null
              ? data['clock_in']['id_absen']
              : null,
          'id_keluar': data['clock_out']['id_absen'] != null
              ? data['clock_out']['id_absen']
              : null,
          'jamMasuk': jamMasuk,
          'jamKeluar': jamKeluar,
          'isSunday': tanggal.weekday == DateTime.sunday,
        };
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    showMonthPicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1, 1),
      lastDate: DateTime(DateTime.now().year + 1, 12),
    ).then((date) async {
      if (date != null) {
        setState(() {
          _selectedDate = date;
          
        });
        await _loadDataForSelectedMonth();
      }
    });
  }

  Widget _buildStatusItem(String title, String count, double fontSize) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          count,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMM().format(_selectedDate);
    int daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Absensi'),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20.0),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: TextButton(
              onPressed: () {
                _selectMonth(context);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                backgroundColor: Colors.transparent,
                side: BorderSide(color: Colors.black, width: 1.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        size: 24,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        formattedDate,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            constraints:
                BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF42A5F5),
                      Color(0xFF1976D2),
                      Color(0xFF0D47A1)
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _buildStatusItem('Absen', '$absenCount', 14),
                        _buildStatusItem(
                            'Late Clock In', '$lateClockInCount', 14),
                        _buildStatusItem(
                            'Early Clock In', '$earlyClockInCount', 14),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _buildStatusItem('No Clock In', '$noClockInCount', 14),
                        _buildStatusItem(
                            'No Clock Out', '$noClockOutCount', 14),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 5.0),
          Expanded(
            child: ListView.separated(
              itemCount: daysInMonth,
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: 10), // Jarak antara setiap item
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> item =
                    _data.isNotEmpty ? _data[index] : {};
                String tanggal = (index + 1).toString();
                bool isSunday = item['isSunday'] ?? false;
                Color dateColor =
                    item['dateColor'] ?? (isSunday ? Colors.red : Colors.black);
                String dateText = item['dateText'] ??
                    (isSunday
                        ? '$tanggal ${DateFormat.MMM().format(_selectedDate)}\nHari Libur'
                        : '$tanggal ${DateFormat.MMM().format(_selectedDate)}');

                return AbsensiListItem(
                  dateText: dateText,
                  dateColor: dateColor,
                  jamMasuk: item['jamMasuk'] ?? '--:--',
                  jamKeluar: item['jamKeluar'] ?? '--:--',
                  idMasuk: item['id_masuk'] ?? 0,
                  idKeluar: item['id_keluar'] ?? 0,
                  isSunday: isSunday,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AbsensiListItem extends StatefulWidget {
  final String dateText;
  final Color dateColor;
  final String jamMasuk;
  final String jamKeluar;
  final int idMasuk;
  final int idKeluar;
  final bool isSunday;

  AbsensiListItem({
    required this.dateText,
    required this.dateColor,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.idMasuk,
    required this.idKeluar,
    required this.isSunday,
  });

  @override
  _AbsensiListItemState createState() => _AbsensiListItemState();
}

class _AbsensiListItemState extends State<AbsensiListItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.isSunday ? Colors.grey[200] : Colors.white,
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  widget.dateText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.dateColor,
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          right: 10), // Jeda 10px di antara kedua teks
                      child: Text(
                        widget.jamMasuk,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      widget.jamKeluar,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.dateColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        isExpanded ? Icons.remove : Icons.add,
                        size: 16,
                        color: widget.dateColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: <Widget>[
                  Divider(), // Divider added here
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/detailAbsensi',
                          arguments: widget.idMasuk);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Jam Masuk:',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          widget.jamMasuk,
                          style: TextStyle(fontSize: 14),
                        ),
                        Icon(
                          Icons.arrow_right_rounded,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Divider(), // Divider added here
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/detailAbsensi',
                          arguments: widget.idKeluar);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Jam Keluar:',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          widget.jamKeluar,
                          style: TextStyle(fontSize: 14),
                        ),
                        Icon(
                          Icons.arrow_right_rounded,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
