import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDB {
  static final LocalDB _instance = LocalDB._internal();
  factory LocalDB() => _instance;
  LocalDB._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'supermarket.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stores(
        id TEXT PRIMARY KEY,
        name TEXT,
        logo TEXT,
        address TEXT,
        phone TEXT,
        openHours TEXT,
        rating REAL,
        deliveryTime INTEGER,
        deliveryFee REAL,
        isOpen INTEGER,
        categories TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        storeId TEXT,
        name TEXT,
        description TEXT,
        price REAL,
        originalPrice REAL,
        images TEXT,
        category TEXT,
        unit TEXT,
        stock INTEGER,
        isAvailable INTEGER,
        rating REAL,
        reviewCount INTEGER
      )
    ''');
  }

  Future<void> insert(String table, Map<String, Object?> values) async {
    final db = await database;
    await db.insert(table, values,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) await db.close();
    _db = null;
  }

  // Método para limpiar todas las tablas
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('stores');
    await db.delete('products');
  }

  // Método para resetear completamente la BD
  Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'supermarket.db');
    await deleteDatabase(path);
    _db = null;
  }
}
