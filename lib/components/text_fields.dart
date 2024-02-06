import 'package:flutter/material.dart';


class TextForm extends StatelessWidget {
  TextForm({
    super.key,
    required this.controller,
    required this.text,
    required this.textInputType,
    this.validator,
    required this.isEnabled,
  });
  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(
          horizontal: 20), //text box text and border gap
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 7)
          ]),
      child: TextFormField(
        keyboardType: textInputType,
        enabled: true,
        validator: validator,
        controller: controller,
        decoration: InputDecoration(
            hintText: text,
            border: InputBorder.none,
            hintStyle: TextStyle(
              fontSize: 15,
            )),
      ),
    );
  }
}
