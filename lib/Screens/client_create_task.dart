import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:clean_connector/Constant/const_api.dart';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/login_screen.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Controller/authController.dart';
import '../components/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dioo;

import '../components/text_button.dart';

File? image;

class ClientTaskCreate extends StatefulWidget {
  @override
  State<ClientTaskCreate> createState() => _ClientTaskCreateState();
}

class _ClientTaskCreateState extends State<ClientTaskCreate> {
  bool isLoading = false;
  String profilePic = '';
  String task = '';
  String taskdes = '';
  String assignee = '';
  String selectedDate = '';
  DateTime _date = DateTime.now();
  TextEditingController taskController = new TextEditingController();
  TextEditingController taskdesController = new TextEditingController();
  TextEditingController dobController = new TextEditingController();
  TextEditingController assigneeController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static final now = DateTime.now();
  String? _selectedAssignee;
  String? _selectedAssigneeId;
  int? priorityValue;
  List<String> _userTypeList = [];
  bool _isLoading = true;
  Map<String, String> _usernameToIdMap = {};
  String? _selectedPriority;
  List<String> priorityList = <String>["High", "Medium", "Low"];
  String? _selectedSite;
  List<String> siteList = [];
  Map<String, String> _sitenameToIdMap = {};
  String? _selectedSiteId;
  File? _image;

  int getPriorityValue(String priority) {
    switch (priority) {
      case "High":
        return 1;
      case "Medium":
        return 2;
      case "Low":
        return 3;
      default:
        return 0; // Default value or handle error case
    }
  }

  @override
  void initState() {
    super.initState();
    getCleaners();
    getSites();
  }

  Future<void> getSites() async {
    print("Getting sites list....");
    userList = [];
    final response = await Dio().get("${BASE_API2}site/getall-sites",
        options:
            Options(headers: {"Authorization": loginUserData['accessToken']}));
    var data = response.data['sites'];
    print("DATA: $data");
    if (response.statusCode == 200) {
      final List<dynamic> siteData = response.data['sites'];
      print("List: $siteData");

      final Map<String, String> sitenameToIdMap = {};
      final List<String> siteNamesWithAddress = [];

      for (final site in siteData) {
        final String siteId = site['site_id'].toString();
        final String sitename = site['site_name'].toString();
        final String siteAddress = site['site_address'].toString();

        // Store both site name and address in the map
        sitenameToIdMap["$sitename - $siteAddress"] = siteId;

        // Create a string that combines site name and address
        final String siteNameWithAddress = "$sitename - $siteAddress";
        siteNamesWithAddress.add(siteNameWithAddress);
      }

      setState(() {
        siteList = siteNamesWithAddress;
        _sitenameToIdMap = sitenameToIdMap;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> getCleaners() async {
    print("Getting cleaners list....");
    userList = [];
    final response = await Dio().get(
        "${BASE_API2}user/getCleanerUsersBySiteId/${loginUserData['id']}",
        options:
            Options(headers: {"Authorization": loginUserData['accessToken']}));
    var data = response.data['result'];
    print("DATA: $data");
    if (response.statusCode == 200) {
      final List<dynamic> usersData = response.data['result'];
      print("List: $usersData");

      final Map<String, String> usernameToIdMap = {};
      final List<String> userDisplayNames =
          []; // Change to store emp_no - f_name l_name

      for (final user in usersData) {
        final String userId = user['user_id'].toString();
        final String displayName =
            "${user['emp_no']} - ${user['f_name']} ${user['l_name']}";

        usernameToIdMap[displayName] = userId;
        userDisplayNames.add(displayName);
      }

      setState(() {
        _userTypeList = userDisplayNames;
        _usernameToIdMap = usernameToIdMap;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  // Create Task

  String getUserIdByUsername(String username) {
    return _usernameToIdMap[username] ??
        ''; // Assuming _usernameToIdMap is defined somewhere with usernames as keys and user IDs as values
  }

  Future CreateTask() async {
    final receiverId = getUserIdByUsername(_selectedAssignee ?? '');
    //final prefs = await SharedPreferences.getInstance();
    print(
        'receiver id-$receiverId\ntask controller-${taskController.text}\ndeadline-${dobController.text}\ntaskdes: ${taskdesController.text}\npriority-$priorityValue');
    setState(() {
      isLoading = true;
    });
    try {
      print("xxxx");
      var response = await Dio().post('${BASE_API2}tasks/createTask',
          options: Options(headers: {
            "Authorization": "Bearer " + loginUserData["accessToken"]
          }),
          data: {
            "sender": loginUserData['id'],
            "receiver": _selectedAssigneeId,
            "deadline": dobController.text,
            "task_tittle": taskController.text,
            "description": taskdesController.text,
            "priority": getPriorityValue(_selectedPriority!),
          });

      print("!!!!!!!!!!$response");
      print(response.data["accessToken"]);
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        if (response.data["message"] == "Task Created successfully") {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) => ViewTaskScreen(),
            ),
            (Route route) => false,
          );
        } else {
          print("Failed");
        }
      } else if (response.statusCode == 400) {
        print("Bad error.....................");
      } else {
        print(response.statusCode);
        setState(() {
          isLoading = false;
        });
        if (response.data["message"] == "User entered wrong password") {
          print("User entered wrong password");
        }
      }
      print("@Error");
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        print("Bad Error");
        print(e.response?.data["message"]);
        if (e.response?.data["message"] == "User entered wrong password") {}
      }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    DateTime? _datePicker = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1947),
      lastDate: DateTime(2500),
      initialDatePickerMode: DatePickerMode.year,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(), // Set the theme to dark
          child: child!,
        );
      },
    );
    if (_datePicker != null && _datePicker != _date) {
      String formattedDate = DateFormat("yyyy-MM-dd").format(_datePicker);
      setState(() {
        dobController.text = formattedDate.toString();
        _date = _datePicker;
        print(_date.toString());
      });
    }
  }

