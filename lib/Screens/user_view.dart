import 'dart:async';
import 'dart:convert';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_edit.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import '../Constant/const_api.dart';
import '../Controller/authController.dart';
import '../components/bottom_bar.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';

class UserView extends StatefulWidget {
  
  UserView({
    required this.id,
    required this.f_Name,
    required this.l_Name,
    required this.emailAdd,
    required this.startDate,
    required this.endDate,
    required this.mobile,
    required this.suburbs,
    required this.image,
    required this.userType,
    required this.siteId,
    required this.empNo,
    required this.doc
  });
  String? id;
  String? f_Name;
  String? l_Name;
  String? emailAdd;
  String? startDate;
  String? endDate;
  String? mobile;
  String? suburbs;
  String? image;
  String? userType;
  String? siteId;
  String? empNo;
  String? doc;
  @override
  State<UserView> createState() => _UserViewState();
}
class _UserViewState extends State<UserView> {
  bool isLoading = false;
  String profilePic = '';
  String name = '';
  String email = '';
  String s_date = '';
  String e_date = '';


  @override
  void initState() {
    print("User Data sending ${widget.siteId}");
    if(widget.startDate!=null || widget.endDate!=null){
      DateTime SD = new DateFormat("yyyy-MM-dd").parse(widget.startDate.toString());
      print(SD);
      DateTime ED = new DateFormat("yyyy-MM-dd").parse(widget.endDate.toString());
      setState(() {
        s_date = DateFormat("yyyy-MM-dd").format(SD);
        e_date = DateFormat("yyyy-MM-dd").format(ED);
      });
    }else{
      s_date= DateFormat("yyyy-MM-dd").format(DateTime.now());
      e_date= DateFormat("yyyy-MM-dd").format(DateTime.now());
    }

    // Get.closeAllSnackbars;
    super.initState();
    isLoading = true;
    print("???????????????????: $profilePic");
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deletion successful'),
          content: Text('Cleaner deleted successfully'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UserList()));
              },
            ),
          ],
        );
      },
    );
  }

  Future deleteUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      print(loginUserProfile['id']);
      print(widget.emailAdd);
      final response =
      await Dio().delete(BASE_API2 + "user/deleteCleaner/${widget.id}",
          options: Options(headers: {
            "Authorization": "Bearer "+ loginUserData["accessToken"]
          }));
      print(" Delete user response: $response");
      if(response.statusCode == 200 && response.data['message'] == "Cleaner Deleted Successfully"){

        showSuccessDialog(context);
        print("Delete Successfully");
        
      }
      setState(() {
        isLoading = false;
      });
    } on DioException catch (e) {
      if(e.response?.statusCode == 400){
        print("Bad Error");
        print(e.response?.data["message"] );
        if(e.response?.data["message"]=="Delete not allowed super admin account"){
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text(
                    'Not allowed to delete super admin account.',
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
                      },),
                  ],
                );
              });
        }else if(e.response?.data["message"]=="Cleaner Doesn't Exist"){
          
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("No any registered user for this email"),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.only(
                // bottom: MediaQuery
                //     .of(context)
                //     .size
                //     .height - 100,
                right: 5,
                left: 5,
                top: 100),
          ));
          Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserList()));
        }
      } else if((e.response?.statusCode == 401)){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Session expired. Please Login again"),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.only(
                // bottom: MediaQuery
                //     .of(context)
                //     .size
                //     .height - 100,
                right: 5,
                left: 5,
                top: 100),
          ));
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text("CLEANER INFORMATION", style: kboldTitle,),
          backgroundColor: Colors.white,
          actions: <Widget>[
            // logoutButton(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
          child: Column(
            children: [
              Container(
                height: screenHeight*0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: screenWidth/8.5,
                      backgroundColor: kcardBackgroundColor,
                      child: CircleAvatar(
                        radius: screenWidth/9,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(widget.image.toString()),
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Text(
                      widget.f_Name.toString() +" "+ widget.l_Name.toString(),
                      style: kTitle,
                    ),
                    // const SizedBox(height: 15,),
                    // Text(
                    //   widget.emailAdd.toString(),
                    //   style: kTitle
                    // ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: kcardBackgroundColor,
                    borderRadius: BorderRadius.circular(50)
                ),
                width: screenWidth,
                height: 3,
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            Row(
                                children: [
                                  const Icon(Icons.person, color: kiconColor,),
                                  const SizedBox(width: 20,),
                                  Container(
                                    width: screenWidth*0.2,
                                    child: const Text(
                                      "First Name ",
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
                                      widget.f_Name.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black26,
                                          fontFamily: "OpenSans"),
                                      maxLines: 3,
                                    ),
                                  )
                                ]
                            ),
                            const SizedBox(height: 30,),
                            Row(
                                children: [
                                  const Icon(Icons.person, color: kiconColor,),
                                  const SizedBox(width: 20,),
                                  Container(
                                    width: screenWidth*0.2,
                                    child: const Text(
                                      "Last Name ",
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
                                      widget.l_Name.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black26,
                                          fontFamily: "OpenSans"),
                                      maxLines: 3,
                                    ),
                                  )
                                ]
                            ),
                            const SizedBox(height: 30,),
                            Row(
                        children: [
                          const Icon(Icons.email_outlined, color: kiconColor,),
                        const SizedBox(width: 20,),
                        Container(
                          width: screenWidth*0.2,
                        child: const Text(
                          "Email Address ",
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
                            widget.emailAdd.toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black26,
                                fontFamily: "OpenSans"),
                            maxLines: 3,
                          ),
                        )
                        ]
                      ),
                            const SizedBox(height: 30,),
                            Row(
                                children: [
                                  const Icon(Icons.phone, color: kiconColor,),
                                  const SizedBox(width: 20,),
                                  Container(
                                    width: screenWidth*0.2,
                                    child: const Text(
                                      "Phone Number ",
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
                                      "0"+widget.mobile.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black26,
                                          fontFamily: "OpenSans"),
                                      maxLines: 3,
                                    ),
                                  )
                                ]
                            ),
                            const SizedBox(height: 30,),
                            Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: kiconColor,),
                                  const SizedBox(width: 20,),
                                  Container(
                                    width: screenWidth*0.2,
                                    child: const Text(
                                      "Start Date ",
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
                                      s_date,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black26,
                                          fontFamily: "OpenSans"),
                                      maxLines: 3,
                                    ),
                                  )
                                ]
                            ),
                            
                            const SizedBox(height: 30,),
                            
                            Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: kiconColor,),
                                  const SizedBox(width: 20,),
                                  Container(
                                    width: screenWidth*0.2,
                                    child: const Text(
                                      "End Date ",
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
                                      e_date,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black26,
                                          fontFamily: "OpenSans"),
                                      maxLines: 3,
                                    ),
                                  )
                                ]
                            ),
                            
                            const SizedBox(height: 30,),
                            
                            // (widget.userType.toString() == "admin")?
                            
                            // const SizedBox(height: 10,)
                            //     : 
                            //   Row(
                            //     children: [
                            //       const Icon(Icons.location_history, color: kiconColor,),
                            //       const SizedBox(width: 20,),
                            //       Container(
                            //         width: screenWidth*0.2,
                            //         child: const Text(
                            //           "Client ",
                            //           style: TextStyle(
                            //               fontWeight: FontWeight.w600,
                            //               fontSize: 15,
                            //               color: kiconColor,
                            //               fontFamily: "OpenSans"),
                            //         ),
                            //       ),
                            //       Container(
                            //         width: 10,
                            //         child: const Text(
                            //           ":",
                            //           style: TextStyle(
                            //               fontWeight: FontWeight.w600,
                            //               fontSize: 15,
                            //               color: kiconColor,
                            //               fontFamily: "OpenSans"),
                            //         ),
                            //       ),
                            //       Expanded(
                            //         child: Text(
                            //           widget.suburbs.toString(),
                            //           style: const TextStyle(
                            //               fontWeight: FontWeight.w600,
                            //               fontSize: 15,
                            //               color: Colors.black26,
                            //               fontFamily: "OpenSans"),
                            //           maxLines: 3,
                            //         ),
                            //       )
                            //     ]
                            // ),

            ]
                )
                      ),
                      const SizedBox(height: 30,),
                      (loginUserData['userType']== "admin")?
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                          builder: (context) => UserEdit(
                                            userid: widget.id.toString(), 
                                            fname: widget.f_Name.toString(), 
                                            ename: widget.l_Name.toString(), 
                                            emailAdd: widget.emailAdd.toString(), 
                                            end_day: e_date, 
                                            mobile: widget.mobile.toString(), 
                                            suburbs: widget.suburbs.toString(),
                                            siteId: widget.siteId.toString(),
                                            image: widget.image.toString(), 
                                            document: widget.doc.toString(),
                                            type: widget.userType.toString(), 
                                            start_day: s_date,
                                            empNo : widget.empNo,
                                          )
                                      )
                                    );
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
                                onPressed: () async{
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Are you sure you want to delete ${widget.f_Name} ${widget.l_Name}?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('OK', style: TextStyle(color: Colors.blue),),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                await deleteUser();
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Cancel', style: TextStyle(color: Colors.blue),),
                                              onPressed: () async {
                                                Navigator.of(context).pop();
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
                          : (loginUserData['userType']== "admin")?
                              Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                          builder: (context) => UserEdit(userid: widget.id.toString(), fname: widget.f_Name.toString(), ename: widget.l_Name.toString(),  emailAdd: widget.emailAdd.toString(), mobile: widget.mobile.toString(),siteId: widget.siteId.toString(), suburbs: widget.suburbs.toString(), image: widget.image.toString(), type: widget.userType.toString(), start_day: s_date, end_day: e_date,empNo : widget.empNo, document: widget.doc.toString(),)));

                                },
                              ),
                            ),
                          ],
                        ),
                      )
                                : const SizedBox(height: 10,)
                    ],
                  )
                  ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }
}

