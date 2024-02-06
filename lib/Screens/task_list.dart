import 'dart:convert';

import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/client_create_task.dart';
import 'package:clean_connector/Screens/create_task.dart';
import 'package:clean_connector/Screens/create_user.dart';
import 'package:clean_connector/Screens/site_profile.dart';
import 'package:clean_connector/Screens/super_admin_profile.dart';
import 'package:clean_connector/Screens/task_view.dart';
import 'package:clean_connector/Screens/user_profile.dart';
import 'package:clean_connector/Screens/user_view.dart';
import 'package:clean_connector/components/bottom_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../Constant/const_api.dart';
import '../Controller/authController.dart';
import 'login_screen.dart';

class ViewTaskScreen extends StatefulWidget {
  const ViewTaskScreen({super.key});

  @override
  State<ViewTaskScreen> createState() => _ViewTaskScreenState();
}

Map<String, dynamic> loginUserProfile = {
  'id': '',
  'fname': '',
  'lname': '',
  'phone': '',
  'email': '',
  'image': '',
  'startDate': '',
  'endDate': '',
  'siteId': '',
  'site_name': '',
  "site_address": "",
  "rate": "",
};

class _ViewTaskScreenState extends State<ViewTaskScreen> {
  String name = '';
  bool isLoading = false;
  bool isEmptyList = false;
  List<Tasks> taskList = [];
  List<Tasks> filteredUserList = [];
  bool isSearching = false;
  String searchValue = '';
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> notifications = [];
  bool isEmptyNotifications = false;
  List<String> notificationTaskIds = [];
  List<String> notificationCommentIds = [];
  String mapPriorityToText(int priority) {
    switch (priority) {
      case 1:
        return "High";
      case 2:
        return "Medium";
      case 3:
        return "Low";
      default:
        return "";
    }
  }

  Future<void> getNotifications() async {
    try {
      print("Getting Notifications....");
      notifications = [];
      notificationTaskIds = [];
      notificationCommentIds = [];
      final response = await Dio().get(
        "${BASE_API2}comments/notification/${loginUserData['id']}",
        options:
            Options(headers: {"Authorization": loginUserData['accessToken']}),
      );
      var data = response.data['notifications'];
      print("NOTIFICATION DATA: $data");

      if (response.statusCode == 200) {
        final List<dynamic> notifications = response.data['notifications'];
        print("Notification List: $notifications");

        if (notifications.isEmpty) {
          setState(() {
            isEmptyNotifications = true;
          });
        }

        // Iterate through the notifications and print task_id and comment_id
        for (var notification in notifications) {
          var taskId = notification['task_id'].toString();
          var commentId = notification['comment_id'].toString();
          notificationTaskIds.add(taskId as String);
          notificationCommentIds.add(commentId as String);
          print("Task ID: $taskId, Comment ID: $commentId");
        }
      } else {
        setState(() {
          isEmptyNotifications = true;
        });
        throw Exception('Failed to load notifications');
      }

      // This line ensures that the print statement is executed after the API call
      print("Notification Task IDs: $notificationTaskIds");
      print("Notification Comment IDs: $notificationCommentIds");
    } catch (error) {
      print("Error fetching notifications: $error");
    }
  }

