
import 'dart:convert';

import 'package:http/http.dart' as http;
Future<bool> createSettlement(Map map) async {
  try {
    final response = await http.post(
      Uri.parse('http://192.168.206.215:5222/api/Settlements'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(map),
    );
print(response.statusCode);
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error response: ${response.body}');
      throw Exception('Failed to create sattle');
    }
  } catch (e) {
    print('Error during sattlement creation: $e');
    rethrow;
  }
}
