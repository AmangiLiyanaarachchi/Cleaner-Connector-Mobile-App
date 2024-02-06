import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/verification.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import '../Constant/const_api.dart';

String? finalusername;
String? finalpassword;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
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
        body: Container(
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
                child: Center(child: ForgotPasswordForm()),
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
    );
  }
}

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({Key? key}) : super(key: key);

  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  TextEditingController emailEditingController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String email = '';
  String userID = '';
  bool isLoading = false;
  bool typing = true;

  Future GetVerifyCode() async {
    //final prefs = await SharedPreferences.getInstance();
    print(
        'username-$email');
    setState(() {
      isLoading = true;
      typing = false;
    });
    try { print("xxxx");
    var response = await Dio().post(BASE_API + 'users/get-verification-code',
        data: {
          "email": email,
        });

    print("!!!!!!!!!!$response");
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      if (response.data["message"] == "Varification Code sent successfully") {
        setState(() {
          userID = response.data["userId"];
        });
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => VerificationScreen(userid: userID,),
          ),
              (Route route) => false,
        );
      }
      else{
        print(response.data["message"]);
      }
    }
    else if(response.statusCode == 400){
      print("Bad error.....................");
    }else {
      print(response.statusCode);
      setState(() {
        isLoading=false;
      });
    }
    print("@Error");
    } on DioException catch (e) {
      if(e.response?.statusCode == 400){
        print("Bad Error");
        print(e.response?.data["message"] );
      }
      print(e.toString());
      setState(() {
        isLoading = false;
        typing = true;
      });
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              // SizedBox(height: 130,)
              padding: EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Text(
                "Don’t worry ! It happens.\nPlease click below to contact Clean Connect Service.",
                style: TextStyle(color: Colors.grey, fontSize: 17),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: GestureDetector(
                onTap: ()async{
                  await FlutterPhoneDirectCaller.callNumber('0716779287');
                },
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Icon(Icons.phone_in_talk_sharp, size: 30,),
                    // ),
                    AvatarGlow(
                        child: Icon(Icons.phone_in_talk_sharp, size: 30,),
                        endRadius: 40,
                      glowColor: Colors.grey,
                    ),
                    Text("Contact Clean Connect Service to reset\nyour password",
                      style: TextStyle(color: kiconColor, fontSize: 20),
                      textAlign: TextAlign.center
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
