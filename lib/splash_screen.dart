import 'dart:async';

import 'package:flutter/material.dart';
import 'package:letr/home.dart';
import 'package:letr/profile_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState()
  {
    super.initState();
    Timer(
        const Duration(seconds: 3),
            () =>Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
            HomePage(title: 'LETR', storage: ProfileStorage()))));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.teal,
      body: Center
        (
        child: Text('SplashScreen'),
      ),
    );
  }

}