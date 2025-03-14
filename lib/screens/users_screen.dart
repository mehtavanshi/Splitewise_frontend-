import 'package:flutter/material.dart';
import '../Models/UsersModel.dart';
import '../services/api_service.dart';
import '../screens/addedit_user_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  Future<dynamic>? _userFuture; // Make _userFuture nullable

  @override
  void initState() {
    super.initState();
    // Initialize _userFuture after the state is initialized
    _userFuture = fetchUsersFromAPI();
  }

  // Method to refresh the list of users after adding/updating
  Future<void> _refreshUserList() async {
    setState(() {
      _userFuture = fetchUsersFromAPI(); // Re-fetch the users from API
    });
  }

  // Method to delete user by ID (optional)
  Future<void> _deleteUser(int userId) async {
    try {
      await deleteUser(userId); // Delete user via API
      _refreshUserList(); // Refresh the user list after deletion
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Navigate to AddEditUserScreen for adding a new user
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditUserScreen(
                    userId: 0, // '0' for new user
                    // onUserAdded: _refreshUserList, // Pass the refresh callback
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<dynamic>(
        future: _userFuture,  // Use the nullable _userFuture here
        builder: (context, snapshot) {
          // Check connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            var users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      user.userName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      user.email,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Navigate to AddEditUserScreen with the selected user ID
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditUserScreen(
                                  userId: user.userId, // Pass the user ID
                                  // onUserAdded: _refreshUserList, // Refresh the list after edit
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete User'),
                                  content: Text('Are you sure you want to delete this user?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await deleteUser(user.userId); // Delete user via API
                                          setState(() {
                                            _userFuture = fetchUsersFromAPI(); // Refresh the user list
                                          });
                                          Navigator.of(context).pop(); // Close the dialog
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('User deleted successfully!')),
                                          );
                                        } catch (error) {
                                          Navigator.of(context).pop(); // Close the dialog
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Failed to delete user: $error')),
                                          );
                                        }
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No users found.'));
          }
        },
      ),
    );
  }
}
