import 'dart:async';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/site_list.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dioo;
import 'package:http_parser/http_parser.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Constant/const_api.dart';
import '../components/bottom_bar.dart';
import '../components/text_button.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';

File? image;

class EditClient extends StatefulWidget {
  EditClient({
    required this.id,
    required this.emailAdd,
    required this.client,
    required this.phone,
    required this.site,
    required this.attendance,
    required this.sunD,
    required this.monD,
    required this.tueD,
    required this.wedsD,
    required this.thuD,
    required this.friD,
    required this.satD,
  });
  String? id;
  String? emailAdd;
  String? client;
  String? phone;
  String? site;
  String? attendance;
  String? sunD;
  String? monD;
  String? tueD;
  String? wedsD;
  String? thuD;
  String? friD;
  String? satD;

  @override
  State<EditClient> createState() => _EditClientState();
}

class _EditClientState extends State<EditClient> {
  bool isLoading = false;
  bool _isObscure = true;
  bool _isObscurePw = true;
  String profilePic = '';
  String name = '';
  String email = '';
  String selectedDate = '';
  DateTime _date = DateTime.now();
  bool iseditPw = false;
  TextEditingController siteNameController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController mobileController = new TextEditingController();
  TextEditingController attendanceController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  TextEditingController sun = new TextEditingController();
  TextEditingController mon = new TextEditingController();
  TextEditingController tue = new TextEditingController();
  TextEditingController thu = new TextEditingController();
  TextEditingController wed = new TextEditingController();
  TextEditingController fri = new TextEditingController();
  TextEditingController sat = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedUserType;
  String? userType;
  String adminType = '';
  double rate = 0.0;
  List<String> userTypeList = <String>["Chamara", "Sajith", "Chamalka"];
  static final now = DateTime.now();

