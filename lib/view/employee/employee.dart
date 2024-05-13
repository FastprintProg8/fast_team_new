import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import paket http
import 'dart:convert'; // Import library untuk manipulasi JSON


class EmployeePage extends StatefulWidget {
  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Memanggil fungsi untuk mengambil data saat inisialisasi
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://103.29.214.154:9002/api_absensi/user-absen/'));

    if (response.statusCode == 200) {
      // Jika request berhasil, parsing data JSON
      Map<String, dynamic> data = json.decode(response.body);
      
      // Sesuaikan dengan struktur respons API
      List<dynamic> employeesData = data['data'];

      setState(() {
        employees = List<Map<String, dynamic>>.from(employeesData);
        filteredEmployees.addAll(employees);
      });
    } else {
      // Jika request gagal, tampilkan pesan kesalahan
      print('Failed to load data. Error: ${response.statusCode}');
    }
  }

  void filterEmployees(String query) {
    setState(() {
      filteredEmployees = employees
          .where((employee) =>
              employee['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(100.0)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    filterEmployees('');
                  },
                ),
              ),
              onChanged: (value) {
                filterEmployees(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index];
                return Column(
                  children: <Widget>[
                    ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(employee['image']),
                      ),
                      title: Text(
                        employee['nama'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // subtitle: Text(
                      //   employee['email'],
                      //   style: TextStyle(fontSize: 14),
                      // ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:
                                Icon(Icons.phone, size: 24, color: Colors.blue),
                            onPressed: () {
                              // Implement phone call functionality
                            },
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            icon:
                                Icon(Icons.email, size: 24, color: Colors.blue),
                            onPressed: () {
                              // Implement email functionality
                            },
                          ),
                          SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.all(5),
                            child: Image.asset(
                              'assets/img/whatsapp.png',
                              width: 20,
                              height: 20,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.blue,
    ),
    home: EmployeePage(),
  ));
}
