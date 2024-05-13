import 'package:Fast_Team/style/color_theme.dart';
import 'package:Fast_Team/view/absen/daftarAbsensi.dart';
import 'package:Fast_Team/view/absen/daftarKehadiran.dart';
import 'package:Fast_Team/view/absen/detailAbsensi.dart';
import 'package:Fast_Team/view/absen/kamera.dart';
import 'package:Fast_Team/view/absen/list_absen_page.dart';
import 'package:Fast_Team/view/account/account_page.dart';
import 'package:Fast_Team/view/inbox/detail/detail_attendence_page.dart';
import 'package:Fast_Team/view/inbox/detail/detail_leave_page.dart';
import 'package:Fast_Team/view/inbox/detail/detail_overtime_page.dart';
import 'package:Fast_Team/view/milestone/milestone_page.dart';
import 'package:Fast_Team/view/payslip/payslip_page.dart';
import 'package:Fast_Team/view/payslip/verification_payslip_page.dart';
import 'package:Fast_Team/view/request/schedule_request_page.dart';
import 'package:Fast_Team/view/inbox/approval.dart';
import 'package:Fast_Team/view/auth/login_page.dart';
import 'package:Fast_Team/view/employee/employee.dart';
import 'package:Fast_Team/view/inbox/inbox_page.dart';
import 'package:Fast_Team/view/navigator_bottom_menu.dart';
import 'package:Fast_Team/view/sertificate.dart';
import 'package:Fast_Team/view/splash_screen_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'view/absen/absensi.dart';
import 'view/history.dart';
import 'view/home.dart';
import 'view/absen/map.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Pastikan Flutter sudah terinisialisasi
  await FlutterDownloader.initialize();
  // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  // String avatarImageUrl = sharedPreferences.getString('user-img_url') ?? '';
  // int userId = sharedPreferences.getInt('user-id_user') ?? 0;
  // // print("userid:$userId");
  // bool loggedIn = userId > 0;
  // runApp(MyApp(avatarImageUrl: avatarImageUrl, loggedIn: loggedIn));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const Color navyBlue =
      Color.fromARGB(255, 2, 65, 128); // Nilai warna biru navy

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (_, child) {
          return MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              MonthYearPickerLocalizations.delegate,
            ],
            title: 'Fast Team',
            theme: ThemeData(
              primaryColor: ColorsTheme
                  .primary, // Menggunakan warna biru navy sebagai primary color
              primarySwatch:
                  navyBlueSwatch, // Menggunakan warna biru navy sebagai primary swatch
            ),
            // initialRoute: '/',
            home: const SplashScreen(), // Set rute awal ke '/splash'
            routes: {
              // '/': (context) => SplashScreen(),
              '/login': (context) => const LoginPage(),
              '/navigation': (context) => const NavigatorBottomMenu(),
              '/home': (context) => const HomePage(),
              '/map': (context) => const MapPage(),
              '/kamera': (context) => const KameraPage(),
              '/absensi': (context) => AbsensiPage(),
              '/detailAbsensi': (context) => const DetailAbsensiPage(),
              '/daftarAbsensi': (context) => const DaftarAbsensiPage(),
              '/profile': (context) => const AccountPage(),
              '/request': (context) => const ScheduleRequestPage(),
              '/daftarKehadiran': (context) => DaftarKehadiranPage(),
              '/history': (context) => History(),
              '/employee': (context) => EmployeePage(),
              '/inbox': (context) => const InboxPage(),
              '/approval': (context) => ApprovalPage(),
              '/sertificate': (context) => const SertificatePage(),
              '/attendenceDetail': (context) => const AttendanceDetailPage(),
              '/leaveDetail': (context) => const LeaveDetailPage(),
              '/overtimeDetail': (context) => const OvertimeDetailPage(),
              '/payslip': (context) => const PayslipPage(),
              '/verifPayslip': (context) => const VerifPayslipPage(),
              '/listMember': (context) => const ListAbsentPage(),
              '/milestone': (context) => const MilestonePage(),
              // ignore: equal_keys_in_map
              '/inbox': (context) => const InboxPage(),
              '/account': (context) => const AccountPage(),
            },
          );
        });
  }

  // Membuat primary swatch berdasarkan warna biru navy
  MaterialColor get navyBlueSwatch {
    return MaterialColor(
      navyBlue.value,
      const <int, Color>{
        50: navyBlue,
        100: navyBlue,
        200: navyBlue,
        300: navyBlue,
        400: navyBlue,
        500: navyBlue,
        600: navyBlue,
        700: navyBlue,
        800: navyBlue,
        900: navyBlue,
      },
    );
  }
}

// class MyApp extends StatelessWidget {
//   final String avatarImageUrl;
//   final bool loggedIn;

//   static const Color navyBlue =
//       Color.fromARGB(255, 2, 65, 128); // Nilai warna biru navy

  

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//         designSize: const Size(360, 690),
//         minTextAdapt: true,
//         builder: (_, child) {
//           return MaterialApp(
//             localizationsDelegates: [
//               GlobalMaterialLocalizations.delegate,
//               MonthYearPickerLocalizations.delegate,
//             ],
//             title: 'Fast Team',
//             theme: ThemeData(
//               primaryColor: ColorsTheme
//                   .primary, // Menggunakan warna biru navy sebagai primary color
//               primarySwatch:
//                   navyBlueSwatch, // Menggunakan warna biru navy sebagai primary swatch
//             ),
//             // initialRoute: '/',
//             home: const SplashScreen(), // Set rute awal ke '/splash'
//             routes: {
//               // '/': (context) => AnimatedSplashScreen(
//               //       splash: Image.asset('assets/img/logo_besar.jpg',
//               //           height: 1000, width: 1000),
//               //       splashTransition: SplashTransition.fadeTransition,
//               //       duration: 3000,
//               //       nextScreen: loggedIn ? NavigatorBottomMenu() : LoginPage(),
//               //     ),
//               '/navigation': (context) => NavigatorBottomMenu(),
//               '/home': (context) => HomePage(),
//               '/map': (context) => MapPage(),
//               '/kamera': (context) => KameraPage(),
//               '/absensi': (context) => AbsensiPage(),
//               '/detailAbsensi': (context) => DetailAbsensiPage(),
//               '/daftarAbsensi': (context) => DaftarAbsensiPage(),
//               '/profile': (context) => ProfilePage(),
//               '/request': (context) => RequestPage(),
//               '/daftarKehadiran': (context) => DaftarKehadiranPage(),
//               '/history': (context) => History(),
//               '/employee': (context) => EmployeePage(),
//               '/inbox': (context) => InboxPage(),
//               '/approval': (context) => ApprovalPage(),
//               '/sertificate': (context) => SertificatePage(),
//             },
//           );
//         });
//   }

//   // Membuat primary swatch berdasarkan warna biru navy
//   MaterialColor get navyBlueSwatch {
//     return MaterialColor(
//       navyBlue.value,
//       <int, Color>{
//         50: navyBlue,
//         100: navyBlue,
//         200: navyBlue,
//         300: navyBlue,
//         400: navyBlue,
//         500: navyBlue,
//         600: navyBlue,
//         700: navyBlue,
//         800: navyBlue,
//         900: navyBlue,
//       },
//     );
//   }
// }
