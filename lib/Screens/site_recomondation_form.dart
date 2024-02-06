import 'dart:io';
import 'package:clean_connector/Constant/const_api.dart';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/Site_recommandation.dart';
import 'package:clean_connector/Screens/login_screen.dart';
import 'package:clean_connector/components/text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dioo;
import 'package:http_parser/http_parser.dart';

class SiteRecomondationForm extends StatefulWidget {
  @override
  _SiteRecomondationFormState createState() => _SiteRecomondationFormState();
}

class _SiteRecomondationFormState extends State<SiteRecomondationForm> {
  ScrollController _scrollController = ScrollController();

  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController _documentName = new TextEditingController();
  bool isLoading = false;
  FilePickerResult? _file;
  bool isValidator = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  String _getMimeType(String filePath) {
    // Determine MIME type based on file extension
    File file = File(filePath);
    if (file.existsSync()) {
      if (filePath.toLowerCase().endsWith('.pdf')) {
        return 'application/pdf';
      } else if (filePath.toLowerCase().endsWith('.jpg') ||
          filePath.toLowerCase().endsWith('.jpeg')) {
        return 'image/jpeg';
      } else if (filePath.toLowerCase().endsWith('.png')) {
        return 'image/png';
      } else if (filePath.toLowerCase().endsWith('.mp4')) {
        return 'video/mp4';
      } else if (filePath.toLowerCase().endsWith('.docx')) {
        return 'doc/docx';
      }
      // Add more MIME types for other file formats as needed
    }
    return '';
  }

  Future CreateRecommendation() async {
    setState(() {
      isLoading = true;
    });
    String path = '';
    String name = '';

    if (_file != null) {
      String? pdfPath;
      String? pdfName;
      for (PlatformFile pdf in _file!.files) {
        pdfPath = pdf.path;
        pdfName = pdf.name;
        setState(() {
          path = pdfPath!;
          name = pdfName!;
        });
      }

      print("File Upload name $pdfName");
      print("File Upload path $pdfPath");

      print(_file?.files.single.bytes);
    }
    String mimeType = _getMimeType(path);

    String? siteId;

    dioo.FormData data = dioo.FormData.fromMap({
      'site_id': loginUserData['id'],
      'title': titleController.text,
      'description': descriptionController.text,
      'file': _file != null
          ? await MultipartFile.fromFile(
              path,
              filename: name,
              contentType: MediaType.parse(mimeType),
            )
          : null,
      // await dioo.MultipartFile.fromFile(pdfPath!,
      //     filename: pdfName, contentType: MediaType.parse('application/pdf')),
    });

    try {
      var response = await Dio().post(BASE_API2 + 'recommendation/create',
          data: data,
          options: Options(headers: {
            "Authorization": "Bearer " + loginUserData['accessToken']
          }));
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      print("Response*** => ${response.data["status"]}");

      setState(() {
        isLoading = false;
      });

      if (response.data["status"] == true &&
          response.data["message"] ==
              "SiteRecommendation Created successfully") {
        print("SiteRecommendation Created successfully");
        showSuccessDialog(context);
        _file = null;
      } else if (response.data["status"] == false) {}
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

  void showSubmitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('Registration successful'),
          content: Text('Do you want to submit?'),
          actions: <Widget>[
            TextButton(
              child: Text('YES'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                CreateRecommendation();
              },
            ),
            TextButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Recommendation submitted successfully'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SiteRecomondationScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              "CREATE YOUR RECOMMENDATION",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20, color: kiconColor),
            ),
            backgroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(2, 2),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Column(children: [
                              Row(children: [
                                const Icon(
                                  Icons.text_fields_outlined,
                                  color: kiconColor,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: const Text(
                                    "Title ",
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
                                  controller: titleController,
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
                                    hintText: "Title",
                                    hintStyle: const TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  ),
                                  style: const TextStyle(color: Colors.black),
                                  validator: (String? u_name) {
                                    if (u_name != null && u_name.isEmpty) {
                                      return "Title can't be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Row(children: [
                                const Icon(
                                  Icons.description,
                                  color: kiconColor,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Container(
                                  child: const Text(
                                    "Description ",
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
                                  controller: descriptionController,
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
                                    hintText: "Description",
                                    hintStyle: const TextStyle(
                                        color: Colors.black54, fontSize: 14),
                                  ),
                                  maxLines: 10,
                                  style: const TextStyle(color: Colors.black),
                                  validator: (String? u_name) {
                                    if (u_name != null && u_name.isEmpty) {
                                      return "Description can't be empty";
                                    } else {
                                      return null;
                                    }
                                  },
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
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
                                    "Attachment",
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
                                        borderRadius:
                                            BorderRadius.circular(11)),
                                    // width: width,
                                    child: TextFormField(
                                      controller: _documentName,
                                      enabled: true,
                                      keyboardType: TextInputType.none,
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
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                              color: Colors.red),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          borderSide: const BorderSide(
                                              color: Colors.red),
                                        ),
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                15, 30, 15, 0),
                                        hintStyle: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14),
                                      ),
                                      style:
                                          const TextStyle(color: Colors.black),
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (String? file_name) {
                                        if (_file == null ||
                                            _file!.files.single.name
                                                .contains(".png") ||
                                            _file!.files.single.name
                                                .contains(".pdf") ||
                                            _file!.files.single.name
                                                .contains(".jpg") ||
                                            _file!.files.single.name
                                                .contains(".jpeg")) {
                                          setState(() {
                                            isValidator = false;
                                          });
                                          return null;
                                        } else {
                                          setState(() {
                                            isValidator = true;
                                          });
                                          return "Please add .jpeg, .jpg, .png or .pdf";
                                        }
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    left: 10,
                                    right: 10,
                                    top: 5,
                                    bottom: isValidator == true ? 25 : 5,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        // primary: Colors.blue,
                                        backgroundColor: Colors.grey[
                                            600], // Set your desired background color here
                                      ),
                                      onPressed: _openFileExplorer,
                                      child: Text(_file == null
                                          ? 'Choose File'
                                          : 'Selected File: ${_file?.files.single.name}'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    showSubmitDialog(context);
                                  }
                                  // else if(_file == null){
                                  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  //     content: Text("You should attach a document"),
                                  //     backgroundColor: Colors.black,
                                  //     behavior: SnackBarBehavior.floating,
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(15),
                                  //     ),
                                  //     margin: EdgeInsets.only(
                                  //         bottom: MediaQuery.of(context)
                                  //             .size
                                  //             .height -150,
                                  //         right: 5,
                                  //         left: 5),
                                  //   ));
                                  //
                                  // }
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
                                      : Text("Submit",
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
