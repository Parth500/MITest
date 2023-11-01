import 'package:mi_test/services/localDB/album_db.dart';
import 'package:mi_test/services/localDB/product_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyLocalDB {
  static MyLocalDB? _customerHelper;
  static Database? _database;

  MyLocalDB._createInstance();

  factory MyLocalDB() {
    if (_customerHelper == null) {
      _customerHelper = MyLocalDB._createInstance();
      return _customerHelper!;
    } else {
      return _customerHelper!;
    }
  }

  static Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
      return _database!;
    } else {
      return _database!;
    }
  }

  static Future<Database> initializeDatabase() async {
    final dir = await getDatabasesPath();
    final path = join(dir, "MI_TEST.db");

    final database =
        await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute(AlbumDB().createAlbumTable);
      db.execute(ProductDB().createProductTable);
    });

    return database;
  }
}
