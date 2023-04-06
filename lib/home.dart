import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:letr/ad_state.dart';
import 'package:letr/profile_storage.dart';
import 'package:letr/settings.dart';
import 'package:letr/shared_prefs.dart';
import 'package:letr/shop.dart';
import 'package:letr/target.dart';
import 'package:provider/provider.dart';
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

  /// Shared Prefs instance
  SharedPrefs sharedPrefs = SharedPrefs();

  /// A List Tiles as a future, return when retrieve the users existing letters
  late List<List<String>> allWeeksLetters;
  Future<List<Tile>> futureTiles = Future<List<Tile>>(() {
    return [];
  });

  /// A list of Targets as a future
  Future<List<Target>> futureTargets = Future<List<Target>>(() {
    return [];
  });

  /// Initialize date to get day of week etc
  DateTime date = DateTime.now();

  /// Initialize the startOfWeekDate. Originally set to today. Later changed to
  /// the date of the Sunday of this week
  DateTime startOfWeekDate = DateTime.now();

  /// Initialize the numOfWeek int used to keep track of what day it is in numbers
  /// Sunday:0 Monday:1 etc
  int numOfWeek = -1;

  /// Initialize the dayOfWeek String used to keep a string name of the day of the
  /// week. Sunday, Monday etc
  String dayOfWeek = '';

  /// Initialize variables to act as holders for json profile data
  List<String> currentLettersInTiles = [];
  List<String> currentLettersInTargets = [];

  /// Vars to check if we already retrieved letters for this week
  late Map<String, dynamic> jsonResponse;

  /// The instance of our profile storage which we use to store profile data
  /// like board and rack states
  ProfileStorage profileStorage = ProfileStorage();

  /// Variables to hold our height and width
  int width = 16;
  int height = 16;

  /// A list of our TargetController
  List<TargetController> targetControllers = [];

  /// A list of our TileControllers
  List<TileController> tileControllers = [];

  /// The variables to hold our ads
  BannerAd? banner;

  /// Override the initState to take care of a few things before out page
  /// gets created
  @override
  void initState() {
    /// Init the start day of the week
    startOfWeekDate = findFirstDateOfTheWeek(date);

    /// Increment the number of times the users has opened the app.
    sharedPrefs.incrementCounter();

    /// Set the day of the week variable
    numOfWeek = date.weekday;
    getDayOfWeek(numOfWeek);

    /// Wait for the userName to be filled, then if there is no name saved (null)
    /// this means this is the first time the user has opened the app
    /// Open a dialog to ask what their name is
    sharedPrefs.getName().then((value) {
      /// If name is null, we need their name
      if (value == 'gamer') {
        /// Set the users starting currency to 1000
        sharedPrefs.setCurrency(1000);
        /// Open Dialog to get their name
        _showDialog();
      }
    });

    /// Wait for openedAppCounter to be filled, then if it is their 100th, 200th
    /// etc time opening the app, award them with coins.
    sharedPrefs.getCounter().then((value) {
      if (value % 100 == 0) {
        /// Give the user 100 coins
        sharedPrefs.addCurrency(100);
      }
    });

    /// Call the loadAll function. This function is used to load anything we need
    /// to start this page of the app. It is called in initState so that all of
    /// this happens early on. The reason it is a separate function is so that
    /// we can use functions in it and wait for them to complete. You cannot
    /// use async in initState
    loadAll();

    /// Call the parent function
    super.initState();

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
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: double.infinity,
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(color: Colors.blueGrey),
        child: Scaffold(
          appBar: AppBar(
            title: Text(date.toString().split(' ')[0]),
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
                          future: sharedPrefs.getName(),
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
                              future: sharedPrefs.getCurrency(),
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
                    /// Pop the drawer. BOOM. User at home page
                    Navigator.pop(context);
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
                        builder: (context) => ShopPage(sharedPrefs: sharedPrefs)
                    ));
                    //Navigator.pop(context);
                  },
                ),

                /// Settings page in our drawer. Once clicked, the user will be
                /// redirected to the settings page, unless already there
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage(sharedPrefs: sharedPrefs)
                        ));
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

            /// A future builder used to build all the targets once we get them
            /// from storage. Inside is an InteractiveViewer which allows the user
            /// to zoom in and out of the board to enlarge the spaces. Inside this
            /// is the actual board, a gridview.
            FutureBuilder<List<Target>>(
              future: futureTargets,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Target>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done)
                {
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
                                  children: snapshot.requireData))));
                }
                else
                {
                  return Container();
                }
              },
            ),

            /// A future builder that waits for a List<Tile>. Once 'tiles' is
            /// populated, this tiles are drawn in the form of a Gridview
            FutureBuilder<List<Tile>>(
              future: futureTiles,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Tile>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done)
                {
                  return Expanded(
                      child: Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: GridView.count(
                              mainAxisSpacing: 7,
                              physics: const ScrollPhysics(),
                              crossAxisSpacing: 7,
                              crossAxisCount: 7,
                              children: snapshot.requireData)));
                }
                else
                {
                  return Container();
                }
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
                      heroTag: 'Blank-Tag',
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

  /// This function takes care of the visibility for each Tile on the rack. It
  /// figures out if the letter(hash for letter) is on the board as a target. If
  /// it is, it makes that tile invisible, if its not, it makes it visible. The
  /// reason we set all the non-present-targets to visible is incase the user
  /// took a tile off the board
  Future<void> doVisibility() async {
    /// Initialize some temp vars
    List<int> temp = [];
    List<Target> tempTars = await futureTargets;
    /// Loop through our current Targets
    for(int index = 0; index < tempTars.length; index++)
    {
      /// If we have a letter at this target
      if(tempTars[index].l != "")
      {
        /// Add the has for this letter to our list
        /// This tile is on the board so we need to set it invisible
        temp.add(tempTars[index].hash);
      }

    }

    /// Initialize and wait for our Tiles
    List<Tile> tempTile = await futureTiles;
    /// Loop trough our currentTiles on the rack
    for (int i = 0; i < tempTile.length; i++) {
      /// If this tiles hash is not in our temp list, it is not on the target
      /// board.
      if (!temp.contains(tempTile[i].hash)) {
        /// Call setVisibility to make it visible
        tileControllers[i].setVisibility();
      }
    }
  }

  /// Creates a pop up dialog and Alert Dialog that asks the user for their name
  /// This should only be called once, the first time the user ever opens the
  /// app. It saves the name in sharedPreferences
  _showDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Welcome!'),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: 'Enter Text here'),
            ),
            actions: [
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: () {
                  Future<String>(() {
                    return _textFieldController.text;
                  }).then((value) {
                    sharedPrefs.editProfileName(value);
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
      tileControllers.add(TileController());
      tempTiles.add(Tile(
          visibility: true,
          letter: letters[lnIndex],
          controller: tileControllers[lnIndex],
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

  /// Function used to update the users profile so that their info is saved
  /// This should be called every time something new is done.
  Future<void> updateProfileData() async {
    /// Call the write to profile function in profileStorage class
    await profileStorage.writeToProfile(
        currentLettersInTiles, currentLettersInTargets);
  }

  /// Function called to read the players current data in their storage
  /// It calls the profileStorage read function that returns a json list of
  /// attributes in the users storage. This can be used to populate the users
  /// board and rack
  Future<void> readPlayerData() async {
    /// Call the readFromProfile function the the profileStorage class and store
    /// the result in a map. This will act as json data
    jsonResponse = await profileStorage.readFromProfile();

    /// Loop through each part of the response, printing the key and value.
    jsonResponse.forEach((key, value) async {
     /// print(key + " is: " + value.toString());
      if (key == 'tiles') {
        await addLettersToRack(List<String>.from(value));
      }
    });
  }

  /// Function that takes in a week number and retrieves the letters for that
  /// week number. It returns this as a string
  Future<String> loadLettersFromFile(String weekNum) async
  {
    /// Get all letters from the letters.txt file in assets
    String allLetters = await rootBundle.loadString('assets/letters.txt');

    /// Split this into a list, separating at each week so we can get a particular
    /// week of letters
    List<String> splitWeeks = allLetters.split(':');

    /// Initialize variables
    String weekLetters = "NULL";

    /// Loop through all the weeks of letters
    for (int index = 0; index < splitWeeks.length; index++) {
      /// Check if the current index is this weeks letters. Set it to our var
      /// if it is
      if (splitWeeks[index].contains(weekNum)) weekLetters = splitWeeks[index];
    }

    /// Return this weeks letters
    return weekLetters;
  }

  /// Function that calls loadLettersFromFile. It then separates the letters into
  /// a list of lists of string so that we can access each day of the weeks letters
  Future<List<List<String>>> getWeeksLetters() async {
    /// Initialize vars
    List<List<String>> weeksLetters = [];
    /// Store this weeks letters in a string var
    String thisWeeksLetters = await loadLettersFromFile(startOfWeekDate.toString().split(' ')[0]);

    /// Split this weeks letters into a list where each index is a day of the weeks
    /// letters
    List<String> eachDayList = thisWeeksLetters.split(',');

    /// Remove the first index. This will never be letters. It will always be
    /// what week it is
    eachDayList.removeAt(0);

    /// Loop through this list of strings
    for (int index = 0; index < eachDayList.length; index++) {
      /// Initialize inner list var
      List<String> listOfLetters = [];

      /// Loop through each char in this particular days string
      for (int charAt = 0; charAt < eachDayList[index].length; charAt++) {
        /// Add this char to the list
        listOfLetters.add(eachDayList[index][charAt]);
      }

      /// Add this list of strings to our list of list of strings
      weeksLetters.add(listOfLetters);
    }


    /// TEMPORARY

    // for(int i = 0; i < weeksLetters.length; i++)
    //   {
    //     print('---------------------------------');
    //     for(int j =0; j < weeksLetters[i].length; j++)
    //       {
    //         print(weeksLetters[i][j]);
    //       }
    //     print('-------------------------------------');
    //   }
    /// TEMPORARY
    /// Return our list of this weeks letters
    return weeksLetters;
  }

  /// Function that is called at the beginning of initState to load everything we
  /// need before finalizing the app. This is important because we cannot
  /// make initState async
  void loadAll() async
  {
    /// Get all the letters for this week
    allWeeksLetters = await getWeeksLetters();

    /// Read the data from the players file. If this file does not exist, one
    /// will be created for the player
    await readPlayerData();

    /// If we did not get sundays letters yet (0 is false)
    if (jsonResponse['sunday'] == 0) {
      await addDayToRack(0);
    }
    else
    {
      /// Update the didGet Variable for this day so we keep track of it
      profileStorage.setSpecificDidGetDayVar(0, 1);
    }
    /// If we did not get today's letters yet (0 is false)
    if (jsonResponse[dayOfWeek] == 0) {
      await addDayToRack(numOfWeek);
    }
    else
    {
      /// Update the didGet Variable for this day so we keep track of it
      profileStorage.setSpecificDidGetDayVar(numOfWeek, 1);
    }

    /// Set futureTargets and futureTiles by calling the respective functions
    setState(() {
      futureTargets = Future<List<Target>>(() {
        return getTargetFromList();
      });

      futureTiles = Future<List<Tile>>(() {
        return getLettersInTileForm(currentLettersInTiles);
      });
    });

  }


  /// This is called with a list of letters to be added to the users rack
  Future<void> addLettersToRack(List<String> letters) async
  {
    /// Loop through the letters and add them one by one
    for (int index = 0; index < letters.length; index++) {
      currentLettersInTiles.add(letters[index]);
    }
  }

  /// Add a certain days letters to the rack
  /// This is called when the user first logs in for the week(to get sundays letters)
  /// or first logs on for the day
  Future<void> addDayToRack(int day) async
  {
    /// Get the letters for this day
    List<String> dayLetters = await getSpecificDayLetters(day);
    /// Add the letters
    await addLettersToRack(dayLetters);
    /// Update the files
    await updateProfileData();
  }

  /// Function can be used to return a List<String> which will return the
  /// specific letters for that specific day of this particular week
  Future<List<String>> getSpecificDayLetters(int day) async
  {
    /// Set the value of the 'didGet' for this day to true
    profileStorage.setSpecificDidGetDayVar(day, 1);

    /// Return specific letters at this index
    return allWeeksLetters[day];
  }

  /// Return the day of the week in String form, given the index of the day of
  /// the week
  void getDayOfWeek(int day)
  {
    /// Switch statement over index, set day depending on number
    switch(day) {
      case 0: {  dayOfWeek = 'sunday'; }
      break;

      case 1: {  dayOfWeek = 'monday'; }
      break;

      case 2: {  dayOfWeek = 'tuesday'; }
      break;

      case 3: {  dayOfWeek = 'wednesday'; }
      break;

      case 4: {  dayOfWeek = 'thursday'; }
      break;

      case 5: {  dayOfWeek = 'friday'; }
      break;

      case 6: {  dayOfWeek = 'saturday'; }
      break;

      default: {}
      break;
    }
  }

  /// Function used to get the date of the first day of the week. In this case
  /// it will always be sunday. Takes in the date as a parameter and returns
  /// a date of the sunday of this week
  DateTime findFirstDateOfTheWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % DateTime.daysPerWeek));
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
