import 'package:flutter/material.dart';

class bottomNavBar extends StatelessWidget {
  const bottomNavBar({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) => NavigationBarTheme(
        data: NavigationBarThemeData(),
        child: NavigationBar(
          height: 50,
          backgroundColor: Colors.white,
          onDestinationSelected: (int index) {
            // Menangani navigasi sesuai dengan index yang dipilih
            switch (index) {
              case 0:
                // Navigasi ke halaman Home dengan mengirimkan argumen jika diperlukan
                Navigator.pushNamed(context, '/navigation',
                    arguments: {'key': 0, 'notMainMenu': 1});
                break;
              case 1:
                // Navigasi ke halaman Employee dengan mengirimkan argumen jika diperlukan
                Navigator.pushNamed(context, '/navigation',
                    arguments: {'key': 1, 'notMainMenu': 1});
                break;
              case 2:
                // Navigasi ke halaman Request dengan mengirimkan argumen jika diperlukan
                Navigator.pushNamed(context, '/navigation',
                    arguments: {'key': 2, 'notMainMenu': 1});
                break;
              case 3:
                // Navigasi ke halaman Inbox dengan mengirimkan argumen jika diperlukan
                Navigator.pushNamed(context, '/navigation',
                    arguments: {'key': 3, 'notMainMenu': 1});
                break;
              case 4:
                // Navigasi ke halaman Account dengan mengirimkan argumen jika diperlukan
                Navigator.pushNamed(context, '/navigation',
                    arguments: {'key': 4, 'notMainMenu': 1});
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Employee',
            ),
            NavigationDestination(
              icon: Icon(Icons.request_page),
              label: 'Request',
            ),
            NavigationDestination(
              icon: Icon(Icons.inbox),
              label: 'Inbox',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      );
}