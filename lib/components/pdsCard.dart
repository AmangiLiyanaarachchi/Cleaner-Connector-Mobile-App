import 'package:flutter/material.dart';

import '../Constant/style.dart';

class PdfCardModel extends StatelessWidget {
  final Widget widget;
  PdfCardModel({
    required this.widget,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      height: 80,
      //width: MediaQuery.of(context).size.width*0.5,
      decoration: BoxDecoration(
        color: kcardBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            offset: Offset(
              0.0,
              10.0,
            ),
            blurRadius: 3.0,
            spreadRadius: -6.0,
          ),
        ],
      ),
      child: widget,
    );
  }
}