  Future<List<Tasks>> filterTasks() async {
    print("search tasks....");
    try {
      String apiUrl = "";
      if (loginUserData['userType'] == "client") {
        apiUrl = "${BASE_API2}tasks/allTasksBySiteId/${loginUserData['id']}";
        final response = await Dio().get(apiUrl,
            options: Options(
                headers: {"Authorization": loginUserData['accessToken']}));

        var data = response.data['data'];
        print("DATA: $data");
        if (response.statusCode == 200) {
          taskList = [];
          for (Map i in data) {
            if (i['task_tittle']
                .toString()
                .toLowerCase()
                .startsWith(searchValue.toLowerCase())) {
              Tasks tasks = Tasks(
                id: i['id'],
                receiver: i['receiver'] == null ? '' : i['receiver'],
                sender: i['sender'] == null ? '' : i['sender'],
                createdDate: i['created_date'] == null ? '' : i['created_date'],
                // deadline: i['deadline'] == null
                //     ? ''
                //     : DateFormat('yyyy/MM/dd')
                //         .format(DateTime.parse(i['deadline'])),
                deadline: i['deadline'] == null
                    ? DateTime.now().toString()
                    : i['deadline'],
                taskTitle: i['task_tittle'] == null ? '' : i['task_tittle'],
                description: i['description'] == null ? '' : i['description'],
                priority: i['priority'] == null ? 1 : i['priority'],
                image: i['image'] == null ? '' : i['image'],
                senderUserName:
                    i['senderUserName'] == null ? '' : i['senderUserName'],
                receiverFirstName: i['receiverFirstName'] == null
                    ? ''
                    : i['receiverFirstName'],
                receiverLastName:
                    i['receiverLastName'] == null ? '' : i['receiverLastName'],
              );
              taskList.add(tasks);
            }
          }
          print("!!!!!!!!!!!!!!!!!!!");
          if (taskList.isEmpty) {
            setState(() {
              isEmptyList = true;
            });
          }
          print(taskList);
        }
      } else {
        if (loginUserData['userType'] == "admin") {
          apiUrl = "${BASE_API2}tasks";
        } else if (loginUserData['userType'] == "cleaner ") {
          apiUrl = "${BASE_API2}tasks/${loginUserData['id']}";
        }

        final response = await Dio().get(apiUrl,
            options: Options(
                headers: {"Authorization": loginUserData['accessToken']}));

        var data = response.data['tasks'];
        print("DATA: $data");
        if (response.statusCode == 200) {
          taskList = [];
          for (Map i in data) {
            if (i['task_tittle']
                .toString()
                .toLowerCase()
                .startsWith(searchValue.toLowerCase())) {
              Tasks tasks = Tasks(
                id: i['id'],
                receiver: i['receiver'] == null ? '' : i['receiver'],
                sender: i['sender'] == null ? '' : i['sender'],
                createdDate: i['created_date'] == null ? '' : i['created_date'],
                // deadline: i['deadline'] == null
                //     ? ''
                //     : DateFormat('yyyy/MM/dd')
                //         .format(DateTime.parse(i['deadline'])),
                deadline: i['deadline'] == null
                    ? DateTime.now().toString()
                    : i['deadline'],
                taskTitle: i['task_tittle'] == null ? '' : i['task_tittle'],
                description: i['description'] == null ? '' : i['description'],
                priority: i['priority'] == null ? 1 : i['priority'],
                image: i['image'] == null ? '' : i['image'],
                senderUserName:
                    i['senderUserName'] == null ? '' : i['senderUserName'],
                receiverFirstName: i['receiverFirstName'] == null
                    ? ''
                    : i['receiverFirstName'],
                receiverLastName:
                    i['receiverLastName'] == null ? '' : i['receiverLastName'],
              );
              taskList.add(tasks);
            }
          }
          print("!!!!!!!!!!!!!!!!!!!");
          if (taskList.isEmpty) {
            setState(() {
              isEmptyList = true;
            });
          }
          print(taskList);
        }
      }

      return taskList;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data["message"] == "No Tasks in DB") {
        print("Bad Error");
        print(e.response?.data["message"]);
        setState(() {
          isEmptyList = true;
        });
        return taskList;
      }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
      return taskList;
    }
  }

  Future<List<Tasks>> getTasks() async {
    print("Getting tasks list....${loginUserData['id']}");
    taskList = [];
    String url = '';

    if (loginUserData['userType'] == "admin") {
      setState(() {
        url = "${BASE_API2}tasks";
      });
    } else if (loginUserData['userType'] == "client") {
      setState(() {
        url = "${BASE_API2}tasks/allTasksBySiteId/${loginUserData['id']}";
      });
    } else {
      setState(() {
        url = "${BASE_API2}tasks/${loginUserData['id']}";
      });
    }
    print('Got URL : $url');
    try {
      if (loginUserData['userType'] == "client") {
        final response = await Dio().get(url,
            options: Options(
                headers: {"Authorization": loginUserData['accessToken']}));
        var data = response.data['data'];
        print("DATA: $data");
        if (response.statusCode == 200) {
          taskList = [];
          for (Map i in data) {
            Tasks tasks = Tasks(
              id: i['id'],
              receiver: i['receiver'] == null ? '' : i['receiver'],
              sender: i['sender'] == null ? '' : i['sender'],
              createdDate: i['created_date'] == null ? '' : i['created_date'],
              // deadline: i['deadline'] == null
              //     ? ''
              //     : DateFormat('yyyy/MM/dd')
              //         .format(DateTime.parse(i['deadline'])),
              deadline: i['deadline'] == null
                  ? DateTime.now().toString()
                  : i['deadline'],
              taskTitle: i['task_tittle'] == null ? '' : i['task_tittle'],
              description: i['description'] == null ? '' : i['description'],
              priority: i['priority'] == null ? 1 : i['priority'],
              image: i['image'] == null ? '' : i['image'],
              senderUserName:
                  i['senderUserName'] == null ? '' : i['senderUserName'],
              receiverFirstName:
                  i['receiverFirstName'] == null ? '' : i['receiverFirstName'],
              receiverLastName:
                  i['receiverLastName'] == null ? '' : i['receiverLastName'],
            );
            taskList.add(tasks);
          }
          print("!!!!!!!!!!!!!!!!!!!");
          print(taskList);
        }
        return taskList;
      } else {
        final response = await Dio().get(url,
            options: Options(
                headers: {"Authorization": loginUserData['accessToken']}));
        var data = response.data['tasks'];
        print("DATA: $data");
        if (response.statusCode == 200) {
          taskList = [];
          for (Map i in data) {
            Tasks tasks = Tasks(
              id: i['id'],
              receiver: i['receiver'] == null ? '' : i['receiver'],
              sender: i['sender'] == null ? '' : i['sender'],
              createdDate: i['created_date'] == null ? '' : i['created_date'],
              // deadline: i['deadline'] == null
              //     ? ''
              //     : DateFormat('yyyy/MM/dd')
              //         .format(DateTime.parse(i['deadline'])),
              deadline: i['deadline'] == null
                  ? DateTime.now().toString()
                  : i['deadline'],
              taskTitle: i['task_tittle'] == null ? '' : i['task_tittle'],
              description: i['description'] == null ? '' : i['description'],
              priority: i['priority'] == null ? 1 : i['priority'],
              image: i['image'] == null ? '' : i['image'],
              senderUserName:
                  i['senderUserName'] == null ? '' : i['senderUserName'],
              receiverFirstName:
                  i['receiverFirstName'] == null ? '' : i['receiverFirstName'],
              receiverLastName:
                  i['receiverLastName'] == null ? '' : i['receiverLastName'],
            );
            taskList.add(tasks);
          }
          // Sort the taskList based on the createdDate in descending order
          taskList.sort((a, b) => b.createdDate.compareTo(a.createdDate));
          print("!!!!!!!!!!!!!!!!!!!");
          print(taskList);
        }
        return taskList;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        print("Bad Error");
        print(e.response?.data["message"]);
        setState(() {
          isEmptyList = true;
        });
        return taskList;
      }
      print(e.toString());
      setState(() {
        isLoading = true;
      });
      print(e);
      return taskList;
    }
  }

  @override
  void initState() {
    print("------->" + loginUserData['userType']);
    print("------->" + loginUserData['id']);

    super.initState();
    getNotifications();
    isLoading = true;
    setState(() {
      taskList.isNotEmpty;
    });
    loginUserData['userType'] == "cleaner"
        ? getProfileCleaner()
        : loginUserData['userType'] == "client"
            ? getProfileClient()
            : getProfileClient();
  }

  getProfileCleaner() async {
    print("Data loading....setting ${loginUserData["userId"]}");
    setState(() {
      isLoading = true;
    });
    print(loginUserData["accessToken"]);
    try {
      final response = await Dio().get(
          BASE_API2 +
              "user/getCleanerUsersById/845ca718-1b1a-4910-be61-3fe158afcba1",
          options: Options(headers: {
            "Authorization": "Bearer " + loginUserData["accessToken"]
          }));
      print(response.data['result'][0]['f_name']);
      if (response.statusCode == 200 && response.data['status'] == true) {
        print(response.data['result']);
        setState(() {
          loginUserProfile['id'] = response.data['result'][0]['user_id'] ?? " ";
          loginUserProfile['fname'] =
              response.data['result'][0]['f_name'] ?? " ";
          loginUserProfile['lname'] =
              response.data['result'][0]['l_name'] ?? " ";
          loginUserProfile['phone'] =
              response.data['result'][0]['phone'] ?? " ";
          loginUserProfile['siteId'] =
              response.data['result'][0]['site_id'] ?? " ";
          loginUserProfile['email'] =
              response.data['result'][0]['email'] ?? " ";
          loginUserProfile['image'] =
              response.data['result'][0]['image'] ?? " ";
        });
        print("***" + loginUserProfile['id']);
        print(loginUserProfile['fname']);
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
  }

  getProfileClient() async {
    print("Data loading....setting ${loginUserData["id"]}");
    setState(() {
      isLoading = true;
    });
    print(loginUserData["accessToken"]);
    try {
      final response = await Dio().get(
          BASE_API2 + "site/get-sites/61b2afc2-7409-45f7-b2a7-4672406ecd54",
          options: Options(headers: {
            "Authorization": "Bearer " + loginUserData["accessToken"]
          }));
      if (response.statusCode == 200 && response.data['status'] == true) {
        print(response.data['sites']);
        setState(() {
          loginUserProfile['id'] = response.data['sites'][0]['site_id'] ?? " ";
          loginUserProfile['fname'] =
              response.data['sites'][0]['site_name'] ?? " ";
          loginUserProfile['lname'] =
              response.data['sites'][0]['site_address'] ?? " ";
          loginUserProfile['phone'] =
              response.data['sites'][0]['user_id'] ?? " ";
          loginUserProfile['siteId'] =
              response.data['sites'][0]['site_id'] ?? " ";
          loginUserProfile['email'] =
              response.data['sites'][0]['site_email'] ?? " ";
        });
        print("***" + loginUserProfile['id']);
        print(loginUserProfile['fname']);
      }
    } catch (e) {
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
    return WillPopScope(
      onWillPop: () => _onBackButtonPressed(context),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text(
              "TASK LIST",
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
                        } else if (loginUserData['userType'] == 'admin') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SuperAdminProfile(),
                            ),
                          );
                        } else {
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
                              ? (loginUserProfile['image'] != null
                                  ? CircleAvatar(
                                      radius: 17,
                                      backgroundImage: NetworkImage(
                                          loginUserProfile['image']),
                                    )
                                  : CircleAvatar(
                                      radius: 17,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        color: kprofileincon,
                                      ),
                                    ))
                              : CircleAvatar(
                                  radius: 17,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    color: kprofileincon,
                                  ),
                                )))),
            ],
          ),
          body: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Column(
                children: [
                  (loginUserData['userType'] == "client" ||
                          loginUserData['userType'] == "admin")
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20 * screenWidth / kWidth,
                            vertical: 10 * screenWidth / kWidth,
                          ),
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
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (loginUserData['userType'] == "admin") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TaskCreate()),
                                      );
                                    } else if (loginUserData['userType'] ==
                                        "client") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ClientTaskCreate()),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text('Create Task',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: kiconColor)),
                            ],
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
                        // color: Colors.grey[300]
                        // Add a border color
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
                                //filterTasks(value); // Call filterUsers function
                              },
                              decoration: InputDecoration(
                                hintText: "Search Tasks",
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
                      future:
                          (isSearching == true) ? filterTasks() : getTasks(),
                      builder: (context, AsyncSnapshot<List<Tasks>> snapshot) {
                        return taskList.isNotEmpty
                            ? ListView.builder(
                                itemCount: snapshot.data?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10 * screenWidth / kWidth,
                                        vertical: 5 * screenHeight / kHeight),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10 * screenWidth / kWidth,
                                          vertical:
                                              10 * screenHeight / kHeight),
                                      decoration: BoxDecoration(
                                          color: kcardBackgroundColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      width: screenWidth,
                                      child: InkWell(
                                        onTap: () {
                                          print(snapshot.data![index].id);

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TaskView(
                                                        id: snapshot
                                                            .data![index].id
                                                            .toString(),
                                                        sender: snapshot
                                                            .data![index].sender
                                                            .toString(),
                                                        receiver: snapshot
                                                            .data![index]
                                                            .receiver
                                                            .toString(),
                                                        created_date: snapshot
                                                            .data![index]
                                                            .createdDate
                                                            .toString(),
                                                        deadline: snapshot
                                                            .data![index]
                                                            .deadline
                                                            .toString(),
                                                        description: snapshot
                                                            .data![index]
                                                            .description
                                                            .toString(),
                                                        task_tittle: snapshot
                                                            .data![index]
                                                            .taskTitle
                                                            .toString(),
                                                        receiverUserName: snapshot
                                                                .data![index]
                                                                .receiverFirstName
                                                                .toString() +
                                                            ' ' +
                                                            snapshot
                                                                .data![index]
                                                                .receiverLastName
                                                                .toString(),
                                                        senderName: snapshot
                                                            .data![index]
                                                            .senderUserName
                                                            .toString(),
                                                        priority: snapshot
                                                            .data![index]
                                                            .priority,
                                                        image: snapshot
                                                            .data![index].image
                                                            .toString(),
                                                      )));
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Deadline: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(snapshot.data![index].deadline.toString()))}", // Replace with the actual time
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: kiconColor,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Priority: ",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      mapPriorityToText(snapshot
                                                          .data![index]
                                                          .priority),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            getColorForPriority(
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .priority),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 2, // Height of the line
                                              color: Colors
                                                  .grey, // Color of the line
                                            ),
                                            ListTile(
                                              title: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      _truncateTitle(snapshot
                                                          .data![index]
                                                          .taskTitle),
                                                      style: klistTitle,
                                                    ),
                                                    // Check if there are new notifications and show SpinKitDoubleBounce
                                                    if (notificationTaskIds
                                                        .contains(snapshot
                                                            .data![index].id))
                                                      SpinKitDoubleBounce(
                                                        color: Colors.green,
                                                        size: 20,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: (loginUserData[
                                                            'userType'] ==
                                                        "client")
                                                    ? Text(
                                                        "Assignee: ${snapshot.data![index].receiverFirstName} ${snapshot.data![index].receiverLastName ?? ''}",
                                                        style: klistTitle,
                                                      )
                                                    : Text(
                                                        "Assigned by ${snapshot.data![index].senderUserName.toString()}",
                                                        style: klistTitle,
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : (isEmptyList == true)
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30.0, right: 30.0, top: 50.0),
                                    child: Text("No task to preview"),
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
      ),
    );
  }

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool? exitApp = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Logout ?",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            content: const Text(
              'Are you sure you want to Log Out ?',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )),
              TextButton(
                  onPressed: () async {
                    setState(() {
                      AuthController.logOut(context);
                    });
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )),
            ],
          );
        });
    return exitApp ?? false;
  }
}

