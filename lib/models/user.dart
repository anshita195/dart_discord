import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dart_discord/database/database.dart';

class User {
  String? username;
  String? passwordHash;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  User.register(this.username, String password) {
    passwordHash = _hashPassword(password);
  }

  User(this.username, String password) {
    passwordHash = _hashPassword(password);
  }

  String toJson() {
    String jsonString = jsonEncode(toMap());
    return jsonString;
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username!,
      'passwordHash': passwordHash!,
    };
  }

  Map<String, String> fromJson(String? jsonString) {
    Map<String, String> map = jsonDecode(jsonString!);
    return map;
  }

  static String defaultMessage(String username) {
    Map<String, dynamic> map = {
      'sender': username,
      'receiver': username,
    };
    String json = jsonEncode(map);
    return json;
  }

  //function for Register User
  static Future<void> registerUser() async {
    stdout.write("Please enter a username : ");
    String? username = stdin.readLineSync();
    var path = 'lib/database/users.db';
    Db userDb = Db(path);
    await userDb.openDb();
    List<dynamic>? records = await userDb.storeDb(true);
    for (var rec in records!) {
      if (rec.key == username) {
        print("Username already exists. Please choose a different username.");
        return;
      }
    }

    stdout.write("Password : ");
    String? password = stdin.readLineSync();
    stdout.write("Confirm Password : ");
    String? confirmPwd = stdin.readLineSync();

    if (confirmPwd != password) {
      print("The passwords do not match.");
      return;
    }
    User newUser = User.register(username!, password!);
    await userDb.insertDb(newUser.username, newUser.toJson());
    print("User registered Successfully");
  }

  //function for login user
  static Future<bool> loginUser(String username, String password) async {
    var path = 'lib/database/users.db';
    Db userDb = Db(path);

    await userDb.openDb();

    List<dynamic>? records = await userDb.storeDb(true);
    // print(records);
    String? rec = await userDb.findDb(username);
    // print(rec);
    if (rec == '') {
      print("username does NOT exist");
      return false;
    }
    Map<String, dynamic> map = jsonDecode(rec!);
    String? pwdHash = map['passwordHash'];

    if (pwdHash == "") {
      print("Username does not exist!!");
      return false;
    }
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    String? newHash = digest.toString();
    if (newHash == pwdHash) {
      print("login successful $username");
      return true;
    }
    print("Incorrect username or Password!!");
    return false;
  }

  Future<User> getUserObj(String userName, String password) async {
    passwordHash = _hashPassword(password);

    var path = 'lib/database/users.db';
    Db userDb = Db(path);
    await userDb.openDb();
    List<dynamic>? records = await userDb.storeDb(true);
    // print(records);
    String? rec = await userDb.findDb(userName);
    await userDb.closeDb();
    // print(rec.runtimeType);
    // print(rec);

    Map<String, dynamic> map = jsonDecode(rec!);
    User currUser = User(userName, password);
    return currUser;
  }
}
