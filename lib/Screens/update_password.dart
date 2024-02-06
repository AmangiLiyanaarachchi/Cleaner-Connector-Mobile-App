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
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import '../Constant/const_api.dart';
import '../Controller/authController.dart';
import '../components/bottom_bar.dart';
import '../components/text_button.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';

class UpdatePassword extends StatefulWidget {
  UpdatePassword({
    required this.loginUserid,
  });
  String? loginUserid;

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
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
      final response =
      await Dio().put(BASE_API + "users/update-password/${loginUserProfile['id']}", data: {
        "updatedPassword": confirmpasswordController.text,
      });
      print(" Password update response: $response");
      setState(() {
        isLoading = false;
      });
      if(response.statusCode== 200 && response.data['message'] == "Password Updated successfully"){
        SharedPreferences sharedPreferences = await SharedPreferences
            .getInstance();
        await sharedPreferences.setString(
            'password', confirmpasswordController.text);
        setState(() {
          loginUserData['password'] = confirmpasswordController.text;
        });
        currentpasswordController.clear();
        newpasswordController.clear();
        confirmpasswordController.clear();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewTaskScreen()));
      }else{
        print("Error");
      }
    } catch (e) {
      print(e);
    }
  }

  static const _colors = [
    Color(0x4A40BCFE),
    Color(0xFF00BBF9),
    Color(0x8B0032F9),
  ];

  static const _durations = [6000, 5000, 4000];

  static const _heightPercentages = [0.95, 0.86, 0.75];

  @override
  void initState() {
    print("Forgot password screen");
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Sizes = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      // height: Size.height/2,
                      child: Image(
                        image: const AssetImage(
                          'assets/images/logo.png',
                        ),
                        color: kiconColor,
                        height: width * 0.5,
                        width: width * 0.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Center(child: ForgotPasswordForm(id: widget.loginUserid,)),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    WaveWidget(
                      config: CustomConfig(
                        colors: _colors,
                        durations: _durations,
                        heightPercentages: _heightPercentages,
                      ),
                      // backgroundColor: _backgroundColor,
                      size: Size(width, height * 0.1),
                      waveAmplitude: 3,
                    ),
                  ],
                ),
                // Spacer(
                //   flex: 1,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordForm extends StatefulWidget {
  ForgotPasswordForm({
    required this.id,
  });
  String? id;

  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmpasswordController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String password = '';
  String userID = '';
  bool _isObscure = true;
  bool isLoading = false;
  bool typing = true;

  Future setPassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
      await Dio().put(BASE_API + "users/update-password/${widget.id}", data: {
        "updatedPassword": confirmpasswordController.text,
      });
      print(" Password update response: $response");
      setState(() {
        isLoading = false;
      });
      if(response.statusCode== 200 && response.data['message'] == "Password Updated successfully"){
        SharedPreferences sharedPreferences = await SharedPreferences
            .getInstance();
        await sharedPreferences.setString(
            'password', confirmpasswordController.text);
        confirmpasswordController.clear();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoginScreen()));
      }else{
        print("Error");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size = MediaQuery.of(context).size;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              // SizedBox(height: 130,)
              padding: EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Text(
                "Reset Your Password",
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 70,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.password_sharp,
                    color: kiconColor,
                  ),
                  // const SizedBox(width: 50,),
                  Container(
                    // padding: EdgeInsets.only(top: 20, bottom: 20),
                    width: width * 0.70,
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(2, 2),
                            blurRadius: 2,
                          )
                        ],
                        color: const Color.fromRGBO(241, 239, 239, 0.298),
                        border: Border.all(width: 0, color: Colors.white),
                        borderRadius: BorderRadius.circular(11)),
                    // width: width,
                    child: TextFormField(
                      obscureText: _isObscure,
                      controller: passwordController,
                      enabled: true,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
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
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        isDense: true,
                        contentPadding:
                        const EdgeInsets.fromLTRB(15, 30, 15, 0),
                        hintText: "New Password",
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
                        } else if (!value.contains(
                            RegExp(r'[0-9]'))) {
                          return 'Password must be contains at least 1 number';
                        } else {
                          return null;
                        }
                      },
                      onChanged: (String? text) {
                        password = text!;
                        // print(email);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.password_sharp,
                    color: kiconColor,
                  ),
                  // const SizedBox(width: 50,),
                  Container(
                    // padding: EdgeInsets.only(top: 20, bottom: 20),
                    width: width * 0.70,
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(2, 2),
                            blurRadius: 2,
                          )
                        ],
                        color: const Color.fromRGBO(241, 239, 239, 0.298),
                        border: Border.all(width: 0, color: Colors.white),
                        borderRadius: BorderRadius.circular(11)),
                    // width: width,
                    child: TextFormField(
                      obscureText: _isObscure,
                      controller: confirmpasswordController,
                      enabled: true,
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
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        isDense: true,
                        contentPadding:
                        const EdgeInsets.fromLTRB(15, 30, 15, 0),
                        hintText: "Confirm Password",
                        hintStyle: const TextStyle(
                            color: Colors.black54, fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (c_Pw) {
                        if (c_Pw != null && c_Pw.isEmpty) {
                          return "Confirm password can't be empty";
                        } else if (passwordController.text != confirmpasswordController.text){
                          return "Password and Confirm Password does not match";
                        }else {
                          return null;
                        }
                      },
                      onChanged: (String? text) {
                        password = text!;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle,
                  color: kiconColor,
                ),
                isLoading
                    ? const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: SpinKitDualRing(
                    color: kiconColor,
                    size: 30,
                  ),
                )
                    : TextButton(
                  child: const Text(
                    "Continue",
                    style:
                    TextStyle(color: kiconColor, fontSize: 20),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await setPassword();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
