import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitwiseapp/screens/Expense/expense_screen.dart';
import 'package:splitwiseapp/screens/addedit_user_screen.dart';
import 'package:splitwiseapp/screens/login_screen.dart';
import '../../Models/GroupModel.dart';
import '../../services/api_service.dart';
import '../../services/group_service.dart';
import '../theme_provider.dart';
import 'addedit_group_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupListScreen extends StatefulWidget {
  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  Future<List<Group>>? _groupFuture;
  String? userImageUrl; // Store user image URL

  @override
  void initState() {
    super.initState();
    _loadUserImage();
    _groupFuture = fetchGroupsFromAPI();
  }

  Future<void> _loadUserImage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userImageUrl = prefs.getString('profileImageUrl'); // Fetch from storage
    });
  }

  Future<void> _refreshGroupList() async {
    setState(() {
      _groupFuture = fetchGroupsFromAPI();
    });
  }

  Future<void> _deleteGroup(int groupId) async {
    try {
      await deleteGroup(groupId);
      _refreshGroupList();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Groups',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey.shade200,
          ),
        ),
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
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: isDark ? Colors.white : Colors.white,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          FutureBuilder<String>(
            future: getUserImage(), // Function to fetch user image
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return  Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: userImageUrl != null && userImageUrl!.isNotEmpty
                        ? NetworkImage(userImageUrl!) // Display image if available
                        : null,
                    child: userImageUrl == null || userImageUrl!.isEmpty
                        ? Icon(Icons.person, color: Colors.white) // Default avatar
                        : null,
                  ),
                );
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(snapshot.data!), // User profile image
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('userId').then((data) => {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                )
              });
            },
          ),
        ],
      ),

      body: FutureBuilder<List<Group>>(
        future: _groupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var groups = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                var group = groups[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ExpenseScreen(groupId: group.groupId),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    elevation: 6,
                    color: isDark ? Colors.grey[850] : Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: isDark
                            ? Colors.blue.shade300
                            : Colors.blueAccent,
                        child: Icon(Icons.group, color: Colors.white),
                      ),
                      title: Text(
                        group.groupName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Created By: ${group.createdByUserName}',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700]),
                            ),
                            Text(
                              'At: ${group.createdAt}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: isDark
                                    ? Colors.blue.shade300
                                    : Colors.blueAccent),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupAddEditScreen(
                                    groupId: group.groupId,
                                    name: group.groupName,
                                    onGroupUpdated: _refreshGroupList,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              _showDeleteDialog(group.groupId);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text(
                'No groups found.',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupAddEditScreen(
                groupId: 0,
                onGroupUpdated: _refreshGroupList,
              ),
            ),
          );
        },
        backgroundColor: isDark ? Colors.blue.shade400 : Colors.blueAccent,
        child: Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  void _showDeleteDialog(int groupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Delete Group?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this group?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel')),
            TextButton(
                onPressed: () async {
                  await _deleteGroup(groupId);
                  Navigator.of(context).pop();
                },
                child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );
  }
}
