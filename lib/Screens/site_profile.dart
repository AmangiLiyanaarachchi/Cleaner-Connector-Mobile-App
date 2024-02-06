import 'dart:async';
// import 'dart:convert';
// import 'package:clean_connector/Constant/style.dart';
// import 'package:clean_connector/Screens/task_list.dart';
// import 'package:clean_connector/Screens/user_edit.dart';
// import 'package:clean_connector/Screens/user_profile_edit.dart';
// import 'package:clean_connector/Constant/const_api.dart';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/login_screen.dart';

// import 'package:clean_connector/Screens/communication_admin_login.dart';
import 'package:clean_connector/Screens/task_list.dart';
// import 'package:clean_connector/Screens/user_profile_edit.dart';
// import 'package:cleanerconnectapp/Login.dart';
// import 'package:cleanerconnectapp/const_api.dart';
// import 'package:cleanerconnectapp/logoutButton.dart';
// import 'package:cleanerconnectapp/style.dart';
// import 'package:cleanerconnectapp/task_list.dart';
// import 'package:cleanerconnectapp/user_profile_edit.dart';
import 'package:dio/dio.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:intl/intl.dart';
// import '../Constant/const_api.dart';
// import '../Controller/authController.dart';
// import '../components/bottom_bar.dart';
// import 'login_screen.dart';
import 'package:flutter/material.dart';

import '../Constant/const_api.dart';

class SiteProfile extends StatefulWidget {
  @override
  State<SiteProfile> createState() => _SiteProfileState();
}

class _SiteProfileState extends State<SiteProfile> {
  bool isLoading = false;
  String profilePic = '';
  String name = '';
  String email = '';
  String date = '';

