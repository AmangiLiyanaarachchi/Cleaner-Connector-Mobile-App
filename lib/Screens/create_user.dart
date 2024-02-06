import 'dart:async';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dioo;
import 'package:file_picker/file_picker.dart';
// import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Constant/const_api.dart';
import '../components/bottom_bar.dart';
import '../components/text_button.dart';
import 'login_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';

File? image;

class Sites {
  String site_id, site_name, site_address;

  Sites({
      required this.site_id,
      required this.site_name,
      required this.site_address,
      });
}

class UserCreate extends StatefulWidget {

  @override
  State<UserCreate> createState() => _UserCreateState();
}

class _UserCreateState extends State<UserCreate> {
  bool isLoading = false;
  bool _isObscure = true;
  bool _isObscurePw = true;
  String profilePic = '';
  String name = '';
  String email = '';
  String selectedDate = '';
  DateTime _date = DateTime.now();
  DateTime _startDate= DateTime.now();
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController startDate_Controller = new TextEditingController();
  TextEditingController endDate_Controller = new TextEditingController();
  TextEditingController mobileController = new TextEditingController();
  TextEditingController suburbController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  TextEditingController _documentName = TextEditingController();
  FilePickerResult? _file;
  final _formKey = GlobalKey<FormState>();
  String? _selectedUserType;
  String? userType;
  String adminType = '';
  List<String> userTypeList = <String>["Administrative", "Normal User"];
  static final now = DateTime.now();
  bool isEmptyList = false;

  bool validationDoc = false;
  bool validationPic = false;
  bool validationMobile = false;



  FocusNode focusNode = FocusNode();
  
  List<Sites> siteList = [];
 

  String? selectedSite;

  List<String> sites = [
    'KFC',
    'BlueScope',
    'BOC',
  ];

  @override
  void initState() {
    super.initState();
    requestPermision();
    getSites();
  }

