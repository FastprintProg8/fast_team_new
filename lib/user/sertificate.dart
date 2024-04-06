import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:Fast_Team/utils/bottom_navigation_bar.dart';

class SertificatePage extends StatefulWidget {
  @override
  _SertificatePageState createState() => _SertificatePageState();
}

class _SertificatePageState extends State<SertificatePage> {
  List<Sertificate> sertificateList = [
    Sertificate(title: 'Fast Print Culture 1', issuer: 'Issuer A', isLocked: false),
    Sertificate(title: 'Fast Print Culture 2', issuer: 'Issuer B', isLocked: true),
    // Tambahkan sertifikat dummy lainnya sesuai kebutuhan
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Certificates'),
      ),
      body: sertificateList.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: sertificateList.length,
              itemBuilder: (context, index) {
                return CertificateCard(sertificate: sertificateList[index]);
              },
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTabTapped: (index) {
          // Handle bottom navigation bar taps
        },
      ),
    );
  }
}

class CertificateCard extends StatelessWidget {
  final Sertificate sertificate;

  CertificateCard({required this.sertificate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      elevation: 5,
      child: Container(
        height: 250,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/img/logo_besar.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (sertificate.isLocked)
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sertificate.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(
                              Icons.file_download,
                              color: sertificate.isLocked
                                  ? Colors.grey
                                  : Colors.blue,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              'Unduh Sertifikat',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: sertificate.isLocked
                                    ? Colors.grey
                                    : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      sertificate.isLocked ? Icons.lock : Icons.lock_open,
                      color: sertificate.isLocked ? Colors.red : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Sertificate {
  final String title;
  final String issuer;
  final bool isLocked;

  Sertificate({
    required this.title,
    required this.issuer,
    required this.isLocked,
  });
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primaryColor: Colors.blue,
    ),
    home: SertificatePage(),
  ));
}
