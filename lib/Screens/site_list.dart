import 'dart:convert';
import 'package:clean_connector/Screens/IncidentReport.dart';
import 'package:clean_connector/Screens/Site_bar.dart';
import 'package:clean_connector/Screens/Site_recommandation.dart';
import 'package:clean_connector/Screens/communication.dart';
import 'package:clean_connector/Screens/create_user.dart';
import 'package:clean_connector/Screens/login_screen.dart';
import 'package:clean_connector/Screens/site_profile.dart';
import 'package:clean_connector/Screens/super_admin_profile.dart';
import 'package:clean_connector/Screens/task_list.dart';
import 'package:clean_connector/Screens/user_profile.dart';
import 'package:clean_connector/Screens/user_view.dart';
import 'package:clean_connector/components/bottom_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../Constant/const_api.dart';
import '../Constant/style.dart';
import '../Controller/authController.dart';
import 'IncidentReport.dart';
import 'Site_view.dart';
import 'create_site.dart';

class SiteList extends StatefulWidget {
  const SiteList({Key? key}) : super(key: key);

  @override
  State<SiteList> createState() => _SiteListState();
}

class _SiteListState extends State<SiteList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Sites> siteList = [];
  List<Sites> filteredUserList = [];
  bool isSearching = false;
  bool isLoading = false;
  bool isEmptyList = false;
  String searchValue = '';
  TextEditingController searchController = TextEditingController();


  Future<List<Sites>> getSites() async {
    print("Getting sites....");
    siteList = [];
    try {
      final response = await Dio().get(
          "${BASE_API2}site/getall-Sites",
          options: Options(headers: {
            "Authorization": loginUserData['accessToken']
          }));
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
            attendance: (i['mobile'] == null) ? 80.5 : i['rate'].toDouble(),
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
    }on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data["message"] == "No Sites in DB") {
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

  Future<List<Sites>> filterSites() async {
    print("search sites....");
    try {
      final response = await Dio().get(
          "${BASE_API2}site/getall-Sites",
          options: Options(headers: {
            "Authorization": loginUserData['accessToken']
          }));
      // options: Options(headers: {
      //   "Authorization": loginUserData["token"]
      // }));
      var data = response.data['sites'];
      print("DATA: $data");
      if (response.statusCode == 200) {
        siteList = [];
        for (Map i in data) {
          if (i['site_name'].toString().toLowerCase().startsWith(
              searchValue.toLowerCase())) {
            Sites sites = Sites(
              site_id: (i['site_id'] == null) ? " " : i['site_id'],
              site_name: (i['site_name'] == null) ? " " : i['site_name'],
              site_address: (i['site_address'] == null)
                  ? " "
                  : i['site_address'],
              site_email: (i['site_email'] == null) ? " " : i['site_email'],
              mobile: (i['mobile'] == null) ? " " : i['mobile'],
              attendance: (i['mobile'] == null) ? 0.0 : i['rate'].toDouble(),
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
        }
        print("!!!!!!!!!!!!!!!!!!!");
        if(siteList.isEmpty){
          setState(() {
            isEmptyList = true;
          });
        }
        print(siteList);
      }
      return siteList;
    }on DioException catch (e) {
      if (e.response?.statusCode == 400 && e.response?.data["message"] == "No Sites in DB") {
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

  // Future<List<Sites>> getSitebyId() async {
  //   print("Getting my site....");
  //   siteList = [];
  //   try{
  //     final response = await Dio().get(
  //         "${BASE_API2}site/get-sites/${loginUserData['id']}",
  //         options: Options(
  //             headers: {"Authorization": loginUserData['accessToken']}));
  //     // options: Options(headers: {
  //     //   "Authorization": loginUserData["token"]
  //     // }));
  //     var data = response.data['sites'];
  //     print("DATA: $data");
  //     if (response.statusCode == 200) {
  //       siteList = [];
  //       for (Map i in data) {
  //         Sites sites = Sites(
  //           site_id: (i['site_id'] == null) ? " " : i['site_id'],
  //           site_name: (i['site_name'] == null) ? " " : i['site_name'],
  //           site_address: (i['site_address'] == null) ? " " : i['site_address'],
  //           site_email: (i['site_email'] == null) ? " " : i['site_email'],
  //           mobile: (i['mobile'] == null) ? " " : i['mobile'],
  //           attendance: i['rate'].toDouble(),
  //           userData: (i['user_data'] == []) ? [] : [],
  //         );
  //         siteList.add(sites);
  //       }
  //       print("!!!!!!!!!!!!!!!!!!!");
  //       print(siteList);
  //     }
  //     return siteList;
  //   }on DioException catch (e) {
  //     if (e.response?.statusCode == 400) {
  //       print("Bad Error");
  //       print(e.response?.data["message"]);
  //       setState(() {
  //         isEmptyList = true;
  //       });
  //       return siteList;
  //     }
  //     print(e.toString());
  //     setState(() {
  //       isLoading = false;
  //     });
  //     print(e);
  //     return siteList;
  //   }
  // }

  Future<List<Sites>> getCleanerSites() async {
    print("Getting my site....");
    siteList = [];
    try{
      final response = await Dio().get("${BASE_API2}site/get-cleaner-sites",
          options: Options(
              headers: {"Authorization": loginUserData['accessToken']}));
      // options: Options(headers: {
      //   "Authorization": loginUserData["token"]
      // }));
      var data = response.data['siteAreas'];
      print("DATA: $data");
      if (response.statusCode == 200) {
        siteList = [];
        for (Map i in data) {
          Sites sites = Sites(
            site_id: (i['site_id'] == null) ? " " : i['site_id'],
            site_name: (i['site_name'] == null) ? " " : i['site_name'],
            site_address: (i['site_address'] == null) ? " " : i['site_address'],
            site_email: (i['email'] == null) ? " " : i['email'],
            mobile: (i['mobile'] == null) ? " " : i['mobile'],
            attendance: (i['rate'] == null) ? " " : i['rate'].toDouble(),
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
    }on DioException catch (e) {
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

  Future<List<Sites>> filterCleanerSites() async {
    print("filter my site....");
    try{
      final response = await Dio().get("${BASE_API2}site/get-cleaner-sites",
          options: Options(
              headers: {"Authorization": loginUserData['accessToken']}));
      // options: Options(headers: {
      //   "Authorization": loginUserData["token"]
      // }));
      var data = response.data['siteAreas'];
      print("DATA: $data");
      if (response.statusCode == 200) {
        siteList = [];
        for (Map i in data) {
          if (i['site_name'].toString().toLowerCase().startsWith(
              searchValue.toLowerCase())) {
            Sites sites = Sites(
              site_id: (i['site_id'] == null) ? " " : i['site_id'],
              site_name: (i['site_name'] == null) ? " " : i['site_name'],
              site_address: (i['site_address'] == null)
                  ? " "
                  : i['site_address'],
              site_email: (i['email'] == null) ? " " : i['email'],
              mobile: (i['mobile'] == null) ? " " : i['mobile'],
              attendance: (i['rate'] == null) ? " " : i['rate'].toDouble(),
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
        }
        if(siteList.isEmpty){
          setState(() {
            isEmptyList = true;
          });
        }
        print("!!!!!!!!!!!!!!!!!!!");
        print(siteList);
      }
      return siteList;
    }on DioException catch (e) {
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
            "MY CLIENTS & SITES",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 30.0),
                child: GestureDetector(
                    onTap: () async {
                      if (loginUserData['userType'] == 'client') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SiteProfile(),
                          ),
                        );
                      } else if(loginUserData['userType'] == 'admin'){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuperAdminProfile(),
                          ),
                        );
                      }
                      else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfile(),
                          ),
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: kiconColor,
                      child: (loginUserData['userType'] == 'cleaner')
                          ? (loginUserProfile['image'] != null ?
                              CircleAvatar(
                                radius: 17,
                                backgroundImage:
                                    NetworkImage(loginUserProfile['image']),
                              )
                            : CircleAvatar(
                                radius: 17,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: kprofileincon,
                                ),
                              )
                            ) : 
                            CircleAvatar(
                                radius: 17,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: kprofileincon,
                                ),
                              )
                    ))),
            // logoutButton(),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(
                  loginUserProfile['fname'],
                  style: TextStyle(color: Colors.white), // Change text color
                ),
                accountEmail: Text(
                  loginUserProfile['email'],
                  style: TextStyle(color: Colors.white), // Change text color
                ),
                currentAccountPicture: CircleAvatar(
                  radius: 31,
                  backgroundColor: kiconColor,
                  child: (loginUserProfile['image'] != null)
                      ? CircleAvatar(
                    radius: 30,
                    backgroundImage:
                    NetworkImage(loginUserProfile['image']),
                  )
                      : CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(
                      Icons.person,
                      color: kiconColor,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: kiconColor // Change the background color
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Site Recommandation'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SiteRecomondationScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Communication'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Communication()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Incident Report'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Incident()));
                },
              ),
              Divider(),
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: Column(
              children: [
                (loginUserData['userType'] == "admin")
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20 * screenWidth / kWidth,
                          vertical: 10 * screenWidth / kWidth,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SiteCreate(
                                          id: '',
                                          emailAdd: '',
                                        )));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kiconColor,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('Add Client',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color:
                                          kiconColor)),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 10,
                      ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * screenWidth / kWidth,
                    vertical: 10 * screenWidth / kWidth,
                  ),
                  child: Container(
                    height: 40, // Set your desired height here
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          20), // Set your desired border radius here
                      border: Border.all(color: kbuttonColorPlain),
                      // color: Colors.grey[300]// Add a border color
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
                              //filterUsers(value);
                            },
                            decoration: InputDecoration(
                              hintText: "Search Sites",
                              hintStyle: TextStyle(fontSize: 15),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: (isSearching == true && loginUserData['userType']== "admin")
                        ? filterSites()
                    :(isSearching == true && loginUserData['userType']== "cleaner")
                        ? filterCleanerSites()
                        : loginUserData['userType']== "admin"
                        ? getSites()
                        : getCleanerSites(),
                    builder: (context, AsyncSnapshot<List<Sites>> snapshot) {
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
                                        // boxShadow: [
                                        //   const BoxShadow(
                                        //     color: Colors.black12,
                                        //     offset: Offset(1, 0.5),
                                        //     blurRadius: 2,
                                        //   )
                                        // ],
                                        // border: Border.all(width: 1, color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    width: screenWidth,
                                    child: InkWell(
                                      onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SiteView(
                                                        id: snapshot
                                                            .data![index]
                                                            .site_id
                                                            .toString(),
                                                        userName: snapshot
                                                            .data![index]
                                                            .site_name
                                                            .toString(),
                                                        emailAdd: snapshot
                                                            .data![index]
                                                            .site_email
                                                            .toString(),
                                                        mobile: snapshot
                                                            .data![index].mobile
                                                            .toString(),
                                                        suburbs: snapshot
                                                            .data![index]
                                                            .site_address
                                                            .toString(),
                                                        attendance: snapshot
                                                            .data![index]
                                                            .attendance
                                                            .toString(),
                                                        sunD: snapshot
                                                            .data![index]
                                                            .sun
                                                            .toString(),
                                                        monD: snapshot
                                                            .data![index]
                                                            .mon
                                                            .toString(),
                                                        tueD: snapshot
                                                            .data![index]
                                                            .tue
                                                            .toString(),
                                                        wedsD: snapshot
                                                            .data![index]
                                                            .wed
                                                            .toString(),
                                                        thuD: snapshot
                                                            .data![index]
                                                            .thu
                                                            .toString(),
                                                        friD: snapshot
                                                            .data![index]
                                                            .fri
                                                            .toString(),
                                                        satD: snapshot
                                                            .data![index]
                                                            .sat
                                                            .toString(),
                                                      )));
                                      },
                                      child: ListTile(
                                        // leading: CircleAvatar(
                                        //   radius: 35,
                                        //   backgroundColor: kiconColor,
                                        //   child: CircleAvatar(
                                        //       radius: 27,
                                        //       backgroundColor: Colors.white,
                                        //       backgroundImage: NetworkImage(snapshot.data![index].image.toString(),)
                                        //   ),
                                        // ),
                                        title: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(snapshot.data![index].site_name.toString(),
                                                  style: klistTitle),
                                            ],
                                          ),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Text(
                                              snapshot.data![index].site_address
                                                  .toString(),
                                              style: klistTitle),
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
                                  child: Text("No sites to preview"),
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
        bottomNavigationBar: BottomNavBar(),
        // bottomNavigationBar: Container(
        //   alignment: Alignment.bottomCenter,
        //   // color: ,
        //   height: 130,
        //   decoration: const BoxDecoration(
        //     color: Colors.transparent,
        //     image: DecorationImage(
        //         image: AssetImage(
        //           "assets/images/waves.png",
        //         ),
        //         fit: BoxFit.cover),
        //   ),
        // ),
      ),
    );
  }
}

class Sites {
  String site_id, site_name, site_address, site_email, mobile, sun, mon, tue, wed, thu, fri, sat;
  double attendance;
  List<String>? userData;

  Sites(
      {required this.site_id,
      required this.site_name,
      required this.site_address,
      required this.site_email,
      required this.mobile,
      required this.attendance,
      this.userData,
        required this.sun,
        required this.mon,
        required this.tue,
        required this.wed,
        required this.thu,
        required this.fri,
        required this.sat,
      });
}
