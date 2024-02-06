import 'dart:async';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:clean_connector/Screens/view_task.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/const_api.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  static const String KEYLOGIN = 'login';
  bool isinstalled = false;
  bool isLogged = false;
  String? isinstall = '';
  String? isLog = '';
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    isLoading = true;
    loading();
  }

  loading() async {
    await whereToGo();
    await getValidationData();
    print("ok");
    setState(() {
      isLoading = false;
    });
  }

  Future getValidationData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var obtainedUserName = sharedPreferences.getString('username');
    var obtainedPassWord = sharedPreferences.getString('password');
    var obtainedusertype = sharedPreferences.getString('usertype');
    var obtainedadmintype = sharedPreferences.getString('admintype');
    var obtaineduserToken = sharedPreferences.getString('token');
    var obtaineduserId = sharedPreferences.getString('userId');
    setState(() {
      // loginUserData["admin_name"] = obtainedUserName;
      // finalpassword = obtainedPassWord;
      // loginUserData["id"] = obtainedid;
      // loginUserData["token"] = obtainedtoken;
      // loginUserData["email"] = obtainedemail;
    });
    print(
        '############################################################################################');
    print(obtainedUserName);
    print(obtainedPassWord);
    print(obtainedusertype);
    print(obtaineduserToken);
    setState(() {
      loginUserData['email'] = obtainedUserName;
      loginUserData['userType'] = obtainedusertype;
      loginUserData['accessToken'] = obtaineduserToken;
      loginUserData['password'] = obtainedPassWord;
      loginUserData['id'] = obtaineduserId;
    });

    // var response = await Dio().post(BASE_API +'admin/login', data: {
    //   "admin_name": obtainedUserName,
    //   "password": obtainedPassWord,
    // });
    // print(response.data["sub"]["id"]);
    // print(response);
    //
    // if (response.data["success"] == true) {
    //   if (response.data["status"] == "success" &&
    //       response.data["token"] != null) {
    //     SharedPreferences sharedPreferences = await SharedPreferences
    //         .getInstance();
    //     var obtainedUserName = sharedPreferences.getString('username');
    //     var obtainedPassWord = sharedPreferences.getString('password');
    //     var obtainedwallet = sharedPreferences.getString('usertype');
    //     setState(() {
    //       isLoading = false;
    //       loginUserData["id"] = response.data["sub"]["id"];
    //       loginUserData["admin_name"] = response.data["sub"]["username"];
    //       loginUserData["token"] = response.data["token"];
    //       loginUserData["email"] = response.data["sub"]["email"];
    //     });
    //
    //     //await AuthController.login(loginUserData);
    //     Get.to(const UserList());
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          //backgroundColor: Colors.white,
          body: Center(
        child: Container(
          height: 200,
          child: AnimatedSplashScreen(
            backgroundColor: Colors.transparent,
            splashIconSize: 150,
            splash: Padding(
              padding: const EdgeInsets.only(left: 80.0, right: 80, top: 0),
              child: SizedBox(
                //height: 150,
                child: Image.asset(
                  "assets/images/logo.png",
                  color: kiconColor,
                ),
              ),
            ),
            nextScreen: const LoginScreen(),
            duration: 4000,
            splashTransition: SplashTransition.scaleTransition,
          ),
        ),
      )),
    );
  }

  whereToGo() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    var isLoggedIn = sharedPreferences.getBool(KEYLOGIN);
    print("*****************");
    print("${isLoggedIn}");
    if (isLoggedIn != null) {
      setState(() {
        isLog = "true";
        //isLoggin == 'true';
      });
    }

    Timer(const Duration(seconds: 2), () {
      print(
          "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<object>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      print("is Logged in: $isLoggedIn");
      print("is installed in: $isinstalled");
      if (isLoggedIn != null) {
        setState(() {
          isLog == "true";
        });
      }
      if (isLoggedIn == true) {
        print("object");
        //getValidationData();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ViewTaskScreen(),
            ));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ));
        // Get.to(ConnectWallet(isinstalled: false,));
      }
      // if (isLoggedIn != null) {
      //   print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
      //   print(isLoggedIn);
      //   if (isLoggedIn && isinstalled == true) {
      //     getValidationData();
      //     print("login true, installed true");
      //     //getdata();
      //     Navigator.pushReplacement(context,
      //         MaterialPageRoute(builder: (context) => BottomNavigation(),));
      //     //Get.to(BottomNavigation());
      //   } else {
      //     print("login true, installed false");
      //     // Navigator.pushReplacement(context,
      //     //     MaterialPageRoute(builder: (context) => ConnectWallet(isinstalled: false,),));
      //     Get.to(ConnectWallet());
      //   }
      // } else if(isinstalled == false){
      //   print("login false, installed false");
      //   // Navigator.pushReplacement(context,
      //   //     MaterialPageRoute(builder: (context) => ConnectWallet(isinstalled: false,),));
      //   Get.to(ConnectWallet());
      // }else{
      //   print("login false");
      //   // Navigator.pushReplacement(context,
      //   //     MaterialPageRoute(builder: (context) => ConnectWallet(isinstalled: true,),));
      //   Get.to(ConnectWallet(isinstalled: true,));
      // }
    });
  }
}
