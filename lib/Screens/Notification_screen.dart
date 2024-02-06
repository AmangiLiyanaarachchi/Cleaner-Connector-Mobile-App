import 'package:clean_connector/Constant/const_api.dart';
import 'package:clean_connector/Constant/style.dart';
// import 'package:clean_connector/Screens/communication_admin_login.dart';
import 'package:clean_connector/Screens/site_list.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/task_view.dart';
import 'package:clean_connector/Screens/user_list.dart';
// import 'package:cleanconnectortab/Communication.dart';
// import 'package:cleanconnectortab/Dashboard.dart';
// import 'package:cleanconnectortab/Screen/SiteManual.dart';
// import 'package:cleanconnectortab/Screen/site_recomondation.dart';
// import 'package:cleanconnectortab/Stock.dart';
// import 'package:cleanconnectortab/Timer.dart';
// import 'package:cleanconnectortab/constants/const_api.dart';
// import 'package:cleanconnectortab/constants/style.dart';
// import 'package:cleanconnectortab/login.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'login_screen.dart';

class NotificationScreen extends StatefulWidget {
  static const route = '/notification-screen';

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [
    // {
    //   'body': 'Cleaner 1 requested the Item.',
    //   'timestamp': DateTime.now(), // Set a custom timestamp.
    //   'title': 'Stock',
    //   'isread': false,
    // },
    // {
    //   'body': 'A new site manual has been updated',
    //   'timestamp': DateTime(2023, 10, 10, 18, 45), // Set a custom timestamp.
    //   'title': 'Site Mannual',
    //   'isread': false,
    // },
    // {
    //   'body': 'Cleaner 2 requested the Item',
    //   'timestamp': DateTime(2023, 10, 01, 14, 45), // Set a custom timestamp.
    //   'title': 'Stock',
    //   'isread': false,
    // },
    // {
    //   'body': 'A new site manual has been updated',
    //   'timestamp': DateTime(2023, 10, 01, 14, 45), // Set a custom timestamp.
    //   'title': 'Site Mannual',
    //   'isread': false,
    // },
    // {
    //   'body': 'You have new site recomondation',
    //   'timestamp': DateTime(2023, 10, 01, 14, 45), // Set a custom timestamp.
    //   'title': 'site recomondation',
    //   'isread': false,
    // },
    // {
    //   'body': 'Cleaner 3 requested the Item',
    //   'timestamp': DateTime(2023, 10, 01, 14, 45), // Set a custom timestamp.
    //   'title': 'Stock',
    //   'isread': false,
    // },
    // {
    //   'body': 'A new site manual has been updated',
    //   'timestamp': DateTime(2023, 10, 01, 14, 45), // Set a custom timestamp.
    //   'title': 'Site Mannual',
    //   'isread': true,
    // },
    // {
    //   'body': 'You have new site recomondation',
    //   'timestamp': DateTime(2023, 10, 01, 14, 45), // Set a custom timestamp.
    //   'title': 'site recomondation',
    //   'isread': false,
    // },
    // {
    //   'body': 'A new site manual has been updated',
    //   'timestamp': DateTime(2023, 10, 01, 14, 45), // Set a custom timestamp.
    //   'title': 'Site Mannual',
    //   'isread': true,
    // },
    // {
    //   'body': 'Cleaner 4 requested the Item',
    //   'timestamp': DateTime(2023, 10, 01, 14, 45), // Set a custom timestamp.
    //   'title': 'Stock',
    //   'isread': false,
    // },
    // {
    //   'body': 'A new site manual has been updated',
    //   'timestamp': DateTime(2023, 10, 01, 14, 45), // Set a custom timestamp.
    //   'title': 'Site Mannual',
    //   'isread': true,
    // },
    // {
    //   'body': 'A new site manual has been updated',
    //   'timestamp': DateTime(2023, 10, 01, 14, 45), // Set a custom timestamp.
    //   'title': 'Site Mannual',
    //   'isread': true,
    // },
  ];

