import 'dart:io';
import 'dart:convert';
import 'package:letr/profile.dart';
import 'package:path_provider/path_provider.dart';

import 'Tile.dart';
import 'target.dart';

class ProfileStorage
{
  Profile profile = Profile([], [], 0, 0, 0, 0, 0, 0, 0);
  /// This function retrieves the localPath of the users device and returns
  /// it in a future
  Future<String> get localPath async
  {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// This function gets the users local file using the local path
  /// from the users device and returns it in a future
  Future<File> get localFile async
  {
    final path = await localPath;
    return File('$path/profile.json');
  }

  /// This function reads a users profile by getting the path and file
  /// from the users device and returns it in a future
  Future<String> readProfile() async
  {
    try
    {
      final file = await localFile;

      final contents = await file.readAsString();

      return contents;

    } catch (e)
    {
      return "Error reading users files";
    }
  }

  /// This function writes to a users profile by getting the users local file
  /// It takes in String that is written to the file
  /// It returns a future of a file
  Future<File> writeToProfile(
      List<String> storedTiles,
      List<String> storedTargets) async
  {
    /// Set the vars to our current states
    profile.setStoredTargets(storedTargets);
    profile.setStoredTiles(storedTiles);

    /// Grab the local file
    final file = await localFile;
    /// Write the new data to the file
    return await file.writeAsString(json.encode(profile));
  }

  /// This function is used to read from the users profile.
  /// It returns a Map of keys and dynamic values from the json file
  Future<Map<String, dynamic>> readFromProfile() async
  {
    /// Grab the users local file
    File file = await localFile;
    /// Check if the file does not exist
    if (!(await file.exists()))
    {
      /// Since it doesn't exist, call writeToProfile to create it with empty
      /// data to avoid an error
      file = await writeToProfile([], []);
    }
    /// Read the files contents
    String contents = await file.readAsString();
    /// Return the contents in json form
    return jsonDecode(contents);
  }

  /// Function that set the profiles 'didGet' variable to a value
  /// The param index is used to determine which day the called is trying to set
  /// and the param didGet is used to set it to that value
  void setSpecificDidGetDayVar(int index, int didGet)
  {

    /// Switch statement over index, set day depending on number
    switch(index) {
      case 0: {  profile.didGetSunday = didGet; }
      break;

      case 1: {  profile.didGetMonday = didGet; }
      break;

      case 2: {  profile.didGetTuesday = didGet; }
      break;

      case 3: {  profile.didGetWednesday = didGet; }
      break;

      case 4: {  profile.didGetThursday = didGet; }
      break;

      case 5: {  profile.didGetFriday = didGet; }
      break;

      case 6: {  profile.didGetSaturday = didGet; }
      break;

      default: {}
      break;
    }
  }


}
