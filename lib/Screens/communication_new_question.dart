import 'dart:async';
import 'dart:io';

import 'package:clean_connector/Constant/const_api.dart';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Controller/authController.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:clean_connector/Screens/user_profile.dart';
import 'package:clean_connector/services/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../components/bottom_bar.dart';
import 'package:path/path.dart' as path;

// ignore: must_be_immutable
class NewQuestion extends StatefulWidget {
  NewQuestion(
      {required this.title,
      this.siteId = '',
      this.siteAddress = '',
      this.siteName = ''});
  String title;
  String siteId;
  String siteName;
  String siteAddress;

  @override
  State<NewQuestion> createState() => _NewQuestionState();
}

class _NewQuestionState extends State<NewQuestion> {
  bool isLoading = false;
  String profilePic = '';
  String name = '';
  String email = '';
  String imageUrl = '';

  final TextEditingController _textController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final ChatServices chatServices = ChatServices();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String chatRoomId = "";
  List<Users> userList = [];
  List<String> _userTypeList = [];
  bool _isLoading = true;
  bool isSuperAdmin = false;
  Map<String, String> _usernameToIdMap = {};
  String? _selectedCleaner;
  String selectedUserId = '';
  String? token;
  String userType = "";

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    loginData();
  }

  void loginData() async {
    //Get logged user data
    Map<String, dynamic> userData = await AuthController.getLoginData();
    print(userData.toString());
    setState(() {
      AdminuserId = userData['id'];
      token = userData['token'];
      userType = userData['userType'];
      if (userType == 'admin') {
        isSuperAdmin = true;
      }
    });
    print('userType ' + userType);
    getCleaners();
  }

  String AdminuserId = "";

//create chat if there is no chat room created
//for first message
  void createChat() async {
    print('Inside Send Messages');
    if (_textController.text.isNotEmpty || imageUrl.isNotEmpty) {
      await chatServices
          .createChat(
              isSuperAdmin ? widget.siteId : AdminuserId,
              selectedUserId,
              _textController.text,
              _selectedOptionPiority ?? "",
              _selectedCleaner ?? "",
              widget.title,
              imageUrl: imageUrl)
          .then((value) {
        setState(() {
          chatRoomId = value;
          print(chatRoomId);
          _selectedCleaner = null;
          _selectedOptionPiority = null;
        });
        return '';
      });
      _textController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Message is empty, Enter what you need"),
        ),
      );
    }
  }

