import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final int groupId;
  AddExpenseScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _expenseNameController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _addExpense() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int id = prefs.getInt("userId") ?? 0;
      final Map<String, dynamic> expenseData = {
        "expenseID": 0,
        "groupID": widget.groupId,
        "paidByUserID": id,
        "expenseName": _expenseNameController.text,
        "totalAmount": double.parse(_totalAmountController.text),
        "expenseDate": _selectedDate.toIso8601String(),
      };

      try {
        final response = await http.post(
          Uri.parse('http://localhost:5222/api/Expenses/Add'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(expenseData),
        );

        if (response.statusCode == 200) {
          setState(() {
            _expenseNameController.clear();
            _totalAmountController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Expense added successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add expense: ${response.body}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;

    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Expense',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: isDark
              ? Colors.white
              : Colors.grey.shade200),),

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.grey.shade900, Colors.grey.shade800]
                  : [Colors.blue.shade800, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Expense Name", style: theme.textTheme.titleMedium),
                  TextFormField(
                    controller: _expenseNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter expense name',
                      prefixIcon: Icon(FontAwesomeIcons.moneyBillWave),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter an expense name' : null,
                  ),
                  SizedBox(height: 16.0),
                  Text("Total Amount", style: theme.textTheme.titleMedium),
                  TextFormField(
                    controller: _totalAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter total amount',
                      prefixIcon: Icon(FontAwesomeIcons.dollarSign),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter a total amount';
                      if (double.tryParse(value) == null) return 'Please enter a valid number';
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text("Expense Date", style: theme.textTheme.titleMedium),
                  TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: "${_selectedDate.toLocal()}".split(' ')[0],
                    ),
                    decoration: InputDecoration(
                      hintText: 'Select date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 24.0),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _addExpense,
                      icon: Icon(Icons.add_circle_outline),
                      label: Text('Add Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        backgroundColor: isDarkMode ? Colors.tealAccent[700] : Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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