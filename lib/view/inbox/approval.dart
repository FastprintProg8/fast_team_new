import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: ApprovalPage(),
  ));
}

class ApprovalPage extends StatefulWidget {
  @override
  _ApprovalPageState createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  List<ApprovalItem> approvalItems = [];

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is created.
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userId = sharedPreferences.getInt('user-id_user') ?? 0;
    String arguments = ModalRoute.of(context)!.settings.arguments as String;

    String apiUrl = 'http://103.29.214.154:9002/api/$arguments/list/$userId/';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(jsonData);
        approvalItems = data.map((item) {
          return ApprovalItem.fromJson(item, arguments);
        }).toList();

        setState(() {});
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${ModalRoute.of(context)!.settings.arguments} Approval'),
      ),
      body: approvalItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: approvalItems.length,
              itemBuilder: (context, index) {
                final approvalItem = approvalItems[index];
                return ApprovalItemWidget(approvalItem: approvalItem);
              },
            ),
    );
  }
}

class ApprovalItemWidget extends StatelessWidget {
  final ApprovalItem approvalItem;

  ApprovalItemWidget({required this.approvalItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: ListTile(
        leading: getStatusBadge(approvalItem.status),
        title: Text(approvalItem.jenis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal: ${approvalItem.tanggal}'),
            Text('Status: ${getStatusText(approvalItem.status)}'),
            if (approvalItem is IzinApprovalItem)
              Text('Alasan: ${(approvalItem as IzinApprovalItem).alasan}'),
          ],
        ),
      ),
    );
  }

  Widget getStatusBadge(int status) {
    String statusText = getStatusText(status);
    Color statusColor = getStatusColor(status);

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: statusColor,
        shape: BoxShape.rectangle,
      ),
      child: Text(
        statusText,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approved';
      case 2:
        return 'Rejected';
      default:
        return 'Tidak Diketahui';
    }
  }
}

class ApprovalItem {
  final String jenis;
  final String tanggal;
  final int status;

  ApprovalItem({
    required this.jenis,
    required this.tanggal,
    required this.status,
  });

  factory ApprovalItem.fromJson(Map<String, dynamic> json, String arguments) {
    switch (arguments) {
      case 'izin':
        return IzinApprovalItem.fromIzinJson(json);
      case 'lembur':
        return LemburApprovalItem.fromLemburJson(json);
      case 'pengajuan-absensi':
        return AbsensiApprovalItem.fromAbsensiJson(json);
      default:
        return ApprovalItem(jenis: '', tanggal: '', status: 0);
    }
  }
}

class IzinApprovalItem extends ApprovalItem {
  final String alasan;

  IzinApprovalItem({
    required this.alasan,
    required String jenis,
    required String tanggal,
    required int status,
  }) : super(jenis: jenis, tanggal: tanggal, status: status);

  factory IzinApprovalItem.fromIzinJson(Map<String, dynamic> json) {
    return IzinApprovalItem(
      alasan: json['alasan'] ?? '',
      jenis: json['jenis'] ?? '',
      tanggal: json['tanggal'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class LemburApprovalItem extends ApprovalItem {
  final String jamMulai;
  final String jamSelesai;
  final String mulaiIstirahat;
  final String akhirIstirahat;

  LemburApprovalItem({
    required this.jamMulai,
    required this.jamSelesai,
    required this.mulaiIstirahat,
    required this.akhirIstirahat,
    required String jenis,
    required String tanggal,
    required int status,
  }) : super(jenis: jenis, tanggal: tanggal, status: status);

  factory LemburApprovalItem.fromLemburJson(Map<String, dynamic> json) {
    return LemburApprovalItem(
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
      mulaiIstirahat: json['mulai_istirahat'] ?? '',
      akhirIstirahat: json['akhir_istirahat'] ?? '',
      jenis: json['jenis'] ?? '',
      tanggal: json['tanggal'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class AbsensiApprovalItem extends ApprovalItem {
  final String bukti;

  AbsensiApprovalItem({
    required this.bukti,
    required String jenis,
    required String tanggal,
    required int status,
  }) : super(jenis: jenis, tanggal: tanggal, status: status);

  factory AbsensiApprovalItem.fromAbsensiJson(Map<String, dynamic> json) {
    return AbsensiApprovalItem(
      bukti: json['bukti'] ?? '',
      jenis: json['jenis'] ?? '',
      tanggal: json['tanggal'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}
