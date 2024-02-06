import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/create_task.dart';
import 'package:clean_connector/Screens/create_user.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:dio/dio.dart' as dioo;
import 'package:dio/dio.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart'
    as getFormData;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Constant/const_api.dart';
import '../Controller/authController.dart';
import '../components/bottom_bar.dart';
import '../components/text_button.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';

File? selectedImage;
FilePickerResult? _file;
File? selectedFile;

class TaskEdit extends StatefulWidget {
  final String id;
  final String sender;
  final String receiver;
  final String receiverUserName;
  final String created_date;
  final String deadline;
  final String description;
  final String task_tittle;
  String? image;
  int? priority;

  TaskEdit({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.receiverUserName,
    required this.created_date,
    required this.deadline,
    required this.description,
    required this.task_tittle,
    required this.priority,
    required this.image,
  });
  @override
  State<TaskEdit> createState() => _TaskEditState();
}

class _TaskEditState extends State<TaskEdit> {
  bool isLoading = false;
  String task = '';
  String taskdes = '';
  String date = '';
  String id = '';
  String selectedDate = '';
  String? _selectedPriority;
  String selectedDropdownValue = "";
  String? _selectedAssignee;
  String? _selectedAssigneeId;
  List<String> _userTypeList = [];
  bool _isLoading = true;
  Map<String, String> _usernameToIdMap = {};
  List<String> priorityList = <String>["High", "Medium", "Low"];
  DateTime _date = DateTime.now();
  TextEditingController taskController = new TextEditingController();
  TextEditingController taskdesController = new TextEditingController();
  TextEditingController priority = new TextEditingController();
  TextEditingController dateController = new TextEditingController();
  TextEditingController idController = new TextEditingController();
  TextEditingController assignee = new TextEditingController();
  TextEditingController sender = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    print("User Data sending ProfilePic $selectedImage");
    bool a = selectedImage != null;

