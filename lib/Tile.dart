import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home.dart';

class Tile extends StatefulWidget {
  /// The letter that the tile is representing
  String letter;
  /// The specific hash for the tile, this is important because if we have two
  /// tiles that are the same letter, we would have no way of telling the actual
  /// objects apart unless each one had a has
  int hash;
  /// Boolean variable to indicate if a tile should be visible or not. It should
  /// always be visible if it has not been placed on the target board. And it
  /// should never be visible if it has been placed on the target board.
  bool visibility;
  /// Controller Object that is used so that the home page and target class
  /// can communicate with this class
  final TileController controller;

  /// Constructor for this class
  Tile(
      {Key? key,
      required this.letter,
      required this.visibility,
      required this.controller,
      required this.hash})
      : super(key: key);

  @override
  _Tile createState() => _Tile(controller);
}

class _Tile extends State<Tile> {
  /// Constructor for _Tile class
  _Tile(TileController _controller) {
    _controller.setVisibility = setVisibility;
  }

  /// A function that is passed to the TileController. When called, it sets
  /// the visibility of the specific widget to true. This can be called from the
  /// target class when a user taps a target to get rid of the letter
  void setVisibility()
  {
    setState(() {
      widget.visibility = true;
    });
  }

  /// Our main widget for the Tile Class
  @override
  Widget build(BuildContext context) {
    /// This widget allows our container to be draggable
    return Draggable<Let>(
      data: Let(widget.letter, widget.hash),
      /// This widget allows our container to be visible or invisible
      /// This Draggable child is the thing we see when the tile is in the
      /// rack of letters
      child: Visibility(
          visible: widget.visibility,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          /// Our actual container for the tile
          child: Container(
              height: 25,
              width: 25,
              decoration: const BoxDecoration(
                color: Colors.lightGreen,
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Center(
                  child: Text(widget.letter,
                      style: GoogleFonts.grandstander(fontSize: 42,fontWeight: FontWeight.w900, color: Colors.white))))),
      /// This feedback container for Draggable is what we see while we are dragging
      /// the object. This is a little different than when it is set in place
      feedback: Container(
          height: 50,
          width: 50,
          decoration: const BoxDecoration(
            color: Colors.lightGreen,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Center(
              child: Text(widget.letter,
                  style: GoogleFonts.grandstander(fontSize: 42,fontWeight: FontWeight.w900, color: Colors.white, decoration: TextDecoration.none)))),
      /// This childWhenDragging container is what we see on the rack of letters
      /// while we are dragging a letter. In this case we set it to an empty container
      /// to give the user the illusion we have picked it up
      childWhenDragging: Container(),
      /// This function automatically gets called when we put the tile down
      /// Here is where we set the visibility to false
      onDragCompleted: () {
        setState(() {
          //widget.visibility = false;
        });
      },
      /// This function automatically gets called when we start dragging a tile
      onDragStarted: (){
      },
      /// This function automatically gets called when we finish dragging a tile
      onDragEnd: (data){

      },
    );
  }
}
