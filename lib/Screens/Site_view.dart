import 'dart:async';
import 'dart:convert';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/site_list.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_edit.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:clean_connector/Screens/user_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import '../Constant/const_api.dart';
import '../Controller/authController.dart';
import '../components/bottom_bar.dart';
import 'edit_client.dart';
import 'login_screen.dart';
import 'package:flutter/material.dart';

class SiteView extends StatefulWidget {
  SiteView({ 
    required this.id,
    required this.userName,
    required this.emailAdd,
    required this.mobile,
    required this.suburbs,
    required this.attendance,
    required this.sunD,
    required this.monD,
    required this.tueD,
    required this.wedsD,
    required this.thuD,
    required this.friD,
    required this.satD,
  });
  String id;
  String? userName;
  String? emailAdd;
  String? mobile;
  String? suburbs;
  String? attendance;
  String? sunD;
  String? monD;
  String? tueD;
  String? wedsD;
  String? thuD;
  String? friD;
  String? satD;
  @override
  State<SiteView> createState() => _SiteViewState();
}
class _SiteViewState extends State<SiteView> {
  bool isSearching = false;
  bool isLoading = false;
  bool isEmptyList = false;
  bool isEmptyTempList = false;
  bool isEmptyUserList = false;
  bool isEmptyCleaners = false;
  String profilePic = '';
  String name = '';
  String email = '';
  String date = '';
  String searchValue = '';
  TextEditingController searchController = TextEditingController();
  List<Users> tempArray = [];
  List<String> idList = [];
  List<Users> fiteruserlist = [];

