import 'dart:convert';

import 'package:clean_connector/Constant/const_api.dart';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/QRScanData.dart';
import 'package:clean_connector/Screens/login_screen.dart';


import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  String? qr;
  bool camState = true;
  bool dirState = false;
  bool isLoading = false;
  String? siteName;
  String? siteId;
  String? siteArea;
  String? userId = loginUserData['id'];


  @override
  void initState() {
    super.initState();
  }

  Future<void> showSiteNameDialog() async {
    print('Site Id: $siteId');
    //await fetchSitbySIteId();
    print('fetchUserDatabySIteId ***Site Name $siteName');
    print('fetchUserDatabySIteId ***Site Name $siteArea');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text("Success"),
          content: Text("Have you finished cleaning $siteName - $siteArea ?"),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 52, 137, 207),
              ),
              onPressed: () {
                UpdateSite();
                // Navigator.of(context).pop();
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => Dashboard()));

                //API call
              },
              child: Text("Yes"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 52, 137, 207),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => QRScanData()));
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  Future<void> showErrorDialog(e) async {
    print("UpdateSite Dialog $e");
    showDialog(
    context: context, // Provide the context from your widget
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(e), // Assuming `e` is the error message
        actions: <Widget>[
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => QRScanData()));
            },
          )
        ],
      );
    },
);
  }

  Future<void> fetchSitbySIteId() async {
    
    try {
      // var response = await Dio().get(BASE_API2 + 'user/getCleanerUsersBySiteId/${siteId}',
      //   options: Options(headers: {
      //     "Authorization": "Bearer " + loginUserData["accessToken"]
      //   }),
      // );

      var response = await Dio().get(BASE_API2 + 'site/get-sites/${siteId}');

      if (response.statusCode == 200) {
        var jsonResponse = response.data; // Access the JSON data from the response


        if (jsonResponse["sites"] is List && jsonResponse["sites"].isNotEmpty) {
          String _siteName = jsonResponse["sites"][0]["site_name"];
          print("fetchSitbySIteId Site Name: $_siteName");


          setState(() {
            siteName = _siteName;
          });

          print("fetchSitbySIteId *****: $siteName");

        } else {
          print("No data or an empty 'result' array in the response.");
        }
      } else {
        print("Request failed with status code: ${response.statusCode}");
      }
      
      // Handle the response here, e.g., update the UI with the data.
    } catch (e) {
      // Handle errors, e.g., network errors.
      print('fetchSitbySIteId Error: $e');
    }
  }

  Future UpdateSite() async {

    print('UpdateSite Site id -$siteId');

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    print('Now = $now');
    print('UpdateSite formattedDate = $formattedDate');
    
    setState(() {
      isLoading = true;
    });

    try {
      print("UpdateSite $userId");
      var response = await Dio().post(BASE_API2 + 'user/scan-data', data: {
        // "site_area": 'fd3a91d9-73b2-11ee-8d1a-0a616426a2b7',
        // "user":'0468b06a-e460-4d1b-a264-f2c7078c1dd4',
        "site_area":siteId,
        "user":userId,
        "time":formattedDate
      }
      );

      print("UpdateSite !!!!!!!!!!$response");
      
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        
        if (response.data["result"]["message"] == "Added Successfully") {
                   
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sanned Successfully"),
            ),
          );
          Navigator.of(context).pop();
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => QRScanData()));
          
        } 
      }
    } on DioException catch (e) {
      print("UpdateSite Error $e");
      //showErrorDialog(e.toString());
      if (e.response?.statusCode == 400) {
        print("Bad Error");
        print(e.response?.data["message"]);
        String message = e.response?.data["message"];
        // if (e.response?.data["message"] == "User entered wrong password") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
       
      }
      
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "SCAN QR CODE",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
          // leading: Padding(
          //   padding: const EdgeInsets.only(left: 20),
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => QRScanData(),
          //           ));
          //     },
          //     child: const CircleAvatar(
          //       radius: 18,
          //       backgroundColor: kiconColor,
          //       child: CircleAvatar(
          //         radius: 15,
          //         backgroundColor: Colors.white,
          //         child: Icon(
          //           Icons.arrow_back_sharp,
          //           color: kiconColor,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: camState
                      ? Center(
                          child: SizedBox(
                            width: 300.0,
                            height: 400.0,
                            child: QrCamera(
                              onError: (context, error) => Text(
                                error.toString(),
                                style: TextStyle(
                                    color: kiconColor),
                              ),
                              // cameraDirection: dirState ? CameraDirection.FRONT : CameraDirection.BACK,
                              cameraDirection: CameraDirection.BACK,
                              qrCodeCallback: (res) {

                                print('QRCODE $res');

                                String code = res?? "";
                                Map<String, dynamic> codeMap = json.decode(code);
                                String sitename = codeMap["id"];
                                print('SiteName $sitename');
                                
                                setState(() {
                                  camState = false;
                                  siteId = codeMap["id"];
                                  siteName = codeMap["site"];
                                  siteArea = codeMap["area"];
                                });
                                showSiteNameDialog();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: kiconColor,
                                    width: 5.0,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(child: Text("Camera inactive"))),
            ],
          ),
        ),
      ),
    );
  }
}
