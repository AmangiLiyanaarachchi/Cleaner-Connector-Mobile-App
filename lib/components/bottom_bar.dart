import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/Site_view.dart';
import 'package:clean_connector/Screens/setting.dart';
import 'package:clean_connector/Screens/site_list.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_list.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../Constant/const_api.dart';
import '../Screens/login_screen.dart';

bool istaskList = false;
bool isuserList = false;
bool settings = false;

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  List<Sites> siteList = [];
  bool isLoading = false;
  bool isEmptyList = false;
  void initState() {
    print("------->" + loginUserData['userType']);
    super.initState();
    if (loginUserData['userType'] == 'client') {
      getSitebyId();
    }
  }

  Future<List<Sites>> getSitebyId() async {
    print("Getting my site....");
    siteList = [];
    try {
      final response = await Dio().get(
          "${BASE_API2}site/get-sites/${loginUserData['id']}",
          options: Options(
              headers: {"Authorization": loginUserData['accessToken']}));
      // options: Options(headers: {
      //   "Authorization": loginUserData["token"]
      // }));
      var data = response.data['sites'];
      print("DATA: $data");
      if (response.statusCode == 200) {
        siteList = [];
        for (Map i in data) {
          Sites sites = Sites(
            site_id: (i['site_id'] == null) ? " " : i['site_id'],
            site_name: (i['site_name'] == null) ? " " : i['site_name'],
            site_address: (i['site_address'] == null) ? " " : i['site_address'],
            site_email: (i['site_email'] == null) ? " " : i['site_email'],
            mobile: (i['mobile'] == null) ? " " : i['mobile'],
            attendance: i['rate'].toDouble(),
            userData: (i['user_data'] == []) ? [] : [],
              sun: (i['sun'] == null) ? " " : i['sun'].toString(),
              mon: (i['mon'] == null) ? " " : i['mon'].toString(),
              tue: (i['tues'] == null) ? " " : i['tues'].toString(),
              wed: (i['wed'] == null) ? " " : i['wed'].toString(),
              thu: (i['thur'] == null) ? " " : i['thur'].toString(),
              fri: (i['fri'] == null) ? " " : i['fri'].toString(),
              sat: (i['satur'] == null) ? " " : i['satur'].toString()
          );
          siteList.add(sites);
        }
        print("!!!!!!!!!!!!!!!!!!!");
        print(siteList);
      }
      return siteList;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        print("Bad Error");
        print(e.response?.data["message"]);
        setState(() {
          isEmptyList = true;
        });
        return siteList;
      }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
      return siteList;
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Stack(
  //     children: [
  //       Container(
  //         height: 60,
  //         decoration: BoxDecoration(
  //             color: Colors.white, borderRadius: BorderRadius.circular(30)),
  //         padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //           children: [
  //             FloatingActionButton.small(
  //               elevation: 0,
  //               backgroundColor: Colors.white,
  //               foregroundColor: kbuttonColorPlain,
  //               onPressed: () {
  //                 Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => ViewTaskScreen()));
  //               },
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(Icons.list),
  //                   Text(
  //                     'Task List',
  //                     style: TextStyle(fontSize: 6),
  //                   ),
  //                 ],
  //               ),
  //             ),

  //             FloatingActionButton.small(
  //               elevation: 0,
  //               backgroundColor: Colors.white,
  //               foregroundColor: kbuttonColorPlain,
  //               onPressed: () {
  //                 Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => UserList()));
  //               },
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(Icons.list),
  //                   Text(
  //                     'User List',
  //                     style: TextStyle(fontSize: 6),
  //                   ),
  //                 ],
  //               ),
  //             ),

  //             // Padding(
  //             //   padding: const EdgeInsets.all(5.0),
  //             //   child: FloatingActionButton.large(
  //             //     shape: const CircleBorder(),
  //             //     elevation: 0,
  //             //     backgroundColor: const Color.fromARGB(255, 52, 137, 207),
  //             //     foregroundColor: Colors.white,
  //             //     child:   const Icon(Icons.add),
  //             //     onPressed: () {},
  //             //   ),
  //             // ),

  //             FloatingActionButton.small(
  //               elevation: 0,
  //               backgroundColor: Colors.white,
  //               foregroundColor: kbuttonColorPlain,
  //               onPressed: () {
  //                 loginUserData['userType'] == "client" ?
  //                 Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => SiteView(id: siteList[0].site_id, userName: siteList[0].site_name, emailAdd: siteList[0].site_email, mobile: siteList[0].mobile, suburbs: siteList[0].site_address, attendance: siteList[0].attendance.toString())))
  //                 : Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => SiteList()));
  //               },
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(Icons.holiday_village),
  //                   Text(
  //                     'Site List',
  //                     style: TextStyle(fontSize: 6),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             FloatingActionButton.small(
  //               elevation: 0,
  //               backgroundColor: Colors.white,
  //               foregroundColor: kbuttonColorPlain,
  //               onPressed: () {
  //                 Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => Setting_Screen()));
  //               },
  //               child: const Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(Icons.settings),
  //                   Text(
  //                     'Setting',
  //                     style: TextStyle(fontSize: 6),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),

  //       )
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    int position = (loginUserData['userType'] == "cleaner") ? 1 : 2;

    List<Widget> rowChildren = [
      FloatingActionButton.small(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: kbuttonColorPlain,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewTaskScreen(),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list),
            Text(
              'Task List',
              style: TextStyle(fontSize: 6),
            ),
          ],
        ),
      ),
      FloatingActionButton.small(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: kbuttonColorPlain,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Setting_Screen(),
            ),
          );
        },
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings),
            Text(
              'Settings',
              style: TextStyle(fontSize: 6),
            ),
          ],
        ),
      ),
    ];

    if (!(loginUserData['userType'] == "cleaner")) {
      rowChildren.insert(
        1, // Insert at the desired position
        FloatingActionButton.small(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: kbuttonColorPlain,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserList(),
              ),
            );
          },
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.list_alt_outlined),
              Text(
                'Cleaner',
                style: TextStyle(fontSize: 6),
              ),
              Text( 'List', style: TextStyle(fontSize: 6),),
            ],
          ),
        ),
      );
    }

    if (!(loginUserData['userType'] == "client")) {
      rowChildren.insert(
        position,
        FloatingActionButton.small(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: kbuttonColorPlain,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SiteList(),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.holiday_village),
              Text(
                'Site List',
                style: TextStyle(fontSize: 6),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: rowChildren,
          ),
        ),
      ],
    );
  }
}
