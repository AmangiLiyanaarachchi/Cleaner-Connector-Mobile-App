import 'dart:async';
// import 'dart:convert';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/History.dart';
import 'package:clean_connector/Screens/QRScanner.dart';
// import 'package:clean_connector/Screens/Site_recommandation.dart';
// import 'package:clean_connector/Screens/communication.dart';
// import 'package:clean_connector/Screens/site_profile.dart';
// import 'package:clean_connector/Screens/super_admin_profile.dart';
// import 'package:clean_connector/Screens/task_list.dart';

// import 'package:clean_connector/Screens/user_profile.dart';

import '../Controller/authController.dart';
import '../components/bottom_bar.dart';
// import 'IncidentReport.dart';
// import 'change_password.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';

class QRScanData extends StatefulWidget {
  @override
  State<QRScanData> createState() => _QRScanDataState();
}

class _QRScanDataState extends State<QRScanData> {
  bool isLoading = false;
  String profilePic = '';
  String name = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    // double screenHeight = MediaQuery.of(context).size.height;
    // double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "QR SCAN DATA",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
          // actions: <Widget>[
          //   Padding(
          //       padding: const EdgeInsets.only(right: 10.0),
          //       child: GestureDetector(
          //           onTap: () async {
          //             if (loginUserData['userType'] == 'client') {
          //               Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                   builder: (context) => SiteProfile(),
          //                 ),
          //               );
          //             } else if(loginUserData['userType'] == 'admin'){
          //               Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                   builder: (context) => SuperAdminProfile(),
          //                 ),
          //               );
          //             }
          //             else {
          //               Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                   builder: (context) => UserProfile(),
          //                 ),
          //               );
          //             }
          //           },
          //           child: CircleAvatar(
          //             radius: 18,
          //             backgroundColor: kiconColor,
          //             child: (loginUserData['userType'] == 'cleaner')
          //                 ? (loginUserProfile['image'] != null ?
          //                     CircleAvatar(
          //                       radius: 17,
          //                       backgroundImage:
          //                           NetworkImage(loginUserProfile['image']),
          //                     )
          //                   : CircleAvatar(
          //                       radius: 17,
          //                       backgroundColor: Colors.white,
          //                       child: Icon(
          //                         Icons.person,
          //                         color: kiconColor,
          //                       ),
          //                     )
          //                   ) : 
          //                   CircleAvatar(
          //                       radius: 17,
          //                       backgroundColor: Colors.white,
          //                       child: Icon(
          //                         Icons.person,
          //                         color: kiconColor,
          //                       ),
          //                     )
          //           ))),
          //   // logoutButton(),
          // ],
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10,top: 50),
            child: Column(
              children: [
                loginUserData['userType']!= 'admin' ?
                Card(
                  child: ListTile(
                    leading: Icon(Icons.qr_code),
                    title: Text("Scan QR Code", style: klistTitle,),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QRScanner()));
                    },
                  ),
                ) : SizedBox(),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: const Text("History", style: klistTitle,),
                    onTap: () {
                       Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => History()));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool? exitApp = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Logout ?",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            content: const Text(
              'Are you sure you want to Log Out ?',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )),
              TextButton(
                  onPressed: () async {
                    setState(() {
                      AuthController.logOut(context);
                    });
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )),
            ],
          );
        });
    return exitApp ?? false;
  }
}
