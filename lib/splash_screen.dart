import 'dart:async';

import 'package:flutter/material.dart';
import 'package:letr/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState()
  {
    /// Call the parent function
    super.initState();
    /// This screen will act as a splash screen. We will wait three seconds on
    /// this screen to make it look like things are loading. Then, after three
    /// seconds, go to our home page
    Timer(
        const Duration(seconds: 3),
            () =>Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                const HomePage(title: 'LETR'))));
  }

  /// The main widget for our splash screen
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