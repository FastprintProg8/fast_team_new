import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fast_Team/utils/bottom_navigation_bar.dart';
import 'package:Fast_Team/user/login.dart';
import 'package:Fast_Team/main.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: SharedPreferences.getInstance().then((prefs) {
        return prefs.getString('user-img_url') ?? '';
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
            ),
            body: Center(child: CircularProgressIndicator()),
            bottomNavigationBar: BottomNavBar(
              currentIndex: 4,
              onTabTapped: (index) {
                if (index == 0) {
                  Navigator.of(context).pushNamed('/home');
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
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final avatarImageUrl =
              snapshot.data ?? ''; // Mengambil nilai dari SharedPreferences

          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
            ),
            body: ProfileBody(avatarImageUrl: avatarImageUrl),
            bottomNavigationBar: BottomNavBar(
              currentIndex: 4,
              onTabTapped: (index) {
                if (index == 0) {
                  Navigator.of(context).pushNamed('/home');
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
      },
    );
  }
}

class ProfileBody extends StatelessWidget {
  final String avatarImageUrl;

  ProfileBody({required this.avatarImageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          color: Color.fromARGB(255, 2, 65, 128),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(5.0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(avatarImageUrl),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
                title: Text(
                  'Personal Info',
                  style: TextStyle(color: Colors.blue),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.blue,
                ),
                tileColor: Colors.transparent,
                onTap: () {
                  // Navigasi ke halaman Personal Info
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.badge,
                  color: Colors.cyan,
                ),
                title: Text(
                  'Sertificate',
                  style: TextStyle(color: Colors.cyan),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.blue,
                ),
                tileColor: Colors.transparent,
                onTap: () async {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.clear();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/sertificate', (Route<dynamic> route) => false);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.monetization_on,
                  color: Colors.green,
                ),
                title: Text(
                  'Payroll Info',
                  style: TextStyle(color: Colors.green),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.blue,
                ),
                tileColor: Colors.transparent,
                onTap: () {
                  // Navigasi ke halaman Payroll Info
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.lock,
                  color: Colors.orange,
                ),
                title: Text(
                  'Change Password',
                  style: TextStyle(color: Colors.orange),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.blue,
                ),
                tileColor: Colors.transparent,
                onTap: () {
                  // Navigasi ke halaman Change Password
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.blue,
                ),
                tileColor: Colors.transparent,
                onTap: () async {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  await sharedPreferences.clear();
                  // Navigator.of(context).pushNamedAndRemoveUntil(
                  //     '/', (Route<dynamic> route) => false);
                  // Navigator.of(context).pushReplacement(
                  //   MaterialPageRoute(
                  //     builder: (BuildContext context) {
                  //       return MyApp(avatarImageUrl: '', loggedIn: false); // Replace with the actual constructor of your main page
                  //     },
                  //   ),
                  // );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
