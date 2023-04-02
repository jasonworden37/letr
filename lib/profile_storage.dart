import 'dart:io';
import 'dart:convert';
import 'package:letr/profile.dart';
import 'package:path_provider/path_provider.dart';

import 'Tile.dart';
import 'target.dart';

class ProfileStorage
{
  Profile profile = Profile([], [], 0);
  /// This function retrieves the localPath of the users device and returns
  /// it in a future
  Future<String> get localPath async
  {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
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
  Future<File> writeToProfile(List<Tile>  storedTiles, List<Target> storedTargets) async
  {
    profile.setStoredTargets(storedTargets);
    profile.setStoredTiles(storedTiles);
    final file = await localFile;
    return file.writeAsString(json.encode(profile));
  }

  Future<Map<String, dynamic>> readFromProfile() async
  {
    final file = await localFile;
    String contents = '';
    try
    {
      contents = await file.readAsString();
    }
    catch (e)
    {
      writeToProfile([], []);
    }
    return jsonDecode(contents);
  }
}
