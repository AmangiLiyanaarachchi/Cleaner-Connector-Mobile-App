import 'dart:io';

import 'package:clean_connector/Screens/Notification_screen.dart';
import 'package:clean_connector/model/push_notification.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'Screens/splash_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: Platform.isAndroid
          ? FirebaseOptions(
              apiKey: 'AIzaSyA7p2rShiMEe_nKhjYbtT9QIkegV10sB3M',
              appId: '1:33588551520:android:c93cd1ba8e0ed5a503c805',
              messagingSenderId: '33588551520',
              projectId: 'cleanerconnect-b06a3',
              storageBucket: "cleanerconnect-b06a3.appspot.com",
            )
          : null);
await FirebaseAPI().initNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Cleaner Connect',
      home: SplashScreen(),
      routes: {
        NotificationScreen.route: (context) => NotificationScreen()
      },
    );
  }

  
}
