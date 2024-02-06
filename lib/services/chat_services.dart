import 'package:clean_connector/Controller/authController.dart';
import 'package:clean_connector/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatServices extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  //Create chat
  Future<String> createChat(String siteId, String receiverId, String message,
      String priorityLevel, String receiveCleaner, String title,
      {String? imageUrl}) async {
    final Timestamp timestamp = Timestamp.now();

    //Get logged user data
    Map<String, dynamic> userData = await AuthController.getLoginData();

    print('User Id ' + userData['id']);
    print('User Email ' + userData['email']);
    print('User Name ' + userData['fname']);
    print('User Name ' + userData['lname']);
    print('Site ID ' + userData['siteId'].toString());

    //create a new msg
    ChatMessage newMessage = ChatMessage(
        senderId: userData['id'],
        receiverId: receiverId,
        receiverName: receiveCleaner,
        senderEmail: userData['email'],
        senderName: userData['userType'] == 'cleaner'
            ? userData['fname'] + ' ' + userData['lname']
            : userData['fname'],
        imageUrl: imageUrl,
        message: message,
        subMessage: "",
        timestamp: timestamp,
        priorityLevel: priorityLevel);

    // //construnct chat room id from current user id and receiver id (sorted to ensure uniqueness)
    // List<String> ids = [userData['id'], receiverId];
    // ids.sort(); //sort the ids (this ensures the chat room id is always the same for any pair of people
    // String chatRoomId = ids.join(
    //     "-"); //combine the ids into a single string to use as a chatroomID
//Get chat room id
    var chatRoomId = _firebaseFirestore.collection('chat_rooms').doc().id;
    print(newMessage.toString());
    //add new msg to database
    await _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap())
        .then((value) => {
              _firebaseFirestore.collection('chat_rooms').doc(chatRoomId).set({
                'site_id': userData['userType'] == 'cleaner'
                    ? userData['siteId']
                    : siteId,
                'created_by': userData['id'],
                'created_by_name': userData['userType'] == 'cleaner'
                    ? userData['fname'] + ' ' + userData['lname']
                    : userData['fname'],
                'created_date': timestamp,
                'active': true,
                'title': title,
                'title_lowercase': title.toLowerCase()
              }, SetOptions(merge: true))
            });

    return chatRoomId;
  }

  //SEND MSG
  Future<void> sendMessages(String chatRoomId, String message,
      {String? imageUrl}) async {
    final Timestamp timestamp = Timestamp.now();

    //Get logged user data
    Map<String, dynamic> userData = await AuthController.getLoginData();

    print('User Id ' + userData['id']);
    print('User Email' + userData['email']);
    print('User Name' + userData['fname']);
    print('User Name' + userData['lname']);
    print('User Name' + imageUrl.toString());
    //create a new msg
    ChatMessage newMessage = ChatMessage(
        senderId: userData['id'],
        receiverId: '2424',
        receiverName: '',
        senderEmail: userData['email'],
        senderName: userData['userType'] == 'cleaner'
            ? userData['fname'] + ' ' + userData['lname']
            : userData['fname'],
        message: message,
        timestamp: timestamp,
        imageUrl: imageUrl,
        priorityLevel: '');
    print(newMessage);
    try {
      //add  msg to database
      await _firebaseFirestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection(
            'messages',
          )
          .add(
            newMessage.toMap(),
          );
    } catch (e) {
      print(e.toString());
    }
  }

  //GET MSG
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await _firebaseFirestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print("Error deleting message: $e");
    }
  }
}
