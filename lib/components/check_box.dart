import 'package:flutter/material.dart';

class CheckBoxForm extends StatefulWidget {
  const CheckBoxForm({super.key, required this.title});

  final String title;

  @override
  State<CheckBoxForm> createState() => _CheckBoxFormState();
}

class _CheckBoxFormState extends State<CheckBoxForm> {
  bool? _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.title),
      value: _isChecked,
      onChanged: (bool? newValue) {
        setState(() {
          _isChecked = newValue;
        });
      },
      activeColor: Colors.blue,
      checkColor: Colors.black,
      tileColor: Colors.black12,
      controlAffinity: ListTileControlAffinity.leading,
      tristate: true,
    );
  }
}
