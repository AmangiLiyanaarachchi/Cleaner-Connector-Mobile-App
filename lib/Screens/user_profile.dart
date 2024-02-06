// import 'dart:async';
// import 'dart:convert';
// import 'package:clean_connector/Constant/style.dart';
// import 'package:clean_connector/Screens/task_list.dart';
// import 'package:clean_connector/Screens/user_edit.dart';
// import 'package:clean_connector/Screens/user_profile_edit.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:intl/intl.dart';
// import '../Constant/const_api.dart';
// import '../Controller/authController.dart';
// import '../components/bottom_bar.dart';
// import 'login_screen.dart';
// import 'package:flutter/material.dart';

// class UserProfile extends StatefulWidget {
//   @override
//   State<UserProfile> createState() => _UserProfileState();
// }

// class _UserProfileState extends State<UserProfile> {
//   bool isLoading = false;
//   String profilePic = '';
//   String name = '';
//   String email = '';
//   String date = '';

//   @override
//   void initState() {
//     // Get.closeAllSnackbars;
//     super.initState();
//     setState(() {
//       isLoading = true;
//     });
//     print("Data loading....setting ${loginUserData["userType"]}");
//     loginUserData['userType'] == "cleaner"
//         ? getProfileCleaner()
//         : loginUserData['userType'] == "client"
//             ? getProfileClient()
//             : getProfileClient();
//     setState(() {
//       isLoading = false;
//     });
//   }

//   Future getProfileCleaner() async {
//     print("Cleaner Profile");
//     print("Data loading....setting ${loginUserData["id"]}");

//     setState(() {
//       isLoading = true;
//     });
//     print(loginUserData["accessToken"]);
//     String user_id = loginUserData["id"];
//     try {
//       final response = await Dio().get(
//           BASE_API2 + "user/getCleanerUsersById/" + user_id,
//           options: Options(headers: {
//             "Authorization": "Bearer " + loginUserData["accessToken"]
//           }));
//       print(response.data['result'][0]['f_name']);
//       if (response.statusCode == 200 && response.data['status'] == true) {
//         print(response.data['result']);
//         setState(() {
//           loginUserProfile['id'] = response.data['result'][0]['user_id'] ?? " ";
//           loginUserProfile['fname'] =
//               response.data['result'][0]['f_name'] ?? " ";
//           loginUserProfile['lname'] =
//               response.data['result'][0]['l_name'] ?? " ";
//           loginUserProfile['phone'] =
//               response.data['result'][0]['phone'] ?? " ";
//           loginUserProfile['siteId'] =
//               response.data['result'][0]['site_id'] ?? " ";
//           loginUserProfile['email'] =
//               response.data['result'][0]['email'] ?? " ";
//           loginUserProfile['image'] =
//               response.data['result'][0]['image'] ?? " ";
//         });
//         print("***" + loginUserProfile['id']);
//         print(loginUserProfile['fname']);
//       }
//     } catch (e) {
//       print(e.toString());
//       setState(() {
//         isLoading = false;
//       });
//       print(e);
//     }
//   }

