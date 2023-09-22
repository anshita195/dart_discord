import 'dart:io';
import 'package:dart_discord/models/user.dart';
import 'package:dart_discord/models/check.dart';
import 'package:dart_discord/models/server.dart';
import 'package:dart_discord/models/category.dart';
import 'package:dart_discord/models/channel.dart';

void main(List<String> arguments) async {
  // stdout.write("here");
  bool running = true;
  User currentUser = User.register('', '');
  while (running) {
    stdout.write(">> ");
    var arguments = stdin.readLineSync();
    bool loggedIn = checkValidity.checkLogin(currentUser.username!);
    if (arguments == 'register') {
      await User.registerUser();
    } else if (arguments == 'login') {
      bool check = checkValidity.checkLogin(currentUser.username!);
      if (!check) {
        stdout.write("Enter username : ");
        String? username = stdin.readLineSync();
        stdout.write("Enter password : ");
        String? password = stdin.readLineSync();
        // currentUser = User(username, password!);
        bool correct = await User.loginUser(username!, password!);
        if (correct) {
          currentUser = await currentUser.getUserObj(username, password);
        } else if (!correct) {
          currentUser = User.register('', '');
        }
      } else {
        print("User already logged in!!");
      }
    } else if (arguments == 'logout') {
      bool check = checkValidity.checkLogin(currentUser.username!);
      if (!check) {
        print("No user logged in!!");
      } else {
        currentUser = User.register('', '');
        print("logout successful");
        stdout.write("would you like to quit as well? [y/n] ");
        String? response = stdin.readLineSync();
        if (response == 'Y' || response == 'y') {
          running = false;
        }
      }
    } else if (arguments == 'user') {
      if (!checkValidity.checkLogin(currentUser.username!)) {
        print("No user logged in!!");
      } else {
        print(currentUser.username);
      }
    } else if (arguments == 'exit' || arguments == 'quit') {
      stdout.write("Are you sure you want to quit? [y/n] ");
      String? response = stdin.readLineSync();
      if (response == 'y' || response == 'Y') {
        running = false;
      }
    } else if (arguments == 'server') {
      bool runningServer = true;
      if (checkValidity.checkLogin(currentUser.username!) == true) {
        while (runningServer) {
          stdout.write("server >> ");
          String? newargument = stdin.readLineSync();

          if (newargument == 'create') {
            await Server.createServer(currentUser.username!);
          } else if (newargument == 'exit') {
            runningServer = false;
          } else if (newargument == 'enter') {
            stdout.write("Print the server you want to enter : ");
            String? serverName = stdin.readLineSync();
            if (await checkValidity.checkServer(serverName!)) {
              bool entry =
                  await Server.enterServer(serverName, currentUser.username!);
              Server currServer = Server.fromDb(serverName);
              currServer = await currServer.getServerObj(serverName);

              while (entry) {
                stdout.write("$serverName >> ");
                String? command = stdin.readLineSync();

                //print categories in a server with a delay of 2 sec

                if (command == 'print categories') {
                  await Server.printCategories(
                      currentUser.username!, currServer);
                }

                //exit server
                if (command == 'exit') {
                  entry = false;
                } else if (command == 'enter category') {
                  stdout.write(
                      "Please provide the name of the category you want to enter : ");
                  bool inCategory = true;
                  String? categoryName = stdin.readLineSync();
                  if (currServer.categories![categoryName] == null) {
                    // print(currServer.categories);
                    inCategory = false;
                    print("such a category does not exist");
                  } else {
                    if (currServer.categories![categoryName] &
                            currServer.users![currentUser.username] ==
                        0) {
                      print("You are not allowed to access this category!!");
                      return;
                    }
                    Category currCategory = await Category.getCategoryObj(
                        categoryName!, serverName);
                    // print(currCategory.categoryName);
                    // print(currCategory.type);
                    while (inCategory) {
                      stdout.write('$serverName >> $categoryName >> ');
                      String? command = stdin.readLineSync();
                      if (command == 'create channel') {
                        await Channel.createChannel(categoryName, currServer,
                            currCategory.type!, currentUser.username!);
                      } else if (command == 'exit')
                        inCategory = false;
                      else if (command == 'enter channel') {
                        stdout.write(
                            "Please provide the name of the channel you want to enter : ");
                        bool inChannel = true;
                        String? channelName = stdin.readLineSync();
                        currCategory =
                            await Category.update(currCategory, serverName);
                        if (!currCategory.channels!.contains(channelName)) {
                          // print(currServer.categories);
                          inChannel = false;
                          print("such a channel does not exist");
                        }

                        Channel currChannel = await Channel.getChannelObj(
                            currCategory, serverName, channelName!);
                        while (inChannel) {
                          stdout.write(
                              '$serverName >> $categoryName >> $channelName >> ');
                          String? command = stdin.readLineSync();
                          if (command == 'send message') {
                            await currChannel.sendMessage(
                                currCategory,
                                currentUser.username!,
                                currChannel.type!,
                                currChannel,
                                serverName);
                          } else if (command == 'exit') {
                            inChannel = false;
                          } else if (command == 'print messages') {
                            currChannel.printMessages();
                          }
                        }
                      }
                    }
                  }
                } else {
                  print("a server with server name $serverName does not exist");
                }
              }
            }
          } else {
            print("Please enter a valid command!!");
          }
        }
      } else {
        print("Please login to user Server functionality");
      }
    }
  }
}