    print("User Data sending 1* $a");
    // Get.closeAllSnackbars;
    super.initState();
    selectedImage = null;
    print("User Data sending 1 $selectedImage");
    _loadImage(widget.image);
    loading();
    getCleaners();
    setState(() {
      isLoading = false;
      taskController.text = widget.task_tittle.toString();
      priority.text = convertPriorityToString(widget.priority);
      assignee.text = widget.receiverUserName.toString();
      taskdesController.text = widget.description.toString();
      idController.text = widget.id.toString();
      sender.text = widget.sender.toString();
      _selectedAssigneeId = widget.receiver.toString();
      _selectedPriority = widget.priority == 1
          ? "High"
          : widget.priority == 2
              ? "Medium"
              : "Low";
      DateTime.parse(widget.deadline.toString());
      String formattedDate = DateFormat("yyyy-MM-dd")
          .format(DateTime.parse(widget.deadline.toString()));
      dateController.text = formattedDate;
    });
  }

  Future<void> _loadImage(String? imagepath) async {
    print("User Data sending path*** loadImage $imagepath");
    final response = await http.get(Uri.parse(imagepath!));

    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}${widget.task_tittle}.jpg');
      print("Image path *** $file");
      await file.writeAsBytes(bytes);
      setState(() {
        selectedImage = file;
      });
    } else {
      throw Exception('Failed to load image');
    }
  }

  _getFromGallery() async {
    print("User Data sending _getFromGallery");

    final picker = ImagePicker();

    var _pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxHeight: 500,
      maxWidth: 500,
    );

    if (_pickedFile == null) {
      // User canceled image selection
      return;
    }

    print("User Data sending Image path* 2 $selectedImage");

    // Delete existing image if it exists
    if (selectedImage != null) {
      try {
        selectedImage!.deleteSync();
        print("Existing image deleted successfully");
      } catch (e) {
        print("Error deleting existing image: $e");
      }
    }

    File _image = File(_pickedFile.path);

    setState(() {
      selectedImage = _image;
      widget.image = _pickedFile.path;
    });

    print("User Data sending Image path* 3 $selectedImage");

    bool b = selectedImage != null;
    print("User Data sending Image path** $b");
  }

  loading() async {
    setState(() {
      isLoading = false;
    });
  }

  var path =
      "https://t3.ftcdn.net/jpg/03/08/10/96/360_F_308109632_PzN8J2fHpLYbIOkMJOPAZSxbH6oBlKg1.jpg";

  // void saveImage() async {
  //   final imagePicker = ImagePicker();
  //   final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

  //   if (pickedFile == null) {
  //     // User canceled image selection
  //     return;
  //   }

  //   final path = pickedFile.path;

  //   await GallerySaver.saveImage(path);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text("Downloaded Successfully."),
  //     ),
  //   );
  // }

  Future<void> getCleaners() async {
    print("Getting cleaners list....");
    print(widget.sender);
    userList = [];
    final response = await Dio().get(
        "${BASE_API2}user/getCleanerUsersBySiteId/${widget.sender}",
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

  // Future updateTask() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     // Assuming priority.text contains the priority string
  //     String priorityText = priority.text;
  //     int priorityValue = getPriorityValue(priorityText);

  //     dio.FormData formData = dio.FormData.fromMap({
  //       "id": idController.text,
  //       "deadline": dateController.text,
  //       "task_title": taskController.text,
  //       "description": taskdesController.text,
  //       "priority": priorityValue,
  //       "assignee": assignee.text,
  //       "sender": sender.text,
  //       "image": "",
  //     });

  //     final response = await dio.Dio().put(
  //       BASE_API2 + "tasks/updateTask",
  //       options: dio.Options(headers: {
  //         "Authorization": "Bearer " + loginUserData["accessToken"]
  //       }),
  //       data: formData,
  //     );

  //     print("*******************User update response: $response");

  //     setState(() {
  //       isLoading = false;
  //     });

  //     if (response.statusCode == 200 &&
  //         response.data['message'] == "Task Updated Successfully") {
  //       Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(
  //           builder: (BuildContext context) => ViewTaskScreen(),
  //         ),
  //         (Route route) => false,
  //       );
  //       print('Updates Successfully');
  //     }
  //   } on dio.DioError catch (e) {
  //     print("Error navigating to TaskEdit screen: $e");
  //     if (e.response?.statusCode == 400) {
  //       print("Bad Error");
  //       print(e.response);
  //     }
  //     print(e.toString());
  //     setState(() {
  //       isLoading = false;
  //     });
  //     print(e);
  //   }
  // }

  Future updateTask(File? _image) async {
    setState(() {
      isLoading = true;
    });

    String imageName = _image != null ? _image.path.split('/').last : '';
    String priorityText = _selectedPriority.toString();
    int priorityValue = getPriorityValue(priorityText);

    dioo.FormData data = dioo.FormData.fromMap({
      'id': idController.text,
      'deadline': dateController.text,
      'task_tittle': taskController.text,
      'description': taskdesController.text,
      "image": _image != null
          ? await dioo.MultipartFile.fromFile(_image.path,
              filename: imageName, contentType: MediaType.parse('image/jpg'))
          : null,
      "priority": priorityValue,
      "receiver": _selectedAssigneeId,
      "sender": sender.text,
    });

    try {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      var response = await Dio().put(BASE_API2 + "tasks/updateTask",
          data: data,
          options: Options(headers: {
            "Authorization": "Bearer " + loginUserData["accessToken"]
          }));

      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print("Response*** => ${response.data["status"]}");

      setState(() {
        isLoading = false;
      });

      if (response.data["status"] == true &&
          response.data["message"] == "Task Updated Successfully") {
        print("Update User Successfully");
        showSuccessDialog(context);
      } else {
        print("Task Update Fail");
        return;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        print("Bad Error");
        print(e.response?.data["message"]);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.response?.data["message"]),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 100,
              right: 5,
              left: 5),
        ));
      } else if ((e.response?.statusCode == 401)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Session expired. Please Login again"),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.only(right: 5, left: 5, top: 100),
        ));
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
      firstDate: DateTime.now(),
      lastDate: DateTime(2500),
      initialDatePickerMode: DatePickerMode.year,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            // Change background
            colorScheme: ColorScheme.dark().copyWith(
              primary: Colors.grey, // Change button color
              // surface: Colors.blueGrey[50], // Change selected item color
            ),
          ), // Set the theme to dark
          child: child!,
        );
      },
    );
    if (_datePicker != null && _datePicker != _date) {
      String formattedDate = DateFormat("yyyy-MM-dd").format(_datePicker);
      setState(() {
        dateController.text = formattedDate.toString();
        _date = _datePicker;
        print(_date.toString());
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
          title: Text(
            "EDIT TASK INFORMATION",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            // logoutButton(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            children: [
              Container(
                //height: screenHeight * 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.image == ''
                        ? SizedBox()
                        : Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: screenWidth,
                                height: screenWidth * 0.5,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: kcardBackgroundColor,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image(
                                    fit: BoxFit.fill,
                                    image:
                                        NetworkImage(widget.image.toString()),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  _getFromGallery();
                                  Map<Permission, PermissionStatus> statuses =
                                      await [
                                    Permission.storage,
                                    Permission.camera,
                                  ].request();
                                  if (statuses[Permission.storage]!.isGranted &&
                                      statuses[Permission.camera]!.isGranted) {
                                    print("Permission granted.");
                                    // _getFromGallery();
                                  } else {
                                    print("No permission provided");
                                  }
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(
                    color: kcardBackgroundColor,
                    borderRadius: BorderRadius.circular(50)),
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
                      child: Column(children: [
                        Row(children: [
                          Icon(
                            Icons.add_task,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: screenWidth * 0.2,
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
                          Expanded(
                            child: TextFormField(
                              controller: taskController,
                              enabled: true,
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.edit,
                                  color: Colors.grey,
                                ),
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
                                hintStyle: const TextStyle(
                                    color: Colors.black54, fontSize: 14),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (String? Task) {
                                if (Task != null && Task.isEmpty) {
                                  return "Task can't be empty";
                                }
                                return null;
                              },
                            ),
                          )
                        ]),
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
                            width: screenWidth * 0.2,
                            child: const Text(
                              "Task Description",
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
                              controller: taskdesController,
                              enabled: true,
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.edit,
                                  color: Colors.grey,
                                ),
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
                                hintStyle: const TextStyle(
                                    color: Colors.black54, fontSize: 14),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (String? Username) {
                                if (Username != null && Username.isEmpty) {
                                  return "Task Description can't be empty";
                                }
                                return null;
                              },
                            ),
                          )
                        ]),
                        SizedBox(
                          height: 30,
                        ),
                        Row(children: [
                          Icon(
                            Icons.low_priority_outlined,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: screenWidth * 0.2,
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
                          Expanded(
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
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                hintText: priority.text,
                                hintStyle: const TextStyle(color: Colors.black),
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
                              validator: (String? Priority) {
                                if (Priority != null && Priority.isEmpty) {
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
                                int priorityValue = getPriorityValue(value!);

                                // Now you can use priorityValue when calling your API
                                // Example: apiFunction(priorityValue);

                                print(
                                    "priority Level: $_selectedPriority, priorityValue: $priorityValue");
                              },
                              onSaved: (value) {
                                _selectedPriority = value.toString();
                              },
                            ),
                          )
                        ]),
                        SizedBox(
                          height: 30,
                        ),
                        Row(children: [
                          Icon(
                            Icons.person,
                            color: kiconColor,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: screenWidth * 0.2,
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
                          Expanded(
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
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 30, 15, 0),
                                hintText: widget.receiverUserName,
                                hintStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (String? Assignee) {
                                if (Assignee != null && Assignee.isEmpty) {
                                  return "Assignee can't be empty";
                                } else {
                                  return null;
                                }
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              value: _selectedAssignee,
                              items: _usernameToIdMap.keys
                                  .map<DropdownMenuItem<String>>(
                                (String displayName) {
                                  return DropdownMenuItem<String>(
                                    value: displayName,
                                    child: Text(
                                      displayName,
                                    ),
                                  );
                                },
                              ).toList(),
                              onChanged: (value) {
                                print('Selected Display Name: $value');
                                setState(() {
                                  _selectedAssignee = value;
                                  _selectedAssigneeId = _usernameToIdMap[value];
                                  print(
                                      'Selected UserID: $_selectedAssigneeId');
                                });
                              },
                            ),
                          )
                        ]),
                        SizedBox(
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
                            width: screenWidth * 0.2,
                            child: const Text(
                              "Date ",
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
                              controller: dateController,
                              keyboardType: TextInputType.none,
                              onTap: () {
                                setState(() {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  _selectDate(context);
                                });
                              },
                              showCursor: false,
                              enableInteractiveSelection: false,
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
                                hintText: "Ex: 2000-01-01",
                                hintStyle: const TextStyle(
                                    color: Colors.black54, fontSize: 14),
                              ),
                              style: const TextStyle(color: Colors.black),
                              validator: (String? DOB) {
                                if (DOB != null && DOB.isEmpty) {
                                  return "Date can't be empty";
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (String? text) {
                                selectedDate = text!;
                              },
                            ),
                          )
                        ]),
                        SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: GestureDetector(
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                await updateTask(selectedImage);
                                _formKey.currentState!.save();
                              }
                            },
                            child: Buttons_in_form(
                              icon: const Icon(
                                Icons.update_outlined,
                                color: Colors.white,
                              ),
                              text: isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.only(left: 20.0),
                                      child: SpinKitDualRing(
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    )
                                  : Text("Update Task",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.white)),
                            ),
                          ),
                        ),
                      ]),
                    )),
              )),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Update Successful'),
        content: Text('Task updated successfully.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ViewTaskScreen()));
            },
          ),
        ],
      );
    },
  );
}

String convertPriorityToString(int? priorityValue) {
  if (priorityValue == null) {
    return "Unknown";
  }

  String priorityString = "";

  switch (priorityValue) {
    case 1:
      priorityString = "High";
      break;
    case 2:
      priorityString = "Medium";
      break;
    case 3:
      priorityString = "Low";
      break;
    default:
      priorityString = "Unknown";
  }
  print("priorty String Value: $priorityString");
  return priorityString;
}
