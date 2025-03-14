class Group {
  int groupId;
  String groupName;
  int createdByUserID;
  String createdAt;
  String createdByUserName;

  Group({
    required this.groupId,
    required this.groupName,
    required this.createdByUserID,
    required this.createdAt,
    required this.createdByUserName,
  });

  // Factory constructor to parse JSON into a Group object
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['groupID'] ?? 0, // Default to 0 if null
      groupName: json['groupName']?.toString() ?? '', // Default to empty string
      createdAt: json['createdAt']?.toString() ?? '',
      createdByUserID: json['createdByUserID'] ?? 0,
        createdByUserName : json['createdByUserName'] ?? 'asd',
    );
  }

  // Convert Group object to JSON
  Map<String, dynamic> toJson() {
    return {
      'groupID': groupId,
      'groupName': groupName,
      'createdAt': createdAt,
      'createdByUserID': createdByUserID,
      'createdByUserName':createdByUserName,
    };
  }

  // Copy with method to create a new instance with modified fields
  Group copyWith({
    int? groupId,
    String? groupName,
    String? createdAt,
    int? createdBy,
    String? createdByUserName,
  }) {
    return Group(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      createdAt: createdAt ?? this.createdAt,
      createdByUserID: createdBy ?? this.createdByUserID,
      createdByUserName : createdByUserName ?? this.createdByUserName,
    );
  }
}
