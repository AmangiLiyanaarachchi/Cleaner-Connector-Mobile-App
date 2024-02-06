import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/site_list.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery_saver/files.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Constant/const_api.dart';
import '../Controller/authController.dart';
import '../components/bottom_bar.dart';
import '../components/text_button.dart';
import 'create_user.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dioo;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

File? selectedImage;
FilePickerResult? _file;
File? selectedFile;

class Sites {
  String site_id, site_name, site_address;

  Sites({
      required this.site_id,
      required this.site_name,
      required this.site_address,
      });
}

class UserEdit extends StatefulWidget {
  UserEdit({
    required this.userid,
    required this.fname,
    required this.ename,
    required this.emailAdd,
    required this.start_day,
    required this.end_day,
    required this.mobile,
    required this.suburbs,
    required this.siteId,
    required this.image,
    required this.type,
    required this.empNo,
    required this.document
  });
  String? userid;
  String? fname;
  String? ename;
  String? emailAdd;
  String? start_day;
  String? end_day;
  String? mobile;
  String? suburbs;
  String? siteId;
  String? image;
  String? type;
  String? empNo;
  String? document;
  @override
  State<UserEdit> createState() => _UserEditState();
}
class _UserEditState extends State<UserEdit> {
  bool isLoading = false;
  String profilePic = '';
  String name = '';
  String email = '';
  String dob = '';
  String mobile = '';
  String suburbs = '';
  DateTime _date = DateTime.now();
  String selectedDate = '';
  DateTime _startDate= DateTime.now();

  List<Sites> siteList = [];
  String? selectedSite;
  bool isEmptyList = false;
  

  TextEditingController fNameController = new TextEditingController();
  TextEditingController lNameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController s_DateController = new TextEditingController();
  TextEditingController e_DateController = new TextEditingController();
  TextEditingController mobileController = new TextEditingController();
  TextEditingController _documentName = TextEditingController();
  TextEditingController suburbController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedImage = null;
    getSites();
    print("User Data sending 1 $selectedImage");
    _loadImage(widget.image);
    // _loadDoc(widget.document);
    print("User Data sending 2 $selectedImage");
    print("User Data sending ${widget.siteId}");
    print("User Data sending ${widget.document}");
    print("User Data sending ${widget.image}");
    print("User Data sending suburbs ${widget.suburbs}");
    setState(() {
      isLoading = false;
      selectedSite = widget.suburbs;
      fNameController.text = widget.fname.toString();
      lNameController.text = widget.ename.toString();
      emailController.text = widget.emailAdd.toString();
      s_DateController.text = widget.start_day.toString();
      e_DateController.text = widget.end_day.toString();
      mobileController.text = "0" + widget.mobile.toString();
      suburbController.text = widget.suburbs.toString();
      // _file = widget.document;
    });
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

  Future<void> _loadImage(String? imagepath) async {
    print("User Data sending path*** loadImage $imagepath");
    final response = await http.get(Uri.parse(imagepath!));

    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${widget.ename}.jpg');
      print("Image path *** $file");
      await file.writeAsBytes(bytes);
      setState(() {
        selectedImage = file;
      });
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<void> _loadDoc(String? docPath) async {
    print("File Upload _loaddoc");
    final response = await http.get(Uri.parse(docPath!));
    String pdfName = extractPdfNameFromUrl(docPath);
    print("File Upload File name *** $pdfName");

    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/document.pdf');
      print("File Upload File path *** $file");
      await file.writeAsBytes(bytes);
      setState(() {
        selectedFile = file;
      });
    } else {
      throw Exception('Failed to load image');
    }
  }