  Future<void> _getFromGallery() async {
    try {
      final pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxHeight: 500,
        maxWidth: 500,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<void> _checkPermissionsAndPickImage() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      await _getFromGallery();
    } else {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        await _getFromGallery();
      } else {
        print("Camera permission not granted");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          image = null;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ViewTaskScreen()),
            (Route<dynamic> route) => false,
          );
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
              "CREATE TASK",
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
                Expanded(
                    child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: Column(children: [
                              Center(
                                child: _image != null
                                    ? GestureDetector(
                                        onTap: _getFromGallery,
                                        child: Container(
                                          width: screenWidth,
                                          height: screenWidth * 0.5,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: kcardBackgroundColor,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(11),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(11),
                                            child: Image.file(
                                              _image!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: _checkPermissionsAndPickImage,
                                        child: Container(
                                          width: screenWidth,
                                          height: screenWidth * 0.5,
                                          decoration: BoxDecoration(
                                            color: kcardBackgroundColor,
                                            border: Border.all(
                                              color: kcardBackgroundColor,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(11),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.add_photo_alternate,
                                              color: Colors.white,
                                              size: 50,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Row(children: [
                                Icon(
                                  Icons.add_task,
                                  color: kiconColor,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: const Text(
                                    "Task ",
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
                                    border: Border.all(
                                        width: 0, color: Colors.white),
                                    borderRadius: BorderRadius.circular(11)),
                                // width: width,
                                child: TextFormField(
                                  controller: taskController,
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
                                    hintText: "Task",
                                    hintStyle: const TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  validator: (String? task) {
                                    if (task != null && task.isEmpty) {
                                      return "Task can't be empty";
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
                                  Icons.task,
                                  color: kiconColor,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: const Text(
                                    "Task Description ",
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
                              ), //
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
                                  controller: taskdesController,
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
                                    hintText: "Task Description",
                                    hintStyle: const TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  validator: (taskdes) {
                                    if (EmailValidator.validate(taskdes!)) {
                                      return null;
                                    }
                                    if (taskdes != null && taskdes.isEmpty) {
                                      return "Description can't be empty";
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
                                const Icon(
                                  Icons.low_priority_outlined,
                                  color: kiconColor,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: const Text(
                                    "Priority ",
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
                                child: DropdownButtonFormField(
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
                                    hintText: "Select a Priority Level",
                                    hintStyle: const TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  value: _selectedPriority,
                                  items: priorityList.map((String priority) {
                                    // print(allergyNames.length);
                                    return DropdownMenuItem<String>(
                                      value: priority,
                                      child: Text(priority),
                                      // enabled: !this.ispreview,
                                    );
                                  }).toList(),
                                  validator: (String? uType) {
                                    if (_selectedPriority == null) {
                                      return "Priority can't be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPriority = value;
                                    });

                                    // Convert the selected priority to an integer value
                                    int priorityValue =
                                        getPriorityValue(value!);

                                    // Now you can use priorityValue when calling your API
                                    // Example: apiFunction(priorityValue);

                                    print(
                                        "priority Level: $_selectedPriority, priorityValue: $priorityValue");
                                  },
                                  onSaved: (value) {
                                    _selectedPriority = value.toString();
                                  },
                                ),
                              ),
                              // SizedBox(
                              //   height: 30,
                              // ),
                              // Row(children: [
                              //   const Icon(
                              //     Icons.low_priority_outlined,
                              //     color: kiconColor,
                              //   ),
                              //   const SizedBox(
                              //     width: 20,
                              //   ),
                              //   Container(
                              //     child: const Text(
                              //       "Site ",
                              //       style: TextStyle(
                              //           fontWeight: FontWeight.w600,
                              //           fontSize: 15,
                              //           color: kiconColor,
                              //           fontFamily: "OpenSans"),
                              //     ),
                              //   ),
                              //   Container(
                              //     width: 10,
                              //     child: const Text(
                              //       ":",
                              //       style: TextStyle(
                              //           fontWeight: FontWeight.w600,
                              //           fontSize: 15,
                              //           color: kiconColor,
                              //           fontFamily: "OpenSans"),
                              //     ),
                              //   ),
                              // ]),
                              // const SizedBox(
                              //   height: 15,
                              // ),
                              // Container(
                              //   alignment: Alignment.center,
                              //   decoration: BoxDecoration(
                              //     boxShadow: const [
                              //       BoxShadow(
                              //         color: Colors.black12,
                              //         offset: Offset(2, 2),
                              //         blurRadius: 2,
                              //       )
                              //     ],
                              //     color: const Color.fromRGBO(
                              //         241, 239, 239, 0.298),
                              //     border:
                              //         Border.all(width: 0, color: Colors.white),
                              //     borderRadius: BorderRadius.circular(11),
                              //   ),
                              //   child: DropdownButtonFormField(
                              //     decoration: InputDecoration(
                              //       fillColor: Colors.white,
                              //       filled: true,
                              //       enabledBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(5.0),
                              //         borderSide: const BorderSide(
                              //           color: Colors.white,
                              //         ),
                              //       ),
                              //       focusedBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(5.0),
                              //         borderSide: const BorderSide(
                              //           color: kiconColor,
                              //         ),
                              //       ),
                              //       errorBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(5.0),
                              //         borderSide:
                              //             const BorderSide(color: Colors.red),
                              //       ),
                              //       focusedErrorBorder: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(5.0),
                              //         borderSide:
                              //             const BorderSide(color: Colors.red),
                              //       ),
                              //       isDense: true,
                              //       contentPadding: const EdgeInsets.fromLTRB(
                              //           15, 30, 15, 0),
                              //       hintText: "Select a Site",
                              //       hintStyle: const TextStyle(
                              //         color: Colors.black54,
                              //         fontSize: 14,
                              //       ),
                              //     ),
                              //     style: const TextStyle(color: Colors.black),
                              //     validator: (value) {
                              //       if (value == null || value.isEmpty) {
                              //         return 'Please select a site';
                              //       }
                              //       return null;
                              //     },
                              //     autovalidateMode:
                              //         AutovalidateMode.onUserInteraction,
                              //     value: _selectedSite,
                              //     items: siteList.map<DropdownMenuItem<String>>(
                              //       (String siteNameWithAddress) {
                              //         return DropdownMenuItem<String>(
                              //           value: siteNameWithAddress,
                              //           child: Text(siteNameWithAddress),
                              //         );
                              //       },
                              //     ).toList(),
                              //     onChanged: (value) {
                              //       print('Selected Site: $value');
                              //       setState(() {
                              //         // Use the sitename-to-ID map to get the site ID
                              //         _selectedSiteId = _sitenameToIdMap[value];
                              //       });
                              //       print('Selected Site ID: $_selectedSiteId');
                              //       getCleaners(); // Call getCleaners whenever the site selection changes
                              //     },
                              //   ),
                              // ),
                              SizedBox(
                                height: 30,
                              ),
                              Row(children: [
                                Icon(
                                  Icons.supervised_user_circle_rounded,
                                  color: kiconColor,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: const Text(
                                    "Assignee ",
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
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide: const BorderSide(
                                        color: Colors.white,
                                      ),
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
                                    hintText: "Select an Assignee",
                                    hintStyle: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select an assignee';
                                    }
                                    return null;
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  value: _selectedAssignee,
                                  items: _usernameToIdMap.keys
                                      .map<DropdownMenuItem<String>>(
                                    (String displayName) {
                                      return DropdownMenuItem<String>(
                                        value: displayName,
                                        child: Text(displayName),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (value) {
                                    print('Selected Display Name: $value');
                                    setState(() {
                                      _selectedAssignee = value;
                                      _selectedAssigneeId =
                                          _usernameToIdMap[value];
                                      print(
                                          'Selected UserID: $_selectedAssigneeId');
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(
                                height: 30,
                              ),
                              Row(children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: kiconColor,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: const Text(
                                    "Date",
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
                                    border: Border.all(
                                        width: 0, color: Colors.white),
                                    borderRadius: BorderRadius.circular(11)),
                                // width: width,
                                child: TextFormField(
                                  controller: dobController,
                                  keyboardType: TextInputType.text,
                                  onTap: () {
                                    setState(() {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      _selectDate(context);
                                    });
                                  },
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
                                    hintText: "Ex: 2000-01-01",
                                    hintStyle: const TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  validator: (String? time) {
                                    if (time != null && time.isEmpty) {
                                      return "Date & Time can't be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  onChanged: (String? text) {
                                    selectedDate = text!;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    print(
                                        "::::::::::::::::::::::::::::::::::::::::");
                                    await CreateTask();
                                    _formKey.currentState!.save();
                                  } else {
                                    print("Check the form");
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
                                      : Text("Create Task",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.white)),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom))
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
      ),
    );
  }
}
