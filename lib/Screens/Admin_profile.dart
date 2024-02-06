import 'dart:async';
import 'dart:convert';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_edit.dart';
import 'package:clean_connector/Screens/user_profile_edit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import '../Constant/const_api.dart';
import '../Controller/authController.dart';
import '../components/bottom_bar.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';

class AdminProfile extends StatefulWidget {

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}
class _AdminProfileState extends State<AdminProfile> {
  bool isLoading = false;
  String profilePic = '';
  String name = '';
  String email = '';
  String date = '';

  @override
  void initState() {
    // Get.closeAllSnackbars;
    super.initState();
    setState(() {
      isLoading = true;
    });
    loginUserData['userType'] == "cleaner" ? getProfileAdmin()
        :loginUserData['userType'] == "client" ?getProfileClient()
        : getProfileClient();
    setState(() {
      isLoading = false;
    });
  }

  getProfileAdmin() async {
    print("Data loading....setting ${loginUserData["id"]}");
    setState(() {
      isLoading = true;
    });
    print(loginUserData["accessToken"]);
    try {
      final response =
      await Dio().get(BASE_API2 + "user/getCleanerUsersById/845ca718-1b1a-4910-be61-3fe158afcba1",
          options: Options(headers: {
            "Authorization": "Bearer "+ loginUserData["accessToken"]
          }));
      print(response.data['result'][0]['f_name']);
      if(response.statusCode == 200 && response.data['status']==true){
        print(response.data['result']);
        setState(() {
          loginUserProfile['id'] = response.data['result'][0]['user_id']?? " ";
          loginUserProfile['fname'] = response.data['result'][0]['f_name']?? " ";
          loginUserProfile['lname'] = response.data['result'][0]['l_name']?? " ";
          loginUserProfile['phone'] = response.data['result'][0]['phone']?? " ";
          loginUserProfile['siteId'] = response.data['result'][0]['site_id']?? " ";
          loginUserProfile['email'] = response.data['result'][0]['email']?? " ";
          loginUserProfile['image'] = response.data['result'][0]['image']?? " ";
        });
        print("***" +loginUserProfile['id']);
        print(loginUserProfile['fname']);
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }
  getProfileClient() async {
    print("Data loading....setting ${loginUserData["id"]}");
    setState(() {
      isLoading = true;
    });
    print(loginUserData["accessToken"]);
    try {
      final response =
      await Dio().get(BASE_API2 + "site/get-sites/61b2afc2-7409-45f7-b2a7-4672406ecd54",
          options: Options(headers: {
            "Authorization": "Bearer "+ loginUserData["accessToken"]
          }));
      if(response.statusCode == 200 && response.data['status']==true){
        print(response.data['sites']);
        setState(() {
          loginUserProfile['id'] = response.data['sites'][0]['site_id']?? " ";
          loginUserProfile['fname'] = response.data['sites'][0]['site_name']?? " ";
          loginUserProfile['lname'] = response.data['sites'][0]['site_address']?? " ";
          loginUserProfile['phone'] = response.data['sites'][0]['user_id']?? " ";
          loginUserProfile['siteId'] = response.data['sites'][0]['site_id']?? " ";
          loginUserProfile['email'] = response.data['sites'][0]['site_email']?? " ";
        });
        print("***" +loginUserProfile['id']);
        print(loginUserProfile['fname']);
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
          title: Text("USER PROFILE", style: kboldTitle,),
          backgroundColor: Colors.white,
          actions: <Widget>[
            logoutButton(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
          child: Column(
            children: [
              Container(
                height: screenHeight*0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: screenWidth/8.5,
                      backgroundColor: kcardBackgroundColor,
                      child: (loginUserProfile['image']!= null)?
                      CircleAvatar(
                        radius: screenWidth/9,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(loginUserProfile['image']),
                      )
                      :  CircleAvatar(
                        radius: screenWidth/9,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: kiconColor,),
                      ) ,
                    ),
                    const SizedBox(height: 15,),
                    Text(
                      loginUserProfile['fname'],
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
                    borderRadius: BorderRadius.circular(50)
                ),
                width: screenWidth,
                height: 3,
              ),
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Column(
                              children: [
                                Row(
                                    children: [
                                      Icon(Icons.person, color: kiconColor,),
                                      SizedBox(width: 20,),
                                      Container(
                                        width: screenWidth*0.2,
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
                                          loginUserProfile['lname'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.black26,
                                              fontFamily: "OpenSans"),
                                          maxLines: 3,
                                        ),
                                      )
                                    ]
                                ),
                                SizedBox(height: 30,),
                                Row(
                                    children: [
                                      Icon(Icons.email_outlined, color: kiconColor,),
                                      SizedBox(width: 20,),
                                      Container(
                                        width: screenWidth*0.2,
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
                                    ]
                                ),
                                SizedBox(height: 30,),
                                Row(
                                    children: [
                                      Icon(Icons.calendar_month, color: kiconColor,),
                                      SizedBox(width: 20,),
                                      Container(
                                        width: screenWidth*0.2,
                                        child: const Text(
                                          "Date of Birth ",
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
                                          date,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.black26,
                                              fontFamily: "OpenSans"),
                                          maxLines: 3,
                                        ),
                                      )
                                    ]
                                ),
                                SizedBox(height: 30,),
                                Row(
                                    children: [
                                      Icon(Icons.phone, color: kiconColor,),
                                      SizedBox(width: 20,),
                                      Container(
                                        width: screenWidth*0.2,
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
                                          (loginUserProfile['phone']!= null)? "0"+loginUserProfile['phone'].toString():"",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.black26,
                                              fontFamily: "OpenSans"),
                                          maxLines: 3,
                                        ),
                                      )
                                    ]
                                ),
                                SizedBox(height: 30,),
                                (loginUserData['userType'] != "admin")?
                                Row(children: [
                                      Icon(Icons.location_history, color: kiconColor,),
                                      SizedBox(width: 20,),
                                      Container(
                                        width: screenWidth*0.2,
                                        child: const Text(
                                          "Suburb ",
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
                                          (loginUserProfile['siteId']!= null)? loginUserProfile['siteId']: "",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.black26,
                                              fontFamily: "OpenSans"),
                                          maxLines: 3,
                                        ),
                                      )
                                    ])
                                    :SizedBox(height: 10,),

                              ]
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kiconColor,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserProfileEdit(userid: loginUserProfile['id'], username: loginUserProfile['fname'], emailAdd: loginUserProfile['email'], birthDay: date, mobile: loginUserProfile['phone'].toString(), suburbs: loginUserProfile['suburb'], image: loginUserProfile['image'], type: loginUserData['userType'],)));

                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}

