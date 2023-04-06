import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs
{
  /// Shared Preferences instance
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Shared Preferences values saved for the user
  /// OpenedAppCounter is used to keep a count of how many times the users opens
  /// the app
  late Future<int> openedAppCounter;

  /// userName is used to keep track of the users name. It is set the first time
  /// the user opens the app
  late Future<String> userName;

  /// currency is used to keep track of how many coins the user has, this starts
  /// at 1000
  late Future<int> currency;

  /// getName function is used to retrieve the name of the user
  /// and also updates the local variable incase it is being used
  Future<String> getName() async
  {
    userName = _prefs.then((SharedPreferences prefs) {
      return prefs.getString('name') ?? 'gamer';
    });

    return userName;
  }

  /// _getCounter function is used to retrieve the number of times a user has
  /// opened the app and also updates the local variable incase it is being used
  Future<int> getCounter() async
  {
    openedAppCounter = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('counter') ?? 0;
    });

    return openedAppCounter;
  }

  /// _getCurrency function is used to retrieve the currency of the user
  /// and also updates the local variable incase it is being used
  Future<int> getCurrency() async
  {
    currency = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('currency') ?? 0;
    });

    return currency;
  }

  /// _subtractCurrency function is used to add currency to a users bank
  /// This will be saved in shared preferences
  Future<void> subtractCurrency(int sub) async {
    final SharedPreferences prefs = await _prefs;
    final int cur = (prefs.getInt('currency') ?? 0) - sub;
      currency = prefs.setInt('currency', cur).then((bool success) {
        return cur;
    });
  }

  /// _addCurrency function is used to add currency to a users bank
  /// This will be saved in shared preferences
  Future<void> addCurrency(int add) async {
    final SharedPreferences prefs = await _prefs;
    final int cur = (prefs.getInt('currency') ?? 0) + add;
      currency = prefs.setInt('currency', cur).then((bool success) {
        return cur;
    });
  }

  /// _setCurrency function is used to set the currency of a user. This will
  /// overwrite any previous currency and it will be lost forever
  Future<void> setCurrency(int set) async {
    final SharedPreferences prefs = await _prefs;
      currency = prefs.setInt('currency', set).then((bool success) {
        return set;
    });
  }

  /// _incrementCounter function is used to increment the counter that keeps
  /// track of how many times the user has opened the app, by one. Then it is
  /// stored in shared preferences
  Future<void> incrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('counter') ?? 0) + 1;

      openedAppCounter = prefs.setInt('counter', counter).then((bool success) {
        return counter;
    });
  }

  /// EditProfileName function is used to edit the users name
  /// This is called but _showDialog when the user enters their name. From here
  /// the name is stored in shared preferences
  Future<void> editProfileName(String newName) async {
    final SharedPreferences prefs = await _prefs;
      userName = prefs.setString('name', newName).then((bool success) {
        return newName;
    });
  }
}