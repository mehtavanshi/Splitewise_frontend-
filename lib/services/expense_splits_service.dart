import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/expense_splits_model.dart';




  Future<List<ExpenseSplit>> fetchExpenseSplits(int groupID) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
     int id=prefs.getInt("userId")??0; // Retrieves a string value
     const String baseUrl = "http://192.168.206.215:5222/api/ExpenseSplits";

    final response = await http.get(
      Uri.parse('$baseUrl/GetExpenseSplits?groupID=$groupID&userID=$id'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => ExpenseSplit.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load expense splits");
    }
  }

Future<bool> updateExpenseSplits(Map<String, dynamic> map) async {
  String baseUrl = "http://192.168.206.215:5222/api/ExpenseSplits/${map["splitID"]}";

  print("Updating Expense Split: $baseUrl");
  print("Request Body: ${jsonEncode(map)}"); // Debugging print

  final response = await http.put(
    Uri.parse(baseUrl),
    headers: {
      "Content-Type": "application/json",  // Set header for JSON request
    },
    body: jsonEncode(map), // Convert map to JSON string
  );

  print("Response Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception("Failed to update expense split: ${response.body}");
  }
}

