import 'Tile.dart';
import 'target.dart';

class Profile
{
  late List<String>  storedTiles;
  late List<String> storedTargets;
  late int didGetSunday, didGetMonday, didGetTuesday,
      didGetWednesday, didGetThursday, didGetFriday, didGetSaturday;


  Profile(
      this.storedTiles,
      this.storedTargets,
      this.didGetSunday,
      this.didGetMonday,
      this.didGetTuesday,
      this.didGetWednesday,
      this.didGetThursday,
      this.didGetFriday,
      this.didGetSaturday,
      );


  /// Setter to set the stored Tiles in this class
  setStoredTiles(List<String> storedTiles)
  {
    this.storedTiles = storedTiles;
  }

  /// Setter to set the Stored Targets in this class
  setStoredTargets(List<String> storedTargets)
  {
    this.storedTargets = storedTargets;
  }

  /// Function used to set the variables from a map
  Profile.fromJson(Map<String, dynamic> json) {
    storedTiles = json['tiles'];
    storedTargets = json['targets'];
    didGetSunday = json['sunday'];
    didGetMonday = json['monday'];
    didGetTuesday = json['tuesday'];
    didGetWednesday = json['wednesday'];
    didGetThursday = json['thursday'];
    didGetFriday = json['friday'];
    didGetSaturday = json['saturday'];
  }

  /// Function used to create Json data
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['tiles'] = storedTiles;
    data['targets'] = storedTargets;
    data['sunday'] = didGetSunday;
    data['monday'] = didGetMonday;
    data['tuesday'] = didGetTuesday;
    data['wednesday'] = didGetWednesday;
    data['thursday'] = didGetThursday;
    data['friday'] = didGetFriday;
    data['saturday'] = didGetSaturday;
    return data;
  }
}