import 'package:Fast_Team/server/local/local_session.dart';
import 'package:Fast_Team/view/navigator_bottom_menu.dart';
import 'package:flutter/material.dart';
import 'package:Fast_Team/controller/login_controller.dart';
import 'package:Fast_Team/view/auth/reset_password_page.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //server controller
  LoginController? loginController;

  //input controller
  TextEditingController? emailInput;
  TextEditingController? passwordInput;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initConstructor();
    initClearSession();
  }

  initConstructor() {
    emailInput = TextEditingController();
    passwordInput = TextEditingController();
    loginController = Get.put(LoginController());
    LocalSession localSession = Get.put(LocalSession());
  }

  initClearSession() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  showSnackBar(message) {
    snackbar() => SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 2000),
        );
    ScaffoldMessenger.of(context).showSnackBar(snackbar());
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
                  padding: const EdgeInsets.all(20),
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
                  child: Stack(alignment: Alignment.center, children: <Widget>[
                    Column(children: <Widget>[
                      logo(),
                      const SizedBox(height: 16.0),
                      appName(),
                      const SizedBox(height: 32.0),
                      emailFormInput(),
                      const SizedBox(height: 16.0),
                      passwordFormInput(),
                      const SizedBox(height: 16.0),
                      _buildButton(context, emailInput!, passwordInput!,
                          loginController!),
                      const SizedBox(
                        height: 32.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ResetPasswordPage(),
                              ));
                        },
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Color.fromARGB(255, 2, 65, 128),
                          ),
                        ),
                      )
                    ])
                  ]))
            ],
          ),
        ),
      ),
    );
  }

  Widget logo() => SizedBox(
        width: 50.0,
        height: 50.0,
        child: Image.asset('assets/img/logo.png'),
      );

  Widget appName() => const Text(
        'Fast Team',
        style: TextStyle(
          color: Color.fromARGB(255, 2, 65, 128),
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget emailFormInput() => TextFormField(
        controller: emailInput,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.email),
          hintText: "Email",
          labelText: "Email",
        ),
        keyboardType: TextInputType.emailAddress,
      );

  Widget passwordFormInput() => TextFormField(
        controller: passwordInput,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.lock),
          hintText: "Password",
          labelText: "Password",
        ),
        keyboardType: TextInputType.text,
        obscureText: true,
      );

  Widget _buildButton(BuildContext context, TextEditingController emailInput,
      TextEditingController passwordInput, LoginController controller) {
    requestLogin() async {
      var userResult = await controller.requestLoginUser(
          emailInput.text, passwordInput.text);
      // print(userResult);
      if (userResult['status'] == 200) {
        if (userResult['details']['status'] == "success") {
          controller.storeUserInfo(userResult['details']['data']);
          controller.storeJsonUser(userResult['details']['data']);
          controller.storeToken(userResult['details']['token']);
          var employeeResult = await controller.retrieveEmployeeInfo(
              userResult['details']['data']['empoloyee_id'] ?? 0);
          // print(employeeResult);
          if (employeeResult['status'] == 200) {
            controller.storeEmployeeInfo(employeeResult['details']['data']);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => NavigatorBottomMenu(),
              ),
            );
            // showSnackBar('berhasil');
          } else {
            showSnackBar('Server dalam gangguan');
          }
        } else if (userResult['details']['status'] == "error") {
          showSnackBar(userResult['details']['message']);
        }
      } else {
        showSnackBar('Server dalam gangguan');
      }
    }

    validateFormInput() async {
      if (emailInput.text.isEmpty && passwordInput.text.isEmpty) {
        showSnackBar("Email and password cannot be empty");
      } else if (emailInput.text.isEmpty) {
        showSnackBar("Email cannot be empty");
      } else if (passwordInput.text.isEmpty) {
        showSnackBar("Password cannot be empty");
      } else {
        await requestLogin();
      }

      setState(() {
        isLoading = false;
      });
    }

    Widget buttonSubmission() => ElevatedButton(
          onPressed: () async {
            setState(() {
              isLoading = true;
            });

            validateFormInput();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
            splashFactory: InkSplash.splashFactory,
            minimumSize: const Size(double.infinity, 48.0),
          ).copyWith(overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                // Customize the overlay color when pressed
                return Colors.blue[800]!;
              }
              return Colors.transparent;
            },
          )),
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Text(
                  'Sign in',
                  style: TextStyle(color: Colors.white),
                ),
        );

    return buttonSubmission();
  }
}
