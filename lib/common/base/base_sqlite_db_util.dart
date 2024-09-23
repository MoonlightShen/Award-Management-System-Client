import 'package:award_management_system/common/base/base_json_serializable.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseSQLiteDBUtil<T extends BaseJsonSerializable> {
  String getDBFile();
  String getCreateSheetSQL();
  String getSheetName();
  int getDBVersion();
  String getKeyName();
  dynamic getItemKey(T item);
  T fromJson(Map<String, dynamic> json);

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      getDBFile(),
      version: getDBVersion(),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      getCreateSheetSQL(),
    );
  }

  Future<void> insert(T item) async {
    final db = await database;
    await db.insert(
      getSheetName(),
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<T>> loadAll() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(getSheetName());
    return List<T>.from(maps.map((json) => fromJson(json)).toList());
  }

  Future<void> updateByKey(T item) async {
    final db = await database;
    await db.update(
      getSheetName(),
      item.toJson(),
      where: '$getKeyName() = ?',
      whereArgs: [getItemKey(item)],
    );
  }

  Future<void> deleteByKey(T item) async {
    final db = await database;
    await db.delete(
      getSheetName(),
      where: '$getKeyName() = ?',
      whereArgs: [getItemKey(item)],
    );
  }
}
