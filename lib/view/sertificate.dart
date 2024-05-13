// ignore_for_file: library_private_types_in_public_api

import 'dart:ui';
import 'package:flutter/material.dart';

class SertificatePage extends StatefulWidget {
  const SertificatePage({super.key});

  @override
  _SertificatePageState createState() => _SertificatePageState();
}

class _SertificatePageState extends State<SertificatePage> {
  List<Sertificate> sertificateList = [
    Sertificate(
        title: 'Fast Print Culture 1', issuer: 'Issuer A', isLocked: false),
    Sertificate(
        title: 'Fast Print Culture 2', issuer: 'Issuer B', isLocked: true),
    // Tambahkan sertifikat dummy lainnya sesuai kebutuhan
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Certificate',
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
      body: sertificateList.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: sertificateList.length,
              itemBuilder: (context, index) {
                return CertificateCard(sertificate: sertificateList[index]);
              },
            ),
    );
  }
}

class CertificateCard extends StatelessWidget {
  final Sertificate sertificate;

  const CertificateCard({super.key, required this.sertificate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 5,
      child: SizedBox(
        height: 250,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
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
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
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
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Icon(
                              Icons.file_download,
                              color: sertificate.isLocked
                                  ? Colors.grey
                                  : Colors.blue,
                            ),
                            const SizedBox(width: 8.0),
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
    home: const SertificatePage(),
  ));
}
