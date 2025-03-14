import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/expence.dart';

class ExpenseService {
  final String baseUrl;

  ExpenseService(this.baseUrl);

  /// Fetch expenses by group ID
  Future<List<Expense>> fetchExpensesByGroupId(int groupId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$groupId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Expense.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load expenses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching expenses: $e');
    }
  }

  Future<bool> deleteExpence(int expenseId) async {
    try {
      final response = await http.delete(Uri.parse('http://192.168.206.215:5222/api/Expenses/Delete/$expenseId'));

      if (response.statusCode == 200) {
        // final List<dynamic> data = json.decode(response.body);
        return true;
      } else {
        throw Exception('Failed to load expenses. Status code: ${response.statusCode}');
        // return
      }
    } catch (e) {
      throw Exception('Error fetching expenses: $e');
    }
  }


  Future<bool> sattleExpence(int expenseId) async {
    try {
      final response = await http.post(Uri.parse('http://192.168.206.215:5222/api/ExpenseSplits/InsertExpenseSplits/$expenseId'));

      if (response.statusCode == 200) {
        // final List<dynamic> data = json.decode(response.body);
        return true;
      } else {

        throw Exception('Failed to load expenses. Status code: ${response.statusCode}');
        // return
      }
    } catch (e) {
      print(e);
      throw Exception('Error fetching expenses: $e');
    }
  }
  // Function to add or update an expense
   Future<void> saveExpense({
    required int expenseID,
    required int groupID,
    required int paidByUserID,
    required String expenseName,
    required double totalAmount,
    required String expenseDate,
  }) async {
    final url = expenseID == 0
        ? Uri.parse('$baseUrl/Add') // Add new expense
        : Uri.parse('$baseUrl/Update'); // Update existing expense

    // Create the expense object
    Expense expense = Expense(
      expenseID: expenseID,
      groupID: groupID,
      paidByUserID: paidByUserID,
      expenseName: expenseName,
      totalAmount: totalAmount,
      expenseDate: expenseDate,
    );

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(expense.toJson()),
      );

      if (response.statusCode == 200) {
        // Successfully saved expense
        return;
      } else {
        // Failed to save expense
        throw Exception('Failed to save expense');
      }
    } catch (error) {
      throw Exception('Error during expense save: $error');
    }
  }
}