  String fcmToken = '';
  final TextEditingController tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch notifications when the screen is initialized
    fetchNotifications();
    initFCMToken();
  }

  Future<void> initFCMToken() async {
    // Obtain the FCM token
    final String token = await FirebaseMessaging.instance.getToken() ?? '';
    setState(() {
      fcmToken = token;
      tokenController.text = token;
    });
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await Dio().get(
          "${BASE_API2}notification/get-all-notifications",
          options: Options(headers: {
            "Authorization": loginUserData['accessToken']
          })); // Replace with your API endpoint
      var data = response.data['data'];
      print(data);
      if (response.statusCode == 200) {
        final jsonData = response.data;
        final List<dynamic> data = jsonData['data'];

        setState(() {
          notifications =
              data.map((json) => NotificationModel.fromJson(json)).toList();
        });
      } else {
        // Handle error
        print('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      // Handle DioError or other exceptions
      print('Error fetching notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "NOTIFICATIONS",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: kiconColor),
          ),
          backgroundColor: Colors.white,
          // leading: Padding(
          //   padding: const EdgeInsets.only(left: 20),
          //   child: GestureDetector(
          //       onTap: () {
          //         loginStatus == true
          //             ? Navigator.push(
          //                 context,
          //                 MaterialPageRoute<dynamic>(
          //                   builder: (_) => TimerScreen(),
          //                 ),
          //               )
          //             : Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                     builder: (context) => const Dashboard()));
          //       },
          //       child: CircleAvatar(
          //         radius: 18,
          //         backgroundColor: kiconColor,
          //         child: CircleAvatar(
          //           radius: 17,
          //           backgroundColor: Colors.white,
          //           child: Icon(
          //             Icons.arrow_back,
          //             color: kiconColor,
          //           ),
          //         ),
          //       )),
          // ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(2, 2),
                  blurRadius: 2,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                //   Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: TextField(
                //     controller: tokenController,
                //     readOnly: true,
                //     decoration: InputDecoration(
                //       labelText: 'FCM Token',
                //       border: OutlineInputBorder(),
                //       suffixIcon: IconButton(
                //         icon: Icon(Icons.content_copy),
                //         onPressed: () {
                //           Clipboard.setData(ClipboardData(text: fcmToken));
                //           ScaffoldMessenger.of(context).showSnackBar(
                //             SnackBar(
                //               content: Text('FCM Token copied to clipboard'),
                //             ),
                //           );
                //         },
                //       ),
                //     ),
                //   ),
                // ),
                  Expanded(
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (BuildContext context, int index) {
                    final NotificationModel notification = notifications[index];
              
                    final type = notification.title;
              
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom:
                              15 * kHeight / MediaQuery.of(context).size.height),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10 * screenWidth / kWidth,
                            vertical: 10 * screenHeight / kHeight),
                        decoration: BoxDecoration(
                            color: notification.isread
                                ? Colors.white
                                : kcardBackgroundColor,
                            borderRadius: BorderRadius.circular(10)),
                        width: screenWidth,
                        height: screenHeight * 0.125,
                        
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kiconColor,
                            child: Icon(Icons.notifications),
                          ),
                          title: Text(
                            '${notification.title}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Padding(
                              padding: const EdgeInsets.only(),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${notification.body}',
                                      style:
                                          TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      formatTimestamp(
                                          DateTime.parse(notification.timestamp)),
                                      style:
                                          TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    
                                  ])),
                          onTap: () {
                            // Handle tapping on a notification.
              
                            if (type == "User") {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserList()));
                            } else if (type == "Site") {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SiteList()));
                            } else if (type == "Task") {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ViewTaskScreen()));
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      final dateFormatter = DateFormat('dd MMM yyyy HH:mm');
      return dateFormatter.format(timestamp);
    }
  }
}

// {
//   'body': 'A new site manual has been updated',
//   'timestamp': DateTime(2023, 10, 01, 14, 45), // Set a custom timestamp.
//   'title': 'Site Mannual',
//   'isread': true,
// },

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  final bool isread;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isread,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime formattedDateTime = DateFormat('MM/dd/yyyy, h:mm:ss a')
        .parse(json['formattedTimestamp'] ?? '', true);
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['description'] ?? '',
      timestamp: formattedDateTime.toString(),
      isread: false,
    );
  }
}
