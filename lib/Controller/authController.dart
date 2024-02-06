import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/login_screen.dart';
import '../Screens/user_list.dart';

class AuthController {
  static login(Map userData) async {
    var response = userData;
    var any = await SharedPreferences.getInstance();

    any.setString("userData", json.encode(response));
    Get.off(UserList());
  }

  Future<bool> tryAutoLogin() async {
    var any = await SharedPreferences.getInstance();
    if (!any.containsKey("userData")) {
      print("No user DATA");
      return false;
    } else {
      print("have user DATA");
      final extractedUserData =
          json.decode(any.getString('userData').toString());
      print(extractedUserData);
      loginUserData["id"] = extractedUserData['id'];
      loginUserData["token"] = extractedUserData['token'];
      loginUserData["email"] = extractedUserData["email"];
      loginUserData["admin_name"] = extractedUserData["admin_name"];

      return true;
    }
  }

  static logOut(context) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      // the new route
      MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen(),
      ),

      // this function should return true when we're done removing routes
      // but because we want to remove all other screens, we make it
      // always return false
      (Route route) => false,
    );
  }

//Get logged user data
  static Future<Map<String, dynamic>> getLoginData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> userData = {};

    String id = await sharedPreferences.getString('userId').toString();
    String email = await sharedPreferences.getString('email').toString();
    String name = await sharedPreferences.getString('admin_name').toString();
    String token = await sharedPreferences.getString('token').toString();
    String fname = await sharedPreferences.getString('fname').toString();
    String lname = await sharedPreferences.getString('lname').toString();
    String userType = await sharedPreferences.getString('userType').toString();
    String siteId = await sharedPreferences.getString('siteId').toString();
    //userData = {'id': id, 'email': email, 'name': name};
    userData = {
      'id': id,
      'email': email,
      'name': email,
      'token': token,
      'fname': fname,
      'lname': lname,
      'userType': userType,
      'siteId': siteId
    };

    print(userData.toString());

    return userData;
  }
}
