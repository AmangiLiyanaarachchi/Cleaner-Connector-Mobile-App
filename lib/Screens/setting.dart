import 'dart:async';
// import 'dart:convert';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/History.dart';
import 'package:clean_connector/Screens/Notification_screen.dart';
import 'package:clean_connector/Screens/QRScanData.dart';
// import 'package:clean_connector/Screens/QRScanner.dart';
import 'package:clean_connector/Screens/Site_recommandation.dart';
import 'package:clean_connector/Screens/communication.dart';
import 'package:clean_connector/Screens/site_profile.dart';
import 'package:clean_connector/Screens/super_admin_profile.dart';
import 'package:clean_connector/Screens/task_list.dart';
// import 'package:clean_connector/Screens/task_view.dart';
// import 'package:clean_connector/Screens/user_edit.dart';
import 'package:clean_connector/Screens/user_profile.dart';
import 'package:dio/dio.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import '../Constant/const_api.dart';
import '../Constant/const_api.dart';
import '../Controller/authController.dart';
import '../components/bottom_bar.dart';
import 'IncidentReport.dart';
// import 'change_password.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';

class Setting_Screen extends StatefulWidget {
  @override
  State<Setting_Screen> createState() => _Setting_ScreenState();
}

class _Setting_ScreenState extends State<Setting_Screen> {
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
      print("+++++++++++>" + loginUserData['userType']);
      final response = await Dio().get(
          '${BASE_API2}user/getCleanerUsersById/${loginUserData['id']}',
          options: Options(headers: {
            "Authorization": "Bearer " + loginUserData["accessToken"]
          }));
      print(response);
      print(response.data['status']);
      if (response.statusCode == 200 && response.data['status'] == true) {
        print(response.data['result']);
        print("Result");
        print(response.data['result'][0]['f_name']);
        setState(() {
          loginUserProfile['id'] = response.data['result'][0]['user_id'] ?? " ";
          loginUserProfile['name'] =
              response.data['result'][0]['f_name'] ?? " ";
          loginUserProfile['phone'] =
              response.data['result'][0]['phone'] ?? " ";
          loginUserProfile['email'] =
              response.data['result'][0]['email'] ?? " ";
          loginUserProfile['image'] =
              response.data['result'][0]['image'] ?? " ";
          loginUserProfile['site_name'] =
              response.data['result'][0]['site_name'] ?? " ";
          loginUserProfile['site_address'] =
              response.data['result'][0]['site_address'] ?? " ";
        });
        print(loginUserProfile['name']);
        print(loginUserProfile['id']);
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
            "SETTINGS",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () async {
                      if (loginUserData['userType'] == 'client') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SiteProfile(),
                          ),
                        );
                      } else if (loginUserData['userType'] == 'admin') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuperAdminProfile(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfile(),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                        radius: 18,
                        backgroundColor: kiconColor,
                        child: (loginUserData['userType'] == 'cleaner')
                            ? (loginUserProfile['image'] != null
                                ? CircleAvatar(
                                    radius: 17,
                                    backgroundImage:
                                        NetworkImage(loginUserProfile['image']),
                                  )
                                : CircleAvatar(
                                    radius: 17,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      color: kprofileincon,
                                    ),
                                  ))
                            : CircleAvatar(
                                radius: 17,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: kprofileincon,
                                ),
                              )))),
            if (loginUserData['userType'] != 'cleaner')
              IconButton(
                icon: Icon(Icons.notifications, color: kprofileincon),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(),
                    ),
                  );
                },
              ),
            // logoutButton(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
          child: Column(
            children: [
              // Container(
              //   height: screenHeight * 0.24,
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
              //         height: 5,
              //       ),
              //       Text(
              //         loginUserProfile['fname'],
              //         style: kTitle,
              //       ),
              //       const SizedBox(
              //         height: 5,
              //       ),
              //       Text(loginUserProfile['email'].toString(),
              //           style: kSubTitle),
              //     ],
              //   ),
              // ),
              // Container(
              //   decoration: BoxDecoration(
              //       color: kcardBackgroundColor,
              //       borderRadius: BorderRadius.circular(50)),
              //   width: screenWidth,
              //   height: 3,
              // ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(children: [
//                                 Row(
//                                     children: [
//                                       const Icon(Icons.notifications_active_rounded, color: kiconColor,),
//                                       const SizedBox(width: 20,),
//                                       Container(
// // width: 130,
//                                         child: const Text(
//                                           "Notifications ",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: Colors.black,
//                                               fontFamily: "OpenSans"),
//                                         ),
//                                       ),
//                                     ]
//                                 ),
                        SizedBox(
                          height: 30,
                        ),
                        // Row(children: [
                        //   Icon(
                        //     Icons.password,
                        //     color: kiconColor,
                        //   ),
                        //   SizedBox(
                        //     width: 20,
                        //   ),
                        //   Container(
                        //     child: GestureDetector(
                        //       onTap: () {
                        //         Navigator.push(
                        //             context,
                        //             MaterialPageRoute(
                        //                 builder: (context) =>
                        //                     ChangePassword()));
                        //       },
                        //       child: const Text(
                        //         "Change Password ",
                        //         style: TextStyle(
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 15,
                        //             color: Colors.black,
                        //             fontFamily: "OpenSans"),
                        //       ),
                        //     ),
                        //   ),
                        // ]),
                        // SizedBox(
                        //   height: 30,
                        // ),
                        Row(children: [
                          Icon(
                            Icons.chat,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Communication()));
                              },
                              child: const Text(
                                "Communication ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontFamily: "OpenSans"),
                              ),
                            ),
                          ),
                        ]),
                        SizedBox(
                          height: 30,
                        ),
                        Row(children: [
                          Icon(
                            Icons.recommend_outlined,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SiteRecomondationScreen()));
                              },
                              child: const Text(
                                "Site Recommendation ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontFamily: "OpenSans"),
                              ),
                            ),
                          ),
                        ]),
                        SizedBox(
                          height: 30,
                        ),
                        Row(children: [
                          Icon(
                            Icons.picture_as_pdf_outlined,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Incident()));
                              },
                              child: const Text(
                                "Incident Report ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontFamily: "OpenSans"),
                              ),
                            ),
                          ),
                        ]),
                        SizedBox(
                          height: 30,
                        ),

                        Row(children: [
                          Icon(
                            Icons.qr_code,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                loginUserData['userType'] == 'cleaner'
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => QRScanData()))
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => History()));
                              },
                              child: const Text(
                                "QR Scan Data",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontFamily: "OpenSans"),
                              ),
                            ),
                          ),
                        ]),

                        SizedBox(
                          height: 30,
                        ),
                        Row(children: [
                          Icon(
                            Icons.logout,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            child: GestureDetector(
                              onTap: () async {
                                _onBackButtonPressed(context);
                              },
                              child: const Text(
                                "Log Out ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontFamily: "OpenSans"),
                              ),
                            ),
                          ),
                        ]),
                      ])),
                ],
              )),
            ],
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
