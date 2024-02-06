import 'dart:async';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/update_password.dart';
import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

import '../Constant/const_api.dart';
import 'login_screen.dart';

class VerificationScreen extends StatefulWidget {
  VerificationScreen({
    required this.userid,
  });
  String? userid;

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const _colors = [
    Color(0x4A40BCFE),
    Color(0xFF00BBF9),
    Color(0x8B0032F9),
  ];

  static const _durations = [6000, 5000, 4000];

  static const _heightPercentages = [0.95, 0.86, 0.75];

  @override
  void initState() {
    print("verification screen");
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
                  child: Center(child: VerifyForm(user_id: widget.userid.toString(),)),
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

class VerifyForm extends StatefulWidget {
  VerifyForm({
    required this.user_id,
  });
  String? user_id;

  @override
  _VerifyFormState createState() => _VerifyFormState();
}

/*Map<String, dynamic> loginUserData = {
  'id' : '',
  'admin_name': '',
  'email': '',
  'token' : ''
};*/
class _VerifyFormState extends State<VerifyForm> {
  TextEditingController emailEditingController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool typing = true;
  String code ='';

  List<String> verificationCode = List.generate(4, (index) => '');

  List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());
  List<TextEditingController> controllers =
      List.generate(4, (index) => TextEditingController());

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future SubmitVerifyCode() async {
    //final prefs = await SharedPreferences.getInstance();
    print(
        'username-$verificationCode');
    setState(() {
      code = verificationCode.reduce((value, element) {
        return value + element;
      });
      print("Code: $code");
      isLoading = true;
      typing = false;
    });
    try { print("xxxx");
    var response = await Dio().post(BASE_API + 'users/verifiy-code',
        data: {
          "userId": widget.user_id,
          "verificationCode": code,
        });

    print("!!!!!!!!!!$response");
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      if (response.data["message"] == "Verify successfully") {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => UpdatePassword(loginUserid: widget.user_id,),
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              // SizedBox(height: 130,)
              padding: EdgeInsets.only(left: 70, right: 70, top: 30),
              child: Text(
                "Enter the OTP sent to testing@gmail.com",
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
                  children: List.generate(
                    4,
                    (index) => SizedBox(
                      width: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          controller: controllers[index],
                          focusNode: focusNodes[index],
                          onChanged: (value) {
                            verificationCode[index] = value;
                            if (value.isNotEmpty) {
                              if (index < 3) {
                                FocusScope.of(context)
                                    .requestFocus(focusNodes[index + 1]);
                              } else {
                                // Last digit entered, perform validation or submit action
                                // Example: _submitVerificationCode();
                              }
                            }
                          },
                          maxLength: 1,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            counterText: '',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                )),
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
                          color: Color(0xffaeddf8),
                          size: 30,
                        ),
                      )
                    : TextButton(
                        child: const Text(
                          "Submit",
                          style:
                              TextStyle(color: kiconColor, fontSize: 20),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            await SubmitVerifyCode();
                            // Timer(
                            //     const Duration(milliseconds: 1500),
                            //     () => Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //             builder: (context) =>
                            //                 const ViewTaskScreen())));
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
