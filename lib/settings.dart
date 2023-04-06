import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget
{
  const SettingsPage({Key? key}) : super(key: key);


  @override
  State<SettingsPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingsPage>
{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SettingsPage(),
    );
  }

}