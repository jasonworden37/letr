import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:letr/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Create the status for requesting if we are allowed to use external
  /// storage
  PermissionStatus permissionStatus = PermissionStatus.denied;
  /// Create the actual permission for the external storage
  Permission externalStoragePermission = Permission.manageExternalStorage;
  @override
  void initState()
  {
    /// Call the parent function
    super.initState();
    requestExternalStorageProject();
  }

  /// Wait for a status
  void waitForExternalStoragePermissionStatus() async {
    final status = await externalStoragePermission.status;
    setState(() => permissionStatus = status);
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      permissionStatus = status;
    });
  }

  void requestExternalStorageProject() async
  {
    var status = await Permission.storage.status;

    while(!status.isGranted)
    {
      print('Permission not originally granted ');
      status = await Permission.storage.request();
    }
      print('Permission Granted');

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