// import 'package:clean_connector/Constant/style.dart';
// import 'package:clean_connector/components/bottom_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
//
// import 'create_task.dart';
//
// class ViewTaskScreen extends StatelessWidget {
//   const ViewTaskScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: kbackgroundColor,
//       body: SafeArea(
//         child: Container(
//           child: Column(
//             children: [
//               Container(
//                // height: 90,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 2,
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 20 * screenWidth / kWidth,
//                         vertical: 20 * screenWidth / kWidth,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Spacer(),
//                           Text(
//                             'TASK LIST',
//                             style: kboldTitle,
//                           ),
//                           Spacer(),
//                           IconButton(
//                             icon: Icon(
//                               Icons.person,
//                               color: Color.fromARGB(255, 52, 137, 207),
//                             ),
//                             onPressed: () {
//                               Navigator.pop(context);
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               GestureDetector(
//                 onTap: (){
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => TaskCreate()));
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 20 * screenWidth / kWidth,
//                     vertical: 10 * screenWidth / kWidth,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Color.fromARGB(255, 52, 137, 207),
//                         ),
//                         child: IconButton(
//                           icon: Icon(
//                             Icons.add,
//                             color: Colors.white,
//                           ),
//                           onPressed: () {},
//                         ),
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Text('Create Task',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12,
//                               color: Color.fromARGB(255, 52, 137, 207))),
//                     ],
//                   ),
//                 ),
//               ),
//               //card list
//
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       //card list
//
//                       CategortListCard(
//                         taskNo: 'Task 01',
//                         title: 'Task Title',
//                         description: '',
//                         date: '',
//                         time: '',
//                       ),
//                       CategortListCard(
//                         taskNo: 'Task 02',
//                         title: 'Task Title',
//                         description: '',
//                         date: '',
//                         time: '',
//                       ),
//                       CategortListCard(
//                         taskNo: 'Task 03',
//                         title: 'Task Title',
//                         description: '',
//                         date: '',
//                         time: '',
//                       ),
//                       CategortListCard(
//                         taskNo: 'Task 04',
//                         title: 'Task Title',
//                         description: '',
//                         date: '',
//                         time: '',
//                       ),
//                       CategortListCard(
//                         taskNo: 'Task 05',
//                         title: 'Task Title',
//                         description: '',
//                         date: '',
//                         time: '',
//                       ),
//                       CategortListCard(
//                         taskNo: 'Task 06',
//                         title: 'Task Title',
//                         description: '',
//                         date: '',
//                         time: '',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: const BottomNavBar(),
//     );
//   }
// }
//
// //Single list card
// // ignore: must_be_immutable
// class CategortListCard extends StatelessWidget {
//   CategortListCard({
//     required this.taskNo,
//     required this.title,
//     required this.description,
//     required this.date,
//     required this.time,
//   });
//   String taskNo;
//   String title;
//   String description;
//   String date;
//   String time;
//
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Padding(
//       padding: EdgeInsets.symmetric(
//           horizontal: 10 * screenWidth / kWidth,
//           vertical: 5 * screenHeight / kHeight),
//       child: GestureDetector(
//         onTap: () {},
//         child: Container(
//           padding: EdgeInsets.symmetric(
//               horizontal: 10 * screenWidth / kWidth,
//               vertical: 10 * screenHeight / kHeight),
//           color: kcardBackgroundColor,
//           width: screenWidth,
//           child: Container(
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                         width: screenWidth * 0.6,
//                         child: Text(taskNo,
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               color: Color.fromARGB(255, 52, 137, 207),
//                             ))),
//                     Text(
//                       '20/03/2023',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 52, 137, 207),
//                       ),
//                     ),
//                     SizedBox(
//                         width: 5), // Add some spacing between date and time
//                     Text(
//                       '10:54',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 52, 137, 207),
//                       ),
//                     ),
//                     Spacer(
//                       flex: 1,
//                     ),
//                   ],
//                 ),
//                 Container(
//                   height: 1,
//                   color: Colors.grey, // Set the underline color here
//                 ),
//                 SizedBox(
//                   height: 20,
//                 ),
//                 Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         //color: Color.fromARGB(255, 52, 137, 207),
//                       ),
//                     )),
//                 SizedBox(
//                   height: 5,
//                 ),
//                 Align(
//                     alignment: Alignment.topLeft,
//                     child: Text(
//                       'Task Description',
//                       style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey),
//                     )),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
