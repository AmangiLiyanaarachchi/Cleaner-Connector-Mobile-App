import 'dart:async';
import 'package:clean_connector/Constant/const_api.dart';
import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/login_screen.dart';
import 'package:clean_connector/Screens/site_recomondation_form.dart';
import 'package:clean_connector/Screens/view_recommendation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

List<Recomendation> recList = [];

class SiteRecomondationScreen extends StatefulWidget {
  const SiteRecomondationScreen({Key? key}) : super(key: key);

  @override
  _SiteRecomondationScreenState createState() =>
      _SiteRecomondationScreenState();
}

class _SiteRecomondationScreenState extends State<SiteRecomondationScreen> {
  // final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isEmptyList = false;
  bool isEmptyUserList = false;

  Future<List<Recomendation>> getReccomendationsbySiteId() async {
    print(
        "Getting orders.... ${loginUserData['id']}  \n ${loginUserData['accessToken']}");
    recList = [];
    try {
      if (loginUserData['userType'] == "client") {
        final response = await Dio().get(
            "${BASE_API2}recommendation/approved/site/${loginUserData['id']}",
            options: Options(
                headers: {"Authorization": loginUserData['accessToken']}));
        var data = response.data['siteRecommendations'];
        print("DATA: $data");
        if (response.statusCode == 200) {
          print("DATA: 1");
          recList = [];
          for (Map i in data) {
            // if (loginSiteData['id'] == i['site_id']) {
            Recomendation recs = Recomendation(
              id: i['id'] == null ? 0 : i['id'],
              title: i['title'] == null ? '' : i['title'],
              cleaner_title:
                  i['cleaner_title'] == null ? '' : i['cleaner_title'],
              description: i['description'] == null ? '' : i['description'],
              url: i['url'] == null ? '' : i['url'],
              cleaner_description: i['cleaner_description'] == null
                  ? ''
                  : i['cleaner_description'],
              cleaner_image:
                  i['cleaner_image'] == null ? '' : i['cleaner_image'],
            );
            recList.add(recs);
          }
          print("------------------");
          print(recList.length);
          if (recList.length == 0) {
            setState(() {
              isEmptyList = true;
            });
          }
        }
        return recList;
      } else if (loginUserData['userType'] == "admin") {
        final response = await Dio().get(
            "${BASE_API2}recommendation/approved/list",
            options: Options(
                headers: {"Authorization": loginUserData['accessToken']}));
        var data = response.data['siteRecommendations'];
        print("DATA: $data");
        if (response.statusCode == 200) {
          print("DATA: 1");
          recList = [];
          for (Map i in data) {
            // if (loginSiteData['id'] == i['site_id']) {
            Recomendation recs = Recomendation(
              id: i['id'] == null ? 0 : i['id'],
              title: i['title'] == null ? '' : i['title'],
              cleaner_title:
                  i['cleaner_title'] == null ? '' : i['cleaner_title'],
              description: i['description'] == null ? '' : i['description'],
              url: i['url'] == null ? '' : i['url'],
              cleaner_description: i['cleaner_description'] == null
                  ? ''
                  : i['cleaner_description'],
              cleaner_image:
                  i['cleaner_image'] == null ? '' : i['cleaner_image'],
            );
            recList.add(recs);
          }
          print("------------------");
          print(recList.length);
          if (recList.length == 0) {
            setState(() {
              isEmptyList = true;
            });
          }
        }
        return recList;
      } else {
        final response = await Dio().get(
            "${BASE_API2}recommendation/approved/cleaner_id/${loginUserData['id']}",
            options: Options(
                headers: {"Authorization": loginUserData['accessToken']}));
        var data = response.data['siteRecommendations'];
        print("DATA: $data");
        if (response.statusCode == 200) {
          print("DATA: 1");
          recList = [];
          for (Map i in data) {
            // if (loginSiteData['id'] == i['site_id']) {
            Recomendation recs = Recomendation(
              id: i['id'] == null ? 0 : i['id'],
              title: i['title'] == null ? '' : i['title'],
              cleaner_title:
                  i['cleaner_title'] == null ? '' : i['cleaner_title'],
              description: i['description'] == null ? '' : i['description'],
              url: i['url'] == null ? '' : i['url'],
              cleaner_description: i['cleaner_description'] == null
                  ? ''
                  : i['cleaner_description'],
              cleaner_image:
                  i['cleaner_image'] == null ? '' : i['cleaner_image'],
            );
            recList.add(recs);
          }
          print("------------------");
          print(recList.length);
          if (recList.length == 0) {
            setState(() {
              isEmptyList = true;
            });
          }
        }
        return recList;
      }
    } on DioException catch (e) {
      setState(() {
        isEmptyList = true;
      });
      if (e.response?.statusCode == 401) {
        print("Bad Error");
        print(e.response?.data["message"]);
        setState(() {
          isEmptyList = true;
        });
      }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
    return recList;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double columnWidth = (screenWidth - 100) / 5;

    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "SITE RECOMMENDATION",
          style: kboldTitle,
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0), // Add rounded corners
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(2, 2),
                blurRadius: 2,
              )
            ],
          ),
          child: Column(
            children: [
              if (loginUserData['userType'] != "admin")
                Padding(
                  padding:
                      const EdgeInsets.only(right: 20, bottom: 10, top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kiconColor,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SiteRecomondationForm(),
                            ),
                          );
                        },
                        child: Text('Add Site Recommendation'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, right: 10, bottom: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(8.0), // Add rounded corners
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(2, 2),
                          blurRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: screenWidth,
                          decoration: BoxDecoration(
                            color: kiconColor,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                topLeft: Radius.circular(8)),
                          ),
                          child: ListTile(
                            title: isLoading == false
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: columnWidth,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.transparent,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "ID",
                                            style: ktableTitle,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: columnWidth * 2,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.transparent,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Title",
                                            style: ktableTitle,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: columnWidth * 2,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.transparent,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Recommendation",
                                            style: ktableTitle,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: FutureBuilder(
                              future: getReccomendationsbySiteId(),
                              builder: (context,
                                  AsyncSnapshot<List<Recomendation>> snapshot) {
                                return recList.isNotEmpty
                                    ? ListView.builder(
                                        itemCount: recList.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            color: kcardBackgroundColor,
                                            width: screenWidth,
                                            child: GestureDetector(
                                              onTap: () async {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ViewRecommendation(
                                                              id: snapshot
                                                                  .data![index]
                                                                  .id
                                                                  .toString(),
                                                              title: snapshot
                                                                  .data![index]
                                                                  .title
                                                                  .toString(),
                                                              cleaner_title: snapshot
                                                                  .data![index]
                                                                  .cleaner_title
                                                                  .toString(),
                                                              description: snapshot
                                                                  .data![index]
                                                                  .description
                                                                  .toString(),
                                                              url: snapshot
                                                                  .data![index]
                                                                  .url
                                                                  .toString(),
                                                              cleaner_des: snapshot
                                                                  .data![index]
                                                                  .cleaner_description
                                                                  .toString(),
                                                              cleaner_image: snapshot
                                                                  .data![index]
                                                                  .cleaner_image
                                                                  .toString(),
                                                            )));
                                              },
                                              child: ListTile(
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width: columnWidth,
                                                      height: 36,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.white,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "Rec_" +
                                                              snapshot
                                                                  .data![index]
                                                                  .id
                                                                  .toString(),
                                                          style: klistTitle,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: columnWidth * 2,
                                                      height: 36,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.white,
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0,
                                                                right: 8,
                                                                top: 2,
                                                                bottom: 2),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            (snapshot
                                                                        .data![
                                                                            index]
                                                                        .cleaner_title
                                                                        .length >
                                                                    70)
                                                                ? snapshot
                                                                        .data![
                                                                            index]
                                                                        .cleaner_title
                                                                        .substring(
                                                                            0,
                                                                            70)
                                                                        .toString() +
                                                                    "..."
                                                                : snapshot
                                                                    .data![
                                                                        index]
                                                                    .cleaner_title,
                                                            style: klistTitle,
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: columnWidth * 2,
                                                      height: 36,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors.white,
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0,
                                                                right: 8,
                                                                top: 2,
                                                                bottom: 2),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            (snapshot
                                                                        .data![
                                                                            index]
                                                                        .title
                                                                        .length >
                                                                    70)
                                                                ? snapshot
                                                                        .data![
                                                                            index]
                                                                        .title
                                                                        .substring(
                                                                            0,
                                                                            70)
                                                                        .toString() +
                                                                    "..."
                                                                : snapshot
                                                                    .data![
                                                                        index]
                                                                    .title,
                                                            style: klistTitle,
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        })
                                    : (isEmptyList == true)
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 30.0,
                                                right: 30.0,
                                                top: 50.0),
                                            child: Text(
                                                "No site recommendation to preview"),
                                          )
                                        : const Padding(
                                            padding:
                                                EdgeInsets.only(left: 20.0),
                                            child: SpinKitDualRing(
                                              color: kiconColor,
                                              size: 30,
                                            ),
                                          );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class Recomendation {
  String cleaner_title,
      title,
      description,
      cleaner_description,
      url,
      cleaner_image;
  int id;

  Recomendation({
    required this.id,
    required this.title,
    required this.cleaner_title,
    required this.description,
    required this.url,
    required this.cleaner_description,
    required this.cleaner_image,
  });
}
