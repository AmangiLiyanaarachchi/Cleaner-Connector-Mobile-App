import 'package:flutter/material.dart';

class TextForm extends StatelessWidget {
  const TextForm({
    super.key,
    required this.controller,
    required this.text,
    required this.textInputType,
    this.validator,
    required this.isEnabled,
    this.maxLength,
  });
  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  final bool isEnabled;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 7)
          ]),
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: TextFormField(
          maxLength: maxLength,
          validator: validator,
          controller: controller,
          enabled: true,
          keyboardType: textInputType,
          decoration: InputDecoration(hintText: text, border: InputBorder.none),
        ),
      ),
    );
  }
}
