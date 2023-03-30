import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:letr/ad_state.dart';
import 'package:letr/profile.dart';
import 'package:letr/profile_storage.dart';
import 'package:letr/target.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  /// Title of the app
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Text Controller used to capture the input of the users name 
  final TextEditingController _textFieldController = TextEditingController();

  /// Shared Preferences instance
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  /// Shared Preferences values saved for the user
  /// OpenedAppCounter is used to keep a count of how many times the users opens
  /// the app
  late Future<int> openedAppCounter;
  /// userName is used to keep track of the users name. It is set the first time
  /// the user opens the app
  late Future<String> userName;
  /// currency is used to keep track of how many coins the user has, this starts
  /// at 1000
  late Future<int> currency;
  /// A List Tiles as a future, return when retrieve the users existing letters
  Future<List<Tile>> tiles = Future<List<Tile>>(() {
    return [];
  });
  /// A list of Targets as a future
  Future<List<Target>> targets = Future<List<Target>>(() {
    return [];
  });

  /// The instance of our profile storage which we use to store profile data
  /// like board and rack states
  ProfileStorage profileStorage = ProfileStorage();
  /// A temporary list of letters used for the rack
  List<String> letters = [
    "B",
    "T",
    "X",
    "H",
    "Y",
    "A",
    "B",
    "T",
    "X",
    "H",
    "Y",
    "A",
    "B",
    "T",
    "X",
    "H",
    "Y",
    "A",
    "B",
    "T",
    "X",
    "H",
    "Y",
    "A",
  ];

  /// Variables to hold our height and width
  int width = 16;
  int height = 16;

  /// A temporary list of "" used for the targets
  List<String> empty = ["", "", "", "", "", "", "", "", "", "", "", "", "", ""];

  /// A double List of String to store what is on the board
  List<List<String>> list = [];

  /// A list of our TargetController
  List<TargetController> targetControllers = [];

  /// A list of our TileControllers
  List<TileController> tileControllers = [];

  /// The variables to hold our ads
  BannerAd? banner;

  /// Override the initState to take care of a few things before out page
  /// gets created
  @override
  void initState()
  {
    /// Call the parent function
    super.initState();
    /// Increment the number of times the users has opened the app.
    _incrementCounter();
    /// Set the local app count variable to what is stored in the shared
    /// preferences
    openedAppCounter = _getCounter();
    /// Set the local userName variable to what is stored in the shared
    /// preferences app
    userName = _getName();
    /// Set the local currency variable to what is stored int the shared
    /// preferences app. If there is none saved, the default is 1000
    currency = _getCurrency();
    /// Wait for the userName to be filled, then if there is no name saved (null)
    /// this means this is the first time the user has opened the app
    /// Open a dialog to ask what their name is
    userName.then((value){
      /// If name is null, we need their name
      if(value == 'null')
      {
        /// Set the users starting currency to 1000
        _setCurrency(1000);
        /// Open Dialog to get their name
        _showDialog();
      }
    });
    /// Wait for openedAppCounter to be filled, then if it is their 100th, 200th
    /// etc time opening the app, award them with coins.
    openedAppCounter.then((value) {
      if(value % 100 == 0)
      {
        /// Give the user 100 coins
        _addCurrency(100);
      }
    });

    readPlayerData();
  }

  /// Overriding this function to initialize our ads
  @override
  void didChangeDependencies() {
    /// Call the parent function
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initialization.then((status) {
      setState(() {
        /// Initialize the bannerAd for the bottom of the game
        banner = BannerAd(
            size: AdSize.banner,
            adUnitId: adState.bannerAdUnitId,
            request: const AdRequest(),
            listener: adState.bannerAdListener)
          ..load();
      });
    });
  }
  /// The home page widget
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(color: Colors.blueGrey),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Week 34'),
            actions: <Widget>[
              /// This button is used remove all character from the board
              /// If a user is having trouble, they can remove them all so that
              /// they can fully start over. They should be prompted and asked
              /// 'are you sure' before we actually follow through
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: () {
                  // do something
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
                          future: userName,
                          builder:
                              (BuildContext context, AsyncSnapshot<String> snapshot) {
                                if(snapshot.connectionState == ConnectionState.done)
                                {
                                  return Text('Hello there,\n ' + snapshot.data!, style: GoogleFonts.grandstander(
                                      fontSize: 42,fontWeight: FontWeight.w900,
                                      color: Colors.white));
                                }
                                else
                                {
                                  return Text('Hello there,\n Gamer!', style: GoogleFonts.grandstander(
                                      fontSize: 42,fontWeight: FontWeight.w900,
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
                              future: currency,
                              builder:
                                  (BuildContext context, AsyncSnapshot<int> snapshot) {
                                if(snapshot.connectionState == ConnectionState.done)
                                {
                                  return Text(snapshot.data.toString(), style: GoogleFonts.grandstander(
                                      fontSize: 21,fontWeight: FontWeight.w900,
                                      color: Colors.white));
                                }
                                else
                                {
                                  return Text('', style: GoogleFonts.grandstander(
                                      fontSize: 21,fontWeight: FontWeight.w900,
                                      color: Colors.white));
                                }
                              },
                            ),
                          ],
                        )
                      ]
                  ),
                ),
                /// Shop page in our drawer. Once clicked, the user will be
                /// redirected to the shop
                ListTile(
                  leading: const Icon(Icons.shopping_cart),
                  title: const Text('Shop'),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
                /// Settings page in our drawer. Once clicked, the user will be
                /// redirected to the settings page
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
                /// This button is remove adds
                /// The user will have to pay a fee for this
                ListTile(
                  leading: const Icon(Icons.not_interested),
                  title: const Text('Remove Ads'),
                  onTap: () {
                  },
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          /// The Main column for the page
          body: Column(children: <Widget>[
            /// A future builder used to build all the targets once we get them
            /// from storage. Inside is an InteractiveViewer which allows the user
            /// to zoom in and out of the board to enlarge the spaces. Inside this
            /// is the actual board, a gridview.
            FutureBuilder<List<Target>>(
              future: targets,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Target>> snapshot) {
                return Expanded(
                    flex: 3,
                    /// InteractiveViewer used for zooming in and out of grid
                    child: InteractiveViewer(
                        maxScale: 100,
                        child: SizedBox(
                            width: 400,
                            child: GridView.count(
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 3,
                                crossAxisSpacing: 3,
                                crossAxisCount: width,
                                children: getTargetFromList()))));
              },
            ),
            /// A future builder that waits for a List<Tile>. Once 'tiles' is
            /// populated, this tiles are drawn in the form of a Gridview
            FutureBuilder<List<Tile>>(
              future: tiles,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Tile>> snapshot) {
                return Expanded(
                    child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: GridView.count(
                            mainAxisSpacing: 7,
                            physics: const ScrollPhysics(),
                            crossAxisSpacing: 7,
                            crossAxisCount: 7,
                            children: getLettersInTileForm(letters))));
              },
            ),
            /// A Row inside the main column use to hold some buttons
            Expanded(child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                FloatingActionButton.extended(
                    label: const Text('Check'),
                    icon: const Icon(Icons.check),
                    backgroundColor: Colors.teal,
                    heroTag: 'Check-Tag',
                    onPressed: giveBlankTile),
              /// This button will be used to get a free tile that can be placed
              /// anywhere they want. Similar to the hint button, the user will
              /// first have to watch an ad fully.
              FloatingActionButton.extended(
                  label: const Text('Blank'),
                  icon: const Icon(Icons.square_rounded),
                  backgroundColor: Colors.teal,
                  heroTag: 'Blank-Tag' ,
                  onPressed: updateProfileData),

            ])
            ),
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

  /// @param x the x coordinate
  /// @param y the y coordinate
  /// @return int The index at a certain (x,y) coordinate
  int getIndex(int x, int y) {
    return (x * width) + y;
  }

  /// TODO: Take care of the visibility for the tiles and targets
  Future<void> doVisibility() async {
    // List<int> temp = [];
    // for (var x = 0; x < height; x++) {
    //   for (var y = 0; y < width; y++) {
    //     if (list[x][y] != "-") {
    //       int index = (x * width) + y;
    //       if ( targets.[index].l != "") {
    //         temp.add(targets[index].hash);
    //       }
    //     }
    //   }
    // }
    // for (int i = 0; i < letters.length; i++) {
    //   if (!temp.contains(tiles[i].hash)) {
    //     tileControllers[i].setVis();
    //   }
    // }
  }

  /// getName function is used to retrieve the name of the user
  /// and also updates the local variable incase it is being used
  Future<String> _getName() async
  {
    userName = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('name') ?? 'null';
    });

    return userName;
  }

  /// _getCounter function is used to retrieve the number of times a user has
  /// opened the app and also updates the local variable incase it is being used
  Future<int> _getCounter() async
  {
    openedAppCounter = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('counter') ?? 0;
    });

    return openedAppCounter;
  }

  /// _getCurrency function is used to retrieve the currency of the user
  /// and also updates the local variable incase it is being used
  Future<int> _getCurrency() async
  {
    currency = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('currency') ?? 0;
    });

    return currency;
  }
  /// _subtractCurrency function is used to add currency to a users bank
  /// This will be saved in shared preferences
  Future<void> _subtractCurrency(int sub) async {
    final SharedPreferences prefs = await _prefs;
    final int cur = (prefs.getInt('currency') ?? 0) - sub;
    setState(() {
      currency = prefs.setInt('currency', cur).then((bool success) {
        return cur;
      });
    });
  }

  /// _addCurrency function is used to add currency to a users bank
  /// This will be saved in shared preferences
  Future<void> _addCurrency(int add) async {
    final SharedPreferences prefs = await _prefs;
    final int cur = (prefs.getInt('currency') ?? 0) + add;
    setState(() {
      currency = prefs.setInt('currency', cur).then((bool success) {
        return cur;
      });
    });
  }

  /// _setCurrency function is used to set the currency of a user. This will
  /// overwrite any previous currency and it will be lost forever
  Future<void> _setCurrency(int set) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      currency = prefs.setInt('currency', set).then((bool success) {
        return set;
      });
    });
  }

  /// _incrementCounter function is used to increment the counter that keeps
  /// track of how many times the user has opened the app, by one. Then it is
  /// stored in shared preferences
  Future<void> _incrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('counter') ?? 0) + 1;

    setState(() {
      openedAppCounter = prefs.setInt('counter', counter).then((bool success) {
        return counter;
      });
    });
  }

  /// EditProfileName function is used to edit the users name
  /// This is called but _showDialog when the user enters their name. From here
  /// the name is stored in shared preferences
  Future<void> _editProfileName(String newName) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      userName = prefs.setString('name', newName).then((bool success) {
        return newName;
      });
    });
  }

  /// Creates a pop up dialog and Alert Dialog that asks the user for their name
  /// This should only be called once, the first time the user ever opens the
  /// app. It saves the name in sharedPreferences
  _showDialog()  {
     return showDialog(
         context: context,
         builder: (context){
           return AlertDialog(
             title: const Text('Welcome!'),
             content: TextField(
               controller: _textFieldController,
               decoration:const InputDecoration(hintText: 'Enter Text here'),
             ),
             actions: [
               ElevatedButton(
                 child: const Text('Submit'),
                 onPressed: () {
                   userName = Future<String>((){return _textFieldController.text;});
                   userName.then((value){
                     _editProfileName(value);
                   });
                   Navigator.of(context).pop();
                 },
               )
             ],
           );
         });
   }

  /// @param List<String> A list of letters the user has on their rack
  /// Create a tile for each letter and store it in a list
  /// @return List<Tile> the letters created into tiles, in a list
  List<Tile> getLettersInTileForm(List<String> letters) {
    /// Temporary list for Tiles
    List<Tile> tempTiles = [];
    /// Loop through letters the user has and create tiles for them
    for (int lnIndex = 0; lnIndex < letters.length; lnIndex++) {
      /// Add the created tiles to the temp list
      tempTiles.add(Tile(
          visibility: true,
          letter: letters[lnIndex],
          controller: TileController(),
          hash: lnIndex));
    }
    /// return the temp list
    return tempTiles;
  }

  /// Create targets for each spot on the board using the height and width
  /// Give each target a unique controller and coordinates
  /// @return List<Target>
  List<Target> getTargetFromList() {
    /// Temporary list for Targets
    List<Target> tempTar = [];
    /// Loop through width and height
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        int index = getIndex(x, y);
        targetControllers.add(TargetController());
        /// Create a Target for this coordinate and add it to the list
        tempTar.add(Target(
            x: x,
            y: y,
            c: '',
            onVisibilitySelect: () {
              doVisibility();
            },
            controller: targetControllers[index]));
      }
    }
    /// return the temp list
    return tempTar;
  }

  /// TODO: Function to give a hint
  void giveBlankTile() {}

  Future<void> updateProfileData() async {
    profileStorage.writeToProfile(await tiles, await targets);
  }

  Future<void> readPlayerData () async {
    Map<String, dynamic> jsonResponse = await profileStorage.readFromProfile();
    jsonResponse.forEach((key, value) {
      print(key + " is: " + value);
    });
  }
}

/// Class Let is a class to represent a letter
class Let {
  String letter;
  int id;

  Let(this.letter, this.id);
}

/// Class TileController to allow communication between the Tile, Target and
/// Home dart objects
class TileController {
  late void Function() setVisibility;
}

/// Class TargetController to allow communication between the Tile, Target and
/// Home dart objects
class TargetController {
  late void Function() clearLetter;
  late void Function() setColor;
}

/// The callback function for visibility. This is call
typedef VisibilityCallback = void Function();
