import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:Fast_Team/user/controllerApi.dart';
import 'package:Fast_Team/utils/bottom_navigation_bar.dart';

void main() {
  runApp(MaterialApp(
    home: DaftarKehadiranPage(),
  ));
}

class DaftarKehadiranPage extends StatefulWidget {
  @override
  _DaftarKehadiranPageState createState() => _DaftarKehadiranPageState();
}

class _DaftarKehadiranPageState extends State<DaftarKehadiranPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  int _selectedYear = DateTime.now().year;
  bool _isLoading = false;

  int _currentIndex = 0;

  List<Map<String, dynamic>> _absenData = [];

  Future<void> fetchAbsenData(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        '${globalVariable.baseUrl}/user-absen/${date.toString().substring(0, 10)}/'));
    // print(
    //     '${globalVariable.baseUrl}/user-absen/${date.toString().substring(0, 10)}/');
    if (response.statusCode == 200) {
      setState(() {
        final data = json.decode(response.body);
        _absenData = List<Map<String, dynamic>>.from(data['data']);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAbsenData(_selectedDay); // Fetch data for today initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Kehadiran'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.blue[200], // Set your desired background color
              child: TableCalendar(
                firstDay: DateTime.utc(_selectedYear - 1, 1, 1),
                lastDay: DateTime.utc(_selectedYear + 1, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  fetchAbsenData(selectedDay);
                },
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('List Absen',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 16),
            Visibility(
              visible: _isLoading,
              child: CircularProgressIndicator(),
            ),
            Visibility(
              visible: !_isLoading,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Text(
                          'Nama',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      DataColumn(
                          label: Text(
                        'Divisi',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )),
                      DataColumn(
                          label: Text(
                        'Status',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )),
                    ],
                    rows: _absenData.map((absen) {
                      String imageUrl = absen['image'] != ''
                          ? absen['image']
                          : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEPPiaQhO0spbCu9tuFuG3QsKNOjMuplRr2A&usqp=CAU';
                      Color clockInColor =
                          absen['clock_in'] > 0 ? Colors.blue : Colors.grey;
                      Color clockOutColor =
                          absen['clock_out'] > 0 ? Colors.blue : Colors.grey;
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    child: Image.network(
                                      imageUrl,
                                      width: 50,
                                      height: 50,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.error);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${absen['nama']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(Text('${absen['divisi']}')),
                          DataCell(
                            Row(
                              children: [
                                Icon(Icons.input, color: clockInColor),
                                SizedBox(width: 8),
                                Icon(Icons.output, color: clockOutColor),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
