import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Models/GroupMember.dart';
import '../Models/GroupModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

String groupBaseUrl = 'http://192.168.206.215:5222/api/Groups/'; // Base URL for Group API

/// Fetches all groups from the API and returns a list of [Group] objects.
Future<List<Group>> fetchGroupsFromAPI() async {
  print("Fetching groups...");
  try {
    // Sending a GET request to the API
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt("userId") ?? 0;
    final response = await http.get(
        Uri.parse(groupBaseUrl + "user/" + id.toString()));

    // Logging the response status and body for debugging
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      // Parsing the response body into a list of dynamic JSON objects
      List<dynamic> jsonData = json.decode(response.body);

      // Mapping each JSON object to a Group object and returning the list
      return jsonData.map((groupJson) => Group.fromJson(groupJson)).toList();
    }
    else if(response.statusCode == 404) {
      throw Exception('No groups ${response.statusCode}');
    }
    else
 {
      // Throwing an exception for non-200 status codes
      throw Exception('Failed to fetch groups. Status: ${response.statusCode}');
    }
  } catch (error) {
    // Logging and rethrowing any errors that occur
    print('Error: $error');
    rethrow;
  }
}

// Fetch a single group by ID
Future<Group> fetchGroupById(int groupId) async {
  final response = await http.get(
    Uri.parse('$groupBaseUrl/$groupId'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    return Group.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load group');
  }
}

// Create a new group
Future<Group> createGroup({
  required String groupName,
  required int createdByUserID,
  // required String createdByUserName,
}) async {
  try {
    final response = await http.post(
      Uri.parse(groupBaseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'groupName': groupName,
        'createdByUserID': createdByUserID,
        // "CreatedByUserName":"hello",
        "createdAt": "2025-01-26T15:34:19.102Z"
      }),
    );

    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode(response.body));
    } else {
      print('Error response: ${response.body}');
      throw Exception('Failed to create group');
    }
  } catch (e) {
    print('Error during group creation: $e');
    rethrow;
  }
}

// Update an existing group
Future<void> updateGroup(int groupId, Group updatedGroup) async {
  try {
    var headers = {
      'Content-Type': 'application/json'
    };
    print("$groupBaseUrl$groupId");
    var request = http.Request('PUT', Uri.parse('$groupBaseUrl${groupId}'));
    request.body = json.encode({
      "groupID": groupId,
      "groupName": updatedGroup.groupName,
      "createdByUserID": updatedGroup.createdByUserID,
      "createdByUserName": updatedGroup.createdByUserName,
      "createdAt": "2025-01-26T16:16:00.272Z"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print("${response.statusCode}javavavavav");
      print(await response.stream.bytesToString());
    }
    else {
      print("${response.statusCode} - Error: Failed to update group.");
      String errorResponse = await response.stream.bytesToString();
      print("Error Details: $errorResponse");
    }


    // final response = await http.put(
    //   Uri.parse('$groupBaseUrl/$groupId'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode(updatedGroup.toJson()),
    // );
    // print(response.body);
    // if (response.statusCode != 204) {
    //   print('Error response: ${response.body}');
    //   throw Exception('Failed to update group');
    // }
  } catch (e) {
    print('Error during group update: $e');
    rethrow;
  }
}

// Delete a group
Future<void> deleteGroup(int groupId) async {
  // print()
  print('$groupId------------------');
  try {
    var request = http.Request(
      'DELETE',
      Uri.parse('http://192.168.206.215:5222/api/Groups/$groupId'),
    );

    print('Sending DELETE request to ${request.url}...');
    http.StreamedResponse response = await request.send();

    print('Response Status Code: ${response.statusCode}');
    String responseBody = await response.stream.bytesToString();
    print('Response Body: $responseBody');

  //   if (response.statusCode == 200) {
  //     // showAlert('Group deleted.');
  //   } else {
  //     showAlert('Failed to delete group: $responseBody', isError: true);
  //   }
  // } catch (e) {
  //   print('Exception during DELETE request: $e');
  //   showAlert('An error occurred: $e', isError: true);
  // }
    if (response.statusCode == 404) {
      showAlert('User not found.', isError: true);
    } else if (response.statusCode == 200 || response.statusCode == 204) {
      print('group deleted successfully.');
    }

    else {
      throw Exception('Unexpected error occurred: ${response.statusCode}');
    }
  } catch (e) {
    print('Error during user deletion: $e');
    showAlert('An unexpected error occurred. Please try again. Forgain key conflict', isError: true);
    rethrow;
  }
}

// Global navigator key for alerts
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Show alert dialog
void showAlert(String message, {bool isError = true}) {
  showDialog(
    context: navigatorKey.currentContext!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(isError ? 'Error' : 'Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<List<GroupMember>> fetchGroupMembers(int groupId) async {
  final url = 'http://192.168.206.215:5222/api/GroupMembers/GetByGroup/$groupId';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((data) => GroupMember.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load group members');
    }
  } catch (e) {
    print("Error fetching group members-------: $e");
    throw e;
  }
}
Future<bool> addGroupMembers(int memberId,int groupId) async {
  print('$groupId--------');
  final url = 'http://192.168.206.215:5222/api/GroupMembers/Add';
  try {

    final response = await http.post(Uri.parse(url),headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },body: jsonEncode(<String, dynamic>{
      "memberID": 0,
      "groupID": groupId,
      "userID": memberId,
      "userName": "string",
      "joinDate": "2025-01-30T18:12:17.100Z"
    }),);

    if (response.statusCode == 200) {

      return true;
    } else {
      print("added member${response.body}");
      throw Exception('Failed to load group members');
    }
  } catch (e) {
    print("Error fetching group members: $e");
    throw e;
  }
}
Future<void> deleteGroupMember(int memberId) async {
  // print()
  print('$memberId------------------');
  try {
    var request = http.Request(
      'DELETE',
      Uri.parse('http://192.168.206.215:5222/api/GroupMembers/Remove/$memberId'),
    );

    print('Sending DELETE request to ${request.url}...');
    http.StreamedResponse response = await request.send();

    print('Response Status Code: ${response.statusCode}');
    String responseBody = await response.stream.bytesToString();
    print('Response Body: $responseBody');

    if (response.statusCode == 200) {
      // showAlert('Group deleted.');
    } else {
      showAlert('Failed to delete group: $responseBody', isError: true);
    }
  } catch (e) {
    print('Exception during DELETE request: $e');
    showAlert('An error occurred: $e', isError: true);
  }
}
// List<Map<String, dynamic>>.from(json.decode(response.body));
Future<List<Map<String, dynamic>>> fetchUsers() async {
  try {
    final response = await http.get(Uri.parse('http://192.168.206.215:5222/api/User/dropdown'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to load users");
    }
  } catch (e) {
    throw Exception("Error fetching users: $e");
  }
}

