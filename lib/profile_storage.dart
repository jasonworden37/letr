import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ProfileStorage
{

  Future<String> get localPath async
  {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get localFile async
  {
    final path = await localPath;
    return File('$path/profile.json');
  }

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

  Future<File> writeToProfile(String name) async
  {
    final file = await localFile;

    return file.writeAsString(name);

  }
}