  String extractPdfNameFromUrl(String url) {
  // Split the URL using '%2F' (URL-encoded '/') to get the file path
    List<String> urlParts = url.split('%2F');

    // The last part of the URL should contain the file name
    String lastPart = urlParts.last;

    // Decode the URL-encoded string to get the actual file name
    String decodedFileName = Uri.decodeComponent(lastPart);

    // Extract the file name from the decoded string
    String pdfName = decodedFileName.split('/').last;

    return pdfName;
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
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Successful'),
          content: Text('Cleaner updated successfully.'),
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


  Future UpdateUser(File _image) async {

    print("Site List $siteList");

    String? siteId;

    for (Sites site in siteList) {
      if(site.site_name == selectedSite){
        setState(() {
          siteId = site.site_id;
          print("Getting site.... Selected Site ID: $selectedSite");
        });
      }
    }

    setState(() {
      isLoading = true;
    });
    print("User Data sending...............  ${(widget.siteId == '')}");
    print("File Upload **** ${(_file == null)}");
    print("File Upload **** ${widget.document}");
    String imageName = _image.path.split('/').last;
    String? pdfPath;
    String? pdfName;


    if(_file != null) {
      for (PlatformFile pdf in _file!.files) {
        pdfPath = pdf.path;
        pdfName = pdf.name;
      }

      print("File Upload name $pdfName");
      print("File Upload path $pdfPath");
    } else {
      _loadDoc(widget.document);
      // pdfPath = selectedFile;
      
    }

    // String siteId = (widget.siteId == '') ? '2e27181a-cfac-4e75-9513-5845f21d64d4' : (widget.siteId.toString());

    dioo.FormData data = dioo.FormData.fromMap({
      'fname': fNameController.text,
      'lname': lNameController.text,
      'phone': mobileController.text,
      'email': emailController.text,    
      "image": await dioo.MultipartFile.fromFile(_image.path, filename: imageName, contentType: MediaType.parse('image/jpg')),     
      'start_date': s_DateController.text,
      'end_date': e_DateController.text,
      'documents' : (_file == null) ? widget.document : await dioo.MultipartFile.fromFile(pdfPath!, filename: pdfName, contentType: MediaType.parse('application/pdf')),
      'emp_no' : widget.empNo,
      'role': 'cleaner',
      'site_id': siteId,
      'password': null,
      'allocation_id': null,
    });
    try {
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      var response = await Dio().post(BASE_API2 + 'user/editCleanerUser/${widget.userid}',
          data: data,
          options: Options(headers: {
            "Authorization": "Bearer " + loginUserData["accessToken"]
          }));
      
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print("Response*** => ${response.data["status"]}");
      
      setState(() {
        isLoading = false;
      });
      if (response.data["status"] == true && response.data["message"] == "Cleaner updated successfully!") {
        print("Update User Successfully");
        showSuccessDialog(context);
        selectedImage = null;
        selectedFile = null;
        _file = null;

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
            primary: Colors.grey, // Change button color
            // surface: Colors.blueGrey[50], // Change selected item color
          ),
        ), // // Set the theme to dark
        child: child!,
      );
    },
      
      
    );
    if (_datePicker != null && _datePicker != _date) {
      if (isStart == true){
        String formattedDate = DateFormat("yyyy-MM-dd").format(_datePicker);
        setState(() {
          s_DateController.text = formattedDate.toString();
          _date = _datePicker;
          _startDate = _datePicker;
          print(
              _date.toString()
          );
        });
      }else{
        String formattedDate = DateFormat("yyyy-MM-dd").format(_datePicker);
        setState(() {
          e_DateController.text = formattedDate.toString();
          _date = _datePicker;
          print(
              _date.toString()
          );
        });
      }
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
          title: Text("EDIT CLEANER INFORMATION", style: kboldTitle,),
          backgroundColor: Colors.white,
          // actions: <Widget>[
          //   logoutButton(),
          // ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
          child: Column(
            children: [
              Container(
                height: screenHeight*0.25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProfilePic(),
                    // CircleAvatar(
                    //   radius: screenWidth/8.5,
                    //   backgroundColor: kcardBackgroundColor,
                    //   child: (widget.image!= null)?
                    //   CircleAvatar(
                    //     radius: screenWidth/9,
                    //     backgroundColor: Colors.white,
                    //     backgroundImage: NetworkImage(widget.image.toString()),
                    //   )
                    //       :  CircleAvatar(
                    //     radius: screenWidth/9,
                    //     backgroundColor: Colors.white,
                    //     child: Icon(Icons.person, color: kiconColor,),
                    //   ) ,
                    // ),
                    const SizedBox(height: 15,),
                    Text(
                      widget.fname.toString() +" "+ widget.ename.toString(),
                      style: kTitle,
                    ),
                    const SizedBox(height: 5,),
                    Text(
                      widget.emailAdd.toString(),
                      style: kSubTitle
                    ),
                    const SizedBox(height: 10,),
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
                                      Expanded(
                                        child: TextFormField(
                                          controller: fNameController,
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
                                              return "First Name can't be empty";
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
                                SizedBox(height: 30,),
                                Row(
                                    children: [
                                      Icon(Icons.person, color: kiconColor,),
                                      SizedBox(width: 20,),
                                      Container(
                                        width: screenWidth*0.2,
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
                                      Expanded(
                                        child: TextFormField(
                                          controller: lNameController,
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
                                              return "Last Name can't be empty";
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
                                
                                SizedBox(height: 30,),

                                Row(
                                    children: [
                                      Icon(Icons.person, color: kiconColor,),
                                      SizedBox(width: 20,),
                                      Container(
                                        width: screenWidth*0.2,
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
                                      Expanded(
                                        child: TextFormField(
                                          controller: emailController,
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
                                              return "Email can't be empty";
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
                                
                                SizedBox(height: 30,),
                                
                                Row(
                                    children: [
                                      Icon(Icons.phone, color: kiconColor,),
                                      SizedBox(width: 20,),
                                      Container(
                                        width: screenWidth*0.2,
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
                                      Expanded(
                                        child: 
                                        TextFormField(
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
                                            } 
                                            // else if (mobileNumber!.length != 10)
                                            //   return 'Mobile Number must be 10 digit';

                                            return null;
                                          },
                                          onChanged: (String? text) {
                                            email = text!;
                                            // print(email);
                                          },
                                        ),
                                        // IntlPhoneField(
                                        //   initialCountryCode: 'AU',
                                        //   autovalidateMode: AutovalidateMode.onUserInteraction,
                                        //   decoration: InputDecoration(
                                        //     filled: true,
                                        //     fillColor: const Color.fromRGBO(248, 248, 248, 1),
                                        //     border: OutlineInputBorder(
                                        //       borderRadius: BorderRadius.circular(6),
                                        //       borderSide: BorderSide.none,
                                        //     ),
                                        //     focusedBorder: const OutlineInputBorder(
                                        //       borderSide: BorderSide(width: 1, color: Colors.blue, ),
                                        //     ),
                                        //     errorBorder: const OutlineInputBorder(
                                        //       borderSide: BorderSide(width: 1, color: Colors.red,),
                                        //     ),
                                        //     errorMaxLines: 2,
                                        //     errorStyle: const TextStyle(fontSize: 8),
                                        //     contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 5,),
                                        //   ),
                                        //   onChanged: (value) {
                                        //     setState(() {
                                        //       mobileController.text = value.completeNumber;
                                        //     });
                                        //   },
                                        //   validator : (value) {
                                        //     print("Empty number $value");
                                        //     if (value!.completeNumber.isEmpty) {
                                        //       print("Empty number");
                                        //       return "Mobile Number can't be empty";
                                        //     }
                                        //     return null; 
                                        //   },
                                        // ),
                                      )
                                    ]
                                ),
                                
                               
                                SizedBox(height: 30,),





                                Row(
                                    children: [
                                      Icon(Icons.calendar_month, color: kiconColor,),
                                      SizedBox(width: 20,),
                                      Container(
                                        width: screenWidth*0.2,
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
                                      Expanded(
                                        child: TextFormField(
                                          controller: s_DateController,
                                          keyboardType: TextInputType.none,
                                          onTap: () {
                                            setState(() {
                                              FocusManager.instance.primaryFocus?.unfocus();
                                              _selectDate(context, true);
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
                                              return "Start date can't be empty";
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
                                      Icon(Icons.calendar_month, color: kiconColor,),
                                      SizedBox(width: 20,),
                                      Container(
                                        width: screenWidth*0.2,
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
                                      Expanded(
                                        child: TextFormField(
                                          controller: e_DateController,
                                          keyboardType: TextInputType.none,
                                          onTap: () {
                                            setState(() {
                                              FocusManager.instance.primaryFocus?.unfocus();
                                              _selectDate(context, false);
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
                                              return "End date can't be empty";
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
                                


                                Container(
                                  // width: screenWidth * 0.36,
                                  child: DropdownButtonFormField<String>(
                                      value: selectedSite,
                                    
                                      items: siteList.map((site) {
                                        return DropdownMenuItem<String>(
                                          value: site.site_name,
                                          child: Text(site.site_name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        try {
                                          setState(() {
                                              // selectedSite = value!;
                                              // print("Getting site.... Selected Site ID: $selectedSite");
                                              if (siteList.any((site) => site.site_name == value)) {
                                                selectedSite = value!;
                                                print("Getting site.... Selected Site ID: $selectedSite");
                                              } else {
                                                throw Exception("Selected value not found in siteList");
                                              }
                                            }); 
                                          
                                        } catch (e) {
                                          print("Drop down error $e");
                                          
                                        }
                                                                               
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
                                        hintText: selectedSite,
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

                                SizedBox(height: 30,),

                                Row(
                                  children: [
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
                                  ]
                                ),
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
                                        //   if (suburb != null && suburb.isEmpty) {
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
                                
                                SizedBox(height: 50,),
                                Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: GestureDetector(
                                    onTap: () async{
                                      if (_formKey.currentState!.validate()) {
                                      // if (_formKey.currentState!.validate() && image != null && _file != null ) {
                                        
                                        DateTime startDate = DateTime.parse(s_DateController.text);
                                          DateTime endDate = DateTime.parse(e_DateController.text);

                                          if (startDate.isBefore(endDate)) {
                                            print("::::::::::::::::::::::::::::::::::::::::");
                                            await UpdateUser(selectedImage!);
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

                                      }

                                
                                      // else if (image == null || _file == null ) {

                                      //   String message;

                                      //   if(image == null && _file != null){
                                      //     message = "Profile Picture can't be empty";
                                      //   }
                                      //   else if(image != null && _file == null){
                                      //     message = "Document can't be empty";
                                      //   } else {
                                      //     message = "Profile Picture and document can't be empty";
                                      //   }

                                      //   print(message);
                                      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      //     content: Text(message),
                                      //     backgroundColor: Colors.black,
                                      //     behavior: SnackBarBehavior.floating,
                                      //     shape: RoundedRectangleBorder(
                                      //       borderRadius: BorderRadius.circular(15),
                                      //     ),
                                      //     margin: EdgeInsets.only(
                                      //         bottom: MediaQuery.of(context)
                                      //                 .size
                                      //                 .height -150,
                                      //         right: 5,
                                      //         left: 5),
                                      //   ));
                                      // }
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
                                          : Text("Update Cleaner",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.white)),),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))
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

class ProfilePic extends StatefulWidget {
  const ProfilePic({Key? key}) : super(key: key);
  
  @override
  _ProfilePicState createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  // XFile? _pickedFile;
  // CroppedFile? _croppedFile;

  @override
  void initState() {
    print("User Data sending ProfilePic $selectedImage");
    bool a=  selectedImage != null;

    print("User Data sending 1* $a");
    super.initState();    
  }

  
 
  _getFromGallery() async {

    print("User Data sending _getFromGallery");
    
    File _image;
    final picker = ImagePicker();

    var _pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxHeight: 500,
      maxWidth: 500
    );
    
    print(_pickedFile!.path);
    print("User Data sending Image path* 2 $selectedImage");
    
    _image = File(_pickedFile!.path);
    
    selectedImage = _image;

    print("User Data sending Image path* 3 $selectedImage");

    bool b =  selectedImage != null;
    print("User Data sending Image path** $b");

  }

  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    bool a=  selectedImage != null;
    print("User Data sending ///* $selectedImage");
    print("User Data sending* $a");

    return Padding(
      padding: const EdgeInsets.only(left: 0.0),
      child: Column(
        children: [
          const SizedBox(height: 5),
          selectedImage != null 
              ? 
              Stack(children: [
                // selectedImage != null ?
                  CircleAvatar(
                    radius: screenWidth * 0.13,
                    backgroundColor: kcardBackgroundColor,
                    // backgroundImage: NetworkImage(image.toString()),
                    child: ClipOval(
                      child: Image.file(
                        selectedImage!,
                        width: screenWidth * 0.12 * 2,
                        height: screenWidth * 0.12 * 2,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  // :
                  // CircleAvatar(
                  //   radius: screenWidth * 0.13,
                  //   backgroundColor: kcardBackgroundColor,
                  //   // backgroundImage: NetworkImage(image.toString()),
                  //   // child: ClipOval(
                  //   //   child: Image.file(
                  //   //     selectedImage!,
                  //   //     width: screenWidth * 0.12 * 2,
                  //   //     height: screenWidth * 0.12 * 2,
                  //   //     fit: BoxFit.cover,
                  //   //   ),
                  //   // ),
                  // )
                  ,
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
                                icon: const Icon(
                                  Icons.photo_camera_outlined,
                                  color: kiconColor,
                                )),
                          ),
                        )),
                  ),
                ])
              : 
              Stack(                 
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

