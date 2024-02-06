// import 'dart:convert';
// import 'dart:ffi';

import 'package:clean_connector/Constant/style.dart';
// import 'package:clean_connector/Screens/QRScanData.dart';
import 'package:clean_connector/Screens/login_screen.dart';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import '../Constant/const_api.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Users> siteList = [];
  bool isLoading = false;
  bool isEmptyList = false;

  Future<List<Users>> getUsers() async {
    setState(() {
      isLoading = true;
      isEmptyList = false;
    });

    try {
      print("!!!!!!History!!!!!!");

      final response = await Dio().get(
        "${BASE_API2}user/scan-data",
        options: Options(headers: {
          "Authorization": "Bearer " + loginUserData['accessToken']
        }),
      );
      print(response.data["message"]);

      if (response.statusCode == 200 && response.data['status'] == true) {
        print(response.data['data']);
        final List<dynamic> responseData = response.data['data'];
        final usersList =
            responseData.map((userData) => Users.fromJson(userData)).toList();

        // usersList.sort((a, b) {
        //   // First, compare the end_date
        //   final endDateComparison = b.end_date.compareTo(a.end_date);

        //   // If the end_date is the same, compare the scannedTime
        //   if (endDateComparison == 0) {
        //     return b.scannedTime.compareTo(a.scannedTime);
        //   }

        //   return endDateComparison;
        // });

        usersList.sort((a, b) {
          // First, compare the end_date in descending order
          final endDateComparison = b.end_date.compareTo(a.end_date);

          // If the end_date is the same, compare the scannedTime in descending order
          if (endDateComparison == 0) {
            return b.scannedTime.compareTo(a.scannedTime);
          }

          return endDateComparison;
        });

        setState(() {
          siteList = usersList;
          isLoading = false;
        });

        return usersList; // Return the list of users
      } else {
        //print("No user found");
        setState(() {
          isLoading = false;
          isEmptyList = true;
        });

        return <Users>[]; // Return an empty list in case of an error
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });

      return <Users>[]; // Return an empty list in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "HISTORY",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: FutureBuilder<List<Users>>(
                    future: getUsers(),
                    builder: (context, AsyncSnapshot<List<Users>> snapshot) {
                      return siteList.isNotEmpty
                          ? ListView.builder(
                              itemCount: siteList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10 * screenWidth / kWidth,
                                      vertical: 5 * screenHeight / kHeight),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10 * screenWidth / kWidth,
                                        vertical: 10 * screenHeight / kHeight),
                                    decoration: BoxDecoration(
                                        color: kcardBackgroundColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    width: screenWidth,
                                    child: InkWell(
                                      onTap: () {},
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 35,
                                          backgroundColor: kiconColor,
                                          child: CircleAvatar(
                                            radius: 27,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.home_outlined,
                                              color: kiconColor,
                                            ),
                                          ),
                                        ),
                                        title: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  "${siteList[index].siteName} - ${siteList[index].siteAddress}",
                                                  style: klistTitle),
                                            ],
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 5),
                                              Text(
                                                  "Area: ${siteList[index].area_name}",
                                                  style: klistTitle),
                                              SizedBox(height: 5),
                                              Text(
                                                  "Cleaner: ${siteList[index].fName}",
                                                  style: klistTitle),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                  "Date: ${siteList[index].end_date}",
                                                  style: klistTitle),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                  "Time: ${siteList[index].scannedTime}",
                                                  style: klistTitle),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })
                          : (isEmptyList == true)
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30.0, right: 30.0, top: 50.0),
                                  child: Text("No users to preview"),
                                )
                              : const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: SpinKitDualRing(
                                    color: kiconColor,
                                    size: 30,
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
    );
  }
}

class Users {
  final String id;
  final String siteArea;
  final String siteId;
  final String userId;
  final String scannedTime;
  final String siteName;
  final String siteAddress;
  final String email;
  final String password;
  final double rate;
  final String mobile;
  final int site_no;
  final String created_at;
  final String updated_at;
  final String last_updated;
  final String fName;
  final String lName;
  final String phone;
  final String image;
  final String role;
  final String start_date;
  final String end_date;
  final int emp_no;
  final String area_name;
  final String barcode_image;

  Users({
    required this.id,
    required this.siteId,
    required this.siteArea,
    required this.userId,
    required this.scannedTime,
    required this.siteName,
    required this.siteAddress,
    required this.email,
    required this.password,
    required this.rate,
    required this.mobile,
    required this.site_no,
    required this.created_at,
    required this.updated_at,
    required this.last_updated,
    required this.fName,
    required this.lName,
    required this.phone,
    required this.image,
    required this.role,
    required this.start_date,
    required this.end_date,
    required this.emp_no,
    required this.area_name,
    required this.barcode_image,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
        id: json['id'],
        siteId: json['site_id'],
        siteArea: json['site_area'],
        userId: json['user_id'],
        scannedTime:
            DateFormat('HH:mm:ss').format(DateTime.parse(json['scanned_time'])),
        siteName: json['site_name'],
        siteAddress:
            json['site_address'] == null ? "No receiver" : json['site_address'],
        email: json['email'],
        password: json['password'],
        rate: (json['rate'] is int)
            ? (json['rate'] as int).toDouble()
            : json['rate'],
        mobile: json['mobile'] == null ? "No Mobile" : json['mobile'],
        site_no: json['site_no'],
        created_at: json['created_at'],
        updated_at: json['updated_at'],
        last_updated : json['last_updated'],
        fName: json['f_name'],
        lName: json['l_name'],
        phone: json['phone'],
        image: json['image'],
        role: json['role'],
        start_date: json['start_date'] == null
            ? DateFormat('yyyy-MM-dd').format(DateTime.now())
            : DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(json['start_date'])),
        end_date: json['end_date'] == null
            ? DateFormat('yyyy-MM-dd').format(DateTime.now())
            : DateFormat('yyyy-MM-dd')
                .format(DateTime.parse(json['scanned_time'])),
        emp_no: json['emp_no'],
        area_name: json['area_name'],
        barcode_image: json['barcode_image']);
  }
}
