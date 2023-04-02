import 'Tile.dart';
import 'target.dart';

class Profile
{
  late List<Tile>  storedTiles;
  late List<Target> storedTargets;
  late int didGetSunday;


  Profile(
      this.storedTiles,
      this.storedTargets,
      this.didGetSunday
      );


  setStoredTiles(List<Tile> storedTiles)
  {
    this.storedTiles = storedTiles;
  }

  setStoredTargets(List<Target> storedTargets)
  {
    this.storedTargets = storedTargets;
  }

  Profile.fromJson(Map<String, dynamic> json) {
    //storedTiles = json['tiles'];
    //storedTargets = json['targets'];
    didGetSunday = json['sunday'];


  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    // data['tiles'] = storedTiles;
    // data['targets'] = storedTargets;
    data['sunday'] = didGetSunday;
    return data;
  }
}