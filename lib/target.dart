import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Home.dart';

class Target extends StatefulWidget {
  int x, y, hash = -1;
  Color col = Colors.transparent;
  bool isRed = false, shouldShake = false, isLocked = false;
  String c, l = "";
  List<String> triedLetters = [];
  TargetController controller;
  final VisibilityCallback onVisibilitySelect;

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
  _Target(TargetController controller) {
    controller.clearLetter = clearLetter;
    controller.setColor = setColor;
    controller.setR = setR;
    controller.shake = shake;
  }

  Color getColor() {
    if (widget.isLocked) {
      widget.col = Colors.lightGreen;
    } else if (widget.c != "-") {
      widget.col = Colors.blue;
    } else {
      widget.col = Colors.transparent;
    }
    return widget.col;
  }

  void clearLetter() {
    setState(() {
      widget.l = "";
    });
  }

  void setColor() {
    setState(() {
      getColor();
    });
  }

  void shake() {
    if (!widget.isLocked) {
      setState(() {
        widget.shouldShake = true;
      });
    }
  }

  void setR() {
    if (widget.isRed) {
      setState(() {
        widget.isRed = false;
      });
    } else if (!widget.isLocked) {
      setState(() {
        widget.isRed = true;
      });
    }
  }

  double shake2(double animation) =>
      2 * (0.5 - (0.5 - Curves.bounceOut.transform(animation)).abs());

  Offset getOffSet(double animation) {
    if (widget.shouldShake) {
      widget.shouldShake = false;
      return Offset(20 * shake2(animation), 0);
    }
    return Offset(0, 0);
  }


  @override
  Widget build(BuildContext context) {
    return DragTarget<Let>(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return InkWell(
            onTap: () {
              if (!widget.isLocked) {
                setState(() {
                  widget.shouldShake = false;
                  widget.l = "";
                  widget.hash = -1;
                  widget.onVisibilitySelect();
                });
              }
            },
            child: ShakeAnimatedWidget(
                enabled: widget.shouldShake,
                duration: const Duration(milliseconds: 1500),
                shakeAngle: Rotation.deg(z:10 ),
                curve: Curves.linear,
                child: Container(
                  decoration: BoxDecoration(
                    color: (widget.isRed) ? Colors.red : getColor(),
                  ),
                  height: 100.0,
                  width: 100.0,
                  child: Center(
                    child: Text(widget.l,
                        style: GoogleFonts.grandstander(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                  ),
                )));
      },
      onAccept: (data) {
        setState(() {
          //widget.isRed = false;
          widget.l = data.letter;
          widget.hash = data.id;
          widget.onVisibilitySelect();
        });
      },
      onWillAccept: (data) {
        return widget.c != "-" && !widget.isLocked;
      },
    );
  }
}
