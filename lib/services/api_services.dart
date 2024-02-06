import 'package:clean_connector/Constant/const_api.dart';
import 'package:dio/dio.dart';

class ApiServices {
  static Future<Map<String, dynamic>> getLoggedUserDetails(
      String userId, String token) async {
    print("Getting userdata....");

    final response = await Dio().get(
        "${BASE_API2}user/getCleanerUsersById/$userId",
        options: Options(headers: {"Authorization": "Bearer $token"}));
    var data = response.data['result'];
    print("DATA: $data");
    if (response.statusCode == 200) {
      final List<dynamic> usersData = response.data['result'];
      print("List: $usersData");
      int index =
          usersData.indexWhere((element) => element['user_id'] == userId);
      String fname = usersData[index]['f_name'];
      String lname = usersData[index]['l_name'];
      String siteId = usersData[index]['site_id'];
      print("Site id ###############" + usersData[index]['site_id']);

      final Map<String, String> userDetails = {
        'fname': fname,
        'lname': lname,
        'siteId': siteId
      };
      print(userDetails.toString());
      return userDetails;
    } else {
      throw Exception('Failed to load user data');
    }
  }

//Get sites Ids of a cleaner
  static Future<List<String>> getSiteIds(String userId, String token) async {
    print("Getting site Ids....");
    List<String> siteIdList = [];
    final response = await Dio().get(
        "${BASE_API2}user/getCleanerUsersById/$userId",
        options: Options(headers: {"Authorization": "Bearer $token"}));
    var data = response.data['result'];

    if (response.statusCode == 200) {
      List<dynamic> usersData = response.data['result'];

      for (int i = 0; i < usersData.length; i++) {
        siteIdList.add(usersData[i]['site_id'].toString());
      }
      print(" siteIdList: $siteIdList");

      return siteIdList;
    } else {
      throw Exception('Failed to load siteIds');
    }
  }

//Get site data by site Id (client ID)
  static Future<Map<String, dynamic>> getSiteDataBySiteId(
      String siteId, String token) async {
    print("Getting sit data.... $siteId, $token");

    final response = await Dio().get(
        "${BASE_API2}client/getAdminUsersById/$siteId",
        options: Options(headers: {"Authorization": "Bearer $token"}));
    var data = response.data['result'];
    print("site data by site id +$data");
    if (response.statusCode == 200) {
      if (!response.data['status']) {
        return {'': ''};
      }
      List<dynamic> usersData = response.data['result'];

      Map<String, dynamic> siteData = {
        'site_name': usersData[0]['site_name'],
        'site_address': usersData[0]['site_address']
      };

      return siteData;
    } else {
      throw Exception('Failed to load siteData');
    }
  }
}
