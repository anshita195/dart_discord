import 'dart:convert';

import 'package:dart_discord/models/user.dart';
import 'package:dart_discord/database/database.dart';

class checkValidity {
  bool check = false;

  static bool checkLogin(String currentUser) {
    if (currentUser == '') {
      return false;
    }
    return true;
  }

  static Future<bool> checkRegistration(String userName) async {
    var path = 'lib/database/users.db';
    Db userDb = Db(path);
    await userDb.openDb();
    List<dynamic>? records = await userDb.storeDb(false);
    for (var rec in records!) {
      if (rec.key == userName) return true;
    }
    return false;
  }

  static Future<bool> checkServer(String serverName) async {
    var path = 'lib/database/server.db';
    Db serverDb = Db(path);
    await serverDb.openDb();
    List<dynamic>? records = await serverDb.storeDb(true);
    String? record = await serverDb.findDb(serverName);
    await serverDb.closeDb();
    if (record == '') return false;
    return true;
  }

  static Future<bool> checkServerUser(
      String username, String serverName) async {
    var path = 'lib/database/server.db';
    Db serverDb = Db(path);
    await serverDb.openDb();
    List<dynamic>? records = await serverDb.storeDb(true);
    String? record = await serverDb.findDb(serverName);
    await serverDb.closeDb();

    Map<String, dynamic> map = jsonDecode(record!);
    Map<String, dynamic> userMap = jsonDecode(map['users']!);
    if (userMap[username] == null) return false;
    if (map[username] == null) return false;

    return true;
  }
}
