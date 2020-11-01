import 'dart:async';
import 'dart:io';
import 'package:micard/helper/userProfileTable.dart';
import 'package:micard/model/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "profile.db";
  static final _databaseVersion = 1;

  static final DatabaseHelper instance = DatabaseHelper._createInstance();
  static Database _db;

  DatabaseHelper._createInstance();

  Future<Database> initDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "/" + _databaseName;
    final appDb = await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
    return appDb;
  }

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  void _onCreate(Database db, int version) async {
    Batch batch = db.batch();

    // drop first
    batch.execute("DROP TABLE IF EXISTS $userTable ;");

    // Create User Profile Table in the DB
    batch.execute(""" 
    CREATE TABLE IF NOT EXISTS $userTable(
      $userColId INTEGER PRIMARY KEY,
      $userColName TEXT,
      $userColEmail TEXT,
      $userColPhone TEXT,
      $userColAbout TEXT,
      $userColImage TEXT
    )""");

    await batch.commit();
  }

  //HANDLING PROFILE RELATED ACTIVITIES
  Future<int> saveUser(User user) async {
    Database dbClient = await db;
    final int result = await dbClient.insert(userTable, user.toMap());
    return result;
  }

  Future<int> updateUser(User user) async {
    Database dbClient = await db;
    final int result = await dbClient
        .update(userTable, user.toMap(), where: "id = ?", whereArgs: [user.id]);
    return result;
  }

  Future<User> getUserWithId(int id) async {
    Database dbClient = await db;
    var response =
        await dbClient.query(userTable, where: "id = ?", whereArgs: [id]);

    return response.isNotEmpty ? User.fromMap(response.first) : null;
  }

  Future<User> getUser(String email, String phone) async {
    Database dbClient = await db;
    String sql = "SELECT * FROM user WHERE email = $email AND phone = $phone";
    var result = await dbClient.rawQuery(sql);
    if (result.length == 0) return null;

    return User.fromMap(result.first);
  }
}
