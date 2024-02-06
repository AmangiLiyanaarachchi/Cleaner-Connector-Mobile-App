import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/task_edit.dart';
import 'package:dio/dio.dart' as dioo;
import 'package:clean_connector/Screens/task_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../Constant/const_api.dart';
import '../components/bottom_bar.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

File? commentImage;

class TaskView extends StatefulWidget {
  TaskView({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.created_date,
    required this.deadline,
    required this.description,
    required this.task_tittle,
    required this.receiverUserName,
    required this.senderName,
    required this.priority,
    required this.image,
  });
  String? id;
  String? sender;
  String? receiver;
  String? created_date;
  String? deadline;
  String? description;
  String? task_tittle;
  String? receiverUserName;
  String? senderName;
  String? image;
  int? priority;
  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  TextEditingController commentEditingController = new TextEditingController();
  bool isLoading = false;
  String deadline = '';
  String comment = '';
  String getComent = 'hi. how are you';
  bool isEmptyList = false;
  File? _image;
  List<Comment> commentList = [];

  saveImage() async {
    try {
      http.Response response =
          await http.get(Uri.parse(widget.image.toString()));

      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;

        final directory = await getTemporaryDirectory();
        final File file = File('${directory.path}/temp_image.png');
        await file.writeAsBytes(bytes);

        await GallerySaver.saveImage(file.path);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Downloaded and Saved Successfully."),
          ),
        );
      } else {
        throw Exception(
            "Failed to download image. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to save image."),
        ),
      );

      print(e.toString());
    }
  }

  AddComment(File? _image) async {
    print("Add Comment.........................");
    setState(() {
      isLoading = true;
    });

    try {
      print("Form Data...........................");
      FormData formData = FormData.fromMap({
        "task_id": widget.id,
        "user_id": widget.receiver,
        "description": commentEditingController.text,
      });

      if (_image != null) {
        String imageName = _image.path.split('/').last;
        formData.files.add(MapEntry(
          "image",
          await MultipartFile.fromFile(
            _image.path,
            filename: imageName,
            contentType: MediaType.parse('image/jpg'),
          ),
        ));
      }

      var response = await Dio().post(
        '${BASE_API2}comments/createComment',
        options: Options(headers: {
          "Authorization": "Bearer " + loginUserData["accessToken"]
        }),
        data: formData,
      );

      if (response.statusCode == 200) {
        // Comment added successfully
        if (response.data["message"] == "Comment added successfully") {
          print("Comment added successfully.....................");
          // Navigate or perform any other action as needed
        } else {
          print("Failed");
        }
      } else {
        print("Unexpected response: ${response.statusCode}");
      }
    } on DioError catch (e) {
      print("DioError: $e");
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Comment>> getComm() async {
    print("Getting tasks comments....");
    String url;
    commentList = [];
    url = "${BASE_API2}comments/${widget.id}";
    try {
      final response = await Dio().get(url,
          options: Options(headers: {
            "Authorization": "Bearer " + loginUserData["accessToken"]
          }));
      print('Got URL');
      var data = response.data['comments'];
      print("DATA: $data");
      commentList = [];
      if (response.statusCode == 200) {
        for (Map i in data) {
          Comment coms = Comment(
            id: i['comment_id'],
            receiver: i['id'] == null ? '' : i['id'],
            sender: i['comment_created_user_id'] == null
                ? ''
                : i['comment_created_user_id'],
            createdDate: i['comment_created_date'] == null
                ? ''
                : i['comment_created_date'],
            deadline: i['deadline'] == null
                ? DateTime.now().toString()
                : i['deadline'],
            taskTitle: i['comment_description'] == null
                ? ''
                : i['comment_description'],
            description: i['description'] == null ? '' : i['description'],
            // priority: i['priority'] == null ? 1 : i['priority'],
            image: i['comment_image'] == null ? '' : i['comment_image'],
            // senderUserName:
            //     i['senderUserName'] == null ? '' : i['senderUserName'],
            // receiverFirstName:
            //     i['receiverFirstName'] == null ? '' : i['receiverFirstName'],
            // receiverLastName:
            //     i['receiverLastName'] == null ? '' : i['receiverLastName'],
          );
          commentList.add(coms);
        }
        print("!!!!!!!!!!!!!!!!!!!");
        print(commentList);
      }
      if (data.isEmpty) {
        setState(() {
          isEmptyList = true;
        });
      }
      return commentList;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        print("Bad Error");
        print(e.response?.data["message"]);
        setState(() {
          isEmptyList = true;
        });
        return commentList;
      }
      print(e.toString());
      setState(() {
        isLoading = true;
      });
      print(e);
      return commentList;
    }
  }

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

    commentImage = _image;
    print("Image path 3 $commentImage");
    setState(() {});
  }

  Future deleteTask() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Dio().delete(
        BASE_API2 + "tasks/${widget.id}",
        options: Options(
          headers: {
            "Authorization": "Bearer " + loginUserData["accessToken"],
          },
        ),
      );

      if (response.statusCode == 200 &&
          response.data['message'] == "Task Deleted Successfully") {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: const Text(
                'Task Deleted Successfully',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontFamily: 'brandon-grotesque',
                  fontWeight: FontWeight.w400,
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      fontSize: 18,
                      color: kiconColor,
                      fontFamily: 'brandon-grotesque',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        print("Task Deleted Successfully");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => const ViewTaskScreen(),
          ),
          (Route route) => false,
        );
      } else {
        print("Error: ${response.data['message']}");
      }
    } on DioError catch (e) {
      print("Error: ${e.toString()}");
    } finally {
      setState(() {
        isLoading = false;
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
          title: const Text(
            "VIEW TASK INFORMATION",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // widget.receiver == ''
                // ?
                Center(
                    child: Column(
                  children: [
                    Text(
                      widget.task_tittle ?? 'Task Title Not Available',
                      style: kTitle,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(widget.description ?? 'Task Description Not Available',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: kiconColor)),
                    SizedBox(
                      height: 15,
                    ),
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
                              if (loginUserData['userType'] == "admin")
                                IconButton(
                                  onPressed: () {
                                    saveImage();
                                  },
                                  icon: Icon(
                                    Icons.download,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                )),
                Container(
                  decoration: BoxDecoration(
                      color: kcardBackgroundColor,
                      borderRadius: BorderRadius.circular(50)),
                  width: screenWidth,
                  height: 3,
                ),
                Container(
                    child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Column(children: [
                            Row(children: [
                              Icon(
                                Icons.person,
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
                              Expanded(
                                child: Text(
                                  widget.receiverUserName.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black26,
                                      fontFamily: "OpenSans"),
                                  maxLines: 3,
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
                                child: const Text(
                                  "Assigned by ",
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
                                child: Text(
                                  widget.senderName.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black26,
                                      fontFamily: "OpenSans"),
                                  maxLines: 3,
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
                                child: const Text(
                                  "Priority",
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
                                child: Text(
                                  mapPriorityToString(widget.priority),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black26,
                                      fontFamily: "OpenSans"),
                                  maxLines: 3,
                                ),
                              )
                            ]),
                            SizedBox(
                              height: 30,
                            ),
                            Row(children: [
                              Icon(
                                Icons.timer,
                                color: kiconColor,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Container(
                                child: const Text(
                                  "Date & Time ",
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
                                child: Text(
                                  DateFormat('yyyy-MM-dd').format(
                                      DateTime.parse(widget.deadline ?? "")),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black26,
                                    fontFamily: "OpenSans",
                                  ),
                                  maxLines: 3,
                                ),
                              )
                            ]),
                            SizedBox(
                              height: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.comment,
                                      color: kiconColor,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Container(
                                      child: const Text(
                                        "Comment ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: kiconColor,
                                          fontFamily: "OpenSans",
                                        ),
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
                                          fontFamily: "OpenSans",
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.zero,
                                      border: Border.all(
                                          width: 1.5, color: Colors.black)),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: FutureBuilder(
                                              future: getComm(),
                                              builder: (context,
                                                  AsyncSnapshot<List<Comment>>
                                                      snapshot) {
                                                return Scrollbar(
                                                  thumbVisibility: true,
                                                  child: ListView.builder(
                                                      itemCount:
                                                          commentList.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return commentList
                                                                .isNotEmpty
                                                            ? Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            snapshot.data![index].taskTitle.isNotEmpty
                                                                                ? TextButton(
                                                                                    onPressed: () {},
                                                                                    child: Container(
                                                                                      //color: Colors.grey[200],
                                                                                      child: Text(
                                                                                        insertLineBreaks(snapshot.data![index].taskTitle, 35),
                                                                                        maxLines: null,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : SizedBox(),
                                                                            GestureDetector(
                                                                                onTap: () {
                                                                                  showImageDialog(context, snapshot.data![index].taskTitle, snapshot.data![index].image);
                                                                                },
                                                                                child: Icon(Icons.image)),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : isEmptyList ==
                                                                    true
                                                                ? Text(
                                                                    "There are no any comments.",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  )
                                                                : Text(
                                                                    "There are no any comments.",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  );
                                                      }),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      loginUserData['userType'] == "cleaner",
                                  child: Column(
                                    children: [
                                      // Container(
                                      //   height: 100,
                                      //   width: screenWidth,
                                      //   decoration: BoxDecoration(
                                      //     color: kcardBackgroundColor,
                                      //     borderRadius: BorderRadius.only(
                                      //       topRight: Radius.circular(5),
                                      //       topLeft: Radius.circular(5),
                                      //     ),
                                      //   ),
                                      //   child: Padding(
                                      //     padding:
                                      //         const EdgeInsets.all(25.0),
                                      //     child: Text(comment),
                                      //   ),
                                      // ),
                                      // Add some spacing between the Row and the TextFormField
                                      SizedBox(
                                        height: 10,
                                      ), // Adjust the height as needed

                                      TextFormField(
                                        controller: commentEditingController,
                                        enabled: true,
                                        decoration: InputDecoration(
                                          prefixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  await _getFromGallery();
                                                },
                                                // onPressed:
                                                //     _getFromGallery(), // Call the function when the button is pressed
                                                icon: Icon(Icons.attach_file),
                                              ),
                                            ],
                                          ),
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    comment =
                                                        commentEditingController
                                                            .text;
                                                  });
                                                  await AddComment(commentImage)
                                                      .then((value) {});
                                                  commentEditingController
                                                      .clear();
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                },
                                                icon: Icon(Icons.send),
                                              ),
                                            ],
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            borderSide: const BorderSide(
                                              color: kiconColor,
                                            ),
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
                                          hintText:
                                              "Comment", // Clear the default hintText
                                        ),
                                        style: const TextStyle(
                                            color: Colors.black),
                                        validator: (String? comment) {
                                          if (comment != null &&
                                              comment.isEmpty) {
                                            return "Comment can't be empty";
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ])),
                      (loginUserData['userType'] == "admin" ||
                              loginUserData['userType'] == "client")
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kiconColor,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => TaskEdit(
                                                      id: widget.id.toString(),
                                                      sender: widget.sender
                                                          .toString(),
                                                      receiver: widget.receiver
                                                          .toString(),
                                                      created_date: widget
                                                          .created_date
                                                          .toString(),
                                                      deadline: widget.deadline
                                                          .toString(),
                                                      description: widget
                                                          .description
                                                          .toString(),
                                                      task_tittle: widget
                                                          .task_tittle
                                                          .toString(),
                                                      receiverUserName: widget
                                                          .receiverUserName
                                                          .toString(),
                                                      priority: widget.priority
                                                          as int,
                                                      image: widget.image
                                                          .toString(),
                                                    )));
                                      },
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kiconColor,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    'Are you sure you want to delete this task?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text(
                                                      'OK',
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      await deleteTask();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : (loginUserData['userType'] == "admin" ||
                                  loginUserData['userType'] == "client")
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: kiconColor,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TaskEdit(
                                                          id: widget.id
                                                              .toString(),
                                                          sender: widget.sender
                                                              .toString(),
                                                          receiver: widget
                                                              .receiver
                                                              .toString(),
                                                          created_date: widget
                                                              .created_date
                                                              .toString(),
                                                          deadline: widget
                                                              .deadline
                                                              .toString(),
                                                          description: widget
                                                              .description
                                                              .toString(),
                                                          task_tittle: widget
                                                              .task_tittle
                                                              .toString(),
                                                          receiverUserName: widget
                                                              .receiverUserName
                                                              .toString(),
                                                          priority: widget
                                                              .priority as int,
                                                          image: widget.image
                                                              .toString(),
                                                        )));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(
                                  height: 10,
                                )
                    ],
                  ),
                )),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom))
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }

  void showImageDialog(BuildContext context, String text, String imageURL) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          content: Container(
            height: 200,
            width: 200,
            color: Colors.white,
            child: Image(
              image: NetworkImage(imageURL),
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

String insertLineBreaks(String text, int maxCharacters) {
  StringBuffer buffer = StringBuffer();
  int count = 0;

  for (int i = 0; i < text.length; i++) {
    buffer.write(text[i]);
    count++;

    if (count == maxCharacters) {
      buffer.write('\n');
      count = 0;
    }
  }

  return buffer.toString();
}

String mapPriorityToString(int? priority) {
  if (priority == null) {
    return 'Unknown Priority';
  }

  switch (priority) {
    case 1:
      return 'High';
    case 2:
      return 'Medium';
    case 3:
      return 'Low';
    default:
      return 'Unknown Priority';
  }
}

class Comment {
  String sender,
      receiver,
      id,
      createdDate,
      deadline,
      description,
      taskTitle,
      //     receiverFirstName,
      //     receiverLastName,
      image;
  //     senderUserName;
  // int priority;

  Comment({
    required this.sender,
    required this.receiver,
    required this.id,
    required this.createdDate,
    required this.deadline,
    required this.description,
    required this.taskTitle,
    // required this.receiverFirstName,
    // required this.receiverLastName,
    required this.image,
    // required this.senderUserName,
    // required this.priority,
  });
}
