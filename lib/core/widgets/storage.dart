import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<List<String>> loadTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList('tokens') ?? []);
  }

  static Future<void> addToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tokens = (prefs.getStringList('tokens') ?? []);
    tokens.add(token);
    await prefs.setStringList('tokens', tokens);
  }

  static Future<void> delToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tokens = (prefs.getStringList('tokens') ?? []);
    tokens.remove(token);
    await prefs.setStringList('tokens', tokens);
  }
}
