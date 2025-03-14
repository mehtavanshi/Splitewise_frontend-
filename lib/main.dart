import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:splitwiseapp/screens/Group/group_list_screen.dart';
import 'package:splitwiseapp/screens/login_screen.dart';
import 'package:splitwiseapp/screens/theme_provider.dart';
import 'package:splitwiseapp/services/api_service.dart';
import 'Models/UsersModel.dart';
import 'screens/users_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoginScreen(),
    );
  }
}