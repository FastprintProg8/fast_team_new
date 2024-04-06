import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fast_Team/controller/schedule_request_controller.dart';
import 'package:get/get.dart';

class OvertimePage extends StatefulWidget {
  const OvertimePage({super.key});

  @override
  State<OvertimePage> createState() => _OvertimePageState();
}

class _OvertimePageState extends State<OvertimePage> with AutomaticKeepAliveClientMixin {
  
  int userId = 0;
  bool isLoading = false;
  ScheduleRequestController? scheduleRequestController;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTimeStart = TimeOfDay.now();
  TimeOfDay selectedTimeEnd = TimeOfDay.now();
  String overtimeReason = ''; // Added for reason

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
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _dateField(context),
              _timeStartField(context),
              _timeEndField(context),
              _reasonField(context),
              const SizedBox(height: 16.0,),
              _buildButton(context),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildButton(BuildContext context) {

    insertAbsentSubmission() async {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      String formattedStartTime = selectedTimeStart.format(context);
      String formattedEndTime = selectedTimeEnd.format(context);

      Map<String, dynamic> requestBody = {
        'user': userId.toString(),
        'tanggal': formattedDate,
        'jam_mulai': formattedStartTime,
        'jam_selesai': formattedEndTime,
        'alasan': overtimeReason,
      };

      var result = await scheduleRequestController!.insertOvertimeSubmission(requestBody);

      if (result['status'] == 200 ) {
          setState(() {
            overtimeReason = '';
          });
          showCustomDialog(context, 'Request has been submitted, please check your inbox periodically for confirmation updates');
      } else {
        showSnackBar('Server having trouble');
      }
    }

    validateFormInput() async {
        if(overtimeReason.isEmpty) {
          showSnackBar("Reason field cannot be empty");
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
      )  
    );
  }

  TextFormField _timeStartField(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Time Start',
        prefixIcon: Icon(Icons.access_time),
      ),
      readOnly: true,
      onTap: () async {
        final selectedTimeStart = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (selectedTimeStart != null) {
          setState(() {
            this.selectedTimeStart = selectedTimeStart;
          });
        }
      },
      controller: TextEditingController(
        text: selectedTimeStart.format(context),
      )  
    );
  }

  TextFormField _timeEndField(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Time End',
        prefixIcon: Icon(Icons.access_time),
      ),
      readOnly: true,
      onTap: () async {
        final selectedTimeEnd = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (selectedTimeEnd != null) {
          setState(() {
            this.selectedTimeEnd = selectedTimeEnd;
          });
        }
      },
      controller: TextEditingController(
        text: selectedTimeEnd.format(context),
      )  
    );
  }

  TextFormField _reasonField(BuildContext context) {
    return TextFormField(
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Reason',
        prefixIcon: Icon(Icons.abc),
      ),
      onChanged: (value) async {
        overtimeReason = value;
      },
      keyboardType: TextInputType.multiline,
      controller: TextEditingController(
        text: overtimeReason,
      )  
    );
  }
}