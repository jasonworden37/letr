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

  /// Override the initState to request permissions
  @override
  void initState()
  {
    /// Call the parent function
    super.initState();
    /// Request External storage permission
    requestExternalStorageProject();
  }

  /// This function gets the status of the permission
  void waitForExternalStoragePermissionStatus() async {
    final status = await externalStoragePermission.status;
    setState(() => permissionStatus = status);
  }

  /// This function requests permission to use this feature from the user
  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();

    setState(() {
      permissionStatus = status;
    });
  }

  /// This function calls two functions. One is to check the status of the
  /// external storage permission. The other, if the permission is denied, is called
  /// to request permission from the user. If the user denies permission, a dialog is
  /// shown explaining why we need it and how to turn it on. The user cannot
  /// got further without enabling it
  void requestExternalStorageProject() async
  {
    var status = await Permission.storage.status;

    status = await Permission.storage.request();
    if(!status.isGranted)
    {
      _showDialog();
    }
    else
    {
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

  /// Dialog called to tell the user to go change the permission in settings
  /// so that they can use the app
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