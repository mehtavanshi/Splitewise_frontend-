class ExpenseSplit {
  final int splitID;
  final int expenseID;
  final int userID;
  final double splitAmount;
  final String expenseName;
  final String? userName;
  final int oweToUserID;
  final String? oweToUserName;

  ExpenseSplit({
    required this.splitID,
    required this.expenseID,
    required this.userID,
    required this.splitAmount,
    required this.expenseName,
    this.userName,
    required this.oweToUserID,
    this.oweToUserName,
  });

  /// Factory constructor to create an `ExpenseSplit` object from JSON
  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    return ExpenseSplit(
      splitID: json['splitID'] as int,
      expenseID: json['expenseID'] as int,
      userID: json['userID'] as int,
      splitAmount: (json['splitAmount'] as num).toDouble(),
      expenseName: json['expenseName'] as String,
      userName: json['userName'] as String?,
      oweToUserID: json['oweToUserID'] as int,
      oweToUserName: json['oweToUserName'] as String?,
    );
  }

  /// Converts `ExpenseSplit` object to JSON
  Map<String, dynamic> toJson() {
    return {
      'splitID': splitID,
      'expenseID': expenseID,
      'userID': userID,
      'splitAmount': splitAmount,
      'expenseName': expenseName,
      'userName': userName,
      'oweToUserID': oweToUserID,
      'oweToUserName': oweToUserName,
    };
  }
}
