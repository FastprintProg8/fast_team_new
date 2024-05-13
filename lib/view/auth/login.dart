// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:Fast_Team/user/controllerApi.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text;
    String password = _passwordController.text;

    try {
      bool isValid = await LoginUser().validateUser(username, password);
      
      if (isValid) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Failed'),
            content: const Text('Email atau Password salah'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Server dalam gangguan'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/img/logo.png',
                            width: 50.w,
                            height: 50.0,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Fast Team',
                          style: TextStyle(
                            color: Color.fromARGB(255, 2, 65, 128),
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          controller: _usernameController,
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          obscureText: true,
                          controller: _passwordController,
                        ),
                        const SizedBox(height: 24.0),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_usernameController.text.isNotEmpty &&
                                      _passwordController.text.isNotEmpty) {
                                    _login();
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Error'),
                                        content: const Text(
                                            'Please enter your email and password'),
                                        actions: [
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                          child: _isLoading
                              ? Text(
                                  'Loading',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        // Garis pembatas
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 16.w),
                          height: 1.0,
                          color: Colors.grey,
                        ),

                        // Tombol Forgot Password
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                String email =
                                    ''; // Variabel untuk menyimpan alamat email

                                return AlertDialog(
                                  title: const Text('Forgot Password'),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 24.w,
                                      horizontal:
                                          16.w), // Sesuaikan ukuran padding sesuai kebutuhan
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        onChanged: (value) {
                                          email = value;
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: 'Email',
                                          prefixIcon: const Icon(Icons.email),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16.w),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color:
                                                    Colors.red, // Warna merah
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Validasi email
                                              if (email.isEmpty) {
                                                // Tampilkan pesan error jika email kosong
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text('Error'),
                                                    content: const Text(
                                                        'Please enter your email'),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text('OK'),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                return;
                                              }

                                              // Membuat objek data yang akan dikirim ke API
                                              final Map<String, dynamic>
                                                  requestData = {
                                                'email': email,
                                              };

                                              try {
                                                // Mengirim permintaan POST ke API
                                                final response =
                                                    await http.post(
                                                  Uri.parse(
                                                      'http://103.29.214.154:9002/api_absensi/user/reset_password/'),
                                                  body: requestData,
                                                );
                                               
                                                // Memeriksa kode respons API
                                                if (response.statusCode ==
                                                    200) {
                                                  // Berhasil, tampilkan pesan berhasil
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: const Text('Success'),
                                                      content: const Text(
                                                          'Password reset instructions sent to your email.'),
                                                      actions: [
                                                        TextButton(
                                                          child: const Text('OK'),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  // Gagal, tampilkan pesan error dari API
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        AlertDialog(
                                                      title: const Text('Error'),
                                                      content: const Text(
                                                          'Failed to reset password. Please try again later.'),
                                                      actions: [
                                                        TextButton(
                                                          child: const Text('OK'),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              } catch (error) {
                                                // Terjadi kesalahan, tampilkan pesan kesalahan
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text('Error'),
                                                    content: const Text(
                                                        'An error occurred. Please try again later.'),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text('OK'),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color.fromARGB(
                                                  255, 2, 65, 128),
                                            ),
                                            child: const Text(
                                              'Submit',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Color.fromARGB(
                                  255, 2, 65, 128), // Warna sesuai kebutuhan
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
