class User {
  int userId;
  String userName;
  String email;
  String password;
  String mobileNo;
  String? profileImageUrl; // New field added

  User({
    required this.userId,
    required this.userName,
    required this.email,
    required this.password,
    required this.mobileNo,
    this.profileImageUrl, // Optional field
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userID'],
      userName: json['userName'].toString(),
      email: json['email'].toString(),
      password: json['passwordHash'].toString(),
      mobileNo: json['mobileNumber'].toString(),
      profileImageUrl: json['profileImageUrl']?.toString(), // Handle null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userId,
      'userName': userName,
      'email': email,
      'passwordHash': password,
      'mobileNumber': mobileNo,
      'profileImageUrl': profileImageUrl, // Include in API requests
    };
  }

  User copyWith({
    int? userId,
    String? userName,
    String? email,
    String? password,
    String? mobileNo,
    String? profileImageUrl, // Add this field
  }) {
    return User(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      password: password ?? this.password,
      mobileNo: mobileNo ?? this.mobileNo,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl, // Handle update
    );
  }
}
