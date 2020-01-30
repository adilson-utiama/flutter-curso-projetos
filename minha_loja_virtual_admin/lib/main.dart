import 'package:flutter/material.dart';
import 'package:minha_loja_virtual_admin/screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loja Virtual Admin',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