//   Future getProfileClient() async {
//     print("Client Profile");
//     print("Data loading....setting ${loginUserData["id"]}");
//     String site_id = loginUserData["id"];
//     setState(() {
//       isLoading = true;
//     });
//     print(loginUserData["accessToken"]);
//     try {
//       final response = await Dio().get(BASE_API2 + "site/get-sites/" + site_id,
//           options: Options(headers: {
//             "Authorization": "Bearer " + loginUserData["accessToken"]
//           }));
//       if (response.statusCode == 200 && response.data['status'] == true) {
//         print(response.data['sites']);
//         setState(() {
//           loginUserProfile['id'] = response.data['sites'][0]['site_id'] ?? " ";
//           loginUserProfile['fname'] =
//               response.data['sites'][0]['site_name'] ?? " ";
//           loginUserProfile['lname'] =
//               response.data['sites'][0]['site_address'] ?? " ";
//           loginUserProfile['phone'] =
//               response.data['sites'][0]['user_id'] ?? " ";
//           loginUserProfile['siteId'] =
//               response.data['sites'][0]['site_id'] ?? " ";
//           loginUserProfile['email'] =
//               response.data['sites'][0]['site_email'] ?? " ";
//         });
//         print("***" + loginUserProfile['id']);
//         print(loginUserProfile['fname']);
//       }
//     } catch (e) {
//       print(e.toString());
//       setState(() {
//         isLoading = false;
//       });
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         resizeToAvoidBottomInset: false,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           centerTitle: true,
//           title: Text(
//             "USER PROFILE",
//             style: kboldTitle,
//           ),
//           backgroundColor: Colors.white,
//           actions: <Widget>[
//             logoutButton(),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
//           child: Column(
//             children: [
//               Container(
//                 height: screenHeight * 0.2,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircleAvatar(
//                       radius: screenWidth / 8.5,
//                       backgroundColor: kcardBackgroundColor,
//                       child: (loginUserProfile['image'] != null)
//                           ? CircleAvatar(
//                               radius: screenWidth / 9,
//                               backgroundColor: Colors.white,
//                               backgroundImage:
//                                   NetworkImage(loginUserProfile['image']),
//                             )
//                           : CircleAvatar(
//                               radius: screenWidth / 9,
//                               backgroundColor: Colors.white,
//                               child: Icon(
//                                 Icons.person,
//                                 color: kiconColor,
//                               ),
//                             ),
//                     ),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     Text(
//                       loginUserProfile['fname'],
//                       style: kTitle,
//                     ),
//                     // const SizedBox(height: 15,),
//                     // Text(
//                     //   widget.emailAdd.toString(),
//                     //   style: kTitle
//                     // ),
//                   ],
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                     color: kcardBackgroundColor,
//                     borderRadius: BorderRadius.circular(50)),
//                 width: screenWidth,
//                 height: 3,
//               ),
//               Expanded(
//                   child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                       padding: EdgeInsets.only(top: 30),
//                       child: Column(children: [
//                         Row(children: [
//                           Icon(
//                             Icons.person,
//                             color: kiconColor,
//                           ),
//                           SizedBox(
//                             width: 20,
//                           ),
//                           Container(
//                             width: screenWidth * 0.2,
//                             child: const Text(
//                               "User Name ",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: kiconColor,
//                                   fontFamily: "OpenSans"),
//                             ),
//                           ),
//                           Container(
//                             width: 10,
//                             child: const Text(
//                               ":",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: kiconColor,
//                                   fontFamily: "OpenSans"),
//                             ),
//                           ),
//                           Expanded(
//                             child: Text(
//                               loginUserProfile['lname'],
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: Colors.black26,
//                                   fontFamily: "OpenSans"),
//                               maxLines: 3,
//                             ),
//                           )
//                         ]),
//                         SizedBox(
//                           height: 30,
//                         ),
//                         Row(children: [
//                           Icon(
//                             Icons.email_outlined,
//                             color: kiconColor,
//                           ),
//                           SizedBox(
//                             width: 20,
//                           ),
//                           Container(
//                             width: screenWidth * 0.2,
//                             child: const Text(
//                               "Email Address ",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: kiconColor,
//                                   fontFamily: "OpenSans"),
//                             ),
//                           ),
//                           Container(
//                             width: 10,
//                             child: const Text(
//                               ":",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: kiconColor,
//                                   fontFamily: "OpenSans"),
//                             ),
//                           ),
//                           Expanded(
//                             child: Text(
//                               loginUserProfile['email'],
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: Colors.black26,
//                                   fontFamily: "OpenSans"),
//                               maxLines: 3,
//                             ),
//                           )
//                         ]),
//                         SizedBox(
//                           height: 30,
//                         ),
//                         Row(children: [
//                           Icon(
//                             Icons.calendar_month,
//                             color: kiconColor,
//                           ),
//                           SizedBox(
//                             width: 20,
//                           ),
//                           Container(
//                             width: screenWidth * 0.2,
//                             child: const Text(
//                               "Date of Birth ",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: kiconColor,
//                                   fontFamily: "OpenSans"),
//                             ),
//                           ),
//                           Container(
//                             width: 10,
//                             child: const Text(
//                               ":",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: kiconColor,
//                                   fontFamily: "OpenSans"),
//                             ),
//                           ),
//                           Expanded(
//                             child: Text(
//                               date,
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: Colors.black26,
//                                   fontFamily: "OpenSans"),
//                               maxLines: 3,
//                             ),
//                           )
//                         ]),
//                         SizedBox(
//                           height: 30,
//                         ),
//                         Row(children: [
//                           Icon(
//                             Icons.phone,
//                             color: kiconColor,
//                           ),
//                           SizedBox(
//                             width: 20,
//                           ),
//                           Container(
//                             width: screenWidth * 0.2,
//                             child: const Text(
//                               "Phone Number ",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: kiconColor,
//                                   fontFamily: "OpenSans"),
//                             ),
//                           ),
//                           Container(
//                             width: 10,
//                             child: const Text(
//                               ":",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: kiconColor,
//                                   fontFamily: "OpenSans"),
//                             ),
//                           ),
//                           Expanded(
//                             child: Text(
//                               (loginUserProfile['phone'] != null)
//                                   ? "0" + loginUserProfile['phone'].toString()
//                                   : "",
//                               style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 15,
//                                   color: Colors.black26,
//                                   fontFamily: "OpenSans"),
//                               maxLines: 3,
//                             ),
//                           )
//                         ]),
//                         SizedBox(
//                           height: 30,
//                         ),
//                         (loginUserData['userType'] != "admin")
//                             ? Row(children: [
//                                 Icon(
//                                   Icons.location_history,
//                                   color: kiconColor,
//                                 ),
//                                 SizedBox(
//                                   width: 20,
//                                 ),
//                                 Container(
//                                   width: screenWidth * 0.2,
//                                   child: const Text(
//                                     "Suburb ",
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 15,
//                                         color: kiconColor,
//                                         fontFamily: "OpenSans"),
//                                   ),
//                                 ),
//                                 Container(
//                                   width: 10,
//                                   child: const Text(
//                                     ":",
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 15,
//                                         color: kiconColor,
//                                         fontFamily: "OpenSans"),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     (loginUserProfile['siteId'] != null)
//                                         ? loginUserProfile['siteId']
//                                         : "",
//                                     style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 15,
//                                         color: Colors.black26,
//                                         fontFamily: "OpenSans"),
//                                     maxLines: 3,
//                                   ),
//                                 )
//                               ])
//                             : SizedBox(
//                                 height: 10,
//                               ),
//                       ])),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 20.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Container(
//                           width: 40,
//                           height: 40,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: kiconColor,
//                           ),
//                           child: IconButton(
//                             icon: Icon(
//                               Icons.edit,
//                               color: Colors.white,
//                             ),
//                             onPressed: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => UserProfileEdit(
//                                             userid: loginUserProfile['id'],
//                                             username: loginUserProfile['fname'],
//                                             emailAdd: loginUserProfile['email'],
//                                             birthDay: date,
//                                             mobile: loginUserProfile['phone']
//                                                 .toString(),
//                                             suburbs: loginUserProfile['suburb'],
//                                             image: loginUserProfile['image'],
//                                             type: loginUserData['userType'],
//                                           )));
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               )),
//             ],
//           ),
//         ),
//         bottomNavigationBar: BottomNavBar(),
//       ),
//     );
//   }
// }

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

