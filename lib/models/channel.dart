import 'dart:convert';
import 'dart:io';
import 'package:dart_discord/database/database.dart';
import 'package:dart_discord/models/category.dart';
import 'package:dart_discord/models/message.dart';
import 'package:dart_discord/models/server.dart';

class Channel{
  String? channelName;
  String? serverName;
  String? categoryName;
  int? type;
  List<dynamic>? messages;

  Channel(this.channelName, this.categoryName, this.serverName, this.type, String? channelCreator){
    Message newMsg = Message.channel(channelCreator, "I have created this channel");
    String jsonMsg = newMsg.msgToJson();
    messages = [jsonMsg];
  }

  Channel.fromDb(this.channelName, this.categoryName, this.serverName);

  Map<String, dynamic> toMap(){
    return{
      'channelName' : channelName,
      'serverName' : serverName,
      'categoryName' : categoryName,
      'type' : type,
      'messages' : jsonEncode(messages),
    };
  }

  static Future<void> createChannel(String categoryName, Server server, int type, String channelCreator) async {

    stdout.write("Please enter the name of the channel : ");
    String? channelName = stdin.readLineSync();

    Channel newChannel = Channel(channelName, categoryName, server.serverName, type, channelCreator);
    String serverName = server.serverName!;

    var path = 'lib/database/$serverName.db';
    Db channelDb = Db(path);

    String jsonKey = jsonEncode([categoryName, channelName]);

    await channelDb.openDb();
    List<dynamic>? records = await channelDb.storeDb(true);
    await channelDb.insertDb(jsonKey, jsonEncode(newChannel.toMap()));

    var pathCat = 'lib/database/categories.db';
    Db categoryDb = Db(pathCat);

    await categoryDb.openDb();
    List<dynamic>? recordsCat = await categoryDb.storeDb(true);
    String? recCat = await categoryDb.findDb(serverName);
    await categoryDb.deleteDb(serverName);
    Map<String,dynamic> jsonChMap = jsonDecode(recCat!);
    List<dynamic>? jsonChannels = jsonChMap[categoryName];
    jsonChannels!.add(channelName);
    jsonChMap[categoryName] = jsonChannels;
    String jsonCh = jsonEncode(jsonChMap);
    await categoryDb.insertDb(serverName, jsonCh);
  }

  static Future<void> defaultChannel(String categoryName, Server server, int type, String channelCreator) async {

    String? channelName = 'default';

    Channel newChannel = Channel(channelName, categoryName, server.serverName, type, channelCreator);
    String serverName = server.serverName!;

    var path = 'lib/database/$serverName.db';
    Db channelDb = Db(path);

    String jsonKey = jsonEncode([categoryName, channelName]);

    await channelDb.openDb();
    List<dynamic>? records = await channelDb.storeDb(true);
    await channelDb.insertDb(jsonKey, jsonEncode(newChannel.toMap()));
  }

  Future<Channel> sendMessage(Category currCategory, String userName, int userRole, Channel currChannel, String serverName) async{
    if(userRole & type! == 0){
      print("You do not have permission to send message in this channel");
      return currChannel;
    }
    String messageJson = Message.newMessageinChannel(userName);
    currChannel.messages!.add(messageJson);

    var path = 'lib/database/$serverName.db';
    Db channelDb = Db(path);
    String? key = jsonEncode([currCategory.categoryName, currChannel.channelName]);
    await channelDb.openDb();
    List<dynamic>? records = await channelDb.storeDb(true);
    await channelDb.deleteDb(key);
    await channelDb.insertDb(key, jsonEncode(currChannel.toMap()));
    return currChannel;
  }

  static Future<Channel> getChannelObj(Category category, String serverName, String channelName) async{
    // print("$categoryName, $serverName, $channelName");
    var path = 'lib/database/$serverName.db';
    Db channelDb = Db(path);
    await channelDb.openDb();
    Channel obj = Channel.fromDb(channelName, category.categoryName, serverName);
    List<dynamic>? channelRecords = await channelDb.storeDb(true);
    String? key = jsonEncode([category.categoryName, channelName]);
    // print(key);
    String? channelRec = await channelDb.findDb(key);
    // print(channelRec);
    // print(channelDb.currDb);
    await channelDb.closeDb();
    List<dynamic>? messageJson = jsonDecode(jsonDecode(channelRec!)['messages']);
    obj.messages = messageJson;
    obj.type = category.type;

    // print("channel object created");
    return obj;

  }

  void printMessages(){
    List<dynamic>? messageJson = messages;
    int length = messageJson!.length;
    int count = 0;
    print("");
    print("-----------------------------------------");
    for(int i = length-1; count<10 && i>=0; i--){
      Map<String,dynamic> map = jsonDecode(messageJson[i]);
      stdout.write('message :  ${map['message'].toString()};  sender : ${map['sender'].toString()}');
      print("");
      // print('timestamp : ${map['timestamp']}');
      count++;
    }
    print("-------------------------------------------");
    print("");
  }
}