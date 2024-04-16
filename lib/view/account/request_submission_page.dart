import 'package:Fast_Team/widget/refresh_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RequestSubmissionPage extends StatefulWidget {
  const RequestSubmissionPage({super.key});

  @override
  State<RequestSubmissionPage> createState() => _RequestSubmissionPageState();
}

class _RequestSubmissionPageState extends State<RequestSubmissionPage> {
  List<String> items = [
   
    'Nama Lengkap',
    'Email',
    'Jenis Kelamin',
    'Tempat Lahir',
    'Tanggal Lahir',
    'Status Pernikahan',
    'Agama',
    'Nomor KTP',
    'Alamat KTP',
    'Alamat Tinggal'
  ];
  String? selectedItem ;
  @override
  void initState() {
    super.initState();
    
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Change Data',
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
        ),
      ),
      body: contentBody(),
    );
  }

  Widget contentBody() {
    return Container(
      margin:EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Data'),
              DropdownButton<String>(
                items: items
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ))
                    .toList(),
                value: selectedItem,
                onChanged: (item) {
                  setState(() {
                    selectedItem = item;
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
