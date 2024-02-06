import 'dart:async';
import 'dart:convert';
// import 'package:clean_connector/Constant/style.dart';
// import 'package:clean_connector/Screens/task_list.dart';
// import 'package:clean_connector/Screens/user_edit.dart';
// import 'package:clean_connector/Screens/user_profile_edit.dart';
import 'package:clean_connector/Constant/const_api.dart';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/login_screen.dart';

// import 'package:clean_connector/Screens/communication_admin_login.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_profile_edit.dart';
// import 'package:cleanerconnectapp/Login.dart';
// import 'package:cleanerconnectapp/const_api.dart';
// import 'package:cleanerconnectapp/logoutButton.dart';
// import 'package:cleanerconnectapp/style.dart';
// import 'package:cleanerconnectapp/task_list.dart';
// import 'package:cleanerconnectapp/user_profile_edit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
// import '../Constant/const_api.dart';
// import '../Controller/authController.dart';
// import '../components/bottom_bar.dart';
// import 'login_screen.dart';
import 'package:flutter/material.dart';

class SuperAdminProfile extends StatefulWidget {
  @override
  State<SuperAdminProfile> createState() => _SuperAdminProfileState();
}

class _SuperAdminProfileState extends State<SuperAdminProfile> {
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
          loginUserProfile['phone'] =
              response.data['sites'][0]['mobile'] ?? " ";
          loginUserProfile['email'] =
              response.data['sites'][0]['site_email'] ?? " ";
          // loginUserProfile['image'] = response.data['result'][0]['image'] ?? " ";
          loginUserProfile['site_name'] =
              response.data['sites'][0]['site_name'] ?? " ";
          loginUserProfile['rate'] =
              response.data['sites'][0]['rate'].toString() ?? " ";
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
    // await getProfile();
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
            "ADMIN PROFILE",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            // logoutButton(),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
            child: Column(
              children: [
                Hero(
                  tag: 'cleanConnectWelcomeText', // Unique Hero tag for the Text widget
                  child: Text(
                    "Welcome to Clean Connect's",
                    style: kTitle,
                  ),
                ),
                Hero(
                  tag: 'cleanConnectServiceProviderText', // Unique Hero tag for the Text widget
                  child: Text(
                    "Service Provider Portal",
                    style: kTitle,
                  ),
                ),
                SizedBox(height: 20,),
                Hero(
                  tag: 'cleanConnectLogo', // Unique Hero tag for the Image widget
                  child: Image(
                    image: const AssetImage(
                      'assets/images/logo.png',
                    ),
                    color: kiconColor,
                    height: 150,
                    width: 150,
                  ),
                ),
                 SizedBox(height: 20,),
                 Hero(
                  tag: 'cleanConnectListTitle1', // Unique Hero tag for the Text widget
                  child: Text(
                    "Commercial Cleaning & Property",
                    style: klistTitle,
                  ),
                ),
                Hero(
                  tag: 'cleanConnectListTitle2', // Unique Hero tag for the Text widget
                  child: Text(
                    "Services",
                    style: klistTitle,
                  ),
                ),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}
