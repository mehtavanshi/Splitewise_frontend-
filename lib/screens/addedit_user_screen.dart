import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitwiseapp/screens/login_screen.dart';
import 'package:splitwiseapp/screens/theme_provider.dart';
import '../Models/UsersModel.dart';
import '../services/api_service.dart';

class AddEditUserScreen extends StatefulWidget {
  final int userId;

  AddEditUserScreen({required this.userId});

  @override
  _AddEditUserScreenState createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.userId != 0) {
      _fetchUserDetails();
    }
  }

  Future<void> _fetchUserDetails() async {
    setState(() => _isLoading = true);

    try {
      User user = await fetchUserById(widget.userId);
      _userNameController.text = user.userName;
      _emailController.text = user.email;
      _passwordController.text = user.password;
      _mobileNoController.text = user.mobileNo;
    } catch (e) {
      print('Error fetching user details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validateUserName(String? value) {
    if (value == null || value.isEmpty) return 'User name must not be empty.';
    if (value.length < 3 || value.length > 50) return 'User name must be between 3 and 50 characters.';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email must not be empty.';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) return 'Invalid email format.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password must not be empty.';
    if (value.length < 6) return 'Password must be at least 6 characters long.';
    return null;
  }

  String? _validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) return 'Mobile number must not be empty.';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return 'Mobile number must be 10 digits.';
    return null;
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        if (widget.userId == 0) {
          await createUser(
            userName: _userNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            mobileNo: _mobileNoController.text.trim(),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User created successfully!'), backgroundColor: Colors.green),
          );
          final prefs = await SharedPreferences.getInstance();
          prefs.getInt("userId");

        } else {
          await updateUser(
            widget.userId,
            User(
              userId: widget.userId,
              userName: _userNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              mobileNo: _mobileNoController.text.trim(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User updated successfully!'), backgroundColor: Colors.green),
          );
        }

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;


    return Scaffold(
      backgroundColor:isDark? Colors.black:Colors.blue.shade50,
      appBar: AppBar(

        title: Text(widget.userId == 0 ? 'Sign Up' : 'Edit Profile',
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
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())

          : Padding(
        padding: const EdgeInsets.all(20.0),

        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: _userNameController,
                      label: 'User Name',
                      icon: Icons.person,
                      validator: _validateUserName,
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: _validatePassword,
                    ),
                    _buildTextField(
                      controller: _mobileNoController,
                      label: 'Mobile Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: _validateMobileNumber,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        widget.userId == 0 ? 'Sign Up' : 'Save Changes',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
      ),
    );
  }
}
