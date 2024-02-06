// import 'dart:async';
// import 'dart:convert';
// import 'package:clean_connector/Constant/style.dart';
// import 'package:clean_connector/Screens/task_list.dart';
// import 'package:clean_connector/Screens/user_edit.dart';
// import 'package:clean_connector/Screens/user_list.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:intl/intl.dart';
// import '../Constant/const_api.dart';
// import '../Controller/authController.dart';
// import '../components/bottom_bar.dart';
// import 'login_screen.dart';
// import 'package:flutter/material.dart';
//
// class UserProfileView extends StatefulWidget {
//   UserProfileView({
//     required this.id,
//     required this.userName,
//     required this.emailAdd,
//     required this.birthDay,
//     required this.mobile,
//     required this.suburbs,
//     required this.image,
//     required this.userType
//   });
//   String? id;
//   String? userName;
//   String? emailAdd;
//   String? birthDay;
//   String? mobile;
//   String? suburbs;
//   String? image;
//   String? userType;
//   @override
//   State<UserProfileView> createState() => _UserProfileViewState();
// }
// class _UserProfileViewState extends State<UserProfileView> {
//   bool isLoading = false;
//   String profilePic = '';
//   String name = '';
//   String email = '';
//   String date = '';
//
//
//   @override
//   void initState() {
//     if(widget.birthDay!=null){
//       DateTime dofb = new DateFormat("yyyy-MM-dd").parse(widget.birthDay.toString());
//       print(dofb);
//       setState(() {
//         date = DateFormat("yyyy-MM-dd").format(dofb);
//       });
//     }else{
//       date= DateFormat("yyyy-MM-dd").format(DateTime.now());
//     }
//
//     // Get.closeAllSnackbars;
//     super.initState();
//     isLoading = true;
//     loading();
//     print("???????????????????: $profilePic");
//   }
//
//   loading() async {
//     // await getImage();
//     // await getAllUsers();
//     //await deleteUser();
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   Future deleteUser() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       print(loginUserProfile['id']);
//       print(widget.emailAdd);
//       final response =
//       await Dio().delete(BASE_API + "users/${widget.id}",
//           options: Options(headers: {
//             "Authorization": "Bearer "+ loginUserData["accessToken"]
//           }));
//       print(" Delete user response: $response");
//       if(response.statusCode == 200 && response.data['message'] == "Delete Successfully"){
//         print("Delete Successfully");
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(
//             builder: (BuildContext context) => UserList(),
//           ),
//               (Route route) => false,
//         );
//       }
//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         resizeToAvoidBottomInset: false,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           centerTitle: true,
//           title: Text("USER INFORMATION", style: kboldTitle,),
//           backgroundColor: Colors.white,
//           actions: <Widget>[
//             Padding(
//                 padding: const EdgeInsets.only(right: 30.0),
//                 child: GestureDetector(
//                     onTap: () async {
//                       setState(() {
//                         AuthController.logOut(context);
//                       });
//                     },
//                     child: CircleAvatar(
//                       radius: 18,
//                       backgroundColor: kiconColor,
//                       child: CircleAvatar(
//                         radius: 17,
//                         backgroundColor: Colors.white,
//                         child: Icon(
//                           Icons.logout,
//                           color: kiconColor,
//                         ),
//                       ),
//                     ))),
//           ],
//         ),
//         body: Padding(
//           padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
//           child: Column(
//             children: [
//               Container(
//                 height: screenHeight*0.2,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircleAvatar(
//                       radius: screenWidth/8.5,
//                       backgroundColor: kcardBackgroundColor,
//                       child: CircleAvatar(
//                         radius: screenWidth/9,
//                         backgroundColor: Colors.white,
//                         backgroundImage: NetworkImage(widget.image.toString()),
//                       ),
//                     ),
//                     const SizedBox(height: 15,),
//                     Text(
//                       widget.userName.toString(),
//                       style: kTitle,
//                     ),
//                     // const SizedBox(height: 15,),
//                     // Text(
//                     //   widget.emailAdd.toString(),
//                     //   style: kTitle
//                     // ),
//                   ],
//                 ),
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                     color: kcardBackgroundColor,
//                     borderRadius: BorderRadius.circular(50)
//                 ),
//                 width: screenWidth,
//                 height: 3,
//               ),
//               Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Padding(
//                           padding: EdgeInsets.only(top: 30),
//                           child: Column(
//                               children: [
//                                 Row(
//                                     children: [
//                                       Icon(Icons.person, color: kiconColor,),
//                                       SizedBox(width: 20,),
//                                       Container(
//                                         width: screenWidth*0.2,
//                                         child: const Text(
//                                           "User Name ",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: kiconColor,
//                                               fontFamily: "OpenSans"),
//                                         ),
//                                       ),
//                                       Container(
//                                         width: 10,
//                                         child: const Text(
//                                           ":",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: kiconColor,
//                                               fontFamily: "OpenSans"),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Text(
//                                           widget.userName.toString(),
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: Colors.black26,
//                                               fontFamily: "OpenSans"),
//                                           maxLines: 3,
//                                         ),
//                                       )
//                                     ]
//                                 ),
//                                 SizedBox(height: 30,),
//                                 Row(
//                                     children: [
//                                       Icon(Icons.email_outlined, color: kiconColor,),
//                                       SizedBox(width: 20,),
//                                       Container(
//                                         width: screenWidth*0.2,
//                                         child: const Text(
//                                           "Email Address ",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: kiconColor,
//                                               fontFamily: "OpenSans"),
//                                         ),
//                                       ),
//                                       Container(
//                                         width: 10,
//                                         child: const Text(
//                                           ":",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: kiconColor,
//                                               fontFamily: "OpenSans"),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Text(
//                                           widget.emailAdd.toString(),
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: Colors.black26,
//                                               fontFamily: "OpenSans"),
//                                           maxLines: 3,
//                                         ),
//                                       )
//                                     ]
//                                 ),
//                                 SizedBox(height: 30,),
//                                 Row(
//                                     children: [
//                                       Icon(Icons.calendar_month, color: kiconColor,),
//                                       SizedBox(width: 20,),
//                                       Container(
//                                         width: screenWidth*0.2,
//                                         child: const Text(
//                                           "Date of Birth ",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: kiconColor,
//                                               fontFamily: "OpenSans"),
//                                         ),
//                                       ),
//                                       Container(
//                                         width: 10,
//                                         child: const Text(
//                                           ":",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: kiconColor,
//                                               fontFamily: "OpenSans"),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Text(
//                                           date,
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: Colors.black26,
//                                               fontFamily: "OpenSans"),
//                                           maxLines: 3,
//                                         ),
//                                       )
//                                     ]
//                                 ),
//                                 SizedBox(height: 30,),
//                                 Row(
//                                     children: [
//                                       Icon(Icons.phone, color: kiconColor,),
//                                       SizedBox(width: 20,),
//                                       Container(
//                                         width: screenWidth*0.2,
//                                         child: const Text(
//                                           "Phone Number ",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: kiconColor,
//                                               fontFamily: "OpenSans"),
//                                         ),
//                                       ),
//                                       Container(
//                                         width: 10,
//                                         child: const Text(
//                                           ":",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: kiconColor,
//                                               fontFamily: "OpenSans"),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Text(
//                                           widget.mobile.toString(),
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: Colors.black26,
//                                               fontFamily: "OpenSans"),
//                                           maxLines: 3,
//                                         ),
//                                       )
//                                     ]
//                                 ),
//                                 SizedBox(height: 30,),
//                                 (loginUserData['userType']== "admin") ?
//                                 SizedBox(height: 10,)
//                                     : Row(
//                                     children: [
//                                       Icon(Icons.location_history, color: kiconColor,),
//                                       SizedBox(width: 20,),
//                                       Container(
//                                         width: screenWidth*0.2,
//                                         child: const Text(
//                                           "Suburb ",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: kiconColor,
//                                               fontFamily: "OpenSans"),
//                                         ),
//                                       ),
//                                       Container(
//                                         width: 10,
//                                         child: const Text(
//                                           ":",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: kiconColor,
//                                               fontFamily: "OpenSans"),
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: Text(
//                                           widget.suburbs.toString(),
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600,
//                                               fontSize: 15,
//                                               color: Colors.black26,
//                                               fontFamily: "OpenSans"),
//                                           maxLines: 3,
//                                         ),
//                                       )
//                                     ]
//                                 ),
//
//                               ]
//                           )
//                       ),
//                       (loginUserData['userType']== "admin" && loginUserData['adminType']== "super")?
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 20.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: kiconColor,
//                               ),
//                               child: IconButton(
//                                 icon: Icon(
//                                   Icons.edit,
//                                   color: Colors.white,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => UserEdit(userid: widget.id.toString(), username: widget.userName.toString(), emailAdd: widget.emailAdd.toString(), birthDay: date, mobile: widget.mobile.toString(), suburbs: widget.suburbs.toString(), image: widget.image.toString(), type: widget.userType.toString(),)));
//                                 },
//                               ),
//                             ),
//                             Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: kiconColor,
//                               ),
//                               child: IconButton(
//                                 icon: Icon(
//                                   Icons.delete,
//                                   color: Colors.white,
//                                 ),
//                                 onPressed: () async{
//                                   await deleteUser();
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                           : (loginUserData['userType']== "admin")?
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 20.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             Container(
//                               width: 40,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: kiconColor,
//                               ),
//                               child: IconButton(
//                                 icon: Icon(
//                                   Icons.edit,
//                                   color: Colors.white,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => UserEdit(userid: widget.id.toString(), username: widget.userName.toString(), emailAdd: widget.emailAdd.toString(), birthDay: date, mobile: widget.mobile.toString(), suburbs: widget.suburbs.toString(), image: widget.image.toString(), type: widget.userType.toString(),)));
//
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                           : SizedBox(height: 10,)
//                     ],
//                   )
//               ),
//             ],
//           ),
//         ),
//         bottomNavigationBar: BottomNavBar(),
//       ),
//     );
//   }
// }
//
