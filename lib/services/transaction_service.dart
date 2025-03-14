
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:splitwiseapp/Models/TransactionModel.dart';

Future<bool> createTransaction(Map<String, dynamic> transactionData) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.206.215:5222/api/Transactions'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(transactionData),
    );

    print(response.statusCode);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("added transection sussfully");
      return true;
    } else {
      print('Error response: ${response.body}');
      throw Exception('Failed to create transaction');
    }
  } catch (e) {
    print('Error during transaction creation: $e');
    rethrow;
  }
}

// final String baseUrl = "http://localhost:5222/api/Transactions";
//
// Future<List<TransactionModel>> getTransactionsByUserID(int userID) async {
//   final response = await http.get(
//     Uri.parse('$baseUrl/GetByUserID/$userID'),
//     headers: {"Content-Type": "application/json"},
//   );
//
//   if (response.statusCode == 200) {
//     List<dynamic> jsonResponse = jsonDecode(response.body);
//     return jsonResponse.map((data) => TransactionModel.fromJson(data)).toList();
//   } else {
//     throw Exception("Failed to load transactions");
//   }
// }
Future<List<TransactionModel>> fetchTransactionsByUserID(int userID) async {
  final String baseUrl = "http://192.168.206.215:5222/api/Transactions/GetByUserID/$userID";

  final response = await http.get(
    Uri.parse('$baseUrl'), // Adjust API endpoint
    headers: {"Content-Type": "application/json"},
  );
  print('baseUrl'+baseUrl);
  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = jsonDecode(response.body);
    if (jsonResponse.isEmpty) {
      print("No transactions are available.");
      return []; // Return empty list if no transactions exist
    }
    return jsonResponse.map((data) => TransactionModel.fromJson(data)).toList();
  } else {
    throw Exception("Failed to load transactions");
  }
}