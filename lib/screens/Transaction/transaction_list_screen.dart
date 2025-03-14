import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/TransactionModel.dart';
import '../../services/transaction_service.dart';
import '../../screens/theme_provider.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<TransactionModel> transactions = [];
  bool isLoading = true;
  int? userID;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt("userId") ?? 0;

    if (id != null) {
      userID = id;
      try {
        List<TransactionModel> fetchedTransactions = await fetchTransactionsByUserID(id);
        print('TransactionUID:' + id.toString());
        setState(() {
          transactions = fetchedTransactions;
          isLoading = false;
        });
      } catch (e) {
        print("Error fetching transactions: $e");
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900] // Dark mode color
            : Colors.blueAccent, // Light mode color
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),

      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
          : transactions.isEmpty
          ? Center(
        child: Text(
          "No transactions available",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return _buildTransactionCard(transactions[index], isDarkMode);
        },
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction, bool isDarkMode) {
    bool isOwedByUser = transaction.owedByUserID == userID;
    Color cardColor = isOwedByUser
        ? (isDarkMode ? Colors.red : Colors.redAccent)
        : (isDarkMode ? Colors.green : Colors.greenAccent);

    IconData icon = isOwedByUser ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: cardColor,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: cardColor),
        ),
        title: Text(
          isOwedByUser
              ? "You sent to ${transaction.paidByUserName}"
              : "${transaction.owedByUserName} sent to you",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          "Amount: ₹${transaction.amount.toStringAsFixed(2)}",
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        trailing: Text(
          transaction.paymentStatus,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
