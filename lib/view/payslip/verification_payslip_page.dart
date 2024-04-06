import 'package:flutter/material.dart';
import 'package:Fast_Team/controller/login_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifPayslipPage extends StatefulWidget {
  const VerifPayslipPage({Key? key}) : super(key: key);

  @override
  State<VerifPayslipPage> createState() => _VerifPayslipPage();
}

class _VerifPayslipPage extends State<VerifPayslipPage> {
  bool isLoading = false;

  LoginController? loginController;
  TextEditingController? passwordInput;

  @override
  void initState() {
    super.initState();
    passwordInput = TextEditingController();
    loginController = Get.put(LoginController());
  }

  showSnackBar(String message, Color color) {
    snackbar() => SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: color,
          duration: const Duration(milliseconds: 2000),
        );
    ScaffoldMessenger.of(context).showSnackBar(snackbar());
  }

  void showCustomDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'My Payslip',
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 70.0),
                _logo(),
                const SizedBox(height: 40.0),
                _infoMessage(),
                const SizedBox(height: 40.0),
                _passwordField(),
                const SizedBox(height: 16.0),
                _buildButton(context, passwordInput!, loginController!)
              ]),
        ),
      ),
    );
  }

  ElevatedButton _buildButton(BuildContext context,
      TextEditingController passwordInput, LoginController controller) {
    requestLogin() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      var userEmail = prefs.getString('user-email');
      var userResult =
          await controller.requestLoginUser(userEmail, passwordInput.text);

      if (userResult['status'] == 200) {
        if (userResult['details']['status'] == 'success') {
          Navigator.pushReplacementNamed(context, '/payslip');
        } else {
          showSnackBar('Wrong password', Colors.red);
        }
      } else {
        showSnackBar('Server dalam gangguan', Colors.red);
      }
    }

    validateFromInput() async {
      if (passwordInput.text.isEmpty) {
        showSnackBar("password cannot be empty", Colors.red);
      } else {
        await requestLogin();
      }
    }

    return ElevatedButton(
      onPressed: () async {
        await validateFromInput();
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
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
    );
  }

  TextFormField _passwordField() {
    return TextFormField(
      controller: passwordInput,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
        hintText: "Password",
        labelText: "Password",
      ),
      obscureText: true,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Text _infoMessage() {
    return Text(
      'Please Enter Your Password To Access Payslip',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        color: Colors.blue[900],
      ),
    );
  }

  SizedBox _logo() {
    return SizedBox(
      width: 80.0,
      height: 80.0,
      child: Image.asset('assets/img/logo.png'),
    );
  }
}
