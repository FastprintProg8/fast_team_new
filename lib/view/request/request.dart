import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Fast_Team/utils/bottom_navigation_bar.dart';
import 'package:Fast_Team/user/controllerApi.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:http_parser/http_parser.dart';

class RequestPage extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  String selectedForm = 'Absent'; // Default selected form
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String absenURL = '';
  File? imageFile; // Using File for images

  // Form fields for Absen
  String absenType = 'Clock In';

  // Form fields for Ijin
  String? ijinType;
  List<Map<String, dynamic>> acaraOptionsList = [];
  String ijinPhotoURL = '';
  String ijinReason = ''; // Added for reason

  // Form fields for Lembur (formerly Cuti)
  TimeOfDay selectedTimeStart = TimeOfDay.now();
  TimeOfDay selectedTimeEnd = TimeOfDay.now();
  String lemburReason = '';

  List<Map<String, dynamic>> requestOptions = [
    {'title': 'Absent', 'icon': Icons.access_time},
    {'title': 'Leave', 'icon': Icons.camera_alt},
    {'title': 'Overtime', 'icon': Icons.note},
  ];

  bool isLoading = false;
  String dialogMessage = '';
  bool isDialogVisible = false;

  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    fetchAcaraOptions();
  }

  void _initializeCamera() async {
    cameras = await availableCameras();
  }

  Future<void> fetchAcaraOptions() async {
    final url = Uri.parse('http://103.29.214.154:9002/api_absensi/cuti/opsi/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> acaraOptions = [];
        for (var item in data) {
          acaraOptions.add({
            'name': item['name'],
            'id': item['id'].toString(), // Store the id as a string
          });
        }

        setState(() {
          acaraOptionsList = acaraOptions;
        });
      } else {
        print('Failed to load acara options: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred while fetching acara options: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return  ListView(
        children: [
          Container(
            color: Color.fromARGB(255, 2, 65, 128),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Type Request',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: requestOptions.map((option) {
                        bool isActive = option['title'] == selectedForm;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedForm = option['title']!;
                            });
                          },
                          child: Card(
                            color: isActive
                                ? Color.fromARGB(255, 2, 65, 128)
                                : Colors.white,
                            elevation: isActive ? 4.0 : 0.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(
                                    option['icon'],
                                    color:
                                        isActive ? Colors.white : Colors.black,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    option['title']!,
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fill the Form $selectedForm',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                if (selectedForm == 'Absent') ...[
                  buildDateFormField('Date', Icons.date_range),
                  buildFormFieldWithIcon(
                    'Time',
                    Icons.access_time,
                    selectedTime.format(context),
                    () async {
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
                  ),
                  buildAbsenTypeRadioButtons(),
                  buildTextFormFieldWithIcon(
                    'URL',
                    absenURL,
                    (value) {
                      absenURL = value;
                    },
                    Icons.link,
                  ),
                ],
                if (selectedForm == 'Leave') ...[
                  buildDateFormField('Date', Icons.date_range),
                  buildFormFieldWithIcon(
                    'Time',
                    Icons.access_time,
                    selectedTime.format(context),
                    () async {
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
                  ),
                  buildDropdownFormField(
                    'Agenda',
                    ijinType,
                    acaraOptionsList
                        .map<String>((item) => item['name'].toString())
                        .toList(),
                    (String? value) {
                      setState(() {
                        ijinType = value;
                      });
                    },
                    Icons.event,
                  ),
                  buildTextFormFieldWithIcon(
                    'Reason',
                    ijinReason,
                    (value) {
                      ijinReason = value;
                    },
                    Icons.note,
                  ),
                  SizedBox(height: 16.0),
                  buildPhotoCard(),
                ],
                if (selectedForm == 'Overtime') ...[
                  buildDateFormField('Date', Icons.date_range),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: buildFormFieldWithIcon(
                          'Start Time',
                          Icons.access_time,
                          selectedTimeStart.format(context),
                          () async {
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (selectedTime != null) {
                              setState(() {
                                this.selectedTimeStart = selectedTime;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        flex: 1,
                        child: buildFormFieldWithIcon(
                          'End Time',
                          Icons.access_time,
                          selectedTimeEnd.format(context),
                          () async {
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (selectedTime != null) {
                              setState(() {
                                this.selectedTimeEnd = selectedTime;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  buildTextFormFieldWithIcon(
                    'Overtime Reason',
                    lemburReason,
                    (value) {
                      lemburReason = value;
                    },
                    Icons.note,
                  ),
                ],
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          int userId = prefs.getInt('user-id_user') ?? 0;
                          if (selectedForm == 'Absent') {
                            setState(() {
                              isLoading = true;
                            });
                            Uri apiUrl = Uri.parse(
                                '${globalVariable.baseUrl}/user-pengajuanAbsensi/');
                            Map<String, String> headers = {
                              'Content-Type': 'application/json',
                            };
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                            String formattedTime = selectedTime.format(context);
                            String jenis =
                                absenType == 'Clock In' ? 'in' : 'out';

                            Map<String, dynamic> requestBody = {
                              'user_id': userId,
                              'tgl': formattedDate,
                              'jam': formattedTime,
                              'jenis': jenis,
                              'bukti': absenURL,
                            };

                            try {
                              final response = await http.post(
                                apiUrl,
                                headers: headers,
                                body: json.encode(requestBody),
                              );

                              if (response.statusCode == 201) {
                                // Request successful
                                setState(() {
                                  dialogMessage =
                                      'Request has been submitted, please check your inbox periodically for confirmation updates';
                                  isDialogVisible = true;
                                  isLoading = false;
                                });
                                showMessageDialog(dialogMessage);
                                print('Request successful: ${response.body}');
                              } else {
                                // Request failed
                                setState(() {
                                  dialogMessage =
                                      'There was a problem with the application, please try again';
                                  isDialogVisible = true;
                                  isLoading = false;
                                });
                                showMessageDialog(dialogMessage);
                                print(
                                    'Failed to send request: ${response.statusCode}');
                              }
                            } catch (error) {
                              // An error occurred while sending the request
                              setState(() {
                                dialogMessage =
                                    'There was a problem with the application, please try again';
                                isDialogVisible = true;
                                isLoading = false;
                              });
                              showMessageDialog(dialogMessage);
                              print('An error occurred: $error');
                            }
                          } else if (selectedForm == 'Leave') {
                            setState(() {
                              isLoading = true;
                            });

                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                            String formattedTime = selectedTime.format(context);

                            // Ambil cuti_id dari dropdown agenda yang dipilih
                            String? selectedCutiId =
                                acaraOptionsList.firstWhere((element) =>
                                    element['name'] == ijinType)['id'];

                            Uri apiUrl = Uri.parse(
                                'http://103.29.214.154:9002/api_absensi/cuti/');
                            var request = http.MultipartRequest('POST', apiUrl);
                            request.headers['Content-Type'] =
                                'application/json';
                            request.fields['user'] = userId.toString();
                            request.fields['cuti_id'] =
                                selectedCutiId.toString();
                            request.fields['tanggal'] = formattedDate;
                            request.fields['time'] = formattedTime + ':00';
                            request.fields['note'] = ijinReason;

                            if (imageFile != null) {
                              final multipartFile = http.MultipartFile(
                                'bukti',
                                imageFile!.readAsBytes().asStream(),
                                imageFile!.lengthSync(),
                                filename: 'image.jpg', // Nama file yang sesuai
                                contentType: MediaType('image',
                                    'jpeg'), // Sesuaikan dengan jenis gambar yang diunggah
                              );
                              request.files.add(multipartFile);
                            }

                            try {
                              final response = await request.send();

                              if (response.statusCode == 200) {
                                // Permintaan berhasil
                                setState(() {
                                  dialogMessage =
                                      'Request has been submitted, please check your inbox periodically for confirmation updates';
                                  isDialogVisible = true;
                                  isLoading = false;
                                });
                                showMessageDialog(dialogMessage);
                              } else {
                                // Permintaan gagal
                                setState(() {
                                  dialogMessage =
                                      'There was a problem with the application, please try again';
                                  isDialogVisible = true;
                                  isLoading = false;
                                });
                                showMessageDialog(dialogMessage);
                                print(
                                    'Gagal mengirim permintaan: ${response.statusCode}');
                              }
                            } catch (error) {
                              // Terjadi kesalahan saat mengirim permintaan
                              setState(() {
                                dialogMessage =
                                    'Ada masalah dengan aplikasi, silakan coba lagi';
                                isDialogVisible = true;
                                isLoading = false;
                              });
                              showMessageDialog(dialogMessage);
                              print('Terjadi kesalahan: $error');
                            }
                          } else if (selectedForm == 'Overtime') {
                            setState(() {
                              isLoading = true;
                            });

                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(selectedDate);
                            String formattedStartTime =
                                selectedTimeStart.format(context);
                            String formattedEndTime =
                                selectedTimeEnd.format(context);

                            // Buat permintaan dengan metode POST ke endpoint lembur
                            Uri apiUrl = Uri.parse(
                                'http://103.29.214.154:9002/api_absensi/lembur/');
                            Map<String, String> headers = {
                              'Content-Type': 'application/json',
                            };

                            Map<String, dynamic> requestBody = {
                              'user': userId.toString(),
                              'tanggal': formattedDate,
                              'jam_mulai': formattedStartTime,
                              'jam_selesai': formattedEndTime,
                            };

                            try {
                              final response = await http.post(
                                apiUrl,
                                headers: headers,
                                body: json.encode(requestBody),
                              );

                              if (response.statusCode == 200) {
                                setState(() {
                                  dialogMessage =
                                      'Request has been submitted, please check your inbox periodically for confirmation updates';
                                  isDialogVisible = true;
                                  isLoading = false;
                                });
                                showMessageDialog(dialogMessage);
                                print('Permintaan berhasil: ${response.body}');
                              } else {
                                // Permintaan gagal
                                setState(() {
                                  dialogMessage =
                                      'There was a problem with the application, please try again';
                                  isDialogVisible = true;
                                  isLoading = false;
                                });
                                showMessageDialog(dialogMessage);
                                print(
                                    'Gagal mengirim permintaan: ${response.statusCode}');
                              }
                            } catch (error) {
                              // Terjadi kesalahan saat mengirim permintaan
                              setState(() {
                                dialogMessage =
                                    'There was a problem with the application, please try again';
                                isDialogVisible = true;
                                isLoading = false;
                              });
                              showMessageDialog(dialogMessage);
                              print('Terjadi kesalahan: $error');
                            }
                          }
                        },
                  child:
                      isLoading ? CircularProgressIndicator() : Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    
  }

  void showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Information'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();

                // Navigate to the "/inbox" route
                Navigator.of(context).pushNamed('/inbox');
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.0),
                backgroundColor: Color.fromARGB(255, 2, 65, 128),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildDateFormField(String labelText, IconData icon) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      readOnly: true,
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null && pickedDate != selectedDate)
          setState(() {
            selectedDate = pickedDate;
          });
      },
      controller: TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(selectedDate),
      ),
    );
  }

  Widget buildFormFieldWithIcon(
    String labelText,
    IconData icon,
    String value,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(labelText),
      subtitle: Text(value),
      onTap: onTap,
      leading: Icon(icon),
    );
  }

  Widget buildAbsenTypeRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
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
            Text('Clock In'),
            Radio(
              value: 'Clock Out',
              groupValue: absenType,
              onChanged: (value) {
                setState(() {
                  absenType = value.toString();
                });
              },
            ),
            Text('Clock Out'),
          ],
        ),
      ],
    );
  }

  Widget buildTextFormFieldWithIcon(
    String labelText,
    String value,
    Function(String) onChanged,
    IconData icon,
  ) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
      initialValue: value,
    );
  }

  // Method to take a picture from the camera
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

  Widget buildPhotoCard() {
    return Card(
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
                  Icon(
                    Icons.photo,
                    size: 100,
                    color: Colors.grey,
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Get Picture',
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
                  child: Icon(
                    Icons.close,
                    size: 20.0,
                    color: Colors.grey, // Close icon color
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Dropdown form field widget
  Widget buildDropdownFormField(
    String labelText,
    String? value,
    List<String> items,
    void Function(String?)? onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
          ),
        ),
      ],
    );
  }
}
