import 'dart:async';
import 'dart:io';

import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Controller/authController.dart';
import 'package:clean_connector/Screens/chat_history_com.dart';
import 'package:clean_connector/services/api_services.dart';
import 'package:clean_connector/services/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../components/bottom_bar.dart';

class Message {
  final String senderName;
  final String text;
  final DateTime timestamp; // Add a timestamp field
  final File? imageFile; // Add an optional image file field

  Message(this.senderName, this.text, this.timestamp, {this.imageFile});
}

class Chat_Screen extends StatefulWidget {
  final String cardNumber;
  final String chatRoomId;
  final bool isactive;
  final String createdby;
  final bool isSuperAdmin;
  final String siteId;

  Chat_Screen({
    required this.siteId,
    required this.isSuperAdmin,
    required this.cardNumber,
    required this.chatRoomId,
    required this.isactive,
    this.createdby = " ",
  });
  @override
  State<Chat_Screen> createState() => _Chat_ScreenState();
}

class _Chat_ScreenState extends State<Chat_Screen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool isLoading = false;
  bool title = false;
  String profilePic = '';
  String name = '';
  String email = '';
  String imageUrl = '';
  String siteName = '';
  String siteAddress = '';

  final TextEditingController _textController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final ChatServices chatServices = ChatServices();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    loginData();
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
                    sendMessages();
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

//empty msg popup msg
  void _showEmptyMsgDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Message is Empty')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.black)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("close"))
            ],
          ),
        );
      },
    );
  }

//delete msg pop up
  void _showDeleteDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Delete Message ')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.black)),
                  onPressed: () async {
                    print("messageId" + messageId);
                    Navigator.of(context).pop();
                    chatServices.deleteMessage(widget.chatRoomId, messageId);
                  },
                  child: Text("Delete"))
            ],
          ),
        );
      },
    );
  }

  void sendMessages() async {
    print('Inside Send Messages');
    if (_textController.text.isNotEmpty || imageUrl.isNotEmpty) {
      await chatServices.sendMessages(widget.chatRoomId, _textController.text,
          imageUrl: imageUrl);
      _textController.clear();
    } else {
      _showEmptyMsgDialog(context);
    }
  }

//build msg list
  Widget _buildMessageList() {
    return StreamBuilder(
        stream: chatServices.getMessages(widget.chatRoomId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error ' + snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          }
          noOfMessages = snapshot.data!.size;
          return ListView(
            children:
                snapshot.data!.docs.map((e) => _buildMessageItem(e)).toList(),
          );
        });
  }

  void loginData() async {
    String? type;
    //Get logged user data
    Map<String, dynamic> userData = await AuthController.getLoginData();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (widget.isSuperAdmin) {
      getSiteData(widget.siteId, userData["token"]);
    }

    setState(() {
      uesrId = userData['id'];
      type = sharedPreferences.getString('usertype');
    });
    print(type);
    print(uesrId);
  }

  String uesrId = "";

  //get site details by site id
  void getSiteData(String siteId, String token) async {
    await ApiServices.getSiteDataBySiteId(siteId, token).then(
      (value) {
        setState(() {
          siteName = value['site_name'];
          siteAddress = value['site_address'];
        });
      },
    );
  }

  String currentFormattedDate = '';
  String previousFormattedDate = '';
  bool firstMessagePassed = false;
  int noOfMessages = 0;
  int noOfdisplayedMessages = 0;

  //build msg item
  Widget _buildMessageItem(DocumentSnapshot documentSnapshot) {
    bool showDate = false;
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    // Ailgn messages to the right if the sender is the current user, otherwise to the left
    var isCurrentUser = (data['senderId'] == uesrId); //need to get login id
    Timestamp timestamp = data['timestamp'];
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat.Hm().format(dateTime);
    String formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
    print('$noOfMessages + ->+ $noOfdisplayedMessages');
//date show
    if (!firstMessagePassed) {
      showDate = true;
      currentFormattedDate = formattedDate;
      previousFormattedDate = formattedDate;
    } else {
      currentFormattedDate = formattedDate;
    }
    print(currentFormattedDate);
    if (currentFormattedDate != previousFormattedDate ||
        noOfMessages == noOfdisplayedMessages) {
      showDate = true;

      previousFormattedDate = formattedDate;
    }
    firstMessagePassed = true;
    noOfdisplayedMessages++;
    String subMessage =
        "Assigned to: ${data['receiverName']}\nPriority level: ${data['priorityLevel']}";
    var alignment;
    if (isCurrentUser) {
      alignment = Alignment.centerRight;
    } else {
      alignment = Alignment.centerLeft;
    }

    return Column(
      children: [
        if (showDate)
          Stack(
            alignment: Alignment.center,
            children: [
              Divider(
                height: 5,
                color: Colors.grey[350],
              ),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[300]),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Text(formattedDate),
                  )),
            ],
          ),
        GestureDetector(
          //on long press appear delete dialog box
          onLongPress: () {
            if (isCurrentUser) {
              _showDeleteDialog(context, documentSnapshot.id);
            }
          },
          child: Align(
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
          ),
        ),
      ],
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
          //   logoutButton(),
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
                                    widget.cardNumber,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              // Sub heading client site and address, if only logged as super admin
                              if (widget.isSuperAdmin)
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
                                      'Site: ${siteName.toString()} , Address: ${siteAddress.toString()}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        // fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              Expanded(child: _buildMessageList()),

                              const Divider(),

                              widget.isactive
                                  ? ListTile(
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(Icons.message,
                                                        color: kiconColor),
                                                  ),
                                                  Expanded(
                                                    child: TextField(
                                                      controller:
                                                          _textController,
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            'Enter what you need', // Include the selected emoji here
                                                        hintStyle: TextStyle(
                                                            fontSize: 15),
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.attachment,
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
                                          CircleAvatar(
                                            backgroundColor: kiconColor,
                                            child: IconButton(
                                                icon: const Icon(Icons.send,
                                                    color: Colors.white),
                                                onPressed: sendMessages),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              widget.isactive && widget.createdby == uesrId
                                  ? GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                "End Chat",
                                              ),
                                              content: Text(
                                                  "Are you sure you want to end the chat?"),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            'chat_rooms')
                                                        .doc(widget
                                                            .chatRoomId) // Assuming 'chatRoomId' is the document ID
                                                        .update(
                                                            {'active': false});
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatHistoryCommunication(),
                                                      ),
                                                    ); // Close the dialog
                                                  },
                                                  child: Text("Yes"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: Text("No"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "End the Chat",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container()
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
