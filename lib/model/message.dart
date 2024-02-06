import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  ChatMessage(
      {required this.senderId,
      required this.receiverId,
      required this.receiverName,
      required this.senderEmail,
      required this.senderName,
      required this.message,
      required this.timestamp,
      required this.priorityLevel,
      this.subMessage = '',
      this.imageUrl = ''});
  final String senderId;
  final String senderEmail;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final String priorityLevel;
  final Timestamp timestamp;
  final String? subMessage;
  final String? imageUrl;

  //convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'receiverName': receiverName,
      'senderName': senderName,
      'priorityLevel': priorityLevel,
      'subMessage': subMessage,
      'imageUrl': imageUrl
    };
  }
}