String _truncateTitle(String title) {
  const int maxLength = 20;
  return title.length <= maxLength
      ? title
      : '${title.substring(0, maxLength)}....';
}

Color getColorForPriority(int priority) {
  switch (priority) {
    case 1:
      return Colors.red; // High priority color
    case 2:
      return Colors.orange; // Medium priority color
    case 3:
      return Colors.green; // Low priority color
    default:
      return Colors.black; // Default color
  }
}

class logoutButton extends StatefulWidget {
  const logoutButton({Key? key}) : super(key: key);

  @override
  State<logoutButton> createState() => _logoutButtonState();
}

class _logoutButtonState extends State<logoutButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: GestureDetector(
            onTap: () async {
              _onBackButtonPressed(context);
              // setState(() {
              //   AuthController.logOut(context);
              // });
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: kiconColor,
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.logout,
                  color: kiconColor,
                ),
              ),
            )));
  }

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool? exitApp = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Logout ?",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            content: const Text(
              'Are you sure you want to Log Out ?',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )),
              TextButton(
                  onPressed: () async {
                    setState(() {
                      AuthController.logOut(context);
                    });
                  },
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )),
            ],
          );
        });
    return exitApp ?? false;
  }
}

class Tasks {
  String sender,
      receiver,
      id,
      createdDate,
      deadline,
      description,
      taskTitle,
      receiverFirstName,
      receiverLastName,
      image,
      senderUserName;
  int priority;

  Tasks({
    required this.sender,
    required this.receiver,
    required this.id,
    required this.createdDate,
    required this.deadline,
    required this.description,
    required this.taskTitle,
    required this.receiverFirstName,
    required this.receiverLastName,
    required this.image,
    required this.senderUserName,
    required this.priority,
  });
}
