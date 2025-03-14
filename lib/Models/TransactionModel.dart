class TransactionModel {
  final int transactionID;
  final int expenseID;
  final int paidByUserID;
  final String? paidByUserName;
  final int owedByUserID;
  final String? owedByUserName;
  final double amount;
  final String paymentStatus;

  TransactionModel({
    required this.transactionID,
    required this.expenseID,
    required this.paidByUserID,
    required this.paidByUserName,
    required this.owedByUserID,
    required this.owedByUserName,
    required this.amount,
    required this.paymentStatus,
  });

  // Factory constructor to create a model from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionID: json['transactionID'],
      expenseID: json['expenseID'],
      paidByUserID: json['paidByUserID'],
      paidByUserName: json['paidByUserName'],
      owedByUserID: json['owedByUserID'],
      owedByUserName: json['owedByUserName'],
      amount: (json['amount'] as num).toDouble(), // Ensuring proper decimal conversion
      paymentStatus: json['paymentStatus'],
    );
  }

  // Method to convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'transactionID': transactionID,
      'expenseID': expenseID,
      'paidByUserID': paidByUserID,
      'paidByUserName': paidByUserName,
      'owedByUserID': owedByUserID,
      'owedByUserName': owedByUserName,
      'amount': amount,
      'paymentStatus': paymentStatus,
    };
  }
}
