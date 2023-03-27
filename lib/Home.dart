import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:letr/adState.dart';
import 'package:letr/target.dart';
import 'package:provider/provider.dart';
import 'Tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  /// A List Tiles as a future, return when retrieve the users existing letters
  Future<List<Tile>> tiles = Future<List<Tile>>(() {
    return [];
  });

  /// A list of Targets as a future
  Future<List<Target>> targets = Future<List<Target>>(() {
    return [];
  });

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
    "A"
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

  /// The variables to hold our ads
  BannerAd? banner;

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
            adUnitId: adState.BannerAdUnitId,
            request: const AdRequest(),
            listener: adState.bannerAdListener)
          ..load();
      });
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
  void giveHint() {}

  /// The home page widget
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(color: Colors.blueGrey),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          /// The Main colum for the page
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
                    flex: 2,
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
                            crossAxisSpacing: 7,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 7,
                            children: getLettersInTileForm(letters))));
              },
            ),
            /// A Row inside the main column use to hold some buttons
            Row(children: <Widget>[
              /// This button is used remove all character from the board
              /// If a user is having trouble, they can remove them all so that
              /// they can fully start over. They should be prompted and asked
              /// 'are you sure' before we actually follow through
              FloatingActionButton(
                  child: const Icon(Icons.delete),
                  backgroundColor: Colors.lightGreenAccent,
                  onPressed: giveHint),

              /// This button will be used to get a free tile that can be placed
              /// anywhere they want. Similar to the hint button, the user will
              /// first have to watch an ad fully.
              FloatingActionButton(
                  child: const Icon(Icons.square_rounded),
                  backgroundColor: Colors.lightGreenAccent,
                  onPressed: giveHint),

              /// This button is remove adds
              /// The user will have to pay a fee for this
              FloatingActionButton.extended(
                  label: const Text('Ads'),
                  icon: const Icon(Icons.not_interested),
                  backgroundColor: Colors.lightGreenAccent,
                  onPressed: giveHint),

            ]),
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
  void doVisibility() {}
}

/// Class Let is a class to represent a letter
class Let {
  String letter;
  int id;

  Let(this.letter, this.id);
}

/// Class TileController to control the tiles
class TileController {
  late void Function() setVis;
}

/// Class TargetController used to control the Targets
class TargetController {
  late void Function() clearLetter;
  late void Function() setColor;
  late void Function() setR;
  late void Function() shake;
}

/// The callback function for visibility
typedef VisibilityCallback = void Function();
