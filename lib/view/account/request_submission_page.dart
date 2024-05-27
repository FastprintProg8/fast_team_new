// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:Fast_Team/controller/account_controller.dart';
import 'package:Fast_Team/model/account_information_model.dart';
import 'package:Fast_Team/style/color_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RequestSubmissionPage extends StatefulWidget {
  const RequestSubmissionPage({super.key});

  @override
  State<RequestSubmissionPage> createState() => _RequestSubmissionPageState();
}

class _RequestSubmissionPageState extends State<RequestSubmissionPage> {
  var email;
  var nama;
  var fullname;
  var divisiName;
  var namaLokasi;
  var jenisKelamin;
  var tempatLahir;
  var tanggalLahir;
  var noHp;
  var statusPerinkahan;
  var agama;
  var nomorID;
  var alamatIdentitas;
  var alamatTinggal;
  var bank;
  var nomorRekening;
  var change;
  var extension;

  bool isLoading = true;
  Future? _loadData;

  List<Map<String, dynamic>> items = [];
  Map<String, dynamic>? selectedItem;
  int? selectedNum;
  List<Map<String, dynamic>> listPernikahan = [
    {'value': 'Single', 'label': 'Single'},
    {'value': 'Married', 'label': 'Married'},
    {'value': 'Divorce', 'label': 'Divorce'},
  ];

  List<Map<String, dynamic>> listJenisKelamin = [
    {'value': 'Mele', 'label': 'Mele'},
    {'value': 'Femele', 'label': 'Femele'},
  ];

  List<Map<String, dynamic>> listAgama = [
    {'value': 'Islam', 'label': 'Islam'},
    {'value': 'Kristen', 'label': 'Kristen'},
    {'value': 'Katolik', 'label': 'Katolik'},
    {'value': 'Hindu', 'label': 'Hindu'},
    {'value': 'Budha', 'label': 'Budha'},
    {'value': 'Konghucu', 'label': 'Konghucu'},
    {'value': 'Lainya', 'label': 'Lainya'},
  ];

  Map<String, Color> extensionColors = {
    'pdf': ColorsTheme.lightRed!,
    'doc': ColorsTheme.primary!,
    'docx': ColorsTheme.primary!,
    'xls': ColorsTheme.lightGreen!,
    'xlsx': ColorsTheme.lightGreen!,
    'ppt': Colors.orange,
    'pptx': Colors.orange,
    'jpg': Colors.purple,
    'jpeg': Colors.purple,
    'png': Colors.purple,
    'gif': Colors.purple,
  };

  // List<Map<String, dynamic>> listBank = [];
  List<Map<String, dynamic>> listBank = [
    {'label': 'BCA', 'value': 1},
    {'label': 'Mandiri', 'value': 2},
  ];

  Color getColorForExtension(String extension) {
    if (extensionColors.containsKey(extension.toLowerCase())) {
      return extensionColors[extension.toLowerCase()]!;
    } else {
      return Colors.brown;
    }
  }