  Future EditClient() async {
    setState(() {
      isLoading = true;
      rate = double.parse(attendanceController.text);
    });
    print("User Data sending............... ${attendanceController.text}");
    try {
      var response = await Dio().put(BASE_API2 + 'site/edit-client/${widget.id}',
          data: {
            "site_name": siteNameController.text,
            "site_address": locationController.text,
            "email": emailController.text,
            "rate" : double.parse(attendanceController.text),
            "mobile" : mobileController.text,
            "password" : passwordController.text,
            "sun": sun.text,
            "mon": mon.text,
            "tues": tue.text,
            "wed": wed.text,
            "thur": thu.text,
            "fri": fri.text,
            "satur": sat.text,
          },
          options: Options(headers: {
            "Authorization": "Bearer "+ loginUserData["accessToken"]
          }));
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print("Response => ${response.data}");
      setState(() {
        isLoading = false;
      });
      if (response.data["status"] == true && response.data["message"] == "Site and Schedule Updated Successfully") {
        print("Edit site Successfully");
        Timer(const Duration(milliseconds: 1500), () =>Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SiteList())));
        image = null;
      } else if (response.data["status"] == false) {
        if (response.data["message"] == "Email already registered") {
        } else if (response.data["message"] == " userName  is already exists") {
          print("Email already exists.");
        }
        else {
          print("Adding user failed");
          return null;
        }
      }
    } on DioException catch (e) {
      if(e.response?.statusCode == 400){
        print("Bad Error");
        print(e.response?.data["message"] );
        if(e.response?.data["message"]=="User entered wrong password"){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Wrong Password'),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .size
                    .height - 100,
                right: 5,
                left: 5),
          ));
        }else if(e.response?.data["message"]=="No any registered user for this email"){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("No any registered user for this email"),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .size
                    .height - 100,
                right: 5,
                left: 5),
          ));
        }
      }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      siteNameController.text = widget.client!;
      locationController.text = widget.site!;
      emailController.text = widget.emailAdd!;
      mobileController.text = widget.phone!;
      attendanceController.text = widget.attendance!;
      sun.text = widget.sunD!;
      mon.text = widget.monD!;
      tue.text = widget.tueD!;
      wed.text = widget.wedsD!;
      thu.text = widget.thuD!;
      fri.text = widget.friD!;
      sat.text = widget.satD!;
    });
  }

  // Future<Null> _selectDate(BuildContext) async {
  //   DateTime? _datePicker = await showDatePicker(
  //     context: context,
  //     initialDate: _date,
  //     firstDate: DateTime(1947),
  //     lastDate: DateTime.now(),
  //     initialDatePickerMode: DatePickerMode.year,
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //   );
  //   if (_datePicker != null && _datePicker != _date) {
  //     String formattedDate = DateFormat("yyyy-MM-dd").format(_datePicker);
  //     setState(() {
  //       dobController.text = formattedDate.toString();
  //       _date = _datePicker;
  //       print(_date.toString());
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return
      // WillPopScope(
      // onWillPop: () async {
      //   image = null;
      //   Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(builder: (context) => const SiteList()),
      //     (Route<dynamic> route) => false,
      //   );
      //   return false;
      // },
      // child:
      SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              "EDIT CLIENT",
              style: kboldTitle,
            ),
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
                // Container(
                //   decoration: BoxDecoration(
                //       color: kcardBackgroundColor,
                //       borderRadius: BorderRadius.circular(50)
                //   ),
                //   width: screenWidth,
                //   height: 3,
                // ),
                Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.disabled,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Column(children: [
                                  Row(children: [
                                    const Icon(
                                      Icons.person_pin,
                                      color: kiconColor,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                      child: const Text(
                                        "Client ",
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
                                  const SizedBox(
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
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius: BorderRadius.circular(11)),
                                    // width: width,
                                    child: TextFormField(
                                      controller: siteNameController,
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
                                          borderSide:
                                          const BorderSide(color: Colors.red),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide:
                                          const BorderSide(color: Colors.red),
                                        ),
                                        isDense: true,
                                        contentPadding: const EdgeInsets.fromLTRB(
                                            15, 30, 15, 0),
                                        hintText: "Client",
                                        hintStyle: const TextStyle(
                                            color: Colors.black54, fontSize: 14),
                                      ),
                                      style: const TextStyle(color: Colors.black),
                                      validator: (String? u_name) {
                                        if (u_name != null && u_name.isEmpty) {
                                          return "Client can't be empty";
                                        } else {
                                          return null;
                                        }
                                      },
                                      autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                      onChanged: (String? text) {
                                        name = text!;
                                        // print(email);
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      color: kiconColor,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Container(
// width: 130,
                                      child: const Text(
                                        "Email ",
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
                                  const SizedBox(
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
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius: BorderRadius.circular(11)),
                                    // width: width,
                                    child: TextFormField(
                                      controller: emailController,
                                      enabled: true,
                                      keyboardType: TextInputType.emailAddress,
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
                                          borderSide:
                                          const BorderSide(color: Colors.red),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide:
                                          const BorderSide(color: Colors.red),
                                        ),
                                        isDense: true,
                                        contentPadding: const EdgeInsets.fromLTRB(
                                            15, 30, 15, 0),
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
                                      autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                      onChanged: (String? text) {
                                        email = text!;
                                        // print(email);
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(children: [
                                    const Icon(
                                      Icons.phone,
                                      color: kiconColor,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                      child: const Text(
                                        "Mobile ",
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
                                  const SizedBox(
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
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius: BorderRadius.circular(11)),
                                    // width: width,
                                    child: TextFormField(
                                      controller: mobileController,
                                      keyboardType: TextInputType.number,
                                      enabled: true,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp("[0-9]")), // only allow digits
                                      ],
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
                                          borderSide:
                                          const BorderSide(color: Colors.red),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide:
                                          const BorderSide(color: Colors.red),
                                        ),
                                        isDense: true,
                                        contentPadding: const EdgeInsets.fromLTRB(
                                            15, 30, 15, 0),
                                        hintText: "Phone Number",
                                        hintStyle: const TextStyle(
                                            color: Colors.black54, fontSize: 14),
                                      ),
                                      style: const TextStyle(color: Colors.black),
                                      validator: (String? mobileNumber) {
                                        if (mobileNumber != null &&
                                            mobileNumber.isEmpty) {
                                          return "Mobile Number can't be empty";
                                        } else if (mobileNumber!.length != 10)
                                          return 'Mobile Number must be 10 digit';

                                        return null;
                                      },
                                      autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                      onChanged: (String? text) {
                                        email = text!;
                                        // print(email);
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(children: [
                                    const Icon(
                                      Icons.location_pin,
                                      color: kiconColor,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                      child: const Text(
                                        "Site ",
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
                                  const SizedBox(
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
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius: BorderRadius.circular(11)),
                                    // width: width,
                                    child: TextFormField(
                                      controller: locationController,
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
                                          borderSide:
                                          const BorderSide(color: Colors.red),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide:
                                          const BorderSide(color: Colors.red),
                                        ),
                                        isDense: true,
                                        contentPadding: const EdgeInsets.fromLTRB(
                                            15, 30, 15, 0),
                                        hintText: "Site",
                                        hintStyle: const TextStyle(
                                            color: Colors.black54, fontSize: 14),
                                      ),
                                      style: const TextStyle(color: Colors.black),
                                      validator: (String? location) {
                                        if (location != null && location.isEmpty) {
                                          return "Site can't be empty";
                                        } else {
                                          return null;
                                        }
                                      },
                                      autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                      onChanged: (String? text) {
                                        email = text!;
                                        // print(email);
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(children: [
                                    const Icon(
                                      Icons.percent,
                                      color: kiconColor,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Container(
// width: 130,
                                      child: const Text(
                                        "Attendance Rate ",
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
                                  const SizedBox(
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
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius: BorderRadius.circular(11)),
                                    // width: width,
                                    child: TextFormField(
                                      controller: attendanceController,
                                      keyboardType: TextInputType.number,
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
                                          borderSide:
                                          const BorderSide(color: Colors.red),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                          borderSide:
                                          const BorderSide(color: Colors.red),
                                        ),
                                        isDense: true,
                                        contentPadding: const EdgeInsets.fromLTRB(
                                            15, 30, 15, 0),
                                        hintText: "%",
                                        hintStyle: const TextStyle(
                                            color: Colors.black54, fontSize: 14),
                                      ),
                                      style: const TextStyle(color: Colors.black),
                                      validator: (String? attendance) {
                                        if (attendance != null &&
                                            attendance.isEmpty) {
                                          return "Attendance can't be empty";
                                        } else if(double.parse(attendance!)>100){
                                          return "Attendance can't be more than 100";
                                        }else {
                                          return null;
                                        }
                                      },
                                      autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                      onChanged: (String? text) {
                                        email = text!;
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(children: [
                                    const Icon(
                                      Icons.password,
                                      color: kiconColor,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                      child: const Text(
                                        "Password ",
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
                                  const SizedBox(
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
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius:
                                        BorderRadius.circular(11)),
                                    // width: width,
                                    child: TextFormField(
                                      controller: passwordController,
                                      enabled: true,
                                      obscureText: _isObscure,
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
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                          ),
                                          // borderSide: BorderSide.none
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                            color: kiconColor,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                              color: Colors.red),
                                        ),
                                        focusedErrorBorder:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                              color: Colors.red),
                                        ),
                                        isDense: true,
                                        contentPadding:
                                        const EdgeInsets.fromLTRB(
                                            15, 30, 15, 0),
                                        hintText: "Password",
                                        hintStyle: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      ),
                                      style: const TextStyle(
                                          color: Colors.black),
                                      validator: (value) {
                                        if(iseditPw == true) {
                                    if (value!.isEmpty) {
                                      return "Password can't be empty";
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
                                  }
                                },
                                      autovalidateMode: AutovalidateMode
                                          .onUserInteraction,
                                      onChanged: (String? text) {
                                        email = text!;
                                        setState(() {
                                          iseditPw = true;
                                        });
                                        // print(email);
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(children: [
                                    const Icon(
                                      Icons.password_sharp,
                                      color: kiconColor,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                      child: const Text(
                                        "Confirm Password ",
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
                                  const SizedBox(
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
                                        border: Border.all(
                                            width: 0, color: Colors.white),
                                        borderRadius:
                                        BorderRadius.circular(11)),
                                    // width: width,
                                    child: TextFormField(
                                      obscureText: _isObscurePw,
                                      controller: confirmPasswordController,
                                      enabled: true,
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        suffixIcon: IconButton(
                                            icon: Icon(
                                                _isObscurePw
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: kiconColor),
                                            onPressed: () {
                                              setState(() {
                                                _isObscurePw =
                                                !_isObscurePw;
                                              });
                                            }),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                          ),
                                          // borderSide: BorderSide.none
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                            color: kiconColor,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                              color: Colors.red),
                                        ),
                                        focusedErrorBorder:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                              color: Colors.red),
                                        ),
                                        isDense: true,
                                        contentPadding:
                                        const EdgeInsets.fromLTRB(
                                            15, 30, 15, 0),
                                        hintText: "Confirm Password",
                                        hintStyle: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      ),
                                      style: const TextStyle(
                                          color: Colors.black),
                                      autovalidateMode: AutovalidateMode
                                          .onUserInteraction,
                                      validator: (c_Pw) {
                                        if(iseditPw == true) {
                                    if (c_Pw != null && c_Pw.isEmpty) {
                                      return "Confirm password can't be empty";
                                    } else if (passwordController.text !=
                                        confirmPasswordController.text) {
                                      return "Password and Confirm Password does not match";
                                    } else {
                                      return null;
                                    }
                                  }
                                },
                                      onChanged: (String? text) {
                                        email = text!;
                                        setState(() {
                                          iseditPw = true;
                                        });// print(email);
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      color: kiconColor,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                      child: const Text(
                                        "Schedule ",
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
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: screenWidth/7,
                                        color: Colors.transparent,
                                        child: Text("SUN:"),
                                      ),
                                      Container(
                                        width: screenWidth/7,
                                        color: Colors.transparent,
                                        child: Text("MON:"),
                                      ),
                                      Container(
                                        width: screenWidth/7,
                                        color: Colors.transparent,
                                        child: Text("TUE:"),
                                      ),
                                      Container(
                                        width: screenWidth/7,
                                        color: Colors.transparent,
                                        child: Text("WED:"),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: screenWidth/7,
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
                                            border: Border.all(
                                                width: 0, color: Colors.white),
                                            borderRadius: BorderRadius.circular(11)),
                                        // width: width,
                                        child: TextFormField(
                                          controller: sun,
                                          keyboardType: TextInputType.number,
                                          inputFormatters:[
                                            LengthLimitingTextInputFormatter(2),
                                          ],
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
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            isDense: true,
                                            contentPadding: const EdgeInsets.fromLTRB(
                                                15, 30, 15, 0),
                                            hintText: "0",
                                            hintStyle: const TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          onChanged: (String? text) {
                                            email = text!;
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth/7,
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
                                            border: Border.all(
                                                width: 0, color: Colors.white),
                                            borderRadius: BorderRadius.circular(11)),
                                        // width: width,
                                        child: TextFormField(
                                          controller: mon,
                                          inputFormatters:[
                                            LengthLimitingTextInputFormatter(2),
                                          ],
                                          keyboardType: TextInputType.number,
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
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            isDense: true,
                                            contentPadding: const EdgeInsets.fromLTRB(
                                                15, 30, 15, 0),
                                            hintText: "0",
                                            hintStyle: const TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          onChanged: (String? text) {
                                            email = text!;
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth/7,
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
                                            border: Border.all(
                                                width: 0, color: Colors.white),
                                            borderRadius: BorderRadius.circular(11)),
                                        // width: width,
                                        child: TextFormField(
                                          controller: tue,
                                          inputFormatters:[
                                            LengthLimitingTextInputFormatter(2),
                                          ],
                                          keyboardType: TextInputType.number,
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
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            isDense: true,
                                            contentPadding: const EdgeInsets.fromLTRB(
                                                15, 30, 15, 0),
                                            hintText: "0",
                                            hintStyle: const TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          onChanged: (String? text) {
                                            email = text!;
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth/7,
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
                                            border: Border.all(
                                                width: 0, color: Colors.white),
                                            borderRadius: BorderRadius.circular(11)),
                                        // width: width,
                                        child: TextFormField(
                                          inputFormatters:[
                                            LengthLimitingTextInputFormatter(2),
                                          ],
                                          controller: wed,
                                          keyboardType: TextInputType.number,
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
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            isDense: true,
                                            contentPadding: const EdgeInsets.fromLTRB(
                                                15, 30, 15, 0),
                                            hintText: "0",
                                            hintStyle: const TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          onChanged: (String? text) {
                                            email = text!;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: screenWidth/7,
                                        color: Colors.transparent,
                                        child: Text("THU:"),
                                      ),
                                      Container(
                                        width: screenWidth/7,
                                        color: Colors.transparent,
                                        child: Text("FRI:"),
                                      ),
                                      Container(
                                        width: screenWidth/7,
                                        color: Colors.transparent,
                                        child: Text("SAT:"),
                                      ),
                                      Container(
                                        width: screenWidth/7,
                                        color: Colors.transparent,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: screenWidth/7,
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
                                            border: Border.all(
                                                width: 0, color: Colors.white),
                                            borderRadius: BorderRadius.circular(11)),
                                        // width: width,
                                        child: TextFormField(
                                          controller: thu,
                                          inputFormatters:[
                                            LengthLimitingTextInputFormatter(2),
                                          ],
                                          keyboardType: TextInputType.number,
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
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            isDense: true,
                                            contentPadding: const EdgeInsets.fromLTRB(
                                                15, 30, 15, 0),
                                            hintText: "0",
                                            hintStyle: const TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          onChanged: (String? text) {
                                            email = text!;
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth/7,
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
                                            border: Border.all(
                                                width: 0, color: Colors.white),
                                            borderRadius: BorderRadius.circular(11)),
                                        // width: width,
                                        child: TextFormField(
                                          controller: fri,
                                          inputFormatters:[
                                            LengthLimitingTextInputFormatter(2),
                                          ],
                                          keyboardType: TextInputType.number,
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
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            isDense: true,
                                            contentPadding: const EdgeInsets.fromLTRB(
                                                15, 30, 15, 0),
                                            hintText: "0",
                                            hintStyle: const TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          onChanged: (String? text) {
                                            email = text!;
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth/7,
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
                                            border: Border.all(
                                                width: 0, color: Colors.white),
                                            borderRadius: BorderRadius.circular(11)),
                                        // width: width,
                                        child: TextFormField(
                                          controller: sat,
                                          inputFormatters:[
                                            LengthLimitingTextInputFormatter(2),
                                          ],
                                          keyboardType: TextInputType.number,
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
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              borderSide:
                                              const BorderSide(color: Colors.red),
                                            ),
                                            isDense: true,
                                            contentPadding: const EdgeInsets.fromLTRB(
                                                15, 30, 15, 0),
                                            hintText: "0",
                                            hintStyle: const TextStyle(
                                                color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(color: Colors.black),
                                          onChanged: (String? text) {
                                            email = text!;
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: screenWidth/7,
                                        color: Colors.transparent,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      if (_formKey.currentState!.validate()) {
                                        print(
                                            "::::::::::::::::::::::::::::::::::::::::");
                                        await EditClient();
                                        _formKey.currentState!.save();
                                      }
                                    },
                                    child: Buttons_in_form(
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                      text: (isLoading == true)
                                          ? const Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: SpinKitDualRing(
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      )
                                          : Text("Edit Client",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.white)),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))
                                ])),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
          bottomNavigationBar: const BottomNavBar(),
        ),
      );
  }
}

class ProfilePic extends StatefulWidget {
  const ProfilePic({Key? key}) : super(key: key);

  @override
  _ProfilePicState createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  // XFile? _pickedFile;
  // CroppedFile? _croppedFile;
  _getFromGallery() async {
    print("Get from gallery");
    File _image;
    final picker = ImagePicker();

    var _pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxHeight: 500,
        maxWidth: 500);

    _image = File(_pickedFile!.path);

    image = _image;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Column(
        children: [
          const SizedBox(height: 5),
          image != null
              ? Stack(children: [
            CircleAvatar(
              radius: screenWidth * 0.13,
              backgroundColor: kcardBackgroundColor,
              child: ClipOval(
                child: Image.file(
                  image!,
                  width: screenWidth * 0.12 * 2,
                  height: screenWidth * 0.12 * 2,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: (screenWidth * 0.13) * 2,
              width: (screenWidth * 0.13) * 2,
              color: Colors.transparent,
              child: Container(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: kcardBackgroundColor,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                          onPressed: () async {
                            //_getFromGallery();
                            Map<Permission, PermissionStatus> statuses =
                            await [
                              Permission.storage,
                              Permission.camera,
                            ].request();
                            if (statuses[Permission.storage]!.isGranted &&
                                statuses[Permission.camera]!.isGranted) {
                              print("Permission granted.");
                              _getFromGallery();
                            } else {
                              print("No permission provided");
                            }
                          },
                          icon: const Icon(
                            Icons.photo_camera_outlined,
                            color: kiconColor,
                          )),
                    ),
                  )),
            ),
          ])
              : Stack(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.13,
                backgroundColor: kcardBackgroundColor,
                child: CircleAvatar(
                  radius: screenWidth * 0.12,
                  backgroundColor: Colors.white,
                ),
              ),
              Container(
                height: (screenWidth * 0.13) * 2,
                width: (screenWidth * 0.13) * 2,
                color: Colors.transparent,
                child: Container(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: kcardBackgroundColor,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            onPressed: () async {
                              Map<Permission, PermissionStatus> statuses =
                              await [
                                Permission.storage,
                                Permission.camera,
                              ].request();
                              if (statuses[Permission.storage]!
                                  .isGranted &&
                                  statuses[Permission.camera]!
                                      .isGranted) {
                                print("Permission granted.");
                                _getFromGallery();
                              } else {
                                print("Permission not granted.");
                              }
                            },
                            icon: const Icon(
                              Icons.photo_camera_outlined,
                              color: kiconColor,
                            )),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
