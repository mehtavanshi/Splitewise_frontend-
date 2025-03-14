/// GroupMember model class
class GroupMember {
  final int memberID;
  final int groupID;
  final int userID;
  final String joinDate;
  final String userName;

  GroupMember({
    required this.memberID,
    required this.groupID,
    required this.userID,
    required this.joinDate,
    required this.userName
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      memberID: json['memberID'],
      groupID: json['groupID'],
      userID: json['userID'],
      joinDate: json['joinDate'],
      userName: json['userName']
    );
  }
}


