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
  /// Text Controller used to capture the input of the users name
  final TextEditingController _textFieldController = TextEditingController();

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

    status = await Permission.storage.request();
    if(!status.isGranted)
    {
      print('Permission not granted ');
      _showDialog();
    }
    else
    {
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

  _showDialog()  {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Letr needs access to your local storage. Go to settings'
                  'and enable it to continue'),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}