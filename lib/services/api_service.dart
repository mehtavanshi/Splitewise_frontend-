import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/UsersModel.dart'; // Import your User model class

String baseUrl = 'http://192.168.206.215:5222/api/User';
String loginUrl=baseUrl+"/login";
// Update base URL for Users

//Fetch all users from the API
Future<Map<String, dynamic>> fetchUsersFromAPILogin(String email, String password) async {
  final url = Uri.parse(loginUrl);
  final headers = {
    'Content-Type': 'application/json',
  };
  final body = json.encode({
    "email": email,
    "passwordHash": password,
  });

  try {
    // Make the POST request
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    // Debugging information
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    // Handle the response
    if (response.statusCode == 200) {
      // Decode JSON response
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      return {
        "success": true,
        "data": responseData,
      };
    } else {
      // Handle invalid credentials or other errors
      final errorResponse = json.decode(response.body) as Map<String, dynamic>;
      return {
        "success": false,
        "message": errorResponse["message"] ?? "Unknown error occurred.",
      };
    }
  } catch (error) {
    print('Error: $error');
    return {
      "success": false,
      "message": "Failed to fetch users. Please try again.",
    };
  }
}



Future<dynamic> fetchUsersFromAPI() async {
  try {
    // Make the GET request
    var response = await http.get(Uri.parse(baseUrl));

    // Log the response details
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    // Return decoded JSON if the status code is 200
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Throw an exception for non-200 status codes
      throw Exception('Failed to fetch users. Status: ${response.statusCode}');
    }
  } catch (error) {
    // Log the error and rethrow for the caller to handle
    print('Error: $error');
    rethrow;
  }
}

// Fetch  user from the API by ID
Future<User> fetchUserById(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/$userId'), // Assuming your API endpoint for fetching user by ID
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body)); // Assuming User model has fromJson method
  } else {
    throw Exception('Failed to load user');
  }
}


// Add or create a new user
Future<User> createUser({
  required String userName,
  required String email,
  required String password,
  required String mobileNo,

}) async {
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userName': userName,
        'email': email,
        'passwordHash': password,
        'mobileNumber': mobileNo,

      }),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      // Print the response body for better error debugging
      print('Error response: ${response.body}');
      throw Exception('Failed to create user');
    }
  } catch (e) {
    print('Error during user creation: $e');
    rethrow;
  }
}


// Update an existing user
Future<void> updateUser(int userId, User updatedUser) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(updatedUser.toJson()),
    );

    if (response.statusCode != 204) {
      // Print the response body for better error debugging
      print('Error response: ${response.body}');
      throw Exception('Failed to update user');
    }
  } catch (e) {
    print('Error during user update: $e');
    rethrow;
  }
}

// Patch (partial update) an existing user
// Future<void> patchUser(String userId, Map<String, dynamic> updates) async {
//   final response = await http.patch(
//     Uri.parse('$baseUrl/$userId'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(updates),
//   );
//
//   if (response.statusCode != 200) {
//     throw Exception('Failed to patch user');
//   }
// }

// Delete an existing user
Future<void> deleteUser(int userId) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 404) {
      showAlert('User not found.', isError: true);
    } else if (response.statusCode == 200 || response.statusCode == 204) {
      print('User deleted successfully.');
    } else {
      throw Exception('Unexpected error occurred: ${response.statusCode}');
    }
  } catch (e) {
    print('Error during user deletion: $e');
    showAlert('An unexpected error occurred. Please try again. Forgain key conflict', isError: true);
    rethrow;
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


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



// Update the isActive status of a user
// Future<List<User>> updateUserStatus(String userId, bool newStatus) async {
//   try {
//     // Send a patch request to update the isActive status
//     await http.patch(
//       Uri.parse('$baseUrl/$userId'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, dynamic>{
//         'isActive': newStatus,
//       }),
//     );
//
//     // Fetch and return the updated list of users
//     return await fetchUsersFromAPI();
//   } catch (error) {
//     print('Error updating user status: $error');
//     throw error;
//   }
// }

// Helper to determine row color based on isActive status
Color determineRowColor(bool isActive) {
  return isActive ? Colors.green.shade100 : Colors.red.shade100;
}

Future<String> getUserImage() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('profileImageUrl') ?? ''; // Change this if fetching from API
}

