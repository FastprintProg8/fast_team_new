import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectedForm extends StatefulWidget {
  final List<String> option;

  SelectedForm({required this.option});

  @override
  _SelectedFormState createState() => _SelectedFormState();
}

class _SelectedFormState extends State<SelectedForm> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.w),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Change To',
          labelStyle: TextStyle(
            color: Colors.black,
          ),
          prefixIcon: Icon(Icons.edit),
        ),
        value: selectedValue,
        items: widget.option
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: (item) {
          setState(() {
            selectedValue = item; // Update nilai yang dipilih
          });
          // Lakukan aksi yang diperlukan saat item dipilih di luar setState jika diperlukan
        },
        selectedItemBuilder: (BuildContext context) {
          return widget.option.map<Widget>((item) {
            return Text(
              "$item",
              style: TextStyle(fontSize: 12.sp),
              overflow: TextOverflow.ellipsis,
            );
          }).toList();
        },
      ),
    );
  }
}
