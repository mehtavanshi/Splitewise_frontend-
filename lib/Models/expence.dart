class Expense {
  final int expenseID;
  final int groupID;
  final int paidByUserID;
  final String expenseName;
  final double totalAmount;
  final String expenseDate;

  Expense({
    required this.expenseID,
    required this.groupID,
    required this.paidByUserID,
    required this.expenseName,
    required this.totalAmount,
    required this.expenseDate,
  });

  /// Factory method to create an Expense instance from JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseID: json['expenseID'],
      groupID: json['groupID'],
      paidByUserID: json['paidByUserID'],
      expenseName: json['expenseName'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      expenseDate: json['expenseDate'],
    );
  }

  /// Converts an Expense instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'expenseID': expenseID,
      'groupID': groupID,
      'paidByUserID': paidByUserID,
      'expenseName': expenseName,
      'totalAmount': totalAmount,
      'expenseDate': expenseDate,
    };
  }
}