  TextStyle alertErrorTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: ColorsTheme.white,
  );
  @override
  void initState() {
    super.initState();
    initConstructor();
    initData();
  }

  initConstructor() {
    email = ''.obs;
    nama = ''.obs;
    fullname = ''.obs;
    divisiName = ''.obs;
    namaLokasi = ''.obs;
    jenisKelamin = ''.obs;
    tempatLahir = ''.obs;
    tanggalLahir = ''.obs;
    noHp = ''.obs;
    statusPerinkahan = ''.obs;
    agama = ''.obs;
    nomorID = 0.obs;
    alamatIdentitas = ''.obs;
    alamatTinggal = ''.obs;
    bank = ''.obs;
    nomorRekening = ''.obs;
  }

  initData() async {
    setState(() {
      isLoading = false;
      _loadData = initializeState();
    });
  }

  Future<void> initializeState() async {
    await retriveAccountInformation();
    // await retriveListBank();
  }

  // retriveListBank()async {
  //   AccountController accountController = Get.put(AccountController());
  //   var bank = await accountController.retrieveEmployeeBank();
  //   setState(() {
  //     listBank = bank['details'];
  //   });
  // }

  retriveAccountInformation() async {
    AccountController accountController = Get.put(AccountController());

    var result = await accountController.retriveAccountInformation();
    AccountInformationModel accountModel =
        AccountInformationModel.fromJson(result['details']['data']);
    email = accountModel.email;
    fullname = accountModel.fullName;
    divisiName.value = accountModel.divisi;
    jenisKelamin.value = accountModel.gender;
    tempatLahir.value = accountModel.tempatLahir;
    tanggalLahir.value = accountModel.tanggalLahir;
    noHp.value = accountModel.nomorHp;
    statusPerinkahan.value = accountModel.statusKawin;
    agama.value = accountModel.agama;
    nomorID.value = accountModel.nomorKtp;
    alamatIdentitas.value = accountModel.alamatKtp;
    alamatTinggal.value = accountModel.alamatTinggal;
    bank.value = accountModel.bank;
    nomorRekening.value = accountModel.nomorRekening;
    items = [
      {'no': 1, 'value': 'Nama Lengkap', 'data': '$fullname'},
      {'no': 2, 'value': 'Email', 'data': '$email'},
      {'no': 3, 'value': 'Jenis Kelamin', 'data': '$jenisKelamin'},
      {'no': 4, 'value': 'Tempat Lahir', 'data': '$tempatLahir'},
      {'no': 5, 'value': 'Tanggal Lahir', 'data': '$tanggalLahir'},
      {'no': 6, 'value': 'Handphone', 'data': '$noHp'},
      {'no': 7, 'value': 'Status Pernikahan', 'data': '$statusPerinkahan'},
      {'no': 8, 'value': 'Agama', 'data': '$agama'},
      {'no': 9, 'value': 'Nomor KTP', 'data': '$nomorID'},
      {'no': 10, 'value': 'Alamat KTP', 'data': '$alamatIdentitas'},
      {'no': 11, 'value': 'Alamat Tinggal', 'data': '$alamatTinggal'},
      {'no': 12, 'value': 'Nama Bank', 'data': '$bank'},
      {'no': 13, 'value': 'Nomor Rekening', 'data': '$nomorRekening'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Request Change Data',
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
            showAlertDialog(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: _loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return contentBody();
          } else if (snapshot.hasError) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              var snackbar = SnackBar(
                content: Text('Error: ${snapshot.error}',
                    style: alertErrorTextStyle),
                backgroundColor: ColorsTheme.lightRed,
                behavior: SnackBarBehavior.floating,
              );
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            });
            return contentBody();
          } else if (snapshot.hasData) {
            return contentBody();
          } else {
            return contentBody();
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          floatingButton(
            context,
            'Submit',
            Colors.blue[800]!,
            ColorsTheme.white!,
            () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Menu masih belum tersedia",
                    style: alertErrorTextStyle),
                backgroundColor: ColorsTheme.lightRed,
                behavior: SnackBarBehavior.floating,
              ));
            },
          ),
          floatingButton(
            context,
            'Cancel',
            ColorsTheme.whiteCream!,
            ColorsTheme.black!,
            () {
              showAlertDialog(context);
            },
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget floatingButton(BuildContext context, String label, Color color,
      Color colorLabel, VoidCallback onPressed) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              color, // Menggunakan warna yang diberikan sebagai warna latar belakang tombol
        ),
        child: Text(
          label,
          style: TextStyle(color: colorLabel),
        ),
      ),
    );
  }

  Widget contentBody() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          choiceData(),
          buildFormWidget(),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(
                color: ColorsTheme.black, // Warna label yang ditetapkan
              ),
              prefixIcon: const Icon(Icons.article),
            ),
            // onChanged: (){},
            // initialValue: value,
          ),
          uploadFile(),
        ],
      ),
    );
  }

  Widget buildFormWidget() {
    if (selectedNum == null) {
      return textForm();
    }
    switch (selectedNum) {
      case 6:
      case 9:
        return numberForm();
      case 2:
        return emailForm();
      case 3:
        return selectedForm(listJenisKelamin);
      case 5:
        return dateForm(context);
      case 7:
        return selectedForm(listPernikahan);
      case 8:
        return selectedForm(listAgama);
      case 12:
        return selectedForm(listBank);
      case 13:
        return numberForm();
      default:
        return textForm();
    }
  }

  Widget uploadFile() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom:
              BorderSide(color: Color.fromARGB(255, 136, 133, 133), width: 1.w),
        ),
      ),
      margin: EdgeInsets.only(top: 15.w),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              children: [
                Icon(
                  Icons.folder,
                  color: Color.fromARGB(255, 73, 72, 72),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text(
                    'Upload File',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Color.fromARGB(255, 100, 98, 98),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: 10.w,
              ),
              InkWell(
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    PlatformFile file = result.files.first;
                    print('File path: ${file.path}');
                    print('File name: ${file.name}');
                    print('File bytes: ${file.bytes}');
                    print('File size: ${file.size}');
                    print('File extension: ${file.extension}');
                    setState(() {
                      extension = file.extension;
                    });
                  } else {}
                },
                child: extension == null
                    ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 10.w),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(255, 100, 98, 98)),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.r),
                            )),
                        child: Icon(
                          Icons.add,
                          size: 50.sp,
                          color: Color.fromARGB(255, 100, 98, 98),
                        ),
                      )
                    : Container(
                        height: 100.w,
                        width: 100.w,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 10.w),
                        decoration: BoxDecoration(
                            color: getColorForExtension(extension),
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.r),
                            )),
                        child: Center(
                            child: Text(
                          '.${extension}',
                          style: TextStyle(
                              color: ColorsTheme.white,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
              ),
              SizedBox(
                height: 10.w,
              ),
              Text(
                'Maximum size is 10 MB',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Color.fromARGB(255, 100, 98, 98),
                ),
              ),
              SizedBox(
                height: 10.w,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget textForm() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Change To',
        labelStyle: TextStyle(
          color: ColorsTheme.black, // Warna label yang ditetapkan
        ),
        prefixIcon: const Icon(Icons.edit),
      ),
      // onChanged: (){},
      // initialValue: value,
    );
  }

  // Widget multiTextForm() {
  //   return TextFormField(
  //     keyboardType: TextInputType.multiline,
  //     maxLines: 4,
  //     decoration: InputDecoration(
  //       labelText: 'Change To',
  //       labelStyle: TextStyle(
  //         color: ColorsTheme.black, // Warna label yang ditetapkan
  //       ),
  //       prefixIcon: Icon(Icons.edit),
  //     ),
  //     // onChanged: (){},
  //     // initialValue: value,
  //   );
  // }

  Widget numberForm() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Change To',
        labelStyle: TextStyle(
          color: ColorsTheme.black, // Warna label yang ditetapkan
        ),
        prefixIcon: const Icon(Icons.edit),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      // onChanged: (){},
      // initialValue: value,
    );
  }

  Widget emailForm() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Change To',
        labelStyle: TextStyle(
          color: ColorsTheme.black, // Warna label yang ditetapkan
        ),
        prefixIcon: const Icon(Icons.edit),
      ),
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            !value.contains('@') ||
            !value.contains('.')) {
          return 'Invalid Email';
        }
        return null;
      },
      // onChanged: (){},
      // initialValue: value,
    );
  }

  Widget dateForm(BuildContext context) {
    final TextEditingController _controller = TextEditingController(
      text: change != null ? DateFormat('yyyy-MM-dd').format(change!) : '',
    );

    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Change To',
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        prefixIcon: Icon(Icons.edit),
      ),
      readOnly: true,
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          initialDate: change ?? DateTime.now(),
        );

        if (pickedDate != null && pickedDate != change) {
          setState(() {
            change = pickedDate;
            _controller.text = DateFormat('yyyy-MM-dd').format(change!);
          });
        }
      },
      controller:
          _controller, // Gunakan TextEditingController yang telah dibuat
    );
  }

  Widget selectedForm(List<Map<String, dynamic>> option) {
    return Container(
      margin: EdgeInsets.only(top: 10.w),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Change To',
          labelStyle: TextStyle(
            color: Colors.black,
          ),
          prefixIcon: Icon(Icons.edit),
        ),
        value: change,
        items: option
            .map((item) => DropdownMenuItem<Map<String, dynamic>>(
                  value: item,
                  child: Text(item['label']!),
                ))
            .toList(),
        onChanged: (item) {
          setState(() {
            change = item;
            // Lakukan aksi yang diperlukan saat item dipilih
          });
        },
        selectedItemBuilder: (BuildContext context) {
          return option.map<Widget>((item) {
            return Text(
              "${item['label']}",
              style: TextStyle(fontSize: 12.sp),
              overflow: TextOverflow.ellipsis,
            );
          }).toList();
        },
      ),
    );
  }

  Widget choiceData() {
    return Container(
      margin: EdgeInsets.only(top: 10.w),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Choice Data', // Label untuk dropdown
          labelStyle: TextStyle(
            color: ColorsTheme.black, // Warna label yang ditetapkan
          ),
          prefixIcon: const Icon(Icons.assignment),
        ),
        items: items
            .map((item) => DropdownMenuItem<Map<String, dynamic>>(
                  value: item,
                  child: Text(item['value']!),
                ))
            .toList(),
        value: selectedItem,
        onChanged: (item) {
          setState(() {
            change = null;
            selectedItem = item;
            selectedNum = item!['no'];
          });
        },
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((item) {
            return Text(
              "${item['value']} : ${item['data']!}",
              style: TextStyle(fontSize: 12.sp),
              overflow: TextOverflow.ellipsis,
            );
          }).toList();
        },
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget yesButton = InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Text(
          "Yes",
          style: TextStyle(fontSize: 15.sp),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
    Widget noButton = InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Text(
          "No",
          style: TextStyle(fontSize: 15.sp),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.r))),
      backgroundColor: ColorsTheme.white,
      content: Text(
        "Are you sure want to cancel the request ?",
        style: TextStyle(fontSize: 15.sp),
      ),
      actions: [
        noButton,
        yesButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
