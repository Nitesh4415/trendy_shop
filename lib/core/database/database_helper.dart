import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

@lazySingleton
class DatabaseHelper {
  static Database? _database;
  static const String cartTableName = 'cart_items';
  static const int _databaseVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'trendyShop.db');
    return await openDatabase(
      path,
      // 2. Use the new version number
      version: _databaseVersion,
      onCreate: (db, version) async {
        // This is for new installs
        await db.execute('''
          CREATE TABLE $cartTableName(
            id TEXT PRIMARY KEY,
            user_email TEXT NOT NULL,
            product_json TEXT NOT NULL,
            quantity INTEGER NOT NULL
          )
        ''');
      },
      // 3. Add the onUpgrade callback
      onUpgrade: (db, oldVersion, newVersion) async {
        // This runs for existing users when the version number increases
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE $cartTableName ADD COLUMN user_email TEXT",
          );
        }
      },
    );
  }
}
