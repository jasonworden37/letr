import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home.dart';

class Tile extends StatefulWidget {
  String letter;
  int hash;
  final TileController controller;

  Tile(
      {Key? key,
      required this.letter,
      required this.controller,
      required this.hash})
      : super(key: key);

  @override
  _Tile createState() => _Tile(controller);
}

class _Tile extends State<Tile> {
  _Tile(TileController _controller) {
  }


  @override
  Widget build(BuildContext context) {
    return Draggable<Let>(
      data: Let(widget.letter, widget.hash),
      child: Container(
          height: 50,
          width: 50,
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              child: Center(
                  child: Text(widget.letter,
                      style: GoogleFonts.grandstander(fontSize: 42,fontWeight: FontWeight.w900, color: Colors.white)))),
      feedback: Container(
          height: 38,
          width: 38,
          decoration: const BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          child: Center(
              child: Text(widget.letter,
                  style: GoogleFonts.grandstander(fontSize: 42,fontWeight: FontWeight.w900, color: Colors.white, decoration: TextDecoration.none)))),
      childWhenDragging: Container(),
      onDragCompleted: () {

      },
    );
  }
}
