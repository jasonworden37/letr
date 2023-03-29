import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:letr/splash_screen.dart';
import 'package:provider/provider.dart';
import 'ad_state.dart';

/// This main function gets called when we first start the app
void main() {
  /// Initialize some ad stuff
  WidgetsFlutterBinding.ensureInitialized();
  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);
  /// Run our app
  runApp(
    Provider.value(
      value: adState,
      builder: (context,child) => const MainApp(),
    )
  );
}

/// This class is our MainApp Class. It is the first class used when we
/// first run our app
class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);
  /// This is our main widget for this class. It is a simple splash screen
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letr',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SplashScreen(),
    );
  }
}