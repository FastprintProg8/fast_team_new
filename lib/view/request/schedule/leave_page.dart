import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fast_Team/controller/schedule_request_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage>
    with AutomaticKeepAliveClientMixin {
  ScheduleRequestController? scheduleRequestController;
  int userId = 0;
  bool isLoading = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? leaveType = 'Leave';
  List<Map<String, dynamic>> leaveOptionsList = [];
  List<String> dropdownOption = [];
  String leaveReason = ''; // Added for reason
  File? imageFile; // Using File for images

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    scheduleRequestController = Get.put(ScheduleRequestController());
    loadSharedPreferences();
    loadListLeaveOption();
  }

  Future<void> loadSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userId = sharedPreferences.getInt('user-id_user') ?? 0;
    });
  }

  Future<void> loadListLeaveOption() async {
    var result = await scheduleRequestController!.retrieveLeaveOption();
    if (result['status'] == 200) {
      List<dynamic> data = result['details'];

      List<Map<String, dynamic>> optionList = [];
      for (var item in data) {
        optionList.add({
          'name': item['name'],
          'id': item['id'].toString(), // Store the id as a string
        });
      }

      setState(() {
        leaveOptionsList = optionList;
        dropdownOption = leaveOptionsList
            .map<String>((item) => item['name'].toString())
            .toList();
      });
    }
  }

  Future<void> _takePicture() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
    }
  }

  showSnackBar(message, Color color) {
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
          duration: const Duration(milliseconds: 3000),
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
              _timeField(context),
              _leaveOptionDropdown(),
              _reasonField(context),
              const SizedBox(
                height: 16.0,
              ),
              _addPhoto(),
              const SizedBox(
                height: 16.0,
              ),
              _buildButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    insertLeaveSubmission() async {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      String formattedTime = selectedTime.format(context);

      RegExp regExp = RegExp(r'^\d{1,2}:\d{2}:\d{2}.\d{6}Z$');
      if (!regExp.hasMatch(formattedTime)) {
        // Jika format bukan "HH:mm:ss.SSSSSS'Z'", maka ubah formatnya
        String hour = selectedTime.hour.toString().padLeft(2, '0');
        String minute = selectedTime.minute.toString().padLeft(2, '0');
        String second =
            '00'; // Karena tidak ada informasi detik dalam objek TimeOfDay
        String microsecond =
            '000000'; // Karena tidak ada informasi mikrodetik dalam objek TimeOfDay

        formattedTime = '$hour:$minute:$second.$microsecond' + 'Z';
      }
      // Ambil cuti_id dari dropdown agenda yang dipilih
      String? selectedCutiId = leaveOptionsList
          .firstWhere((element) => element['name'] == leaveType)['id'];

      Map<String, dynamic> requestBody = {
        'userId': userId.toString(),
        'tanggal': formattedDate,
        'time': formattedTime,
        'note': leaveReason,
        'cuti_id': selectedCutiId.toString(),
      };
      print(requestBody);
      var result = await scheduleRequestController!
          .insertLeaveSubmission(requestBody, imageFile);

      if (result.statusCode == 200) {
        setState(() {
          leaveReason = '';
          imageFile = null;
        });

        showCustomDialog(context,
            'Request has been submitted, please check your inbox periodically for confirmation updates');
        showSnackBar('Leave request created successfully', Colors.green);
      } else if (result.statusCode == 400) {
        String message = "error ${result.statusCode}, contact administrator";

        showSnackBar(message, Colors.red);
      }
    }

    validateFormInput() async {
      if (leaveReason.isEmpty) {
        showSnackBar("Reason field cannot be empty", Colors.red);
      }
      if (imageFile == null) {
        showSnackBar("Picture cannot be empty", Colors.red);
      } else {
        await insertLeaveSubmission();
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

  Center _addPhoto() {
    return Center(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                _takePicture(); // Take a picture from the camera
              },
              child: Column(
                children: [
                  if (imageFile != null)
                    Image.file(
                      imageFile!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else
                    const Icon(
                      Icons.photo,
                      size: 100,
                      color: Colors.grey,
                    ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Take a Picture',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (imageFile != null)
              Positioned(
                top: 5.0,
                right: 5.0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imageFile = null; // Remove the taken image
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200], // Grey background
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20.0,
                      color: Colors.grey, // Close icon color
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DropdownButtonFormField<String> _leaveOptionDropdown() {
    return DropdownButtonFormField(
      value: leaveType,
      items: dropdownOption
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) {
        setState(() {
          leaveType = val as String;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Agenda',
        prefixIcon: Icon(Icons.event),
      ),
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

  TextFormField _reasonField(BuildContext context) {
    return TextFormField(
        maxLines: 2,
        decoration: const InputDecoration(
          labelText: 'Reason',
          prefixIcon: Icon(Icons.abc),
        ),
        onChanged: (value) async {
          leaveReason = value;
        },
        keyboardType: TextInputType.multiline,
        controller: TextEditingController(
          text: leaveReason,
        ));
  }
}
