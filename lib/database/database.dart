import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class Db {
  // ignore: prefer_typing_uninitialized_variables
  var path;
  Database? currDb;
  StoreRef<dynamic, dynamic>? store;
  List<dynamic>? records;

  Db(this.path);

  Future<void> openDb() async {
    final DatabaseFactory dbFactory = databaseFactoryIo;
    currDb = await dbFactory.openDatabase(path);
    // print(currDb);
    // print(path);
  }

  Future<List<dynamic>?> storeDb(bool insert) async {
    store = StoreRef<dynamic, dynamic>.main();
    // print(currDb);
    records = await store!.find(currDb!);
    if (!insert) currDb!.close();
    return records;
  }

  Future<void> insertDb(dynamic key, dynamic value) async {
    await store!.record(key).put(currDb!, value);
    await currDb!.close();
  }

  Future<String?> findDb(String? key) async {
    var jsonString = await store!.record(key!).get(currDb!);
    jsonString ??= '';
    return jsonString;
  }

  Future<void> deleteDb(key) async {
    final finder = Finder(filter: Filter.byKey(key));
    await store!.delete(currDb!, finder: finder);
  }

  Future<void> closeDb() async {
    await currDb!.close();
  }
}
