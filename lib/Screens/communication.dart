import 'package:clean_connector/Screens/chat_history_com.dart';
import 'package:clean_connector/Screens/communication_new_question.dart';
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

class Communication extends StatefulWidget {
  const Communication({Key? key}) : super(key: key);

  @override
  State<Communication> createState() => _SiteListState();
}

class _SiteListState extends State<Communication> {
  List<Users> chatList = [];
  List<String> siteList = [''];
  List<Users> filteredUserList = [];
  List<String> _siteNameList = [];
  List<dynamic> siteData = []; //all site data
  List<dynamic> _siteAdressList = []; //filltered list by site address
  bool isSuperAdmin = false;
  bool isSearching = false;
  bool isLoading = false;
  bool isEmptyList = false;
  String searchValue = '';
  String? _selectedClient;
  String? _selectedSiteAdress;
  String selectedSiteId = '';
  Map<String, String> _siteId = {};
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
    // return chatList;
  }

  Future<List<Users>> getUsers() async {
    print("Getting users....");
    chatList = [];
    final response = await Dio().get(
      "${BASE_API}users/",
    );
    // options: Options(headers: {
    //   "Authorization": loginUserData["token"]
    // }));
    var data = response.data['result'];
    print("DATA: $data");
    if (response.statusCode == 200) {
      chatList = [];
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
        print("!!!!!!!!!!!!!!!!!!!");
        print(chatList);
      }
      return chatList;
    }
    return chatList;
  }

  //For to get all sites - used when admin create chats
  Future<void> getAllSiteData() async {
    print("Inside getAllSiteData");

    print(token);
    final response = await Dio().get("${BASE_API2}client/getAllAdminUsers",
        options: Options(headers: {"Authorization": "Bearer $token"}));
    var data = response.data['result'];
    print("DATA: $data");
    if (response.statusCode == 200) {
      siteData = response.data['result'];
      print("List: $siteData");

      final Map<String, String> siteIdToMap = {};
      List<String> siteNames = [];

      for (final site in siteData) {
        final String siteName = site['site_name'].toString();
        final String siteAddress = site['site_address'].toString();
        final String siteId = site['site_id'];

        siteIdToMap[siteName] = siteId;
        siteNames.add(siteName);
      }

      // Remove duplicates
      siteNames = siteNames.toSet().toList();

      print(siteIdToMap.toString());

      setState(() {
        _siteNameList = siteNames;
        _siteId = siteIdToMap;
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  void filterBySiteAddress() {
    //print(siteData.toString());
    final Map<String, String> siteIdToMap = {};
    List<String> siteAddresses = [];
    List<dynamic> _filtereBySiteAddress = siteData.where((site) {
      return site['site_name'] == _selectedClient;
    }).toList();

    for (final site in _filtereBySiteAddress) {
      final String siteAddress = site['site_address'].toString();
      final String siteId = site['site_id'];

      siteIdToMap[siteAddress] = siteId;
      siteAddresses.add(siteAddress);
    }
// Remove duplicates
    List<String> uniqueList = [];
    Set<String> seen = Set<String>();

    for (String element in siteAddresses) {
      if (seen.add(element)) {
        uniqueList.add(element);
      }
    }

    // siteAddresses = siteAddresses.toSet().toList();

    setState(() {
      _siteAdressList = uniqueList;
      _siteId = siteIdToMap;
    });
    print(_filtereBySiteAddress);
  }

  void _showUserTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose your user type:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: ElevatedButton(
                  onPressed: () {
                    // _showAddTopicDialog(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewQuestion(
                                  title: titleController.text,
                                )));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      fontFamily: "Open Sans",
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              ListTile(
                title: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewQuestion(
                                  title: titleController.text,
                                )));
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  child: const Text(
                    'Cleaner',
                    style: TextStyle(
                        fontFamily: "Open Sans",
                        fontSize: 15,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTopicDialog(BuildContext context) {
    String topic = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                "Before Create the New Chat, Enter the Title: ",
                style: TextStyle(
                  fontFamily: "Open Sans",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Enter a topic",
                    ),
                    onChanged: (value) {
                      setState(() {
                        topic = value; // Update the topic when the user types
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (isSuperAdmin)
                    //Select site name
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: DropdownButton<String>(
                        underline: Divider(
                          height: 5,
                          thickness: 0.5,
                          color: Color.fromARGB(255, 117, 112, 112),
                        ),
                        isExpanded: true,
                        hint: Text('Select Client'),
                        value: _selectedClient,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedClient = newValue!;
                            //set address to initial stage when selecting site name for second time
                            if (_selectedSiteAdress != '' ||
                                _selectedSiteAdress != null) {
                              _selectedSiteAdress = null;
                            }

                            print(" _selectedClient + $_selectedClient");
                            // Find the selected user's ID using the username-to-ID map
                            selectedSiteId = _siteId[newValue] ?? '';
                            print("Selected SiteId: $selectedSiteId");

                            filterBySiteAddress();
                          });
                        },
                        items: [
                          for (var siteName in _siteNameList)
                            DropdownMenuItem<String>(
                              value: siteName,
                              child: Text(
                                'Site: $siteName',
                                style: const TextStyle(
                                  fontFamily: "Open Sans",
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  if (isSuperAdmin)
                    //select site address
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: DropdownButton<String>(
                        underline: Divider(
                          height: 5,
                          thickness: 0.5,
                          color: Color.fromARGB(255, 117, 112, 112),
                        ),
                        isExpanded: true,
                        hint: Text('Select Site'),
                        value: _selectedSiteAdress,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedSiteAdress = newValue!;
                            print(
                                " _selectedSiteAdress + $_selectedSiteAdress");
                            // Find the selected user's ID using the username-to-ID map
                            selectedSiteId = _siteId[newValue] ?? '';
                            print("Selected SiteId: $selectedSiteId");
                          });
                        },
                        items: [
                          for (var siteAdress in _siteAdressList)
                            DropdownMenuItem<String>(
                              value: siteAdress,
                              child: Text(
                                'Address: $siteAdress',
                                style: const TextStyle(
                                  fontFamily: "Open Sans",
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: kiconColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                      ),
                      TextButton(
                        child: const Text(
                          "Add",
                          style: TextStyle(
                            color: kiconColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          if (topic.isNotEmpty) {
                            if (isSuperAdmin) {
                              if (_selectedClient == null) {
// Show an error message or prevent navigation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select client"),
                                  ),
                                );
                              } else if (_selectedSiteAdress == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select Site Address"),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NewQuestion(
                                      title: titleController.text,
                                      siteId: selectedSiteId,
                                      siteName: _selectedClient ?? '',
                                      siteAddress: _selectedSiteAdress ?? '',
                                    ),
                                  ),
                                );
                              }
                            } else {
                              // Only navigate if the topic is not empty
                              Navigator.pop(context);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewQuestion(
                                    title: titleController.text,
                                  ),
                                ),
                              );
                            }
                          } else {
                            // Show an error message or prevent navigation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a topic."),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // String siteId = '';
  String token = '';

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
    setState(() {
      // siteList[0] = userData['siteId'];
      token = userData['token'];
    });
    getAllSiteData();
    print('siteId ' + siteList[0].toString());
  }

//get cleaner site ids
  void getUserSites(String siteId, String token) async {
    List<String> list = await ApiServices.getSiteIds(siteId, token);
    setState(() {
      siteList = list;
    });
  }

//build a list of chats
  Widget _buildUserList(BuildContext context) {
    if (searchController.text.isEmpty) {
      return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('chat_rooms')
              .where('active', isEqualTo: true)
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
              .where('site_id', whereIn: isSuperAdmin ? null : siteList)
              .where('active', isEqualTo: true)
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
                          isactive: true,
                          createdby: data['created_by'],
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginData();

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
            "COMMUNICATION",
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
                                builder: (context) =>
                                    const ChatHistoryCommunication()),
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
                                Icons.history,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(' Chat History',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: kiconColor)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showAddTopicDialog(context);
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
                                Icons.add,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text('Start Chat',
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
                    "Active Chat List",
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
                      border: Border.all(color: kbuttonColorPlain),
                      // color: Colors.grey[300], // Add a border color
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
                                print(value);
                                chatList = [];
                              });
                              //filterUsers(value); // Call filterUsers function
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
