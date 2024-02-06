import 'package:clean_connector/Screens/communication.dart';
import 'package:clean_connector/Screens/individual_chat.dart';
import 'package:clean_connector/Screens/login_screen.dart';
import 'package:clean_connector/components/bottom_bar.dart';
import 'package:clean_connector/services/api_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../Constant/const_api.dart';
import '../Constant/style.dart';
import '../Controller/authController.dart';

class ChatHistoryCommunication extends StatefulWidget {
  const ChatHistoryCommunication({Key? key}) : super(key: key);

  @override
  State<ChatHistoryCommunication> createState() => _SiteListState();
}

class _SiteListState extends State<ChatHistoryCommunication> {
  List<Users> chatList = [];
  List<Users> filteredUserList = [];
  List<String> siteList = [''];
  bool isSuperAdmin = false;
  bool isSearching = false;
  bool isLoading = false;
  bool isEmptyList = false;
  String searchValue = '';

  TextEditingController searchController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  Future<List<Users>> filterUsers(String query) async {
    print("Search value: $searchValue");
    print(isSearching);
    print("Filltering users....");
    setState(() {
      isSearching = true;
    });
    chatList = [];
    print("Filtering users for query: $query");
    query = query.toLowerCase();
    try {
      final response = await Dio().get(
        "${BASE_API}users/$query",
      );
      var data = response.data['result'];
      print("DATA: $data");
      if (response.statusCode == 200) {
        chatList = [];
        //var data = response.data['result'] as List<dynamic>;
        for (Map i in data) {
          Users users = Users(
              name: i['name'],
              email: i['email'],
              id: i['id'],
              dob: i['dob'],
              phone: i['phone'],
              suburb: (i['suburb'] == null) ? "Colombo 03" : i['suburb'],
              image: (i['image'] == null) ? "No image" : i['image'],
              type: i['type']);
          chatList.add(users);
          print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
          print(chatList);
        }
        // setState(() {
        //   userList = filteredUsers;
        // });
        return chatList;
      }
      return chatList;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        print("Bad Error");
        print(e.response?.data["message"]);
        setState(() {
          isEmptyList = true;
        });
        return chatList;
      }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
      return chatList;
    }
  }

//build a list of chats
  Widget _buildUserList(BuildContext context) {
    if (searchController.text.isEmpty) {
      return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chat_rooms')
              .where('active', isEqualTo: false)
              .where('site_id', whereIn: isSuperAdmin ? null : siteList)
              .snapshots(),
          builder: ((context, snapshot) {
            if (snapshot.hasError) {
              return Text('error');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('loading...');
            }
            return ListView(
              children: snapshot.data!.docs
                  .map<Widget>(
                      (doc) => _buildUserListItem(context, doc, doc.id))
                  .toList(),
            );
          }));
    } else {
      return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chat_rooms')
              .where('active', isEqualTo: false)
              .where('site_id', whereIn: isSuperAdmin ? null : siteList)
              .where('title_lowercase', isGreaterThanOrEqualTo: searchValue)
              .where('title_lowercase', isLessThan: searchValue + 'z')
              .snapshots(),
          builder: ((context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('error' + snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('loading...');
            }
            return ListView(
              children: snapshot.data!.docs
                  .map<Widget>(
                      (doc) => _buildUserListItem(context, doc, doc.id))
                  .toList(),
            );
          }));
    }
  }

//build single chat card
  Widget _buildUserListItem(
      BuildContext context, documentSnapshot, String docId) {
    Map<String, dynamic> data =
        documentSnapshot.data()! as Map<String, dynamic>;

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat_Screen(
                          cardNumber: data['title'],
                          chatRoomId: docId,
                          isactive: false,
                          isSuperAdmin: isSuperAdmin,
                          siteId: data['site_id'],
                        )));
          },
          //Active chat list
          child: Column(
            children: [
              ListTile(
                title: Text(
                  data['title'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Add other chat card content here
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(), // Add Spacer to control the space
                  Text(
                    data['created_by_name'] == "Admin"
                        ? "Admin"
                        : data['created_by_name'],
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Open Sans',
                        color: kiconColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // String siteId = '';
  void loginData() async {
    //Get logged user data
    Map<String, dynamic> userData = await AuthController.getLoginData().then(
      (value) {
        //if logged as cleaner, display only messages related to cleaner's sites
        if (value['userType'] == "cleaner") {
          getUserSites(value['id'], value["token"]);
          //if user logged as super admin, display all site messages
        } else if (value['userType'] == "admin") {
          setState(() {
            isSuperAdmin = true;
          });
          //if user logged as client, display messages related to client's site
        } else {
          setState(() {
            siteList[0] = value['siteId'];
          });
        }

        return value;
      },
    );
    print(userData.toString());
    // setState(() {
    //   siteId = userData['siteId'];
    // });
    // print('siteId ' + siteId);
  }

  void getUserSites(String siteId, String token) async {
    List<String> list = await ApiServices.getSiteIds(siteId, token);
    setState(() {
      siteList = list;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    loginData();
    super.initState();
    print('iniside communication');
    print(loginUserData['id']);
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
            "CHAT HISTORY",
            style: kboldTitle,
          ),
          backgroundColor: Colors.white,
          // actions: <Widget>[
          //   Padding(
          //       padding: const EdgeInsets.only(right: 20.0),
          //       child: GestureDetector(
          //           onTap: () async {
          //             Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                     builder: (context) => UserProfile()));
          //           },
          //           child: CircleAvatar(
          //             radius: 18,
          //             backgroundColor: kiconColor,
          //             child: (loginUserProfile['image'] != null)
          //                 ? CircleAvatar(
          //                     radius: 17,
          //                     backgroundImage:
          //                         NetworkImage(loginUserProfile['image']),
          //                   )
          //                 : CircleAvatar(
          //                     backgroundColor: Colors.white,
          //                     radius: 17,
          //                     child: Icon(
          //                       Icons.person,
          //                       color: kiconColor,
          //                     ),
          //                   ),
          //           ))),
          //   // logoutButton(),
          // ],
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * screenWidth / kWidth,
                    vertical: 10 * screenWidth / kWidth,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Communication()),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kiconColor,
                              ),
                              child: const Icon(
                                Icons.chat_bubble,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(' Active Chats',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: kiconColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * screenWidth / kWidth,
                    vertical: 10 * screenWidth / kWidth,
                  ),
                  child: Text(
                    "Chat History",
                    style: TextStyle(
                        fontFamily: "Open Sans",
                        fontSize: 18,
                        //color: Color.fromARGB(255, 52, 137, 207),
                        fontWeight: FontWeight.bold),
                  ),
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
                      border:
                          Border.all(color: kiconColor), // Add a border color
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
                                searchValue = value;
                                chatList = [];
                              });
                              filterUsers(value); // Call filterUsers function
                            },
                            decoration: InputDecoration(
                              hintText: "Search Chat",
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
                  child: _buildUserList(context),
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
  String name, email, id, dob, suburb, image, type;
  int phone;

  Users(
      {required this.name,
      required this.email,
      required this.id,
      required this.dob,
      required this.phone,
      required this.suburb,
      required this.image,
      required this.type});
}
