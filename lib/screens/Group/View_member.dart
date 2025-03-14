import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/GroupMember.dart';
import '../../services/group_service.dart';
import '../theme_provider.dart';

class GroupMembersScreen extends StatefulWidget {
  final int groupId;

  const GroupMembersScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupMembersScreenState createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  late Future<List<GroupMember>> _groupMembers;
  late Future<List<Map<String, dynamic>>> usersFuture;
  List<int> selectedUserIds = [];

  @override
  void initState() {
    super.initState();
    _groupMembers = fetchGroupMembers(widget.groupId);
    usersFuture = fetchUsers();
  }

  void _addSelectedMembers() async {
    for (var userId in selectedUserIds) {
      await addGroupMembers(userId, widget.groupId);
    }
    setState(() {
      _groupMembers = fetchGroupMembers(widget.groupId);
      selectedUserIds.clear();
    });
    Navigator.of(context).pop();
  }

  void _showAddMembersDialog() async {
    List<GroupMember> existingMembers = await _groupMembers;
    List<Map<String, dynamic>> allUsers = await usersFuture;

    List<Map<String, dynamic>> availableUsers = allUsers.where((user) =>
    !existingMembers.any((member) => member.userID == user['userID'])).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Users', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: availableUsers.map((user) {
                      return CheckboxListTile(
                        title: Text(user['userName'], style: TextStyle(fontSize: 16)),
                        value: selectedUserIds.contains(user['userID']),
                        activeColor: Colors.blueAccent,
                        onChanged: (bool? selected) {
                          setState(() {
                            if (selected == true) {
                              selectedUserIds.add(user['userID']);
                            } else {
                              selectedUserIds.remove(user['userID']);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                setState(() {
                  selectedUserIds.clear();
                });
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: Text('Add Members', style: TextStyle(color: Colors.white)),
              onPressed: _addSelectedMembers,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'view Members',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: isDark
              ? Colors.white
              : Colors.grey.shade200),),

        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:isDark
                  ? [Colors.grey.shade900, Colors.grey.shade800]
                  : [Colors.blue.shade800, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.person_add_alt, color: Colors.white),
            onPressed: _showAddMembersDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<GroupMember>>(
        future: _groupMembers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.redAccent)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No members found in this group.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final member = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    title: Text(member.userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('Joined: ${member.joinDate}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        member.userName[0].toUpperCase(),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await deleteGroupMember(member.memberID);
                        setState(() {
                          _groupMembers = fetchGroupMembers(widget.groupId);
                        });
                      },
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
}
