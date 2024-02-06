import 'dart:async';

import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/communication_new_question.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import 'forgot_password.dart';

String? finalusername;
String? finalpassword;

class LoginAdminScreen extends StatefulWidget {
  const LoginAdminScreen({Key? key}) : super(key: key);

  @override
  _LoginAdminScreenState createState() => _LoginAdminScreenState();
}

class _LoginAdminScreenState extends State<LoginAdminScreen> {
  static const _colors = [
    Color(0x4A40BCFE),
    Color(0xFF00BBF9),
    Color(0x8B0032F9),
  ];

  static const _durations = [6000, 5000, 4000];

  static const _heightPercentages = [0.95, 0.86, 0.75];

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
                const Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Center(child: LoginForm()),
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
        // bottomNavigationBar: Stack(
        //   children: [
        //     Container(
        //       alignment: Alignment.bottomCenter,
        //       // color: ,
        //       height: 130,
        //       decoration: const BoxDecoration(
        //         color: Colors.transparent,
        //         image: DecorationImage(
        //             image: AssetImage(
        //               "assets/images/waves.png",
        //             ),
        //             fit: BoxFit.cover),
        //       ),
        //     ),
        //     Text(
        //       "By logging in you agree to our",
        //       textAlign: TextAlign.center,
        //       style: TextStyle(
        //           color: Colors.black54,
        //           fontSize: 17,),
        //     ),
        //     Positioned(
        //       top: 100,
        //         left: 120,
        //         child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         GestureDetector(
        //           child: const Text(
        //             "privacy policy",
        //             style: TextStyle(
        //                 color: Colors.black54,
        //                 fontSize: 17,
        //                 decoration: TextDecoration.underline
        //             ),
        //           ),
        //         ),
        //         const Text(
        //           "  &  ",
        //           style: TextStyle(
        //               color: Colors.black54,
        //               fontSize: 17),
        //         ),
        //         GestureDetector(
        //           child: const Text(
        //             "terms of service",
        //             style: TextStyle(
        //                 color: Colors.black54,
        //                 fontSize: 17,
        //                 decoration: TextDecoration.underline
        //             ),
        //           ),
        //         ),
        //       ],
        //     ))
        //   ],
        // ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  bool _isObscure = true;
  bool isLoading = false;
  bool typing = true;

  // Future LoginData() async {
  //   //final prefs = await SharedPreferences.getInstance();
  //   print('username-$email\npassword-$password');
  //   setState(() {
  //     isLoading = true;
  //     typing = false;
  //   });
  //   try {
  //     print("xxxx");
  //     var response = await Dio().post(BASE_API + 'users/login', data: {
  //       "email": email,
  //       "password": password,
  //     });

  //     print("!!!!!!!!!!$response");
  //     print(response.data["accessToken"]);
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       if (response.data["message"] == "User logged in successfully") {
  //         SharedPreferences sharedPreferences =
  //             await SharedPreferences.getInstance();
  //         sharedPreferences.setBool(SplashScreenState.KEYLOGIN, true);
  //         await sharedPreferences.setString(
  //             'username', emailEditingController.text);
  //         await sharedPreferences.setString(
  //             'password', passwordEditingController.text);
  //         await sharedPreferences.setString(
  //             'usertype', response.data['userType']);
  //         await sharedPreferences.setString(
  //             'admintype',
  //             (response.data['adminType'] == null)
  //                 ? ""
  //                 : response.data['adminType']);
  //         await sharedPreferences.setString(
  //             'token', response.data['accessToken']);
  //         setState(() {
  //           loginUserData['email'] = emailEditingController.text;
  //           loginUserData['password'] = passwordEditingController.text;
  //           loginUserData['adminType'] = (response.data['adminType'] == null)
  //               ? ""
  //               : response.data['adminType'];
  //           loginUserData['userType'] = response.data['userType'];
  //           loginUserData['accessToken'] = response.data['accessToken'];
  //         });
  //         Timer(
  //             const Duration(milliseconds: 1500),
  //             () => Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => const ViewTaskScreen())));
  //         emailEditingController.clear();
  //         passwordEditingController.clear();
  //       } else {}
  //     }
  //   } on DioException catch (e) {
  //     if (e.response?.statusCode == 400) {
  //       print("Bad Error");
  //       print(e.response?.data["message"]);
  //       if (e.response?.data["message"] == "User entered wrong password") {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("Invalid Password."),
  //           ),
  //         );
  //       } else if (e.response?.data["message"] ==
  //           "No any registered user for this email") {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("No any registered user for this email."),
  //           ),
  //         );
  //       }
  //     }
  //     print(e.toString());
  //     setState(() {
  //       isLoading = false;
  //       typing = true;
  //     });
  //     print(e);
  //   }
  // }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.email,
                    color: kiconColor,
                  ),
                  // const SizedBox(width: 50,),
                  Container(
                    // padding: EdgeInsets.only(top: 20, bottom: 20),
                    alignment: Alignment.center,
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
                      controller: emailEditingController,
                      enabled: true,
                      decoration: InputDecoration(
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
                        hintText: "Email",
                        hintStyle: const TextStyle(
                            color: Colors.black54, fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (email) {
                        if (EmailValidator.validate(email!)) {
                          return null;
                        }
                        if (email != null && email.isEmpty) {
                          return "Email can't be empty";
                        } else {
                          return "Please enter a valid email";
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (String? text) {
                        email = text!;
                        // print(email);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.password,
                    color: kiconColor,
                  ),
                  // const SizedBox(width: 50,),
                  Container(
                    alignment: Alignment.center,
                    width: width * 0.70,
                    decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(2, 2),
                            blurRadius: 2,
                          ),
                        ],
                        color: const Color.fromRGBO(241, 239, 239, 0.298),
                        border: Border.all(width: 0, color: Colors.white),
                        borderRadius: BorderRadius.circular(11)),
                    // width: width * 0.,
                    child: TextFormField(
                      controller: passwordEditingController,
                      obscureText: _isObscure,
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
                        hintText: "Password",
                        hintStyle: const TextStyle(
                            color: Colors.black54, fontSize: 14),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: (String? Password) {
                        if (Password != null && Password.isEmpty) {
                          return "Password can't be empty";
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: (String? text) {
                        password = text!;
                        // print(email);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text(
                      "Forgot Password",
                      style: TextStyle(color: kiconColor, fontSize: 14),
                    ),
                    onPressed: () {
                      Timer(
                          const Duration(milliseconds: 1500),
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen())));
                    },
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
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
                          "LOGIN",
                          style: TextStyle(color: kiconColor, fontSize: 20),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // _formKey.currentState!.save();
                            // await LoginData();
                            Timer(
                                const Duration(milliseconds: 1500),
                                () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NewQuestion(
                                              title: "new",
                                            ))));
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
