import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fast_Team/controller/schedule_request_controller.dart';
import 'package:get/get.dart';

class AbsentPage extends StatefulWidget {
  const AbsentPage({super.key});

  @override
  State<AbsentPage> createState() => _AbsentPageState();
}

class _AbsentPageState extends State<AbsentPage>
    with AutomaticKeepAliveClientMixin {
  ScheduleRequestController? scheduleRequestController;
  int userId = 0;
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String absenType = 'Clock In';
  String absenURL = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scheduleRequestController = Get.put(ScheduleRequestController());
    loadSharedPreferences();
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userId = sharedPreferences.getInt('user-id_user') ?? 0;
    });
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
    super.build(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 8.w),
        child: Column(
          children: <Widget>[
            _dateField(context),
            _timeField(context),
            const SizedBox(height: 16.0),
            _absentTypeRadio(),
            _urlField(context),
            const SizedBox(height: 16.0),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    insertAbsentSubmission() async {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      String formattedTime = selectedTime.format(context);
      String jenis = absenType == 'Clock In' ? 'in' : 'out';

      Map<String, dynamic> requestBody = {
        'user_id': userId.toString(),
        'tgl': formattedDate,
        'jam': formattedTime,
        'jenis': jenis,
        'bukti': absenURL,
      };

      var result =
          await scheduleRequestController!.insertAbsentSubmission(requestBody);

      if (result['status'] == 200 || result['status'] == 201) {
        setState(() {
          absenURL = '';
        });
        showCustomDialog(context,
            'Request has been submitted, please check your inbox periodically for confirmation updates');
      } else {
        showSnackBar('Server having trouble');
      }
    }

    validateFormInput() async {
      if (absenURL.isEmpty) {
        showSnackBar("URL field cannot be empty");
      } else {
        await insertAbsentSubmission();
      }

      setState(() {
        isLoading = false;
      });
    }

    return ElevatedButton(
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
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
    );
  }

  Column _absentTypeRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Radio(
              value: 'Clock In',
              groupValue: absenType,
              onChanged: (value) {
                setState(() {
                  absenType = value.toString();
                });
              },
            ),
            const Text('Clock In'),
            Radio(
              value: 'Clock Out',
              groupValue: absenType,
              onChanged: (value) {
                setState(() {
                  absenType = value.toString();
                });
              },
            ),
            const Text('Clock Out'),
          ],
        ),
      ],
    );
  }

  TextFormField _dateField(BuildContext context) {
    return TextFormField(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.date_range),
        ),
        readOnly: true,
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );

          if (pickedDate != null && pickedDate != selectedDate) {
            setState(() {
              selectedDate = pickedDate;
            });
          }
        },
        controller: TextEditingController(
          text: DateFormat('yyyy-MM-dd').format(selectedDate),
        ));
  }

  TextFormField _timeField(BuildContext context) {
    return TextFormField(
        decoration: const InputDecoration(
          labelText: 'Time',
          prefixIcon: Icon(Icons.access_time),
        ),
        readOnly: true,
        onTap: () async {
          final selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (selectedTime != null) {
            setState(() {
              this.selectedTime = selectedTime;
            });
          }
        },
        controller: TextEditingController(
          text: selectedTime.format(context),
        ));
  }

  TextFormField _urlField(BuildContext context) {
    return TextFormField(
        decoration: const InputDecoration(
          labelText: 'URL',
          prefixIcon: Icon(Icons.link),
        ),
        onChanged: (value) async {
          absenURL = value;
        },
        keyboardType: TextInputType.url,
        controller: TextEditingController(
          text: absenURL,
        ));
  }
}