//send messages to the chat room created
//for messages except first message
  void sendMessages() async {
    print('Inside Send Messages');
    if (_textController.text.isNotEmpty || imageUrl.isNotEmpty) {
      await chatServices.sendMessages(chatRoomId, _textController.text,
          imageUrl: imageUrl);
      _textController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Message is empty, Enter what you need"),
        ),
      );
    }
  }

  //pick image and store in firebase storage

  Future<String?> _pickImageFromGallery() async {
    try {
      final pickedFile =
          await ImagePicker().getImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Define a unique filename for the image using a timestamp
        String filename = path.basename(pickedFile.path);

        // Upload the image to Firebase Storage
        final storageReference = _storage.ref().child('Comm_Chats/$filename');
        UploadTask uploadTask = storageReference.putFile(imageFile);

        // Create a Completer to wait for the upload to complete
        Completer<String?> uploadCompleter = Completer<String?>();

        // Listen for the state changes, including errors and completion
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) async {
          if (snapshot.state == TaskState.success) {
            // The upload is complete, obtain the download URL
            imageUrl = await storageReference.getDownloadURL();
            print(imageUrl);

            // Resolve the Completer with the imageUrl
            uploadCompleter.complete(imageUrl);
          } else if (snapshot.state == TaskState.error) {
            // Handle any errors here
            uploadCompleter.completeError('Image upload failed');
          }
        });

        // Show a loading indicator while uploading
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Container(
                width: 300.0,
                height: 300.0,
                child: FutureBuilder<String?>(
                  future: uploadCompleter.future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Image upload failed');
                    } else if (snapshot.hasData) {
                      return Image.file(imageFile);
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (chatRoomId.isNotEmpty) {
                      sendMessages();
                    } else {
                      createChat();
                    }
                    imageUrl = "";
                    // Close the preview
                    Navigator.pop(context, uploadCompleter.future);
                  },
                  child: Text('Send'),
                ),
                TextButton(
                  onPressed: () {
                    // Close the preview
                    Navigator.pop(context, null);
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );

        // Wait for the user to decide (Send or Cancel)
        return await uploadCompleter.future;
      }

      return null;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> getCleaners() async {
    print("Getting cleaners list....");
    userList = [];
    print(token);
    final response = await Dio().get("${BASE_API2}user/getAllCleanerUsers",
        options: Options(headers: {"Authorization": "Bearer $token"}));
    var data = response.data['result'];
    print("DATA: $data");
    if (response.statusCode == 200) {
      final List<dynamic> usersData = response.data['result'];
      print("List: $usersData");

      final Map<String, String> usernameToIdMap = {};
      List<String> usernames = [];

      for (final user in usersData) {
        final String userId = user['user_id'].toString();
        final String username = user['f_name'].toString();
        final String userLastname = user['l_name'].toString();
        final String site_Id = user['site_id'] ?? '';

        // if (isSuperAdmin ? widget.siteId == site_Id : site_Id == AdminuserId) {
        //   print(userId);
        //   usernameToIdMap[username] = userId;
        //   usernames.add(username + " " + userLastname);
        // }

        if (userType == 'admin') {
          print("Super Admin");

          if (widget.siteId == site_Id) {
            print(widget.siteId);
            print(site_Id);

            usernameToIdMap[username] = userId;
            usernames.add(username + " " + userLastname);
          }
        } else {
// Check if user_id is equal to site_id
          if (AdminuserId == site_Id) {
            print(userId);
            usernameToIdMap[username] = userId;
            usernames.add(username + " " + userLastname);
          }
        }
      }

      // Remove duplicates
      usernames = usernames.toSet().toList();
      print(usernameToIdMap.toString());

      setState(() {
        _userTypeList = usernames;
        _usernameToIdMap = usernameToIdMap;
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  final String _userName = "Tashini";
  String _selectedOption = 'Select Cleaner';
  String? _selectedOptionPiority;

  //build msg list
  Widget _buildMessageList() {
    //return container until chat room created in the database
    if (chatRoomId.isEmpty) {
      return Container();
    } else {
      return StreamBuilder(
          stream: chatServices.getMessages(chatRoomId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error ' + snapshot.error.toString());
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            }

            return ListView(
              children:
                  snapshot.data!.docs.map((e) => _buildMessageItem(e)).toList(),
            );
          });
    }
  }

  //build msg item
  Widget _buildMessageItem(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    // Ailgn messages to the right if the sender is the current user, otherwise to the left
    //Get logged user data

    var isCurrentUser =
        (data['senderId'] == AdminuserId); //need to get login id
    Timestamp timestamp = data['timestamp'];
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat.Hm().format(dateTime);
    String subMessage =
        "Assigned to: ${data['receiverName']}\nPriority level: ${data['priorityLevel']}";

    var alignment;
    if (isCurrentUser) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blueGrey[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCurrentUser
                  ? "You"
                  : data['senderName'] == "Admin"
                      ? 'Admin'
                      : data['senderName'],
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? Colors.black : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4.0),
            if (data['message'] != "")
              Text(
                data['message'],
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontFamily: "Open Sans",
                    fontWeight: FontWeight.w600),
              ),
            if (data['receiverName'] != "")
              Text(
                subMessage,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 68, 65, 65),
                    fontFamily: "Open Sans",
                    fontWeight: FontWeight.w600),
              ),
            if (data['imageUrl'] != "")
              Image.network(
                data['imageUrl'],
                height: 250.0,
                width: 250.0,
              ),
            const SizedBox(height: 4.0),
            Text(
              formattedTime,
              // DateFormat('HH:mm').format(data['timestamp']),
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: isCurrentUser ? Colors.black : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            "COMMUNICATION",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
          // actions: <Widget>[
          //   Padding(
          //       padding: const EdgeInsets.only(right: 20.0),
          //       child: GestureDetector(
          //           onTap: () async {
          //             Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                     builder: (context) => UserProfile()));
          //           },
          //           child: CircleAvatar(
          //             radius: 18,
          //             backgroundColor: kiconColor,
          //             child: (loginUserProfile['image'] != null)
          //                 ? CircleAvatar(
          //                     radius: 17,
          //                     backgroundImage:
          //                         NetworkImage(loginUserProfile['image']),
          //                   )
          //                 : CircleAvatar(
          //                     radius: 17,
          //                     backgroundColor: Colors.white,
          //                     child: Icon(
          //                       Icons.person,
          //                       color: kiconColor,
          //                     ),
          //                   ),
          //           ))),
          //   // logoutButton(),
          // ],
        ),
        body: Container(
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Card(
                        elevation: 4, // Add elevation for shadow
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8.0), // Add border radius
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: <Widget>[
                              // Add a heading here
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Container(
                                  width: screenWidth * 0.80,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 50, right: 50, bottom: 10),
                                  child: Text(
                                    widget.title,
                                    textAlign: TextAlign
                                        .center, // Change the text as needed
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              // Sub heading client site and address, if only logged as super admin
                              if (isSuperAdmin)
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    width: screenWidth * 0.80,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.only(
                                      left: 5,
                                      right: 5,
                                    ),
                                    child: Text(
                                      'Site: ${widget.siteName} , Address: ${widget.siteAddress}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: _buildMessageList(),
                              ),
                              const Divider(),
                              if (userType != 'cleaner')
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Row(
                                    children: [
                                      IgnorePointer(
                                        ignoring:
                                            chatRoomId.isEmpty ? false : true,
                                        child: DropdownButton<String>(
                                          hint: Text('Select Cleaner'),
                                          value: _selectedCleaner,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedCleaner = newValue!;

                                              // Find the selected user's ID using the username-to-ID map
                                              selectedUserId =
                                                  _usernameToIdMap[newValue] ??
                                                      '';
                                              print(
                                                  "Selected User ID: $selectedUserId");
                                            });
                                          },
                                          items: [
                                            // DropdownMenuItem<String>(
                                            //   value: 'Select Cleaner',
                                            //   child: Text(
                                            //     'Select Cleaner',
                                            //     style: const TextStyle(
                                            //       fontFamily: "Open Sans",
                                            //       fontSize: 15,
                                            //     ),
                                            //   ),
                                            // ),
                                            for (var userName in _userTypeList)
                                              DropdownMenuItem<String>(
                                                value: userName,
                                                child: Text(
                                                  userName,
                                                  style: const TextStyle(
                                                    fontFamily: "Open Sans",
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      IgnorePointer(
                                        ignoring:
                                            chatRoomId.isEmpty ? false : true,
                                        child: DropdownButton<String>(
                                          hint: Text('Select Piority Level'),
                                          value: _selectedOptionPiority,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedOptionPiority = value!;
                                            });
                                          },
                                          items: <String>[
                                            'High',
                                            'Medium',
                                            'Low',
                                            // Add your dropdown options here
                                          ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: const TextStyle(
                                                    fontFamily: "Open Sans",
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                8.0), // Optional padding
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              30), // Optional border radius
                                          border: Border.all(
                                              color:
                                                  kiconColor), // Optional border
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(Icons.message,
                                                  color: kiconColor),
                                            ),
                                            Expanded(
                                              child: TextField(
                                                controller: _textController,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Enter what you need', // Include the selected emoji here
                                                  hintStyle:
                                                      TextStyle(fontSize: 15),
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.attachment,
                                                  color: kiconColor),
                                              onPressed: () async {
                                                _pickImageFromGallery();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    if (userType != "cleaner")
                                      IgnorePointer(
                                        ignoring: (chatRoomId.isEmpty &&
                                                _selectedCleaner == null &&
                                                _selectedOptionPiority == null)
                                            ? true
                                            : false,
                                        child: CircleAvatar(
                                          backgroundColor: chatRoomId.isEmpty &&
                                                  _selectedCleaner == null &&
                                                  _selectedOptionPiority == null
                                              ? Colors.grey[200]
                                              : kiconColor,
                                          child: IconButton(
                                            disabledColor: Colors.grey[200],
                                            icon: const Icon(Icons.send,
                                                color: Colors.white),
                                            onPressed:
                                                // (_selectedCleaner ==
                                                //             null ||
                                                //         _selectedOptionPiority ==
                                                //             null)
                                                //     ? null

                                                //     :
                                                chatRoomId.isEmpty
                                                    ? createChat
                                                    : sendMessages,
                                          ),
                                        ),
                                      ),
                                    if (userType == "cleaner")
                                      CircleAvatar(
                                        backgroundColor: kiconColor,
                                        child: IconButton(
                                          disabledColor: Colors.grey[200],
                                          icon: const Icon(Icons.send,
                                              color: Colors.white),
                                          onPressed: chatRoomId.isEmpty
                                              ? createChat
                                              : sendMessages,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}