  Future getProfile() async {
    print("Data loading....2");
    setState(() {
      isLoading = true;
    });
    print(loginUserData["accessToken"]);
    // print("${loginUserProfile['id']}");
    // String id = loginUserData['id'];
    // print(loginUserData['id']);
    try {
      print("+++++++++++>" + loginUserData['id']);
      // ${loginUserData['id']}
      final response = await Dio().get(
          '${BASE_API2}site/get-sites/${loginUserData['id']}',
          options: Options(headers: {
            "Authorization": "Bearer " + loginUserData["accessToken"]
          }));
      print(response.statusCode);
      print(response.data['status']);
      if (response.statusCode == 200 && response.data['status'] == true) {
        print(response.data['sites']);
        print("Result");
        print(response.data['sites'][0]['site_name']);
        setState(() {
          loginUserProfile['id'] = response.data['sites'][0]['site_id'] ?? " ";
          loginUserProfile['name'] =
              response.data['sites'][0]['site_address'] ?? " ";
          loginUserProfile['phone'] = response.data['sites'][0]['mobile'] ?? " ";
          loginUserProfile['email'] =
              response.data['sites'][0]['site_email'] ?? " ";
          // loginUserProfile['image'] = response.data['result'][0]['image'] ?? " ";
          loginUserProfile['site_name'] =
              response.data['sites'][0]['site_name'] ?? " ";
          loginUserProfile['rate'] = response.data['sites'][0]['rate'].toString() ?? " ";
        });
        print(loginUserProfile['name']);
        print(loginUserProfile['id']);
        print(loginUserProfile['rate']);
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  void initState() {
    isLoading = true;
    loading();
    // if (loginUserProfile['dob'] != null) {
    //   final dateParts = loginUserProfile['dob'].split('T')[0].split('-');
    //   if (dateParts.length == 3) {
    //     final year = int.parse(dateParts[0]);
    //     final month = int.parse(dateParts[1]);
    //     final day = int.parse(dateParts[2]);
    //     DateTime dob = DateTime(year, month, day);
    //     setState(() {
    //       date = DateFormat("yyyy-MM-dd").format(dob);
    //     });
    //   } else {
    //     date = 'Invalid Date';
    //   }
    // } else {
    //   date = 'No Date Provided';
    // }

    // Get.closeAllSnackbars;
    super.initState();
    print("???????????????????");
  }

  loading() async {
    await getProfile();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "SITE PROFILE",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            // logoutButton(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
          child: Column(
            children: [
              // Container(
              //   height: screenHeight * 0.2,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       CircleAvatar(
              //         radius: screenWidth / 8.5,
              //         backgroundColor: kcardBackgroundColor,
              //         child: (loginUserProfile['image'] != null)
              //             ? CircleAvatar(
              //                 radius: screenWidth / 9,
              //                 backgroundColor: Colors.white,
              //                 backgroundImage:
              //                     NetworkImage(loginUserProfile['image']),
              //               )
              //             : CircleAvatar(
              //                 radius: screenWidth / 9,
              //                 backgroundColor: Colors.white,
              //                 child: Icon(
              //                   Icons.person,
              //                   color: kiconColor,
              //                 ),
              //               ),
              //       ),
              //       const SizedBox(
              //         height: 15,
              //       ),
              //       Text(
              //         loginUserProfile['name'],
              //         style: kTitle,
              //       ),
              //       // const SizedBox(height: 15,),
              //       // Text(
              //       //   widget.emailAdd.toString(),
              //       //   style: kTitle
              //       // ),
              //     ],
              //   ),
              // ),
              Container(
                decoration: BoxDecoration(
                    color: kcardBackgroundColor,
                    borderRadius: BorderRadius.circular(50)),
                width: screenWidth,
                height: 3,
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Column(children: [
                        Row(children: [
                          Icon(
                            Icons.person,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: screenWidth * 0.2,
                            child: const Text(
                              "Site Name ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: kiconColor,
                                  fontFamily: "OpenSans"),
                            ),
                          ),
                          Container(
                            width: 10,
                            child: const Text(
                              ":",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: kiconColor,
                                  fontFamily: "OpenSans"),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              loginUserProfile['site_name'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black26,
                                  fontFamily: "OpenSans"),
                              maxLines: 3,
                            ),
                          )
                        ]),
                        SizedBox(
                          height: 30,
                        ),
                        Row(children: [
                          Icon(
                            Icons.email_outlined,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: screenWidth * 0.2,
                            child: const Text(
                              "Site Email",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: kiconColor,
                                  fontFamily: "OpenSans"),
                            ),
                          ),
                          Container(
                            width: 10,
                            child: const Text(
                              ":",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: kiconColor,
                                  fontFamily: "OpenSans"),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              loginUserProfile['email'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black26,
                                  fontFamily: "OpenSans"),
                              maxLines: 3,
                            ),
                          )
                        ]),
                        SizedBox(
                          height: 30,
                        ),
                        Row(children: [
                          Icon(
                            Icons.location_on,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: screenWidth * 0.2,
                            child: const Text(
                              "Site Address",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: kiconColor,
                                  fontFamily: "OpenSans"),
                            ),
                          ),
                          Container(
                            width: 10,
                            child: const Text(
                              ":",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: kiconColor,
                                  fontFamily: "OpenSans"),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              loginUserProfile['name'],
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black26,
                                  fontFamily: "OpenSans"),
                              maxLines: 3,
                            ),
                          )
                        ]),
                        SizedBox(
                          height: 30,
                        ),
                        Row(children: [
                          Icon(
                            Icons.phone,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: screenWidth * 0.2,
                            child: const Text(
                              "Phone Number ",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: kiconColor,
                                  fontFamily: "OpenSans"),
                            ),
                          ),
                          Container(
                            width: 10,
                            child: const Text(
                              ":",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: kiconColor,
                                  fontFamily: "OpenSans"),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              (loginUserProfile['phone'] != null)
                                  ? "0" + loginUserProfile['phone'].toString()
                                  : "",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.black26,
                                  fontFamily: "OpenSans"),
                              maxLines: 3,
                            ),
                          )
                        ]),
                        SizedBox(
                          height: 30,
                        ),
                        (loginUserData['userType'] != "admin")
                            ? Row(children: [
                                Icon(
                                  Icons.location_history,
                                  color: kiconColor,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  width: screenWidth * 0.2,
                                  child: const Text(
                                    "Site Rate",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: kiconColor,
                                        fontFamily: "OpenSans"),
                                  ),
                                ),
                                Container(
                                  width: 10,
                                  child: const Text(
                                    ":",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: kiconColor,
                                        fontFamily: "OpenSans"),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    (loginUserProfile['rate'] != null)
                                        ? loginUserProfile['rate']
                                        : '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.black26,
                                        fontFamily: "OpenSans"),
                                    maxLines: 3,
                                  ),
                                )
                              ])
                            : SizedBox(
                                height: 10,
                              ),
                      ])),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Container(
                        //   width: 40,
                        //   height: 40,
                        //   decoration: BoxDecoration(
                        //     shape: BoxShape.circle,
                        //     color: kiconColor,
                        //   ),
                        //   // child: IconButton(
                        //   //   icon: Icon(
                        //   //     Icons.edit,
                        //   //     color: Colors.white,
                        //   //   ),
                        //   //   onPressed: () {
                        //   //     Navigator.push(
                        //   //         context,
                        //   //         MaterialPageRoute(
                        //   //             builder: (context) => UserProfileEdit(
                        //   //                   userid: loginUserProfile['id'],
                        //   //                   username: loginUserProfile['name'],
                        //   //                   emailAdd: loginUserProfile['email'],
                        //   //                   birthDay: date,
                        //   //                   mobile: loginUserProfile['phone']
                        //   //                       .toString(),
                        //   //                   suburbs: loginUserProfile[
                        //   //                       'site_address'],
                        //   //                   image: loginUserProfile['image'],
                        //   //                   type: loginUserData['userType'],
                        //   //                 )));
                        //   //   },
                        //   // ),
                        // ),
                      ],
                    ),
                  )
                ],
              )),
            ],
          ),
        ),
        // bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}
