import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letr/target.dart';
import 'Tile.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class TileController {
  late void Function() setVis;
}

class TargetController {
  late void Function() clearLetter;
  late void Function() setColor;
  late void Function() setR;
  late void Function() shake;
}

class _HomePageState extends State<HomePage> {
  Future<List<Tile>> chars = Future<List<Tile>>((){
    return [];
  });

  Future<List<Target>> targets = Future<List<Target>>(()
  {
    return [];
  });
  List<String> letters = ["B", "T", "X", "H", "Y", "A","B", "T", "X", "H", "Y", "A"];
  List<String> empty = ["","","","","","","","","","","","","",""];
  List<List<String>> list = [];
  List<TargetController> targetControllers = [];
 // int test = MediaQuery.of(context).size.width as int;
  int width = 10;
  int height = 10;
  int getIndex(int x, int y) {
    return (x * width) + y;
  }


  List<Tile> getLettersInTileForm(List<String> letters)
  {
    List<Tile> Temptiles = [];
    for (int lnIndex = 0; lnIndex < letters.length; lnIndex++)
    {
      Temptiles.add(
          Tile(
            letter: letters[lnIndex],
            controller: TileController(),
            hash: lnIndex
          )
      );
    }

    return Temptiles;
  }
  List<Target> getTargetFromList()
  {
    List<Target> tempTar = [];
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        int index = getIndex(x, y);
        targetControllers.add(TargetController());
        tempTar.add(Target(
            x: x,
            y: y,
            c: '',
            onVisibilitySelect: () {
              //doVisibility();
            },
            controller: targetControllers[index]));
      }
    }

    return tempTar;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(
          color: Colors.blueGrey
        ),
        child:
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(children: <Widget>[
            FutureBuilder<List<Target>>(
              future: targets,
              builder:
                  (BuildContext context, AsyncSnapshot<List<Target>> snapshot) {
                return Expanded(
                    flex: 7,
                    child: GridView.count(
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: width,
                        children: getTargetFromList()));

              },
            ),
            FutureBuilder<List<Tile>>(
              future: chars,
              builder: (BuildContext context, AsyncSnapshot<List<Tile>> snapshot) {
                return Expanded(
                    flex: 2,
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                      child: GridView.count(
                          mainAxisSpacing: 7,
                          crossAxisSpacing: 7,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 7,
                          children: getLettersInTileForm(letters)
                      )
                  )
                );
              },
            ),
          ]),
        )
    );  }
}
class Let {
  String letter;
  int id;

  Let(this.letter, this.id);
}

typedef VisibilityCallback = void Function();

