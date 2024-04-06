import 'package:flutter/material.dart';
import 'package:Fast_Team/controller/login_controller.dart';
import 'package:get/get.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPage();
}

class _ResetPasswordPage extends State<ResetPasswordPage> {

  bool isLoading = false;
  
  LoginController? loginController;
  TextEditingController? emailInput;

  @override
  void initState() {
    super.initState();
    emailInput = TextEditingController();
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
          'Reset Password',
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
        )
      ),
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
              _emailField(),
              const SizedBox(height: 16.0),
              _buildButton(context, emailInput!, loginController!)
            ]
          ),
        ),
      ),
    );
  }

  ElevatedButton _buildButton(BuildContext context, 
      TextEditingController emailInput,
      LoginController controller) {
    
    requestResetPassword() async {
        var result = await controller.requestResetPassword(emailInput.text);
        print(result);
        if (result['status'] == 200) {
          showCustomDialog(context, 'Password reset instructions sent to your email.');
        } else if (result['status'] == 400){
          String message = '';

          if (result['details']['email'] is List) {
            message = result['details']['email'][0];
          } else {
            message = result['details']['email'];
          }
          
          showSnackBar(message, Colors.red);
        }
    }

    validateFromInput() async {
      if(emailInput.text.isEmpty) {
        showSnackBar("Email cannot be empty", Colors.red);
      } else {
        await requestResetPassword();
      }
      setState(() {
        isLoading = false;
      });
    }

    return ElevatedButton(
      onPressed: () async {
        if(!isLoading) {
          setState(() {
            isLoading = true;
          });

          validateFromInput();
        }
      }, 
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[900],
        splashFactory: InkSplash.splashFactory, 
        minimumSize: const Size(double.infinity, 48.0),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              // Customize the overlay color when pressed
              return Colors.blue[800]!;
            }
            return Colors.transparent;
          },
        )
      ),
      child: isLoading ? 
        const CircularProgressIndicator(color: Colors.white,) 
        : const Text('Submit', style: TextStyle(color: Colors.white),),
    );
  }

  TextFormField _emailField() {
    return TextFormField(
      controller: emailInput,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
        hintText: "Email",
        labelText: "Email",
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Text _infoMessage() {
    return Text(
      'Please Enter Your Email Address To Recieve Verification Message',
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