import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';

class Target extends StatefulWidget {
  /// Define some integers, x and y used for the coordinate in the grid,
  /// hash used for the index of the array so that each target has its on
  /// unique value we can use to address it
  int x, y, hash = -1;
  /// Define the color of the target
  Color col = Colors.transparent;
  /// Define some strings, L is the letter on the target
  String c, l = "";
  TargetController controller;
  /// Initialize a callback function that allows us to communicate with the
  /// home page and turn on or off the visibility of any of our tiles
  final VisibilityCallback onVisibilitySelect;

  /// Constructor for the target class
  Target(
      {Key? key,
      required this.x,
      required this.y,
      required this.c,
      required this.onVisibilitySelect,
      required this.controller})
      : super(key: key);

  @override
  _Target createState() => _Target(controller);
}

class _Target extends State<Target> {
  /// Define our targetController. This allows the Home page to call function
  /// and change the state of a particular target
  _Target(TargetController controller) {
    controller.clearLetter = clearLetter;
    controller.setColor = setColor;
  }

  /// Gets the color that the target should be depending on what is in the target
  Color getColor() {
    /// If there is nothing in the target, make it white30
    if (widget.c != "-") {
      widget.col = Colors.white30;
    }
    /// Otherwise, there is a letter there. Change the color to the color of
    /// the tile
    else
    {
      widget.col = Colors.transparent;
    }
    return widget.col;
  }

  /// Updates and clears the letter that is in the target
  void clearLetter() {
    setState(() {
      widget.l = "";
    });
  }

  /// Updates the color of the target when this function is called
  void setColor() {
    setState(() {
      getColor();
    });
  }

  /// Our main Widget for a target block
  @override
  Widget build(BuildContext context) {
    return DragTarget<Let>(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        /// Inkwell allows us to be able to tap the Container
        return InkWell(
          /// This function is called when we tap the inkWell/Container
          /// When this happens, we want to set the letter of the target to
          /// nothing and make this letter visible again
          onTap: () {
                setState(() {
                  widget.l = "";
                  widget.hash = -1;
                  widget.onVisibilitySelect();
                });
            },
            /// The actual container for the target
            child:  Container(
                  decoration: BoxDecoration(
                    color: getColor(),
                  ),
                  height: 100.0,
                  width: 100.0,
                  child: Center(
                    /// The letter that appears on the Target
                    child: Text(widget.l,
                        style: GoogleFonts.grandstander(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                  ),
                ));
      },
      /// This function is called when a target block accepts a tile
      /// This is where we change the target letter to whatever the tile
      /// letter was. We also need to set the visibility of the tile it came from
      onAccept: (data) {
        setState(() {
          widget.l = data.letter;
          widget.hash = data.id;
          widget.onVisibilitySelect();
        });
      },
      /// This function is called before a tile is accepted in a target
      /// In this case, we only allow a user to put a tile on a target if there
      /// is not already a tile there
      onWillAccept: (data) {
        return widget.c != "-";
      },
    );
  }
}
