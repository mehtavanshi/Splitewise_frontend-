import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitwiseapp/screens/Expense/add_expense_screen.dart';
import 'package:splitwiseapp/screens/Expense/expense_splits_screen.dart'; // Import ExpenseSplitsScreen
import '../../Models/expence.dart';
import '../../services/expense_service.dart';
import '../Group/View_member.dart';
import '../Transaction/transaction_list_screen.dart';
import '../theme_provider.dart';

class ExpenseScreen extends StatefulWidget {
  final int groupId;

  const ExpenseScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  int _selectedIndex = 0;
  late Future<List<Expense>> _expenses;
  final ExpenseService _expenseService =
  ExpenseService('http://192.168.206.215:5222/api/Expenses/GetByGroupID');

  @override
  void initState() {
    super.initState();
    _expenses = _expenseService.fetchExpensesByGroupId(widget.groupId);
  }

  Future<void> _loadUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var userId = prefs.getInt('userID') ?? 0;
    });
  }

  List<Widget> _screens() => [_buildExpenseList()];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExpenseSplitsScreen(groupID: widget.groupId),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionScreen(),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_rounded),
            label: 'Split',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Transactions',
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          'Groups Expenses',
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

        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupMembersScreen(groupId: widget.groupId),
              ),
            ),
            icon: const Icon(Icons.group, color: Colors.white),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddExpenseScreen(groupId: widget.groupId),
              ),
            ).then((value) => setState(() {
              _expenses = _expenseService.fetchExpensesByGroupId(widget.groupId);
            })),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          ),
        ],
      ),
      body: _screens()[_selectedIndex],
    );
  }

  Widget _buildExpenseList() {
    return FutureBuilder<List<Expense>>(
      future: _expenses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text(
                'No expenses found for this group.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ));
        }

        final expenses = snapshot.data!;
        return ListView.builder(
          itemCount: expenses.length,
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    expense.expenseName[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                title: Text(
                  expense.expenseName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  'Paid by User ID: ${expense.paidByUserID}\nAmount: ₹${expense.totalAmount}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                trailing: Text(
                  expense.expenseDate.split('T')[0],
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
                onTap: () => _showSplitDialog(expense.expenseID),
                onLongPress: () => _showSettleDialog(expense.expenseID),
              ),
            );
          },
        );
      },
    );
  }

  void _showSplitDialog(int expenseId) {
    showDialog(
      context: context,
      builder: (context) {
        return _buildDialog(
          title: 'Split',
          content: 'Do you want to split?',
          onConfirm: () async {
            await _expenseService.sattleExpence(expenseId);
            setState(() {
              _expenses = _expenseService.fetchExpensesByGroupId(widget.groupId);
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Split up successfully!')));
          },
        );
      },
    );
  }

  void _showSettleDialog(int expenseId) {
    showDialog(
      context: context,
      builder: (context) {
        return _buildDialog(
          title: 'Settle',
          content: 'Do you want to settle?',
          onConfirm: () async {
            await _expenseService.sattleExpence(expenseId);
            setState(() {
              _expenses = _expenseService.fetchExpensesByGroupId(widget.groupId);
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Settled up successfully!')));
          },
        );
      },
    );
  }

  Widget _buildDialog({required String title, required String content, required VoidCallback onConfirm}) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text('Yes', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