class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
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
      print("Try blog");
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
            "USER PROFILE",
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
              Container(
                height: screenHeight * 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: screenWidth / 8.5,
                      backgroundColor: kcardBackgroundColor,
                      child: (loginUserProfile['image'] != null)
                          ? CircleAvatar(
                              radius: screenWidth / 9,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  NetworkImage(loginUserProfile['image']),
                            )
                          : CircleAvatar(
                              radius: screenWidth / 9,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                color: kiconColor,
                              ),
                            ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      loginUserProfile['name'],
                      style: kTitle,
                    ),
                    // const SizedBox(height: 15,),
                    // Text(
                    //   widget.emailAdd.toString(),
                    //   style: kTitle
                    // ),
                  ],
                ),
              ),
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
                              "User Name ",
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
                            Icons.email_outlined,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: screenWidth * 0.2,
                            child: const Text(
                              "Email Address ",
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
                            Icons.calendar_month,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: screenWidth * 0.2,
                            child: const Text(
                              "Site Name",
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
                                    (loginUserProfile['site_address'] != null)
                                        ? loginUserProfile['site_address']
                                        : "",
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

class cleaner {
  // "user_id": "ddad9028-7d2d-4ee9-896e-65cebcb7339a",
  //           "f_name": "Rumesh",
  //           "l_name": "Piyushan",
  //           "phone": "0776656533",
  //           "email": "rumesh@gmail.com",
  //           "image": "https://firebasestorage.googleapis.com/v0/b/qr-api-be.appspot.com/o/files%2F526.jpg%20Sun%20Nov%2005%202023%2012%3A48%3A52%20GMT%2B0000%20(Coordinated%20Universal%20Time)?alt=media&token=fba9822a-696d-4d0c-80f9-34bb771841f5",
  //           "start_date": "2023-10-25T00:00:00.000Z",
  //           "end_date": "2024-10-25T00:00:00.000Z",
  //           "emp_no": 41,
  //           "document_id": null,
  //           "url": null,
  //           "document_name": null,
  //           "site_id": "3b0d4572-8440-428d-aab0-11e625bcf071",
  //           "site_name": "Rio Tinto",
  //           "site_address": "34 Girvan Grove, Australia",
  //           "site_email": "kfcG@gmail.com"
}
