import 'package:flutter/material.dart';
import 'package:splitwiseapp/screens/Group/group_list_screen.dart';
import 'package:splitwiseapp/screens/addedit_user_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    checkUserLogin();
  }

  Future<void> checkUserLogin() async {
    int? userId = await getUserData("userId");
    if (userId != null && userId > 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GroupListScreen()),
      );
    }
  }

  Future<int?> getUserData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        Map<String, dynamic> response = await fetchUsersFromAPILogin(email, password);

        if (response['success']) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt("userId", response['data']['userId']);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful!'), backgroundColor: Colors.green),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GroupListScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid credentials. Please sign up!'), backgroundColor: Colors.red),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditUserScreen(userId: 0),
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.black : Colors.blue;
    final backgroundColor = isDarkMode ? Colors.black26 : Colors.blue.shade50;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.blue.shade100;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 80,
                  color: primaryColor,
                ),
                SizedBox(height: 10),
                Text(
                  'Splitwise App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined, color: primaryColor),
                            filled: true,
                            fillColor: backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                            filled: true,
                            fillColor: backgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddEditUserScreen(userId: 0)),
                            );
                          },
                          child: Text('Don’t have an account? Sign Up', style: TextStyle(fontSize: 16, color: primaryColor)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
