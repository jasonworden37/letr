import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:letr/shared_prefs.dart';
import 'package:letr/shop.dart';

import 'home.dart';

class SettingsPage extends StatefulWidget
{
  const SettingsPage({Key? key, required this.sharedPrefs}) : super(key: key);
  final SharedPrefs sharedPrefs;

  @override
  State<SettingsPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingsPage>
{
  /// The variables to hold our ads
  BannerAd? banner;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: double.infinity,
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(color: Colors.blueGrey),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            actions: <Widget>[

              /// Currently this button is used to add 100 currency to the users
              /// balance. This is for testing purposes only
              IconButton(
                icon: const Icon(
                  Icons.bug_report,
                  color: Colors.white,
                ),
                onPressed: () {
                 /// Report a bug
                },
              )
            ],
          ),

          /// Drawer used to change pages from the home screen
          /// Current options for this drawer include:
          /// Shop: which will redirect the user to a shop where they can buy
          /// different color and style tiles
          /// Settings: which a user will be able to use to change settings such
          /// as their name or hint types
          /// Remove ads option that lets the user pay to remove ads
          drawer: Drawer(
            backgroundColor: Colors.grey,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                  ),
                  child: Column(
                      children: <Widget>[

                        /// This futureBuilder is waiting for the users name to be grabbed
                        /// Once it is grabbed, we can paste it in the message of the day
                        /// If it is not grabbed, we just say hello gamer
                        FutureBuilder<String>(
                          future: widget.sharedPrefs.userName,
                          builder:
                              (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Text('Hello there,\n ' + snapshot.data!,
                                  style: GoogleFonts.grandstander(
                                      fontSize: 42, fontWeight: FontWeight.w900,
                                      color: Colors.white));
                            }
                            else {
                              return Text('Hello there,\n Gamer!',
                                  style: GoogleFonts.grandstander(
                                      fontSize: 42, fontWeight: FontWeight.w900,
                                      color: Colors.white));
                            }
                          },
                        ),

                        /// Spacer for space constraints
                        const Spacer(),

                        /// Row used to put money and money symbol on same line
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                                Icons.attach_money_sharp,
                                color: Colors.yellow,
                                size: 25),

                            /// FutureBuilder used to paste the users currency
                            /// on the message screen. It waits for the currency
                            /// to be grabbed. If that does not work we paste
                            /// that the user has no currency
                            FutureBuilder<int>(
                              future: widget.sharedPrefs.currency,
                              builder:
                                  (BuildContext context, AsyncSnapshot<
                                  int> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Text(snapshot.data.toString(),
                                      style: GoogleFonts.grandstander(
                                          fontSize: 21,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white));
                                }
                                else {
                                  return Text(
                                      '', style: GoogleFonts.grandstander(
                                      fontSize: 21, fontWeight: FontWeight.w900,
                                      color: Colors.white));
                                }
                              },
                            ),
                          ],
                        )
                      ]
                  ),
                ),

                /// Home Page. Once clicked, the user will be redirected to
                /// the home page of the app, unless already there
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(title: 'LETR')
                        ));
                  },
                ),

                /// Shop page in our drawer. Once clicked, the user will be
                /// redirected to the shop, unless already there
                ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Shop'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShopPage(sharedPrefs: widget.sharedPrefs)
                        ));
                  },
                ),

                /// Settings page in our drawer. Once clicked, the user will be
                /// redirected to the settings page, unless already there
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    /// Pop the drawer. BOOM. User at settings page
                    Navigator.pop(context);
                  },
                ),

                /// This button is remove adds
                /// The user will have to pay a fee for this
                ListTile(
                  leading: const Icon(Icons.not_interested),
                  title: const Text('Remove Ads'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,

          /// The Main column for the page
          body: Column(children: <Widget>[
            /// This code is for the bottom banner ad
            /// If it is null, we will just put an empty box
            /// Otherwise, we will put the banner add
            if (banner == null)
              const SizedBox(
                height: 50,
              )
            else
              SizedBox(
                height: 50,
                child: AdWidget(ad: banner!),
              )

          ]),
        ));
  }

}