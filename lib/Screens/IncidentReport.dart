import 'package:clean_connector/Screens/communication_admin_login.dart';
import 'package:clean_connector/Screens/pdfView_Incident.dart';
import 'package:clean_connector/Screens/setting.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../Constant/const_api.dart';
import '../Constant/style.dart';
import '../components/pdsCard.dart';
import 'IncidentForm.dart';
import 'PDFViewer.dart';
import 'login_screen.dart';

class ReportCardData {
  final String title;
  final String imagePath;
  final String pdfPath;
  final List<NameWithDateTime> namesWithDateTime;

  ReportCardData({
    required this.title,
    required this.imagePath,
    required this.pdfPath,
    required this.namesWithDateTime,
  });
}

class NameWithDateTime {
  final String name;
  final DateTime dateTime;

  NameWithDateTime({
    required this.name,
    required this.dateTime,
  });
}
List<SignedUsers> ackList = [];
List<PDFList> _pdf= [];
List<PDFList> _historyPdf= [];

bool isHistorySM = false;

class Incident extends StatefulWidget {
  const Incident({super.key});

  @override
  State<Incident> createState() => _IncidentState();
}

class _IncidentState extends State<Incident> {
  bool isLoading = false;
  bool isEmptyList = false;

  Future<List<PDFList>> getIncidents() async {
    print("**************************"+loginUserData['userType']);

    try{
      final response = await Dio().get(
          '${BASE_API2}incident/completeList',
          options: Options(headers: {"Authorization": loginUserData['accessToken']}));
      var data = response.data['incidentList'];
      print("DATA: $data");
      if (response.statusCode == 200 && response.data['message'] == " Retrieved successfully") {
        _pdf = [];
        for (Map i in data) {
          PDFList pdfList = PDFList(
            id: i['id'] == null ? '' : i['id'],
            name: i['f_name'] +" " + i['sur_name'],
            url: i['file'] == null ? '' :i['file'],
            added_at: i['date_reported'] == null ? '' : DateFormat("yyyy-MM-dd")
                .format(DateTime.parse(i['date_reported'])),
            site: i['site_address'] == null ? '' : i['site_address'],
          );
          if((loginUserData['userType']== "admin")) {
            _pdf.add(pdfList);
          }
          if(loginUserData['userType'] == 'client') {
            if(i['site'] == loginUserData['id']) {
              _pdf.add(pdfList);
            }
          }
          if(loginUserData['userType']== "cleaner"){
            if(i['site'] == loginUserData['id']) {
              _pdf.add(pdfList);
            }
          }
        }
        print("------------------");
        print(_pdf.length);
        if(_pdf.isEmpty) {
          setState(() {
            isEmptyList = true;
          });
        }
      }
      return _pdf;
    }on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print("Bad Error");
        print(e.response?.data["message"]);
        setState(() {
          isEmptyList= true;
        });
      }
      print(e.toString());
      setState(() {
        isLoading = false;
      });
      print(e);
    }
    return _pdf;
  }

  @override
  void initState() {
    setState(() {
      isHistorySM = false;
    });
    getIncidents();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                Setting_Screen()),
                (Route<dynamic> route) => false,
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
              "INCIDENT REPORT",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20, color: kiconColor),
            ),
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Setting_Screen()));
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: kiconColor,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.arrow_back,
                        color: kiconColor,
                      ),
                    ),
                  )),
            ),
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
                  (loginUserData['userType']== "cleaner")? Padding(
                    padding:
                    const EdgeInsets.only(right: 20, bottom: 10, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: kiconColor,),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IncidentReportForm(),
                                ));
                          },
                          child: Text('Add Incident'),
                        ),
                      ],
                    ),
                  ) : SizedBox(),
                  isLoading?
                  SpinKitDualRing(color: Colors.black,)
                      : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: FutureBuilder(
                        future:  getIncidents(),
                        builder: (context, AsyncSnapshot<List<PDFList>> snapshot) {
                          return  (isEmptyList==true)?
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 50.0),
                            child: Text("No pdf to preview"),
                          )
                              : (isLoading==true)? const Padding(
                            padding: EdgeInsets.only(left: 20.0),
                            child: SpinKitDualRing(
                              color: kiconColor,
                              size: 30,
                            ),
                          )
                              : ListView.builder(
                              itemCount: _pdf.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<dynamic>(
                                          builder: (_) =>
                                              PDFViewerIncident(
                                                pdfAssetPath: _pdf[index].url,
                                              )),
                                    );
                                  },
                                  child: PdfCardModel(
                                    widget: Stack(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              margin: EdgeInsets.only(
                                                  left:
                                                  30), // Adjust the margin value here
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  bottomLeft: Radius.circular(15),
                                                ),
                                                image: DecorationImage(
                                                  image: AssetImage('assets/images/pdf.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                width:
                                                20), // Add spacing between image and text
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    // color: Colors.amber,
                                                    child: Text(
                                                      isHistorySM == true
                                                          ? _historyPdf[index].name
                                                          : _pdf[index].name,
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                  SizedBox(height: 10,),
                                                  Container(
                                                    // color: Colors.amber,
                                                    child: Text(
                                                      isHistorySM == true
                                                          ? _historyPdf[index].added_at
                                                          : _pdf[index].added_at,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PDFList {
  String id, name, url, added_at, site;

  PDFList(
      {required this.id,
        required this.name,
        required this.url,
        required this.added_at,
        required this.site
      });
}

class SignedUsers {
  String fname, lname, read_at;

  SignedUsers(
      {required this.fname,
        required this.lname,
        required this.read_at
      });
}