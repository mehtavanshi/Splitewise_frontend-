import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitwiseapp/services/expense_splits_service.dart';
import 'package:splitwiseapp/Models/expense_splits_model.dart';
import 'package:intl/intl.dart';
import 'package:splitwiseapp/services/sattle_service.dart';
import 'package:splitwiseapp/services/transaction_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme_provider.dart';

class ExpenseSplitsScreen extends StatefulWidget {
  final int groupID;

  const ExpenseSplitsScreen({Key? key, required this.groupID}) : super(key: key);

  @override
  _ExpenseSplitsScreenState createState() => _ExpenseSplitsScreenState();
}

class _ExpenseSplitsScreenState extends State<ExpenseSplitsScreen> {
  late Future<List<ExpenseSplit>> _expenseSplitsFuture;

  @override
  void initState() {
    super.initState();
    _expenseSplitsFuture = fetchExpenseSplits(widget.groupID);
  }

  @override
  Widget build(BuildContext context) {

    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Split expenses',
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

      ),
      body: FutureBuilder<List<ExpenseSplit>>(
        future: _expenseSplitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No expense splits found."));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final expense = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    _showSettlementDialog(expense);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: Colors.grey.shade300,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blueGrey.shade700,
                            radius: 24,
                            child: FaIcon(FontAwesomeIcons.moneyBillWave, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  expense.expenseName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text("Paid by: ${expense.userName ?? 'Unknown'}",
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                Text("Owes to: ${expense.oweToUserName ?? 'Unknown'}",
                                    style: TextStyle(fontSize: 14, color: Colors.red.shade700, fontWeight: FontWeight.w500)),
                                Text(
                                  "Amount: ₹${expense.splitAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMM yyyy').format(DateTime.now()),
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showSettlementDialog(ExpenseSplit expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settle Expense', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Do you want to settle this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  int id = prefs.getInt("userId") ?? 0;
                  await createTransaction({
                    "expenseID": expense.expenseID,
                    "paidByUserID": expense.oweToUserID,
                    "paidByUserName": "Bob",
                    "owedByUserID": id,
                    "owedByUserName": "Charlie1",
                    "amount": expense.splitAmount,
                    "paymentStatus": "Paid",
                  });
                  await createSettlement({
                    "paidByUserID": expense.oweToUserID,
                    "paidByUserName": "Alice",
                    "owedToUserID": id,
                    "owedToUserName": "Bob",
                    "amountSettled": expense.splitAmount,
                    "settlementDate": "2024-12-30T00:00:00",
                    "groupID": widget.groupID,
                    "groupName": "NewStr",
                    "expenseID": expense.expenseID,
                    "expenseName": "Road Trip Fuel",
                    "paymentMethod": "UPI"
                  });
                  await updateExpenseSplits({
                    "splitID": expense.splitID,
                    "expenseID": expense.expenseID,
                    "userID": expense.userID,
                    "oweToUserID": expense.oweToUserID,
                    "splitAmount": expense.splitAmount,
                    "isSplit": true,
                    "expenseName": "Utilities Bill",
                    "userName": "Alice",
                    "oweToUserName": "Bob"
                  });
                  setState(() {
                    _expenseSplitsFuture = fetchExpenseSplits(widget.groupID);
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settled successfully!')));
                } catch (error) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to settle expense: $error')));
                }
              },
              child: const Text('Yes', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
