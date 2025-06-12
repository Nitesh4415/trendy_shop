import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@lazySingleton
class DatabaseHelper {
  static Database? _database;
  static const String cartTableName = 'cart_items';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  // Initializes the database, creating it if it doesn't exist.
  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'trendyShop.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $cartTableName(
            id TEXT PRIMARY KEY,
            product_json TEXT NOT NULL,
            quantity INTEGER NOT NULL
          )
        ''');
      },
    );
  }
}