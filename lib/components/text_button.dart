// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../Constant/style.dart';

class Buttons_in_form extends StatelessWidget {
  Buttons_in_form({required this.icon, required this.text});
  Widget icon;
  Widget text;

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Container(
        width: screenWidth*0.5,
        height: 40,
        decoration: BoxDecoration(
          color: kiconColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(3, 3),
              blurRadius: 2,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: icon,
              onPressed: () {},
            ),
            const SizedBox(
              width: 10,
            ),
            isLoading
                ? const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: SpinKitDualRing(
                color: Colors.white,
                size: 30,
              ),
            )
                : text
            // Text(text,
            //     style: const TextStyle(
            //         fontWeight: FontWeight.bold,
            //         fontSize: 12,
            //         color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
