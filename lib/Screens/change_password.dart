import 'dart:async';
import 'dart:convert';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/task_view.dart';
import 'package:clean_connector/Screens/user_edit.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/const_api.dart';
import '../Controller/authController.dart';
import '../components/bottom_bar.dart';
import '../components/text_button.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool isLoading = false;
  String currentpassword = '';
  String newpassword = '';
  String confirmpassword = '';
  TextEditingController currentpasswordController = new TextEditingController();
  TextEditingController newpasswordController = new TextEditingController();
  TextEditingController confirmpasswordController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isObscuren = true;
  bool _isObscurec = true;

  Future changePassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Dio().put(
          BASE_API + "users/update-password/${loginUserProfile['id']}",
          data: {
            "updatedPassword": confirmpasswordController.text,
          });
      print(" Password update response: $response");
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200 &&
          response.data['message'] == "Password Updated successfully") {
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        await sharedPreferences.setString(
            'password', confirmpasswordController.text);
        setState(() {
          loginUserData['password'] = confirmpasswordController.text;
        });
        currentpasswordController.clear();
        newpasswordController.clear();
        confirmpasswordController.clear();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ViewTaskScreen()));
      } else {
        print("Error");
      }
    } catch (e) {
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
          title: Text(
            "CHANGE PASSWORD",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            logoutButton(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 70),
                          child: Column(children: [
                            Row(children: [
                              Icon(
                                Icons.lock,
                                color: kiconColor,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
// width: 130,
                                child: const Text(
                                  "Current Password",
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
                            ]),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              // padding: EdgeInsets.only(top: 20, bottom: 20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(2, 2),
                                      blurRadius: 2,
                                    )
                                  ],
                                  color: const Color.fromRGBO(
                                      241, 239, 239, 0.298),
                                  border:
                                      Border.all(width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(11)),
                              // width: width,
                              child: TextFormField(
                                controller: currentpasswordController,
                                autocorrect: false,
                                obscureText: _isObscure,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      icon: Icon(
                                          _isObscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: kiconColor),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure = !_isObscure;
                                        });
                                      }),
                                  fillColor: Colors.white,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                    // borderSide: BorderSide.none
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: kiconColor,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                  hintText: ".............",
                                  hintStyle: const TextStyle(
                                      color: Colors.black54, fontSize: 14),
                                ),
                                style: const TextStyle(color: Colors.black),
                                validator: (String? task) {
                                  if (task != null && task.isEmpty) {
                                    return "Current Password can't be empty";
                                  } else if (loginUserData['password'] !=
                                      currentpasswordController.text) {
                                    return "Password did not match";
                                  } else {
                                    return null;
                                  }
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(children: [
                              Icon(
                                Icons.lock,
                                color: kiconColor,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
// width: 130,
                                child: const Text(
                                  "New Password",
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
                            ]),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              // padding: EdgeInsets.only(top: 20, bottom: 20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(2, 2),
                                      blurRadius: 2,
                                    )
                                  ],
                                  color: const Color.fromRGBO(
                                      241, 239, 239, 0.298),
                                  border:
                                      Border.all(width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(11)),
                              // width: width,
                              child: TextFormField(
                                controller: newpasswordController,
                                autocorrect: false,
                                obscureText: _isObscuren,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      icon: Icon(
                                          _isObscuren
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: kiconColor),
                                      onPressed: () {
                                        setState(() {
                                          _isObscuren = !_isObscuren;
                                        });
                                      }),
                                  fillColor: Colors.white,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                    // borderSide: BorderSide.none
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: kiconColor,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                  hintText: "............",
                                  hintStyle: const TextStyle(
                                      color: Colors.black54, fontSize: 14),
                                ),
                                style: const TextStyle(color: Colors.black),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'New Password is Required';
                                  } else if (value.length < 8) {
                                    return 'Password must be at least 8 characters long';
                                  } else if (!value
                                      .contains(RegExp(r'[a-z]'))) {
                                    return 'Password must be at contains least 1 letter';
                                  } else if (!value.contains(
                                      RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                                    return 'Password must be contains at least 1 special character';
                                  } else if (!value
                                      .contains(RegExp(r'[0-9]'))) {
                                    return 'Password must be contains at least 1 number';
                                  } else {
                                    return null;
                                  }
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(children: [
                              Icon(
                                Icons.lock,
                                color: kiconColor,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                child: const Text(
                                  "Confirm Password",
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
                            ]),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              // padding: EdgeInsets.only(top: 20, bottom: 20),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      offset: Offset(2, 2),
                                      blurRadius: 2,
                                    )
                                  ],
                                  color: const Color.fromRGBO(
                                      241, 239, 239, 0.298),
                                  border:
                                      Border.all(width: 0, color: Colors.white),
                                  borderRadius: BorderRadius.circular(11)),
                              // width: width,
                              child: TextFormField(
                                controller: confirmpasswordController,
                                autocorrect: false,
                                obscureText: _isObscurec,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      icon: Icon(
                                          _isObscurec
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: kiconColor),
                                      onPressed: () {
                                        setState(() {
                                          _isObscurec = !_isObscurec;
                                        });
                                      }),
                                  fillColor: Colors.white,
                                  filled: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                    // borderSide: BorderSide.none
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide: const BorderSide(
                                      color: kiconColor,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                  ),
                                  isDense: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                  hintText: "...........",
                                  hintStyle: const TextStyle(
                                      color: Colors.black54, fontSize: 14),
                                ),
                                style: const TextStyle(color: Colors.black),
                                validator: (c_Pw) {
                                  if (c_Pw != null && c_Pw.isEmpty) {
                                    return "Confirm password can't be empty";
                                  } else if (confirmpasswordController.text !=
                                      confirmpasswordController.text) {
                                    return "Password and Confirm Password does not match";
                                  } else {
                                    return null;
                                  }
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: GestureDetector(
                                  onTap: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      await changePassword();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Container(
                                      width: screenWidth / 0.5,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.update,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {},
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          isLoading
                                              ? const Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 10.0,
                                                    right: 10,
                                                  ),
                                                  child: SpinKitDualRing(
                                                    color: Colors.white,
                                                    size: 30,
                                                  ),
                                                )
                                              : Text("Change Password   ",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                      color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                  )),
                            ),
                          ])),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}
