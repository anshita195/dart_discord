import 'dart:convert';
import 'package:dart_discord/models/user.dart';
import 'package:dart_discord/database/database.dart';
import 'dart:io';
import 'package:dart_discord/models/check.dart';
import 'package:dart_discord/models/channel.dart';

class Server {
  String? serverName;
  Map<String, dynamic>? users;
  Map<String, dynamic>? categories;

  Server.fromDb(this.serverName);

  Server(this.serverName, String creator) {}
  Future<Server> getServerObj(String serverName) async {
    var path = 'lib/database/server.db';
    Db serverDb = Db(path);
    await serverDb.openDb();
    List<dynamic>? serverRec = await serverDb.storeDb(true);
    String? record = await serverDb.findDb(serverName);
    await serverDb.closeDb();
    Server obj = Server.fromDb(serverName);
    // print(jsonDecode(record!)['users']);
    String jsonUser = jsonDecode(record!)['users'];
    try {
      obj.users = jsonDecode(jsonUser);
    } catch (e) {
      print(jsonDecode(jsonUser).runtimeType);
      print("Error : $e");
    }
    obj.categories = jsonDecode(jsonDecode(record)['categories']);
    return obj;
  }

  static Future<void> createServer(String creator) async {
    stdout.write("Enter Server Name : ");
    String? serverName = stdin.readLineSync();
    var pathServer = 'lib/database/server.db';
    Db serverDb = Db(pathServer);
    await serverDb.openDb();
    // print(serverDb.currDb);
    List<dynamic>? serverRec = await serverDb.storeDb(true);

    for (var rec in serverRec!) {
      if (rec.key == serverName) {
        print(
            "A server with this name already exists!! Kindly choose a different name");
        return;
      }
    }

    // print("reached here");
    Server newServer = Server(serverName, creator);
    String serverJson = jsonEncode(newServer.toMap());
    await serverDb.insertDb(serverName, serverJson);

    /* List<String> channels = ['default'];
    Map<String, dynamic> catChannelMap = {
      'Admin': channels,
      'People': channels,
      'Discuss': channels,
      'Private': channels,
      'null': channels,
    };
    String channelList = jsonEncode(catChannelMap);
    Map<String, dynamic> categoryMap = newServer.categories!;

    var pathCat = 'lib/database/categories.db';
    Db categoryDb = Db(pathCat);
    await categoryDb.openDb();
    List<dynamic>? categoryRec = await categoryDb.storeDb(true);
    await categoryDb.insertDb(serverName, channelList);
    for (var entry in categoryMap.entries) {
      // print(entry.key);
      await Channel.defaultChannel(entry.key, newServer, entry.value, creator);
    } */
    print("Server created successfully!!");
  }

  Map<String, String> toMap() {
    return {
      'name': serverName!,
      'users': jsonEncode(users),
      'categories': jsonEncode(categories),
    };
  }

  static String toJsonString(Server obj) {
    String? JsonString = jsonEncode(obj.toMap());
    return JsonString;
  }

  static Map<String, dynamic> fromJsonString(String jsonString) {
    Map<String, dynamic> map = jsonDecode(jsonString);
    // return Server.fromMap(map);
    return map;
  }

  static Future<void> printCategories(String username, Server server) async {
    Map<String, dynamic>? categories = server.categories;
    for (var entry in categories!.entries) {
      if (entry.key != 'null') {
        await Future.delayed(Duration(seconds: 2), () async {
          print(entry.key);
        });
      }
    }
  }

  static Future<bool> enterServer(String serverName, String userName) async {
    if (await checkValidity.checkServer(serverName)) {
      if (checkValidity.checkLogin(userName)) {
        if (await checkValidity.checkServerUser(userName!, serverName)) {
          return true;
        }
      }
    }
    return false;
  }
}
