import 'dart:convert';

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
import '../Constant/const_api.dart';
import '../Constant/style.dart';
import '../Controller/authController.dart';

List<Users> userList = [];
class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  
  List<Users> filteredUserList = [];
  List<Users> users = [];
  bool isSearching = false;
  bool isLoading = false;
  bool isEmptyList = false;
  String searchValue = '';
  TextEditingController searchController = TextEditingController();

  String getIdByFnameOrLname(String name) {
    print("Filter : $userList");
    setState(() {
      isSearching = false;
    });

    for (Users user in userList) {
      String fname = user.fname;
      String lname = user.lname;
      print("Filter : $fname Last name $lname");
      print("Filter : 2 $name");
      if (user.fname == name || user.lname == name) {
        print(user.id);
        return user.id;       
      }
    }
    return ''; // Return an empty string or handle the case when no match is found
  }


  Future<List<Users>> filterUsers() async {
    print("Getting users....");
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
            String fullName = i['f_name']+" "+i['l_name'];
            if (fullName.toString().toLowerCase().contains(
                searchValue.toLowerCase())) {
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
                    emp_no: i['emp_no'] == null ? 0 : i['emp_no'], sitename: i['site_name'] == null ? '' : i['site_name'],
                  );
                  userList.add(users);
                  uniqueEmpNos.add(empNo); 
                }
            }
          }
        if(userList.isEmpty){
          isEmptyList = true;
        }

        userList.sort((a, b) => (b.emp_no ?? 0).compareTo(a.emp_no ?? 0));
        
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


  Future<List<Users>> getCleaners() async {
    
    print("Getting cleaners list....");
    userList = [];
    try{

      final response = await Dio().get("${BASE_API2}user/getAllCleanerUsers",
          options: Options(headers: {
            "Authorization": loginUserData['accessToken']
          }));

      var data = response.data['result'];
      print("DATA: $data");
      
      if (response.statusCode == 200) {
        userList = [];
        Set<int> uniqueEmpNos = Set<int>(); // Use a set to track unique empNos

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
              sitename: i['site_name'] == null ? '' : i['site_name'],
              emp_no: empNo,
            );
            userList.add(users);
            uniqueEmpNos.add(empNo); // Add the empNo to the set
          }
        }

        if(userList.isEmpty){
          isEmptyList = true;
        }

        // Sort the userList based on emp_no in descending order
        userList.sort((a, b) => (b.emp_no ?? 0).compareTo(a.emp_no ?? 0));

        print("Filter : 3 $userList");
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

  @override
  void initState() {
    print("Cleaner list");
    getCleaners();
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "CLEANER LIST",
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
                    )
                    
                    )),
            // logoutButton(),
          ],
        ),
        
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: Column(
              children: [
                (loginUserData['userType']== "admin")? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * screenWidth / kWidth,
                    vertical: 10 * screenWidth / kWidth,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserCreate()));
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
                        const Text('Add Cleaner',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: kiconColor)),
                      ],
                    ),
                  ),
                )
                    : SizedBox(height: 10,),
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
                      // color: Colors.grey[300],// Add a border color
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
                        // Expanded(
                        //   child: TextField(
                        //     textInputAction: TextInputAction.search,
                        //     controller: searchController,
                        //     onChanged: (value) {
                        //       setState(() {
                        //         searchValue = value;
                        //         userList =[];
                        //       });
                        //       // filterUsers(value); // Call filterUsers function
                        //     },
                        //     onSubmitted: (String searchText) {
                        //       // Call your search function here with the entered text
                        //       filterUsers(searchText);
                        //     },
                        //     decoration: InputDecoration(
                        //       hintText: "Search Cleaners",
                        //       hintStyle: TextStyle(fontSize: 15),
                        //       border: InputBorder.none,
                        //     ),
                        //   ),
                        // ),

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
                (loginUserData["userType"] == 'cleaner') ? 
                  Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 50.0),
                        child: Text("You don't have access"),
                      )

                 :
                Expanded(
                  child: FutureBuilder(
                    // future: (isSearching == true && loginUserData["userType"])? filterUsers(searchValue) :getCleaners(),
                    future: (isSearching == true)? filterUsers() : getCleaners(), 
                    builder: (context, AsyncSnapshot<List<Users>> snapshot) {
                      return userList.isNotEmpty ? ListView.builder(
                          itemCount: userList.length,
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
                                    borderRadius: BorderRadius.circular(10)),
                                width: screenWidth,
                                child: InkWell(
                                  onTap: () {
                                    //print(snapshot.data![index].allocationId.toString());
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserView(
                                            id: snapshot.data![index].id.toString(), 
                                            f_Name: snapshot.data![index].fname.toString(), 
                                            l_Name: snapshot.data![index].lname.toString(), 
                                            emailAdd: snapshot.data![index].email.toString(), 
                                            startDate: snapshot.data![index].start_date.toString(), 
                                            endDate: snapshot.data![index].end_date.toString(), 
                                            mobile: snapshot.data![index].phone.toString(), 
                                            suburbs: snapshot.data![index].sitename.toString(), 
                                            image: snapshot.data![index].image.toString(), 
                                            userType: 'cleaner', 
                                            siteId: snapshot.data![index].siteid.toString(), 
                                            empNo: snapshot.data![index].emp_no.toString(), 
                                            doc: snapshot.data![index].doc.toString(),  
                                          )
                                      )
                                    );
                                  },
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 35,
                                      //backgroundColor: kiconColor,
                                      child: CircleAvatar(
                                        radius: 35,
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(snapshot.data![index].image.toString(),)
                                      ),
                                    ),
                                    title: Padding(
                                      padding:
                                      const EdgeInsets.only(left: 10.0,),
                                      child: Text(
                                          snapshot.data![index].fname.toString()+" "+ snapshot.data![index].lname.toString(),
                                          style: klistTitle),
                                    ),
                                    subtitle: Padding(
                                      padding:
                                      const EdgeInsets.only(left: 10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text("Emp No : ",style: klistTitle),
                                              Text(
                                                  snapshot.data![index].emp_no .toString(),
                                                  style: klistTitle),
                                            ],
                                          ),
                                          Text( snapshot.data![index].email .toString(),
                                                  style: klistTitle),
                                          
                                          
                                        ],
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
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}

class Users {
  String fname, lname, email, id, start_date, end_date, doc, image, siteid, phone;
  String? allocationId;
  String? sitename;
  int? emp_no;

  Users(
      {required this.fname,
        required this.lname,
        required this.email,
        required this.id,
        required this.start_date,
        required this.end_date,
        required this.phone,
        required this.doc,
        required this.image,
        required this.siteid,
        required this.sitename,
        this.emp_no,
        this.allocationId
      });
}