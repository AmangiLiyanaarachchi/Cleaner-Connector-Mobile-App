import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import '../Constant/const_api.dart';
import '../Controller/authController.dart';
import '../components/bottom_bar.dart';
import '../components/text_button.dart';
import 'create_user.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';

class UserProfileEdit extends StatefulWidget {
  UserProfileEdit({
    required this.userid,
    required this.username,
    required this.emailAdd,
    required this.birthDay,
    required this.mobile,
    required this.suburbs,
    required this.image,
    required this.type
  });
  String? userid;
  String? username;
  String? emailAdd;
  String? birthDay;
  String? mobile;
  String? suburbs;
  String? image;
  String? type;
  @override
  State<UserProfileEdit> createState() => _UserProfileEditState();
}
class _UserProfileEditState extends State<UserProfileEdit> {
  bool isLoading = false;
  String profilePic = '';
  String name = '';
  String email = '';
  String dob = '';
  String mobile = '';
  String suburbs = '';
  DateTime _date = DateTime.now();
  String selectedDate = '';
  TextEditingController userNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController dobController = new TextEditingController();
  TextEditingController mobileController = new TextEditingController();
  TextEditingController suburbController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    print("???????????????????: $profilePic");
    setState(() {
      isLoading = false;
      userNameController.text = widget.username.toString();
      emailController.text = widget.emailAdd.toString();
      dobController.text = widget.birthDay.toString();
      mobileController.text = "0"+widget.mobile.toString();
      suburbController.text = widget.suburbs.toString();
    });
  }

  Future updateUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
      await Dio().put(BASE_API + "users/${widget.userid}", options: Options(headers: {
        "Authorization": "Bearer "+ loginUserData["accessToken"]
      }), data: {
        "name": userNameController.text,
        "dob": dobController.text,
        "phone": mobileController.text,
        "email": emailController.text,
        "suburb": suburbController.text,
        "adminType" : widget.type.toString() == "user"? "": "normal",
        "userType" : widget.type.toString()
      }, );
      print(" User update response: $response");
      setState(() {
        isLoading = false;
      });
      if(response.statusCode == 200 && response.data['message'] == "Updated Successfully"){
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => UserList(),
          ),
              (Route route) => false,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> _selectDate(BuildContext) async {
    DateTime? _datePicker = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1947),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (_datePicker != null && _datePicker != _date) {
      String formattedDate = DateFormat("yyyy-MM-dd").format(_datePicker);
      setState(() {
        dobController.text = formattedDate.toString();
        _date = _datePicker;
        print(
            _date.toString()
        );
      });
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
          title: Text("EDIT USER PROFILE", style: kboldTitle,),
          backgroundColor: Colors.white,
          actions: <Widget>[
            // logoutButton(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
          child: Column(
            children: [
              // Container(
              //   height: screenHeight*0.18,
              //   child: const Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       ProfilePic(),
              //     ],
              //   ),
              // ),
              Container(
                height: screenHeight*0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: screenWidth/8.5,
                      backgroundColor: kcardBackgroundColor,
                      child: (widget.image!= null)?
                      CircleAvatar(
                        radius: screenWidth/9,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(widget.image.toString()),
                      )
                          :  CircleAvatar(
                        radius: screenWidth/9,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: kiconColor,),
                      ) ,
                    ),
                    const SizedBox(height: 15,),
                    Text(
                      widget.username.toString(),
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
                  child: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.disabled,
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
                                        child: TextFormField(
                                          controller: userNameController,
                                          enabled: true,
                                          decoration: InputDecoration(
                                            suffixIcon: Icon(Icons.edit, color: Colors.grey,),
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
                                            contentPadding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                            hintStyle: const TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          validator: (String? Username) {
                                            if (Username != null && Username.isEmpty) {
                                              return "Username can't be empty";
                                            }
                                            return null;
                                          },
                                          onChanged: (String? text) {
                                            email = text!;
                                            // print(email);
                                          },
                                        ),
                                      )
                                    ]
                                ),
                                // SizedBox(height: 30,),
                                // Row(
                                //     children: [
                                //       Icon(Icons.email_outlined, color: kiconColor,),
                                //       SizedBox(width: 20,),
                                //       Container(
                                //         width: screenWidth*0.2,
                                //         child: const Text(
                                //           "Email Address ",
                                //           style: TextStyle(
                                //               fontWeight: FontWeight.w600,
                                //               fontSize: 15,
                                //               color: kiconColor,
                                //               fontFamily: "OpenSans"),
                                //         ),
                                //       ),
                                //       Container(
                                //         width: 10,
                                //         child: const Text(
                                //           ":",
                                //           style: TextStyle(
                                //               fontWeight: FontWeight.w600,
                                //               fontSize: 15,
                                //               color: kiconColor,
                                //               fontFamily: "OpenSans"),
                                //         ),
                                //       ),
                                //       Expanded(
                                //         child: TextField(
                                //           controller: emailController,
                                //           keyboardType: TextInputType.none,
                                //           enabled: true,
                                //           decoration: InputDecoration(
                                //            // suffixIcon: Icon(Icons.edit, color: Colors.grey,),
                                //             fillColor: Colors.white,
                                //             filled: true,
                                //             enabledBorder: OutlineInputBorder(
                                //               borderRadius: BorderRadius.circular(5.0),
                                //               borderSide: const BorderSide(
                                //                 color: Colors.white,
                                //               ),
                                //               // borderSide: BorderSide.none
                                //             ),
                                //             focusedBorder: OutlineInputBorder(
                                //               borderRadius: BorderRadius.circular(5.0),
                                //               borderSide: const BorderSide(
                                //                 color: ,
                                //               ),
                                //             ),
                                //             errorBorder: OutlineInputBorder(
                                //               borderRadius: BorderRadius.circular(5.0),
                                //               borderSide: const BorderSide(color: Colors.red),
                                //             ),
                                //             focusedErrorBorder: OutlineInputBorder(
                                //               borderRadius: BorderRadius.circular(5.0),
                                //               borderSide: const BorderSide(color: Colors.red),
                                //             ),
                                //             isDense: true,
                                //             contentPadding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                //             hintStyle: const TextStyle(
                                //                 color: Colors.black54, fontSize: 14),
                                //           ),
                                //           style: const TextStyle(color: Colors.black),
                                //           // validator: (String? Password) {
                                //           //   if (Password != null && Password.isEmpty) {
                                //           //     return "Password can't be empty";
                                //           //   }
                                //           //   return null;
                                //           // },
                                //           onChanged: (String? text) {
                                //             email = text!;
                                //             // print(email);
                                //           },
                                //         ),
                                //       )
                                //     ]
                                // ),
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
                                        child: TextFormField(
                                          controller: dobController,
                                          keyboardType: TextInputType.none,
                                          onTap: () {
                                            setState(() {
                                              FocusManager.instance.primaryFocus?.unfocus();
                                              _selectDate(context);
                                            });
                                          },
                                          decoration: InputDecoration(
                                            suffixIcon: Icon(Icons.edit),
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
                                            contentPadding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                            hintText: "Ex: 2000-01-01",
                                            hintStyle: const TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          validator: (String? DOB) {
                                            if (DOB != null && DOB.isEmpty) {
                                              return "Date of birth can't be empty";
                                            } else {
                                              return null;
                                            }
                                          },
                                          onChanged: (String? text) {
                                            selectedDate = text!;
                                          },
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
                                        child: TextFormField(
                                          controller: mobileController,
                                          enabled: true,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp("[0-9]")), // only allow digits
                                          ],
                                          decoration: InputDecoration(
                                            suffixIcon: Icon(Icons.edit, color: Colors.grey,),
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
                                            contentPadding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                            hintStyle: const TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          validator: (String? mobileNumber) {
                                            if (mobileNumber != null && mobileNumber.isEmpty) {
                                              return "Mobile Number can't be empty";
                                            } else if (mobileNumber!.length != 10)
                                              return 'Mobile Number must be 10 digit';

                                            return null;
                                          },
                                          onChanged: (String? text) {
                                            email = text!;
                                            // print(email);
                                          },
                                        ),
                                      )
                                    ]
                                ),
                                SizedBox(height: 30,),
                                (loginUserData['userType']=='admin') ?
                                SizedBox(height: 30,)
                                    :Row(
                                    children: [
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
                                        child: TextFormField(
                                          controller: suburbController,
                                          enabled: true,
                                          decoration: InputDecoration(
                                            suffixIcon: Icon(Icons.edit, color: Colors.grey,),
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
                                            contentPadding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                            hintStyle: const TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          validator: (String? Suburb) {
                                            if (Suburb != null && Suburb.isEmpty) {
                                              return "Suburb can't be empty";
                                            }
                                            return null;
                                          },
                                          onChanged: (String? text) {
                                            email = text!;
                                            // print(email);
                                          },
                                        ),
                                      )
                                    ]
                                ),
                                SizedBox(height: 50,),
                                Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: GestureDetector(
                                    onTap: () async{
                                      if (_formKey.currentState!.validate()) {
                                        print("::::::::::::::::::::::::::::::::::::::::");
                                        await updateUser();
                                        _formKey.currentState!.save();
                                      }
                                    },
                                    child: Buttons_in_form(
                                      icon: const Icon(Icons.update_outlined, color: Colors.white,),
                                      text: isLoading
                                          ? const Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: SpinKitDualRing(
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      )
                                          : Text("Update PROFILE",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.white)),),
                                    // child: Container(
                                    //   width: screenWidth*0.3,
                                    //   height: 40,
                                    //   decoration: BoxDecoration(
                                    //     color: kiconColor,
                                    //     borderRadius: BorderRadius.circular(15),
                                    //     boxShadow: const [
                                    //       BoxShadow(
                                    //         color: Colors.black26,
                                    //         offset: Offset(3, 3),
                                    //         blurRadius: 2,
                                    //       )
                                    //     ],
                                    //   ),
                                    //   child: const Row(
                                    //     mainAxisAlignment: MainAxisAlignment.center,
                                    //     children: [
                                    //       Text('Update Information',
                                    //           textAlign: TextAlign.center,
                                    //           style: TextStyle(
                                    //               fontWeight: FontWeight.bold,
                                    //               fontSize: 12,
                                    //               color: Colors.white)),
                                    //     ],
                                    //   ),
                                    // ),
                                  ),
                                ),
                                SizedBox(height: 200,)
                              ]
                          ),
                        )
                    ),
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

