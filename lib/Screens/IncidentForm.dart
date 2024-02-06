// ignore_for_file: prefer_typing_uninitialized_variables, avoid_print, deprecated_member_use

import 'package:clean_connector/Constant/style.dart';
import 'package:clean_connector/Screens/IncidentReport.dart';
import 'package:clean_connector/Screens/communication_admin_login.dart';
import 'package:clean_connector/Screens/login_screen.dart';
import 'package:clean_connector/Screens/text_form_incident.dart';
// import 'package:cleanconnectortab/Screen/incident_Report/incident_report.dart';
// import 'package:cleanconnectortab/Screen/incident_Report/text_form_incident.dart';
// import 'package:cleanconnectortab/constants/style.dart';
// import 'package:cleanconnectortab/login.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:incident_report_full_function/constants/style.dart';
// import 'package:incident_report_full_function/incident_Report/incident_report.dart';
// import 'package:incident_report_full_function/incident_Report/text_form_incident.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class IncidentReportForm extends StatefulWidget {
  const IncidentReportForm({super.key});

  @override
  State<IncidentReportForm> createState() => _IncidentReportFormState();
}

class _IncidentReportFormState extends State<IncidentReportForm> {

  final Map<String, String> sitenameToIdMap = {};

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController contactNController = TextEditingController();
  // final TextEditingController incidentDateController = TextEditingController();
  // final TextEditingController reportedDateController = TextEditingController();
  // final TextEditingController timeReportedController = TextEditingController();
  final TextEditingController contactNuController = TextEditingController();
  // final TextEditingController incidentTypeController = TextEditingController();
  final TextEditingController describeController = TextEditingController();
  final TextEditingController witnessNameController = TextEditingController();
  final TextEditingController contactNumController = TextEditingController();
  final TextEditingController anyoneInjController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController familyController = TextEditingController();
  ////API Call
  void callapi() async {
    print("*****Calling API*******");
    try {
      print("*********Try is working******");
      var dio = Dio();
      String firstNameText = firstNameController.text;
      String lastNameText = lastNameController.text;
      String positionText = positionController.text;
      String selectedDobFormatted = DateFormat('yyyy-MM-dd').format(
        selectedDob.isNotEmpty ? DateTime.parse(selectedDob) : DateTime.now(),
      );

      String contactNText = contactNController.text;
      String selectedIncidentDateFormatted = DateFormat('yyyy-MM-dd').format(
        selectedIncidentDate.isNotEmpty
            ? DateTime.parse(selectedIncidentDate)
            : DateTime.now(),
      );
      // Get the current date and time
      DateTime now = DateTime.now();

      // Format the date and time as needed
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      String formattedTime = DateFormat('HH:mm:ss').format(now);

      // String timeReportedText = timeReportedController.text;
      String contactNuText = contactNuController.text;
      // String incidentTypeText = incidentTypeController.text;
      String describeText = describeController.text;
      String witnessNameText = witnessNameController.text;
      String contactNumText = contactNumController.text;
      String anyoneInjText = anyoneInjController.text;
      String hospitalText = hospitalController.text;
      String familyText = familyController.text;

      var requestData = {
        "person_affected": selectPersonEffect,
        "f_name": firstNameText.isNotEmpty ? firstNameText : null,
        "sur_name": lastNameText.isNotEmpty ? lastNameText : null,
        "position": positionText.isNotEmpty ? positionText : null,
        "site_address": _selectedSite,
        "telephone": contactNText.isNotEmpty ? contactNText : null,
        "date_of_incident": selectedIncidentDateFormatted,
        "date_reported": formattedDate,
        "time_reported": formattedTime,
        "incident_reporter_tele":
            contactNuText.isNotEmpty ? contactNuText : null,
        "type_of_incident": selectTypeOfIncident,
        "treat_type": "Hos",
        "description": describeText.isNotEmpty ? describeText : null,
        "witness": witnessNameText.isNotEmpty ? witnessNameText : null,
        "witness_tele": contactNumText.isNotEmpty ? contactNumText : null,
        "is_anyone_injury": anyoneInjText.isNotEmpty ? anyoneInjText : null,
        "is_taken_hospital": hospitalText.isNotEmpty ? hospitalText : null,
        "is_family_notified": familyText.isNotEmpty ? familyText : null,
        "nature_of_injury": selectedNatureOfInjury.first,
        "body_location": selectedBodyLocation.first,
        "mechanism": selectedMechanismOfInjury.first,
        "agency_of_injury": selectedAgencyOfInjury.first,
        "dob": selectedDobFormatted,
        "site": _selectedSiteId,
      };
      print("*****Request*******");
      print(requestData);

      var response = await dio.post(
          "https://backend.clean-connect.com.au/incident/add-incident",
          data: requestData,
          options: Options(headers: {
            "Authorization": "Bearer " + loginUserData['accessToken']
          }));

      print(response.statusCode);
      print(response.data.toString());
      if (response.statusCode == 200 &&
          response.data["message"] == "Incident reported successfully") {
        print("Incident create Successfully");
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Incident()));
        firstNameController.clear();
        lastNameController.clear();
        positionController.clear();
        dobController.clear();
        contactNController.clear();
        contactNuController.clear();
        describeController.clear();
        witnessNameController.clear();
        contactNumController.clear();
        anyoneInjController.clear();
        hospitalController.clear();
        familyController.clear();
        
      }
    } catch (e) {
      if (e is DioError &&
          e.response != null &&
          e.response!.statusCode == 400) {
        print('Bad request. Check your request parameters.');
        print('Error response: ${e.response!.data}');
      } else {
        print('Error fetching data: $e');
      }
    }
  }

  ///RadioListTile Select Value for the Person Effected
  String selectPersonEffect = '';

  ///RadioListTile Select Value for the Incident Type
  String selectTypeOfIncident = '';

  //// Form Key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ///// Date of birth date picker values
  String selectedDob = '';

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        selectedDob = value?.toLocal().toString() ?? '';
      });
    });
  }

  ///// Incident date picker values
  String selectedIncidentDate = '';

  void _showDatePickerIncident() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2050),
    ).then((value) {
      setState(() {
        selectedIncidentDate = value?.toLocal().toString() ?? '';
      });
    });
  }

