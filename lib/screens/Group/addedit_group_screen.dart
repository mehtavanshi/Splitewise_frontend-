import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/GroupModel.dart';
import '../../services/group_service.dart';
import '../theme_provider.dart';

class GroupAddEditScreen extends StatefulWidget {
  final int groupId;
  final Function() onGroupUpdated;
  final String? name;

  GroupAddEditScreen({required this.groupId, required this.onGroupUpdated, this.name});

  @override
  _GroupAddEditScreenState createState() => _GroupAddEditScreenState();
}

class _GroupAddEditScreenState extends State<GroupAddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupUserNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.groupId != 0) {
      _groupNameController.text = widget.name ?? '';
      _fetchGroupDetails();
    }
  }

  Future<void> _fetchGroupDetails() async {
    setState(() => _isLoading = true);
    try {
      Group group = await fetchGroupById(widget.groupId);
      _groupNameController.text = group.groupName;
      _groupUserNameController.text = group.createdByUserName;
    } catch (e) {
      print('Error fetching group details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        int userId = prefs.getInt("userId") ?? 0;
        if (widget.groupId == 0) {
          await createGroup(groupName: _groupNameController.text.trim(), createdByUserID: userId);
          _showSnackbar('Group created successfully!', Colors.green);
        } else {
          await updateGroup(
            widget.groupId,
            Group(
              groupId: widget.groupId,
              groupName: _groupNameController.text.trim(),
              createdByUserID: userId,
              createdAt: "",
              createdByUserName: _groupUserNameController.text.trim(),
            ),
          );
          _showSnackbar('Group updated successfully!', Colors.green);
        }
        widget.onGroupUpdated();
        Navigator.pop(context);
      } catch (error) {
        _showSnackbar('Error: $error', Colors.red);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDelete() async {
    try {
      await deleteGroup(widget.groupId);
      widget.onGroupUpdated();
      Navigator.pop(context);
    } catch (error) {
      print('Error deleting group: $error');
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color appBarColor = isDarkMode ? Colors.grey[900]! : Colors.blueAccent;
    Color iconColor = isDarkMode ? Colors.white : Colors.black;
    Color buttonColor = isDarkMode ? Colors.grey[800]! : Colors.blueAccent;


    return Scaffold(
      appBar: AppBar(

        title: Text(
            widget.groupId == 0 ? 'Add Group' : 'Edit Group',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: isDark
              ? Colors.white
              : Colors.grey.shade200),),

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
        actions: widget.groupId != 0
            ? [
          IconButton(
            icon: Icon(Icons.delete, color: iconColor),
            onPressed: _handleDelete,
          ),
        ]
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a group name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        widget.groupId == 0 ? 'Add Group' : 'Save Changes',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