  Future<List<Sites>> getSites() async {
    print("Getting site.... 2");
    siteList = [];
    try {
      print("Getting site.... 1");
      final response = await Dio().get(
          "${BASE_API2}site/getall-Sites",
          options: Options(headers: {
            "Authorization": loginUserData['accessToken']
          }));
      // options: Options(headers: {
      //   "Authorization": loginUserData["token"]
      // }));
      var data = response.data['sites'];
      print("Getting site....: $data");
      if (response.statusCode == 200) {
        print("Getting site.... 4: ");
        siteList = [];
        for (Map i in data) {
          print("Getting site.... ");
          Sites sites = Sites(
            site_id: (i['site_id'] == null) ? " " : i['site_id'],
            site_name: (i['site_name'] == null) ? " " : i['site_name'],
            site_address: (i['site_address'] == null) ? " " : i['site_address'],
          );
          siteList.add(sites);
        }
        print("!!!!!!!!!!!!!!!!!!!");
        for (Sites site in siteList) {
          print("Getting site.... Site ID: ${site.site_id}");
          print("Getting site.... Site Name: ${site.site_name}");
          print("Getting site.... Site Address: ${site.site_address}");
          print("Getting site.... ------------------------------");
        }
        print("Getting site.... 5 $siteList");
      }
      return siteList;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 ) {
        print("Bad Error");
        print(e.response?.data["message"]);
        setState(() {
          isEmptyList = true;
        });
        
        return siteList;
      }else if((e.response?.statusCode == 401)){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Session expired. Please Login again"),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.only(
                // bottom: MediaQuery
                //     .of(context)
                //     .size
                //     .height - 100,
                right: 5,
                left: 5,
                top: 100),
          ));
      }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
      return siteList;
    }
  }

  void _openFileExplorer() async {

    String? pdfPath;
    String? pdfName;
     
    _file = (await FilePicker.platform.pickFiles())!;
    for (PlatformFile pdf in _file!.files) {
      pdfPath = pdf.path;
      pdfName = pdf.name;
    }
    // File fileT = File(_file!.path);
    print("File Upload $_file");
    print("File Upload $pdfPath");

    setState(() {
      _file = _file;      
    });
    validationDoc = false;
  }


  
  Future<void> requestPermision() async {
    var status = await Permission.storage.status;
    var statusphotos = await Permission.photos.status;
    if(statusphotos.isGranted){
      print("permission ok");
    }else {
      if (await Permission.photos
          .request()
          .isGranted) {
        print("permission ok");
      } else {
        print("permission not ok");
      }
    }
    if(status.isGranted){
      print("permission ok");
    }else{
      if(await Permission.storage.request().isGranted){
        print("permission ok");
      }else{
        print("permission not ok");
      }
    }
  }

  Future CreateUser(File _image) async {
    setState(() {
      isLoading = true;
    });
    print("User Data sending...............");
    String imageName = _image.path.split('/').last;
    String? pdfPath;
    String? pdfName;

    for (PlatformFile pdf in _file!.files) {
      pdfPath = pdf.path;
      pdfName = pdf.name;
    }
    print("File Upload name $pdfName");
    print("File Upload path $pdfPath");

    print(imageName);
    print(firstNameController.text);
    print(_date.toString());
    print(mobileController.text);
    print(emailController.text);
    print(passwordController.text);
    print(suburbController.text);
    print(_file?.files.single.bytes);

    MultipartFile fileMultipartFile = await MultipartFile.fromFile(
        pdfPath!,
        filename: pdfName,
    );
    
    String? siteId;

    for (Sites site in siteList) {
      if(site.site_name == selectedSite){
        setState(() {
          siteId = site.site_id;
          print("Getting site.... Selected Site ID: $selectedSite");
        });
      }
    }

    print(fileMultipartFile);

    dioo.FormData data = dioo.FormData.fromMap({
      'fname': firstNameController.text,
      'lname': lastNameController.text,
      'phone': mobileController.text,
      'email': emailController.text,
      'password': passwordController.text,
      "image": await dioo.MultipartFile.fromFile(_image.path,
          filename: imageName, contentType: MediaType.parse('image/jpg')),
      'role': 'cleaner',
      'site_id': siteId,
      'documents':await dioo.MultipartFile.fromFile(pdfPath,
          filename: pdfName, contentType: MediaType.parse('application/pdf')),
      // 'documents' : fileMultipartFile,
      'start_date': startDate_Controller.text,
      'end_date': endDate_Controller.text,
    });
    try {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      var response = await Dio().post(BASE_API2 + 'user/register-cleaner',
          data: data,
          options: Options(headers: {
            "Authorization": "Bearer " + loginUserData["accessToken"]
          }));
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print("Response*** => ${response.data["status"]}");
      
      setState(() {
        isLoading = false;
      });
      if (response.data["status"] == true && response.data["message"] == "User registration successful") {
        print("Create User Successfully");
        showSuccessDialog(context);

        // Timer(
        //     const Duration(milliseconds: 1500),
        //     () => Navigator.push(context,
        //         MaterialPageRoute(builder: (context) => const UserList())));
        image = null;
      } else if (response.data["status"] == false) {
        if (response.data["message"] == "User email already exist") {
        } else if (response.data["message"] == " userName  is already exists") {
          print("Email already exists.");
        } else {
          print("Adding user failed");
          return null;
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        print("Bad Error");
        print(e.response);
        var message = e.response?.data["message"];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
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
        
          
      } else if((e.response?.statusCode == 401)){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Session expired. Please Login again"),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.only(
                // bottom: MediaQuery
                //     .of(context)
                //     .size
                //     .height - 100,
                right: 5,
                left: 5,
                top: 100),
          ));
        }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  
  Future<Null> _selectDate(BuildContext context, bool isStart) async {
    DateTime? _datePicker = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: isStart ? DateTime(2000) : _startDate,
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
      return Theme(
       data: ThemeData.dark().copyWith( // Change background
          colorScheme: ColorScheme.dark().copyWith(
            primary: Colors.grey,      
          ),
        ), 
        child: child!,
      );
    },
    );
    if (_datePicker != null && _datePicker != _date) {
      String formattedDate = DateFormat("yyyy-MM-dd").format(_datePicker);
      setState(() {
        if (isStart == true) {
          _startDate = _datePicker;
          startDate_Controller.text = formattedDate.toString();
        } else {
          endDate_Controller.text = formattedDate.toString();
        }
        _date = _datePicker;
        print(_date.toString());
      });
    }
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration successful'),
          content: Text('Cleaner registered successfully'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UserList()));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        image = null;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserList()),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              "ADD CLEANER",
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
                Container(
                  height: screenHeight * 0.18,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ProfilePic(),
                    ],
                  ),
                ),
                validationPic ? Text("Profile Picture can't be empty",style: TextStyle(fontSize: 12,color: Colors.red ),) : SizedBox(height: 0,),
                Container(
                  decoration: BoxDecoration(
                      color: kcardBackgroundColor,
                      borderRadius: BorderRadius.circular(50)),
                  width: screenWidth,
                  height: 3,
                ),
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
                              child: Column(
                                children: [
                                Row(children: [
                                  const Icon(
                                    Icons.person,
                                    color: kiconColor,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    child: const Text(
                                      "First Name ",
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
                                    controller: firstNameController,
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
                                      hintText: "First Name",
                                      hintStyle: const TextStyle(
                                          color: Colors.black54, fontSize: 14),
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                    validator: (String? u_name) {
                                      if (u_name != null && u_name.isEmpty) {
                                        return "First name can't be empty";
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
                                    Icons.person,
                                    color: kiconColor,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    child: const Text(
                                      "Last Name ",
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
                                      color: const Color.fromRGBO( 241, 239, 239, 0.298),
                                      border: Border.all( width: 0, color: Colors.white),
                                      borderRadius: BorderRadius.circular(11)),
                                  // width: width,
                                  child: TextFormField(
                                    controller: lastNameController,
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
                                      hintText: "Last Name",
                                      hintStyle: const TextStyle(
                                          color: Colors.black54, fontSize: 14),
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                    validator: (String? u_name) {
                                      if (u_name != null && u_name.isEmpty) {
                                        return "Last name can't be empty";
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
                                  
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: [
                                          IntlPhoneField(
                                            initialCountryCode: 'AU',
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: const Color.fromRGBO(248, 248, 248, 1),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(6),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(width: 1, color: Colors.blue, ),
                                              ),
                                              errorBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(width: 1, color: Colors.red,),
                                              ),
                                              errorMaxLines: 2,
                                              errorStyle: const TextStyle(fontSize:12),
                                              contentPadding: const EdgeInsets.fromLTRB( 15, 30, 15, 0), ),
                                            onChanged: (value) {
                                              setState(() {
                                                mobileController.text = value.completeNumber;
                                                validationMobile = false;
                                              });
                                              
                                            },
                                            validator : (value) {
                                              print("Empty number $value");
                                              if (value!.completeNumber.isEmpty) {
                                                print("Empty number 2");
                                                return "Mobile Number can't be empty";
                                              }
                                              return null; 
                                            },
                                          ),

                                          

                                          
                                        ],
                                      ),
                                      validationMobile ? Padding(
                                        padding: const EdgeInsets.fromLTRB( 15, 15, 15, 0),
                                        child: Text("Mobile Number can't be empty",style: TextStyle(fontSize: 12,color: Colors.red )),
                                      ) : SizedBox(height: 0,),
                                    ],
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
                                    keyboardType: TextInputType.emailAddress,
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
                                              if (value!.isEmpty) {
                                                return "Password can't be empty";
                                              } else if (value.length < 8) {
                                                return 'Password must be at least 8 characters long';
                                              } else if (!value
                                                  .contains(RegExp(r'[a-z]'))) {
                                                return 'Password must be at contains least 1 letter';
                                              } else if (!value.contains(RegExp(
                                                  r'[!@#$%^&*(),.?":{}|<>]'))) {
                                                return 'Password must be contains at least 1 special character';
                                              } else if (!value
                                                  .contains(RegExp(r'[0-9]'))) {
                                                return 'Password must be contains at least 1 number';
                                              } else {
                                                return null;
                                              }
                                            },
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
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
                                            Icons.password,
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
                                            validator: (c_Pw) {
                                              if (c_Pw != null && c_Pw.isEmpty) {
                                                return "Confirm password can't be empty";
                                              } else if (passwordController
                                                      .text !=
                                                  confirmPasswordController
                                                      .text) {
                                                return "Password and Confirm Password does not match";
                                              } else {
                                                return null;
                                              }
                                            },
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
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
                                    Icons.location_history,
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
                                
                                // Container(
                                //   // padding: EdgeInsets.only(top: 20, bottom: 20),
                                //   alignment: Alignment.center,
                                //   decoration: BoxDecoration(
                                //       boxShadow: const [
                                //         BoxShadow(
                                //           color: Colors.black12,
                                //           offset: Offset(2, 2),
                                //           blurRadius: 2,
                                //         )
                                //       ],
                                //       color: const Color.fromRGBO(
                                //           241, 239, 239, 0.298),
                                //       border: Border.all(
                                //           width: 0, color: Colors.white),
                                //       borderRadius: BorderRadius.circular(11)),
                                //   // width: width,
                                //   child: TextFormField(
                                //     controller: suburbController,
                                //     inputFormatters: [
                                //       FilteringTextInputFormatter.allow(RegExp(
                                //           "[a-zA-Z]")), // only allow digits
                                //     ],
                                //     enabled: true,
                                //     keyboardType: TextInputType.name,
                                //     decoration: InputDecoration(
                                //       fillColor: Colors.white,
                                //       filled: true,
                                //       enabledBorder: OutlineInputBorder(
                                //         borderRadius: BorderRadius.circular(5.0),
                                //         borderSide: const BorderSide(
                                //           color: Colors.white,
                                //         ),
                                //         // borderSide: BorderSide.none
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
                                //       hintText: "Address",
                                //       hintStyle: const TextStyle(
                                //           color: Colors.black54, fontSize: 14),
                                //     ),
                                //     style: const TextStyle(color: Colors.black),
                                //     validator: (String? suburb) {
                                //       if (suburb != null && suburb.isEmpty) {
                                //         return "Address can't be empty";
                                //       } else {
                                //         return null;
                                //       }
                                //     },
                                //     autovalidateMode:
                                //         AutovalidateMode.onUserInteraction,
                                //     onChanged: (String? text) {
                                //       email = text!;
                                //       // print(email);
                                //     },
                                //   ),
                                // ),

                                Container(
                                  // width: screenWidth * 0.36,
                                  child: DropdownButtonFormField<String>(
                                      value: selectedSite,
                                      // items: siteList.map((Sites site) {
                                      //   return DropdownMenuItem<String>(
                                      //     value: site.site_id,
                                      //     child: Text(site.site_name),
                                      //   );
                                      // }).toList(),
                                      items: siteList.map((site) {
                                        return DropdownMenuItem<String>(
                                          value: site.site_name,
                                          child: Text(site.site_name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                              selectedSite = value!;
                                              print("Getting site.... Selected Site ID: $selectedSite");
                                            });                                        
                                      },
                                      
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor:
                                            Color.fromRGBO(248, 248, 248, 1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.red,
                                          ),
                                        ),
                                        errorMaxLines: 1,
                                        errorStyle: const TextStyle(fontSize:12),
                                        contentPadding: const EdgeInsets.fromLTRB( 15, 30, 15, 0),
                                        hintText: "Select a Client",
                                        hintStyle: const TextStyle( color: Colors.black54, fontSize: 14),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Site is required';
                                        }
                                        return null;
                                      },
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                    ),
                                  
                                ),



                                const SizedBox(
                                  height: 30,
                                ),

                                Row(children: [
                                  const Icon(
                                    Icons.file_present_rounded,
                                    color: kiconColor,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Container(
                                    child: const Text(
                                      "Upload Document",
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
                                Stack(
                                  children: [
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
                                        controller: _documentName,
                                        enabled: true,
                                        keyboardType: TextInputType.none,
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
                                          hintStyle: const TextStyle(
                                              color: Colors.black54, fontSize: 14),
                                        ),
                                        style: const TextStyle(color: Colors.black),
                                        // validator: (String? _file) {
                                        //   if (_file == null) {
                                        //     return "Document can't be empty";
                                        //   } else {
                                        //     return null;
                                        //   }
                                        // },
                                        autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                        onChanged: (String? text) {
                                          email = text!;
                                          // print(email);
                                        },
                                      ),
                                    ),
                                    
                                    Positioned(
                                      left: 10,
                                      right: 10,
                                      top: 5,
                                      bottom: 5,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          // primary: Colors.blue,
                                          backgroundColor: Colors.grey[600], // Set your desired background color here
                                        ),
                                        onPressed: _openFileExplorer,
                                        child: Text(_file == null
                                            ? 'Choose File'
                                            : 'Selected File: ${_file?.files.single.name}'),
                                      ),
                                    ),

                                    
                                  ],
                                  
                                ),
                                validationDoc ? 
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB( 15, 15, 15, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text("Document can't be empty",style: TextStyle(fontSize: 12,color: Colors.red ),),
                                      ],
                                    ),
                                  ) : SizedBox(height: 0,),
                                const SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Row(children: [
                                          const Icon(
                                            Icons.calendar_month,
                                            color: kiconColor,
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Container(
                                            child: const Text(
                                              "Start Date ",
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
                                      ),
                                      Spacer(
                                        flex: 1,
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Row(children: [
                                          const Icon(
                                            Icons.calendar_month,
                                            color: kiconColor,
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Container(
                                            child: const Text(
                                              "End Date ",
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
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 10,
                                      child: Container(
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
                                          controller: startDate_Controller,
                                          keyboardType: TextInputType.none,
                                          onTap: () {
                                            setState(() {
                                              FocusManager.instance.primaryFocus?.unfocus();
                                              _selectDate(context, true);
                                            });
                                          },
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
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
                                            errorMaxLines: 2,
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
                                            hintText: "dd-mm-yyyy",
                                            hintStyle: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14),
                                          ),
                                          style: const TextStyle(
                                              color: Colors.black),
                                          validator: (String? DOB) {
                                            if (DOB != null && DOB.isEmpty) {
                                              return "Start date can't be empty";
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
                                    ),
                                    Spacer(
                                      flex: 1,
                                    ),
                                    
                                    Expanded(
                                      flex: 10,
                                      child: Container(
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
                                          controller: endDate_Controller,
                                          keyboardType: TextInputType.none,
                                          onTap: () {
                                            setState(() {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              _selectDate(context, false);
                                            });
                                          },
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              borderSide: const BorderSide( color: Colors.white, ),
                                              // borderSide: BorderSide.none
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              borderSide: const BorderSide( color: kiconColor, ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:  BorderRadius.circular(5.0),
                                              borderSide: const BorderSide( color: Colors.red),
                                            ),
                                            errorMaxLines: 2,
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                              borderSide: const BorderSide( color: Colors.red),
                                            ),
                                            isDense: true,
                                            contentPadding: const EdgeInsets.fromLTRB( 15, 30, 15, 0),
                                            hintText: "dd-mm-yyyy",
                                            hintStyle: const TextStyle( color: Colors.black54, fontSize: 14),
                                          ),
                                          style: const TextStyle(
                                              color: Colors.black),
                                          validator: (String? endDate) {
                                            if (endDate != null && endDate.isEmpty) {
                                              return "End date can't be empty";
                                            } else {
                                              return null;
                                            }
                                          },
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          onChanged: (String? text) {
                                            selectedDate = text!;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                
                                GestureDetector(
                                  onTap: () async {
                                    if (_formKey.currentState!.validate() && image != null && _file != null && !mobileController.text.isEmpty  ) {

                                          print("Empty number ${mobileController.text.isEmpty}");
                                          DateTime startDate = DateTime.parse(startDate_Controller.text);
                                          DateTime endDate = DateTime.parse(endDate_Controller.text);

                                          if (startDate.isBefore(endDate)) {
                                            print( "::::::::::::::::::::::::::::::::::::::::");
                                            print(_file.toString());
                                            await CreateUser(image!).then((value) {});
                                            _formKey.currentState!.save();
                                          } else if (startDate.isAfter(endDate)) {
                                            // startDate is after endDate
                                            print("Invalid date range");
                                            ScaffoldMessenger.of(context) .showSnackBar(SnackBar(
                                              content: const Text("End date can not be a date before start date"),
                                              backgroundColor: Colors.black,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              margin: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context) .size .height -150,
                                                  right: 5,
                                                  left: 5),
                                            ));
                                          }
                                      
                                    } else if (image == null || _file == null || mobileController.text.isEmpty) {
                                      print("Empty number 1 ${mobileController.text.isEmpty}");

                                      String message;

                                      if (mobileController.text.isEmpty){
                                        print("Empty number");
                                        validationMobile = true;
                                      }


                                      if(image == null && _file != null){
                                        //message = "Profile Picture can't be empty";
                                        validationPic = true;
                                      }
                                      else if(image != null && _file == null){
                                       // message = "Document can't be empty";
                                        validationDoc = true;
                                      }
                                      else {
                                        //message = "Profile Picture and document can't be empty";
                                        validationPic = true;
                                        validationDoc = true;
                                      }

                                      //print(message);
                                      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      //   content: Text(message),
                                      //   backgroundColor: Colors.black,
                                      //   behavior: SnackBarBehavior.floating,
                                      //   shape: RoundedRectangleBorder(
                                      //     borderRadius: BorderRadius.circular(15),
                                      //   ),
                                      //   margin: EdgeInsets.only(
                                      //       bottom: MediaQuery.of(context)
                                      //               .size
                                      //               .height -150,
                                      //       right: 5,
                                      //       left: 5),
                                      // ));
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
                                        : Text("Add Cleaner",
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
    
    print("File Upload 2 $_pickedFile");

    _image = File(_pickedFile!.path);

    print("File Upload 3 $_image");

    image = _image;
    print("Image path 3 $image");
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