////Get all sites
  var jsonList;
  List<String> siteList = [];
  String? _selectedSite;
  String? _selectedSiteId;
  String? _selectedNatureOfInjury;
  String? _selectedBodyLocation;
  String? _selectedMechanismOfInjury;
  String? _selectedAgencyOfInjury;

  final TextEditingController address = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formKey.currentState?.reset();
    getData();
  }

  Future<void> getData() async {
    print("Getting sites list....");

    final response = await Dio()
        .get("https://backend.clean-connect.com.au/site/getall-sites",
            options: Options(headers: {
              "Authorization":
                  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImRlMDY2ODY2LTdmMGQtMTFlZS04MWM4LTBhNjE2NDI2YTJiNyIsImVtYWlsIjoidGVzdGVtYWlsQGdtYWlsLmNvbSIsInJvbGUiOiJzdXBlciBhZG1pbiIsImlhdCI6MTcwNDI1Mjk1NywiZXhwIjoxNzA2ODQ0OTU3fQ.RETj7nn-PG21QqRBSFl6Z2wWsCwjKBX8wEhWUUxkPQk',
              // loginUserData['accessToken']
            }));
    var data = response.data['sites'];
    print("DATA: $data");
    if (response.statusCode == 200) {
      final List<dynamic> siteData = response.data['sites'];
      print("List: $siteData");

      
      final List<String> siteNamesWithAddress = [];

      for (final site in siteData) {
        final String siteId = site['site_id'].toString();
        final String sitename = site['site_name'].toString();
        final String siteAddress = site['site_address'].toString();

        // Store both site name and address in the map
        sitenameToIdMap["$sitename - $siteAddress"] = siteId;

        // Create a string that combines site name and address
        final String siteNameWithAddress = "$sitename - $siteAddress";
        siteNamesWithAddress.add(siteNameWithAddress);
      }

      setState(() {
        siteList = siteNamesWithAddress;
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  ////Incident report date and time picker
  final DateTime incidentReportDate = DateTime.now();

  //// Checkbox
  //// Data Table
  final List<String> natureOfInjury = [
    'Fracture/Dislocation',
    'Dislocation',
    'Sprain/Strain',
    'Internal injury',
    'Amputation',
    'Laceration / Open Wound',
    'Contusion/bruising',
    'Burns',
    'Foreign Body',
    'Absorption via inhalation or digestion',
    'Psychological',
    'Multiple Injuries',
    'Others'
  ];
  List<String> selectedNatureOfInjury = [];

  final List<String> bodyLocation = [
    'Eye',
    'Ear',
    'Face',
    'Head',
    'Neck',
    'Lower back',
    'Trunk',
    'Shoulders/Arms',
    'Hands/Fingers',
    'Hips/Legs',
    'Feet/Toes',
    'Respiratory system',
    'Psychological'
  ];
  List<String> selectedBodyLocation = [];

  final List<String> mechanismOfInjury = [
    'Fall from Height',
    'Slip / trip / fall',
    'Physical strike against or by moving object',
    'Exposure to Noise',
    'Repetitive Movement',
    'Use of equipment ',
    'Manual task/s',
    'Exposure to Electricity',
    'Exposure to Heat/Cold',
    'Exposure to Hazardous chemicals or Substances',
    'Aggression in workplace',
    'Ergonomics / workplace design',
    'Others'
  ];
  List<String> selectedMechanismOfInjury = [];

  final List<String> agencyOfInjury = [
    'Machinery Fixed Plant',
    'Mobile Plant',
    'Road Transport',
    'Other Transport',
    'Powered Equip/Tools',
    'Non Power Hand Tools',
    'Non Powered Equip',
    'Chemicals',
    'Other Material/Substance',
    'Outdoor Environment',
    'Indoor Environment',
    'Underground Environment',
    'Other'
  ];
  List<String> selectedAgencyOfInjury = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Incident(),
                    ));
              },
              child: const CircleAvatar(
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
              ),
            ),
          ),
          title: const Text(
            "INCIDENT REPORT FORM",
            style: kTitle,
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Persons Involved",
                        style: GoogleFonts.openSans(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RadioListTile(
                              title: const Text('Employee',style: TextStyle(fontSize: 12)),
                              value: 'Employee',
                              groupValue: selectPersonEffect,
                              onChanged: (String? value) {
                                setState(() {
                                  selectPersonEffect = value!;
                                  print('Selected Value: $selectPersonEffect');
                                });
                              }),
                        ),
                        // const SizedBox(
                        //   width: 5,
                        // ),
                        Expanded(
                          child: RadioListTile(
                              title: const Text('Temporary/Casual',style: TextStyle(fontSize: 12)),
                              value: 'Temporary/Casual',
                              groupValue: selectPersonEffect,
                              onChanged: (String? value) {
                                setState(() {
                                  selectPersonEffect = value!;
                                  print('Selected Value: $selectPersonEffect');
                                });
                              }),
                        ),
                        
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RadioListTile(
                              title: const Text('Contractor',style: TextStyle(fontSize: 12)),
                              value: 'Contractor',
                              groupValue: selectPersonEffect,
                              onChanged: (String? value) {
                                setState(() {
                                  selectPersonEffect = value!;
                                  print('Selected Value: $selectPersonEffect');
                                });
                              }),
                        ),
                        // const SizedBox(
                        //   width: 5,
                        // ),
                        Expanded(
                          child: RadioListTile(
                              title: const Text('Other',style: TextStyle(fontSize: 12)),
                              value: 'Other',
                              groupValue: selectPersonEffect,
                              onChanged: (String? value) {
                                setState(() {
                                  selectPersonEffect = value!;
                                  print('Selected Value: $selectPersonEffect');
                                });
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextForm(
                      controller: firstNameController,
                      text: 'First Name',
                      textInputType: TextInputType.name,
                      isEnabled: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the First Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextForm(
                      controller: lastNameController,
                      text: 'Last Name',
                      textInputType: TextInputType.name,
                      isEnabled: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the Last Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextForm(
                      controller: positionController,
                      text: 'Position',
                      textInputType: TextInputType.name,
                      isEnabled: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the Position';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7)
                          ]),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 15),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(
                                selectedDob.isNotEmpty
                                    ? DateTime.parse(selectedDob)
                                    : DateTime.now(),
                              ),
                              style: GoogleFonts.openSans(
                                  fontSize: 15,
                                  color: Theme.of(context).hintColor),
                            ),
                          ),
                          const SizedBox(
                            width: 50,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: MaterialButton(
                              onPressed: _showDatePicker,
                              child: Text(
                                'Select Date of Birth',
                                style: GoogleFonts.openSans(
                                    fontSize: 15,
                                    color: Theme.of(context).hintColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7)
                          ]),
                      height: 50,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'Select Site',
                              style: GoogleFonts.openSans(
                                fontSize: 15,
                              ),
                            ),
                            items: siteList.map(
                              (String siteNameWithAddress) {
                                return DropdownMenuItem<String>(
                                  value: siteNameWithAddress,
                                  child: Text(siteNameWithAddress),
                                );
                              },
                            ).toList(),
                            value: _selectedSite,
                            onChanged: (value) {
                              setState(() {
                                _selectedSite = value;
                                 _selectedSiteId = sitenameToIdMap[value];
                              });
                            },
                            buttonStyleData: const ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 40,
                              width: double.infinity,
                            ),
                            dropdownStyleData: const DropdownStyleData(
                              maxHeight: 200,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
                            dropdownSearchData: DropdownSearchData(
                              searchController: address,
                              searchInnerWidgetHeight: 50,
                              searchInnerWidget: Container(
                                height: 50,
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 4,
                                  right: 8,
                                  left: 8,
                                ),
                                child: TextFormField(
                                  expands: true,
                                  maxLines: null,
                                  controller: address,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    hintText: 'Search for an site...',
                                    hintStyle: const TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              searchMatchFn: (item, searchValue) {
                                return item.value
                                    .toString()
                                    .contains(searchValue);
                              },
                            ),
                            //This to clear the search value when you close the menu
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {
                                address.clear();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7)
                          ]),
                      height: 50,
                      child: IntlPhoneField(
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          border: InputBorder.none,
                        ),
                        initialCountryCode: 'AU',
                        controller: contactNController,
                        onChanged: (PhoneNumber phone) {},
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Incident Details",
                        style: GoogleFonts.openSans(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7)
                          ]),
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 15),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(
                                  selectedIncidentDate.isNotEmpty
                                      ? DateTime.parse(selectedIncidentDate)
                                      : DateTime.now()),
                              style: GoogleFonts.openSans(
                                  fontSize: 15,
                                  color: Theme.of(context).hintColor),
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: MaterialButton(
                              onPressed: _showDatePickerIncident,
                              child: Text(
                                'Select Date of Incident',
                                style: GoogleFonts.openSans(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7)
                          ]),
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(incidentReportDate),
                              style: GoogleFonts.openSans(fontSize: 15),
                            ),
                            const SizedBox(
                              width: 80,
                            ),
                            Text(
                              'Report Date',
                              style: GoogleFonts.openSans(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7)
                          ]),
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('HH:mm').format(incidentReportDate),
                              style: GoogleFonts.openSans(fontSize: 15),
                            ),
                            const SizedBox(
                              width: 100,
                            ),
                            Text(
                              'Report Time',
                              style: GoogleFonts.openSans(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7)
                          ]),
                      height: 50,
                      child: IntlPhoneField(
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          border: InputBorder.none,
                        ),
                        initialCountryCode: 'AU',
                        controller: contactNuController,
                        onChanged: (PhoneNumber phone) {},
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Type Of Incident",
                        style: GoogleFonts.openSans(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RadioListTile(
                              title: const Text('Notifiable',style: TextStyle(fontSize: 12),),
                              value: 'Notifiable',
                              groupValue: selectTypeOfIncident,
                              onChanged: (String? value) {
                                setState(() {
                                  selectTypeOfIncident = value!;
                                  print(
                                      'Selected Value: $selectTypeOfIncident');
                                });
                              }),
                        ),
                        // const SizedBox(
                        //   width: 2,
                        // ),
                        Expanded(
                          child: RadioListTile(
                              title: const Text('Significant',style: TextStyle(fontSize: 12)),
                              value: 'Significant',
                              groupValue: selectTypeOfIncident,
                              onChanged: (String? value) {
                                setState(() {
                                  selectTypeOfIncident = value!;
                                  print(
                                      'Selected Value: $selectTypeOfIncident');
                                });
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RadioListTile(
                              title: const Text('Minor',style: TextStyle(fontSize: 12)),
                              value: 'Contractor',
                              groupValue: selectTypeOfIncident,
                              onChanged: (String? value) {
                                setState(() {
                                  selectTypeOfIncident = value!;
                                  print(
                                      'Selected Value: $selectTypeOfIncident');
                                });
                              }),
                        ),
                        // const SizedBox(
                        //   width: 2,
                        // ),
                        Expanded(
                          child: RadioListTile(
                              title: const Text('Medical Treatment',style: TextStyle(fontSize: 12)),
                              value: 'Medical Treatment',
                              groupValue: selectTypeOfIncident,
                              onChanged: (String? value) {
                                setState(() {
                                  selectTypeOfIncident = value!;
                                  print(
                                      'Selected Value: $selectTypeOfIncident');
                                });
                              }),
                        ),
                        
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        
                        Expanded(
                          child: RadioListTile(
                              title: const Text('First Aid',style: TextStyle(fontSize: 12)),
                              value: 'First Aid',
                              groupValue: selectTypeOfIncident,
                              onChanged: (String? value) {
                                setState(() {
                                  selectTypeOfIncident = value!;
                                  print(
                                      'Selected Value: $selectTypeOfIncident');
                                });
                              }),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        Expanded(
                          child: RadioListTile(
                              title: const Text('Near Miss',style: TextStyle(fontSize: 12)),
                              value: 'Near Miss',
                              groupValue: selectTypeOfIncident,
                              onChanged: (String? value) {
                                setState(() {
                                  selectTypeOfIncident = value!;
                                  print(
                                      'Selected Value: $selectTypeOfIncident');
                                });
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextForm(
                      controller: describeController,
                      text: 'Describe Incident',
                      textInputType: TextInputType.text,
                      isEnabled: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please Describe the Incident';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextForm(
                      controller: witnessNameController,
                      text: 'Name of Witness',
                      textInputType: TextInputType.text,
                      isEnabled: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the Witness Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 7)
                            ]),
                        height: 50,
                        child: IntlPhoneField(
                          decoration: const InputDecoration(
                            hintText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                          initialCountryCode: 'AU',
                          controller: contactNumController,
                          onChanged: (phone) {
                            setState(() {
                              print(phone.completeNumber);
                            });
                          },
                          keyboardType: TextInputType.phone,
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Injury Details",
                        style: GoogleFonts.openSans(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextForm(
                      controller: anyoneInjController,
                      text: 'Was anyone injured?',
                      textInputType: TextInputType.text,
                      isEnabled: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the details.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextForm(
                      controller: hospitalController,
                      text: 'Injured taken to Hospital?',
                      textInputType: TextInputType.text,
                      isEnabled: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the details.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextForm(
                      controller: familyController,
                      text: 'Has family been notified?',
                      textInputType: TextInputType.text,
                      isEnabled: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the details.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Injury Specifications",
                        style: GoogleFonts.openSans(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7)
                          ]),
                      height: 50,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Nature of Injury',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          items: natureOfInjury.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              enabled: false,
                              child: StatefulBuilder(
                                builder: (context, menuSetState) {
                                  final isSelected =
                                      selectedNatureOfInjury.contains(item);
                                  return InkWell(
                                    onTap: () {
                                      isSelected
                                          ? selectedNatureOfInjury.remove(item)
                                          : selectedNatureOfInjury.add(item);

                                      setState(() {});

                                      menuSetState(() {});
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          if (isSelected)
                                            const Icon(Icons.check_box_outlined)
                                          else
                                            const Icon(
                                                Icons.check_box_outline_blank),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                          value: selectedNatureOfInjury.isEmpty
                              ? null
                              : selectedNatureOfInjury.last,
                          onChanged: (value) {},
                          selectedItemBuilder: (context) {
                            return natureOfInjury.map(
                              (item) {
                                return Container(
                                  alignment: AlignmentDirectional.topStart,
                                  child: Text(
                                    selectedNatureOfInjury.join(', '),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              },
                            ).toList();
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            height: 50,
                            width: double.infinity,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7)
                          ]),
                      height: 50,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Body Location',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          items: bodyLocation.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              enabled: false,
                              child: StatefulBuilder(
                                builder: (context, menuSetState) {
                                  final isSelected =
                                      selectedBodyLocation.contains(item);
                                  return InkWell(
                                    onTap: () {
                                      isSelected
                                          ? selectedBodyLocation.remove(item)
                                          : selectedBodyLocation.add(item);

                                      setState(() {});

                                      menuSetState(() {});
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          if (isSelected)
                                            const Icon(Icons.check_box_outlined)
                                          else
                                            const Icon(
                                                Icons.check_box_outline_blank),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                          value: selectedBodyLocation.isEmpty
                              ? null
                              : selectedBodyLocation.last,
                          onChanged: (value) {},
                          selectedItemBuilder: (context) {
                            return bodyLocation.map(
                              (item) {
                                return Container(
                                  alignment: AlignmentDirectional.topStart,
                                  child: Text(
                                    selectedBodyLocation.join(', '),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              },
                            ).toList();
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            height: 50,
                            width: double.infinity,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7)
                          ]),
                      height: 50,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Mechanism of Injury',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          items: mechanismOfInjury.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              enabled: false,
                              child: StatefulBuilder(
                                builder: (context, menuSetState) {
                                  final isSelected =
                                      selectedMechanismOfInjury.contains(item);
                                  return InkWell(
                                    onTap: () {
                                      isSelected
                                          ? selectedMechanismOfInjury
                                              .remove(item)
                                          : selectedMechanismOfInjury.add(item);

                                      setState(() {});

                                      menuSetState(() {});
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          if (isSelected)
                                            const Icon(Icons.check_box_outlined)
                                          else
                                            const Icon(
                                                Icons.check_box_outline_blank),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                          value: selectedMechanismOfInjury.isEmpty
                              ? null
                              : selectedMechanismOfInjury.last,
                          onChanged: (value) {},
                          selectedItemBuilder: (context) {
                            return mechanismOfInjury.map(
                              (item) {
                                return Container(
                                  alignment: AlignmentDirectional.topStart,
                                  child: Text(
                                    selectedMechanismOfInjury.join(', '),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              },
                            ).toList();
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            height: 50,
                            width: double.infinity,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7)
                          ]),
                      height: 50,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Agency of Injury',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          items: agencyOfInjury.map((item) {
                            return DropdownMenuItem(
                              value: item,
                              enabled: false,
                              child: StatefulBuilder(
                                builder: (context, menuSetState) {
                                  final isSelected =
                                      selectedAgencyOfInjury.contains(item);
                                  return InkWell(
                                    onTap: () {
                                      isSelected
                                          ? selectedAgencyOfInjury.remove(item)
                                          : selectedAgencyOfInjury.add(item);

                                      setState(() {});

                                      menuSetState(() {});
                                    },
                                    child: Container(
                                      height: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          if (isSelected)
                                            const Icon(Icons.check_box_outlined)
                                          else
                                            const Icon(
                                                Icons.check_box_outline_blank),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                          value: selectedAgencyOfInjury.isEmpty
                              ? null
                              : selectedAgencyOfInjury.last,
                          onChanged: (value) {},
                          selectedItemBuilder: (context) {
                            return agencyOfInjury.map(
                              (item) {
                                return Container(
                                  alignment: AlignmentDirectional.topStart,
                                  child: Text(
                                    selectedAgencyOfInjury.join(', '),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                );
                              },
                            ).toList();
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            height: 50,
                            width: double.infinity,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Container(
                          height: 50,
                          width: 180,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  callapi();
                                  print("Successfull");
                                } else {
                                  print('Unsuccessfull');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: const Color(0xFF3489CF),
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              child: Text(
                                'Submit Form',
                                style: GoogleFonts.openSans(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