  Future<List<Users>> filterUsers() async {
    print("Getting filter users....");
    print(isSearching);
    try {
      final response = await Dio().get("${BASE_API2}user/getAllCleanerUsers",
          options: Options(
              headers: {"Authorization": loginUserData['accessToken']}));
      var data = response.data['result'];
      print("DATA: $data");
      if (response.statusCode == 200) {
        fiteruserlist = [];
        Set<int> uniqueEmpNos = Set<int>();
        for (Map i in data) {
          int empNo = i['emp_no'] == null ? '' : i['emp_no'];
          String fullName = i['f_name']+" "+i['l_name'];
          // Check if the empNo is not already added
          if (!uniqueEmpNos.contains(empNo)) {
            if (fullName.toString().toLowerCase().startsWith(
                searchValue.toLowerCase())) {
              Users users = Users(
                fname: i['f_name'] == null ? '' : i['f_name'],
                lname: i['l_name'] == null ? '' : i['l_name'],
                email: i['email'],
                id: i['user_id'] == null ? '' : i['user_id'],
                start_date: i['start_date'] == null ? '' : i['start_date'],
                end_date: i['end_date'] == null ? '' : i['end_date'],
                phone: i['phone'] == null ? '' : i['phone'],
                doc: (i['url'] == null) ? "No Document" : i['url'],
                image: (i['image'] == null) ? "No image" : i['image'],
                siteid: i['site_id'] == null ? '' : i['site_id'],
                allocationId: i['siteAllocateiD'] == null
                    ? ''
                    : i['siteAllocateiD'],
                emp_no: i['emp_no'] == null ? 0 : i['emp_no'],
                sitename: i['site_name'] == null ? '' : i['site_name'],
              );
              fiteruserlist.add(users);
              uniqueEmpNos.add(empNo);
            }
            }
          }
        if(fiteruserlist.isEmpty){
          isEmptyList = true;
        }
        print("!!!!!!!!!!!!!!!!!!!");
        print(fiteruserlist);
      }
      return fiteruserlist;
    }on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        print("Bad Error");
        print(e.response?.data["message"]);
        if (e.response?.data["message"] == "No cleaners found!"  ) {
          setState(() {
            isEmptyList= true;
          });
        }
      }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
    return fiteruserlist;
  }

  // Future<List<Users>> filterCleanersbySiteId() async {
  //   print("Getting filter users getCleanersbySiteId....${widget.id}");
  //   userList = [];
  //   try{
  //     final response = await Dio().get(
  //         "${BASE_API2}user/getCleanerUsersBySiteId/${widget.id}",
  //         options: Options(
  //             headers: {"Authorization": loginUserData['accessToken']}));
  //     var data = response.data['result'];
  //     print("DATA: $data");
  //     if (response.statusCode == 200) {
  //       tempArray = [];
  //       Set<int> uniqueEmpNos = Set<int>();
  //       for (Map i in data) {
  //         int empNo = i['emp_no'] == null ? '' : i['emp_no'];
  //
  //         // Check if the empNo is not already added
  //         if (!uniqueEmpNos.contains(empNo)) {
  //           if (i['f_name'].toString().toLowerCase().startsWith(
  //               searchValue.toLowerCase()) ||
  //               i['l_name'].toString().toLowerCase().startsWith(
  //                   searchValue.toLowerCase())) {
  //             Users users = Users(
  //               emp_no: i['emp_no'] == null ? '' : i['emp_no'],
  //               fname: i['f_name'] == null ? '' : i['f_name'],
  //               lname: i['l_name'] == null ? '' : i['l_name'],
  //               email: i['email'],
  //               id: i['user_id'] == null ? '' : i['user_id'],
  //               start_date: i['start_date'] == null ? '' : i['start_date'],
  //               end_date: i['end_date'] == null ? '' : i['end_date'],
  //               phone: i['phone'] == null ? '' : i['phone'],
  //               doc: (i['url'] == null) ? "No Document" : i['url'],
  //               image: (i['image'] == null) ? "No image" : i['image'],
  //               siteid: i['site_id'] == null ? '' : i['site_id'],
  //               sitename: i['site_name'] == null ? '' : i['site_name'],
  //             );
  //             tempArray.add(users);
  //             uniqueEmpNos.add(empNo);
  //             idList.add(i['user_id']);
  //           }
  //         }
  //       }
  //       if(tempArray.isEmpty){
  //         isEmptyList = true;
  //       }
  //       print("-------------------->>>>>>>>>>>>>>");
  //       print(tempArray.length);
  //     }
  //     return tempArray;
  //   }on DioException catch (e) {
  //     if (e.response?.statusCode == 400) {
  //       print("Bad Error");
  //       print(e.response?.data["message"]);
  //       if (e.response?.data["message"] == "No cleaners found!"  ) {
  //         setState(() {
  //           isEmptyList= true;
  //         });
  //       }
  //     }
  //     print(e.toString());
  //     setState(() {
  //       isLoading = false;
  //     });
  //     print(e);
  //   }
  //   return userList;
  // }

  Future<List<Users>> getUsers() async {
    print("Getting users....");
    print(isSearching);
    userList = [];
   try {
      final response = await Dio().get("${BASE_API2}user/getAllCleanerUsers",
          options: Options(
              headers: {"Authorization": loginUserData['accessToken']}));
      var data = response.data['result'];
      print("DATA: $data");
      if (response.statusCode == 200) {
        userList = [];
        Set<int> uniqueEmpNos = Set<int>();
        for (Map i in data) {
          int empNo = i['emp_no'] == null ? '' : i['emp_no'];

          // Check if the empNo is not already added
          if (!uniqueEmpNos.contains(empNo)) {
            Users users = Users(
              fname: i['f_name'] == null ? '' : i['f_name'],
              lname: i['l_name'] == null ? '' : i['l_name'],
              email: i['email'],
              id: i['user_id'] == null ? '' : i['user_id'],
              start_date: i['start_date'] == null ? '' : i['start_date'],
              end_date: i['end_date'] == null ? '' : i['end_date'],
              phone: i['phone'] == null ? '' : i['phone'],
              doc: (i['url'] == null) ? "No Document" : i['url'],
              image: (i['image'] == null) ? "No image" : i['image'],
              siteid: i['site_id'] == null ? '' : i['site_id'],
              allocationId: i['siteAllocateiD'] == null
                  ? ''
                  : i['siteAllocateiD'],
              emp_no: i['emp_no'] == null ? 0 : i['emp_no'],
              sitename: i['site_name'] == null ? '' : i['site_name'],
            );
            userList.add(users);
            uniqueEmpNos.add(empNo);
          }
        }
        print("!!!!!!!!!!!!!!!!!!!");
        print(userList);
      }
      return userList;
    }on DioException catch (e) {
     if (e.response?.statusCode == 400) {
       print("Bad Error");
       print(e.response?.data["message"]);
       if (e.response?.data["message"] == "No cleaners found!"  ) {
         setState(() {
           isEmptyList= true;
         });
       }
     }
     print(e.toString());
     setState(() {
       isLoading = false;
     });
     print(e);
   }
   return userList;
  }

  Future<List<Users>> getCleanersbySiteId() async {
    print("Getting users getCleanersbySiteId....${widget.id}");
    userList = [];
    try{
      final response = await Dio().get(
          "${BASE_API2}user/getCleanerUsersBySiteId/${widget.id}",
          options: Options(
              headers: {"Authorization": loginUserData['accessToken']}));
      var data = response.data['result'];
      print("DATA: $data");
      if (response.statusCode == 200) {
        tempArray = [];
        Set<int> uniqueEmpNos = Set<int>();
        for (Map i in data) {
          int empNo = i['emp_no'] == null ? '' : i['emp_no'];

          // Check if the empNo is not already added
          if (!uniqueEmpNos.contains(empNo)) {
            Users users = Users(
              emp_no: i['emp_no'] == null ? '' : i['emp_no'],
              fname: i['f_name'] == null ? '' : i['f_name'],
              lname: i['l_name'] == null ? '' : i['l_name'],
              email: i['email'],
              id: i['user_id'] == null ? '' : i['user_id'],
              start_date: i['start_date'] == null ? '' : i['start_date'],
              end_date: i['end_date'] == null ? '' : i['end_date'],
              phone: i['phone'] == null ? '' : i['phone'],
              doc: (i['url'] == null) ? "No Document" : i['url'],
              image: (i['image'] == null) ? "No image" : i['image'],
              siteid: i['site_id'] == null ? '' : i['site_id'],
              sitename: i['site_name'] == null ? '' : i['site_name'],
            );
            tempArray.add(users);
            idList.add(i['user_id']);
            uniqueEmpNos.add(empNo);
            if(tempArray.isEmpty){
              setState(() {
                isEmptyCleaners = true;
              });
            }
          }
        }
        print("------------------>>>>>>>>>>>>>>");
        print(tempArray.length);
      }
      return tempArray;
    }on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        print("Bad Error");
        print(e.response?.data["message"]);
        if (e.response?.data["message"] == "No cleaners found!"  ) {
          setState(() {
            isEmptyTempList= true;
          });
        }
      }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
    return userList;
  }

  Future deleteClient() async {
    setState(() {
      isLoading = true;
    });
    try {
      print(widget.id);
      print(widget.emailAdd);
      final response =
      await Dio().delete(BASE_API2 + "site/delete/${widget.id}",
          options: Options(headers: {
            "Authorization": "Bearer "+ loginUserData["accessToken"]
          }));
      print(" Delete user response: $response");
      if(response.statusCode == 200 && response.data['message'] == "Site Deleted Successfully"){
        showDialogMsg(context, "Success", "Client Delete Successfully",
          TextButton(
            onPressed: (){
            Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (BuildContext context) => const SiteList(),
            ),
                (Route route) => false,
          );},
            child: Text(
            "OK",
            style: TextStyle(
              fontSize: 18,
              color: kiconColor,
              fontFamily: 'brandon-grotesque',
              fontWeight: FontWeight.w400,
            ),
          ),)
        );
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
        }else if(e.response?.data["message"]=="No any registered user for this email"){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("No any registered user for this email"),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.only(
                bottom: MediaQuery
                    .of(context)
                    .size
                    .height - 100,
                right: 5,
                left: 5),
          ));
        }
      }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  Future assignCleaner(String? siteId, String userId) async {
    setState(() {
      isLoading = true;
    });
    print("__________> ${userId}");
    print("__________> ${siteId}");
    try {
      final response =
      await Dio().put(BASE_API2 + "user/assignCleaner", options: Options(headers: {
        "Authorization": "Bearer "+ loginUserData["accessToken"]
      }), data: {
        "site": siteId,
        "id": userId
      }, );
      print(" User update response: $response");
      setState(() {
        isLoading = false;
      });
      if(response.statusCode == 200 && response.data['message'] == "Assigned Successfully."){
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => SiteView(id: widget.id, userName: widget.userName, emailAdd: widget.emailAdd, mobile: widget.mobile, suburbs: widget.suburbs, attendance: widget.attendance,
              sunD: widget.sunD, monD: widget.monD, tueD: widget.tueD, wedsD: widget.wedsD, thuD: widget.thuD, friD: widget.friD, satD: widget.satD, ),
          ),
              (Route route) => false,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future unassignCleaner(String siteId, String userId, allocationId) async {
    setState(() {
      isLoading = true;
    });
    print("__________> ${userId}");
    print("__________> ${siteId}");
    try {
      final response =
      await Dio().delete(BASE_API2 + "user/assignCleaner/$allocationId", options: Options(headers: {
        "Authorization": "Bearer "+ loginUserData["accessToken"]
      }), data: {
        "site": siteId,
        "id": userId
      }, );
      print(" User update response: $response");
      setState(() {
        isLoading = false;
      });
      if(response.statusCode == 200 && response.data['message'] == "Unassigned Successfully."){
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => SiteView(id: widget.id, userName: widget.userName, emailAdd: widget.emailAdd, mobile: widget.mobile, suburbs: widget.suburbs, attendance: widget.attendance,
              sunD: widget.sunD, monD: widget.monD, tueD: widget.tueD, wedsD: widget.wedsD, thuD: widget.thuD, friD: widget.friD, satD: widget.satD, ),
          ),
              (Route route) => false,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    loading();
    print("******************");
    print(tempArray.length);
  }

  loading() async{
    await getCleanersbySiteId();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          image = null;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SiteList()),
                (Route<dynamic> route) => false,
          );
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title:  Text((loginUserData['userType']!= "admin")? "MY SITE" : "ALLOCATE CLEANERS", style: kboldTitle,),
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
                      // CircleAvatar(
                      //   radius: screenWidth/8.5,
                      //   backgroundColor: kcardBackgroundColor,
                      //   child: CircleAvatar(
                      //     radius: screenWidth/9,
                      //     backgroundColor: Colors.white,
                      //     backgroundImage: NetworkImage(widget.image.toString()),
                      //   ),
                      // ),
                      const SizedBox(height: 15,),
                      Text(
                        widget.userName.toString(),
                        style: kTitle,
                      ),
                      const SizedBox(height: 15,),
                      Text(
                        widget.suburbs.toString(),
                        style: kSubTitle
                      ),
                      const SizedBox(height: 15,),
                      // Text(
                      //     "Admin: ${widget.userName}",
                      //     // widget.stieAddress.toString(),
                      //     style: kSubTitle
                      // ),
                      // const SizedBox(height: 15,),
                      Text(
                          widget.emailAdd.toString(),
                          // widget.stieAddress.toString(),
                          style: kSubTitle
                      ),
                    ],
                  ),
                ),
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
                                    builder: (context) => EditClient(id: widget.id, emailAdd: widget.emailAdd, client: widget.userName, phone: widget.mobile, site: widget.suburbs, attendance: widget.attendance,
                                      sunD: widget.sunD, monD: widget.monD, tueD: widget.tueD, wedsD: widget.wedsD, thuD: widget.thuD, friD: widget.friD, satD: widget.satD,
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
                          onPressed: () async{
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Are you sure you want to delete ${widget.userName}?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('OK', style: TextStyle(color: Colors.blue),),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          await deleteClient();
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
                            // showDialogMsg(context,
                            //   "Delete Client ?",
                            //   "Are you sure you want to delete ${widget.userName} ?",
                            //   Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       TextButton(
                            //       child: Text('OK'),
                            //       onPressed: () async{
                            //         Navigator.of(context).pop();
                            //         await deleteClient();
                            //       },
                            // ),
                            //       TextButton(
                            //         child: Text('Cancel'),
                            //         onPressed: () {
                            //           Navigator.of(context).pop(); // Close the dialog
                            //         },
                            //       ),
                            //     ],
                            //   ),);
                            // showDialog(
                            //     context: context,
                            //     builder: (BuildContext context) {
                            //       return CupertinoAlertDialog(
                            //         title: Text(
                            //           'Are you sure you want to delete ${widget.userName}?',
                            //           style: const TextStyle(
                            //             fontSize: 22,
                            //             color: Colors.black,
                            //             fontWeight: FontWeight.w400,
                            //           ),
                            //         ),
                            //         actions: [
                            //           CupertinoDialogAction(
                            //             child: const Text(
                            //               "OK",
                            //               style: TextStyle(
                            //                 fontSize: 18,
                            //                 color: kiconColor,
                            //                 fontFamily: 'brandon-grotesque',
                            //                 fontWeight: FontWeight.w400,
                            //               ),
                            //             ),
                            //             onPressed: () async {
                            //               Navigator.of(context).pop();
                            //               await deleteClient();
                            //             },),
                            //           CupertinoDialogAction(
                            //             child: const Text(
                            //               "Cancel",
                            //               style: TextStyle(
                            //                 fontSize: 18,
                            //                 color: kiconColor,
                            //                 fontFamily: 'brandon-grotesque',
                            //                 fontWeight: FontWeight.w400,
                            //               ),
                            //             ),
                            //             onPressed: () {
                            //               Navigator.of(context).pop();
                            //             },),
                            //         ],
                            //       );
                            //     });
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
                                    builder: (context) => EditClient(id: widget.id, emailAdd: widget.emailAdd, client: widget.userName, phone: widget.mobile, site: widget.suburbs, attendance: widget.attendance,
                                        sunD: widget.sunD, monD: widget.monD, tueD: widget.tueD, wedsD: widget.wedsD, thuD: widget.thuD, friD: widget.friD, satD: widget.satD,)));
                          },
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                      color: kcardBackgroundColor,
                      borderRadius: BorderRadius.circular(50)
                  ),
                  width: screenWidth,
                  height: 3,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    //horizontal: 20 * screenWidth / kWidth,
                    vertical: 10 * screenWidth / kWidth,
                  ),
                  child: Container(
                    height: 40, // Set your desired height here
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          20), // Set your desired border radius here
                      border:
                      Border.all(color: kiconColor), // Add a border color
                      color: Colors.grey[300]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 4.0), // Adjust spacing as needed
                          child: Icon(
                            Icons.search,
                            color: kiconColor,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: (value) {
                              setState(() {
                                isSearching = true;
                                searchValue = value.toString();
                              });
                              //filterUsers(value); // Call filterUsers function
                            },
                            decoration: InputDecoration(
                              hintText: "Search Cleaners",
                              hintStyle: TextStyle(fontSize: 15),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loginUserData['userType'] == "admin" && tempArray.isNotEmpty ?
                Container(
                  height: 180,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10 * screenWidth / kWidth,),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        alignment: WrapAlignment.start,
                        children: tempArray.map((e) {
                          return Card(
                            elevation: 3,
                            color: kiconColor,
                            child: Container(
                              height: 30,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(e.fname +" " + e.lname, style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),),
                                    // IconButton(
                                    //     onPressed: (){
                                    //       setState(() {
                                    //         unassignCleaner(widget.id.toString(), e.id.toString(), e.allocationId.toString());
                                    //         print(tempArray.toString());
                                    //       });
                                    //     },
                                    //     icon: Icon(Icons.close_outlined, color: Colors.white,
                                    //     size: 15,))
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ),
                ) : SizedBox(),
                loginUserData['userType'] == "cleaner" ?
                Expanded(
                  child: FutureBuilder(
                    future: getCleanersbySiteId(),
                      // isEmptyList = true ? Text("no data") :
                      builder: (context, AsyncSnapshot<List<Users>> snapshot) {
                      return tempArray.isNotEmpty ? ListView.builder(
                          itemCount: tempArray.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                //horizontal: 10 * screenWidth / kWidth,
                                  vertical: 2 * screenHeight / kHeight),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  //horizontal: 10 * screenWidth / kWidth,
                                    vertical: 5 * screenHeight / kHeight),
                                decoration: BoxDecoration(
                                    color: kcardBackgroundColor,
                                    // boxShadow: [
                                    //   const BoxShadow(
                                    //     color: Colors.black12,
                                    //     offset: Offset(1, 0.5),
                                    //     blurRadius: 2,
                                    //   )
                                    // ],
                                    // border: Border.all(width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10)),
                                width: screenWidth,
                                child: InkWell(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: kiconColor,
                                      child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.white,
                                          backgroundImage: NetworkImage(snapshot.data![index].image.toString(),)
                                      ),
                                    ),
                                    title: Padding(
                                      padding:
                                      const EdgeInsets.only(left: 10.0,),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              snapshot.data![index].fname.toString() + " " + snapshot.data![index].lname.toString(),
                                              style: klistTitle),
                                        ],
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(left: 10.0,),
                                      child: Text(
                                          "Employee No: " +snapshot.data![index].emp_no.toString(),
                                          style: klistTitle
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          })
                          : (isEmptyList==true)?
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 50.0),
                        child: Text("No cleaners to preview"),
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
                : Expanded(
                  child: FutureBuilder(
                    future: (isSearching == true)? filterUsers() :getUsers(),
                    builder: (context, AsyncSnapshot<List<Users>> snapshot) {
                      return (isSearching == true && fiteruserlist.isNotEmpty) ?
                      ListView.builder(
                          itemCount: fiteruserlist.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  //horizontal: 10 * screenWidth / kWidth,
                                  vertical: 2 * screenHeight / kHeight),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    //horizontal: 10 * screenWidth / kWidth,
                                    vertical: 5 * screenHeight / kHeight),
                                decoration: BoxDecoration(
                                    color: kcardBackgroundColor,
                                    // boxShadow: [
                                    //   const BoxShadow(
                                    //     color: Colors.black12,
                                    //     offset: Offset(1, 0.5),
                                    //     blurRadius: 2,
                                    //   )
                                    // ],
                                    // border: Border.all(width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10)),
                                width: screenWidth,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if(tempArray.contains(snapshot.data![index].fname.toString())){
                                        tempArray.remove(snapshot.data![index].fname.toString());
                                      }else{
                                        setState(() {
                                          isEmptyUserList= true;
                                        });
                                      }
                                      print("My Value");
                                      print(tempArray.toString());
                                    });
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => UserView(id: snapshot.data![index].id.toString(), userName: snapshot.data![index].name.toString(), emailAdd: snapshot.data![index].email.toString(), birthDay: snapshot.data![index].dob.toString(), mobile: snapshot.data![index].phone.toString(), suburbs: snapshot.data![index].suburb.toString(), image: snapshot.data![index].image.toString(), userType: snapshot.data![index].type.toString(),)));
                                  },
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: kiconColor,
                                      child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.white,
                                          backgroundImage: NetworkImage(snapshot.data![index].image.toString(),)
                                      ),
                                    ),
                                    title: Padding(
                                      padding:
                                      const EdgeInsets.only(left: 10.0,),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              snapshot.data![index].fname.toString() + " " + snapshot.data![index].lname.toString(),
                                              style: klistTitle),
                                        ],
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(left: 10.0,),
                                      child: Text(
                                          "Employee No: " +snapshot.data![index].emp_no.toString(),
                                          style: klistTitle
                                      ),
                                    ),

                                    trailing: (loginUserData['userType'] != "client")?
                                    GestureDetector(
                                      onTap: ()  {
                                        idList.contains(snapshot.data![index].id.toString())?
                                        unassignCleaner(widget.id.toString(), snapshot.data![index].id.toString(), snapshot.data![index].allocationId.toString())
                                          : assignCleaner(widget.id.toString(), snapshot.data![index].id.toString());
                                      },
                                      child: Container(
                                        width: 70,
                                        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                        decoration: BoxDecoration(
                                            color: idList.contains(snapshot.data![index].id.toString())? Colors.red : kiconColor,
                                            borderRadius: BorderRadius.circular(5)
                                        ),
                                        child: Text(
                                            idList.contains(snapshot.data![index].id.toString())? "Remove" : "Add",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold
                                            )),
                                      ),
                                    )
                                        : SizedBox()
                                  ),
                                ),
                              ),
                            );
                          })
                      :(isSearching == false && userList.isNotEmpty) ?
                      ListView.builder(
                          itemCount: userList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                //horizontal: 10 * screenWidth / kWidth,
                                  vertical: 2 * screenHeight / kHeight),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  //horizontal: 10 * screenWidth / kWidth,
                                    vertical: 5 * screenHeight / kHeight),
                                decoration: BoxDecoration(
                                    color: kcardBackgroundColor,
                                    // boxShadow: [
                                    //   const BoxShadow(
                                    //     color: Colors.black12,
                                    //     offset: Offset(1, 0.5),
                                    //     blurRadius: 2,
                                    //   )
                                    // ],
                                    // border: Border.all(width: 1, color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10)),
                                width: screenWidth,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if(tempArray.contains(snapshot.data![index].fname.toString())){
                                        tempArray.remove(snapshot.data![index].fname.toString());
                                      }else{
                                        setState(() {
                                          isEmptyUserList= true;
                                        });
                                      }
                                      print("My Value");
                                      print(tempArray.toString());
                                    });
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => UserView(id: snapshot.data![index].id.toString(), userName: snapshot.data![index].name.toString(), emailAdd: snapshot.data![index].email.toString(), birthDay: snapshot.data![index].dob.toString(), mobile: snapshot.data![index].phone.toString(), suburbs: snapshot.data![index].suburb.toString(), image: snapshot.data![index].image.toString(), userType: snapshot.data![index].type.toString(),)));
                                  },
                                  child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: kiconColor,
                                        child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(snapshot.data![index].image.toString(),)
                                        ),
                                      ),
                                      title: Padding(
                                        padding:
                                        const EdgeInsets.only(left: 10.0,),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                snapshot.data![index].fname.toString() + " " + snapshot.data![index].lname.toString(),
                                                style: klistTitle),
                                          ],
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(left: 10.0,),
                                        child: Text(
                                            "Employee No: " +snapshot.data![index].emp_no.toString(),
                                            style: klistTitle
                                        ),
                                      ),

                                      trailing: (loginUserData['userType'] != "client")?
                                      GestureDetector(
                                        onTap: ()  {
                                          idList.contains(snapshot.data![index].id.toString())?
                                          unassignCleaner(widget.id.toString(), snapshot.data![index].id.toString(), snapshot.data![index].allocationId.toString())
                                              : assignCleaner(widget.id.toString(), snapshot.data![index].id.toString());
                                        },
                                        child: Container(
                                          width: 70,
                                          padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                          decoration: BoxDecoration(
                                              color: idList.contains(snapshot.data![index].id.toString())? Colors.red : kiconColor,
                                              borderRadius: BorderRadius.circular(5)
                                          ),
                                          child: Text(
                                              idList.contains(snapshot.data![index].id.toString())? "Remove" : "Add",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold
                                              )),
                                        ),
                                      )
                                          : SizedBox()
                                  ),
                                ),
                              ),
                            );
                          })
                          : (isSearching == true && isEmptyList==true || isSearching == false && isEmptyList==true)?
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 50.0),
                        child: Text("No cleaners to preview"),
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
                ),
              ],
            ),
          ),
          bottomNavigationBar: const BottomNavBar(),
        ),
      ),
    );
  }
}

void showDialogMsg(BuildContext context, String message, String content, Widget actionWidget) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(message),
        content: Text(content),
        actions: <Widget>[
          actionWidget
        ],
      );
    },
  );
}