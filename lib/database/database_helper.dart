import 'package:scan_smart/models/scan_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'scanner.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE scans(id INTEGER PRIMARY KEY AUTOINCREMENT, code TEXT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, image BLOB)',
    );
  }

  Future<void> insertScan(ScanModel scan) async {
    final prefs = await SharedPreferences.getInstance();
    final isSaveHistoryEnabled = prefs.getBool('save_history') ?? false;


    if(isSaveHistoryEnabled){
      final db = await database;
      await db.insert('scans', scan.toMap());
    }
  }

  Future<List<ScanModel>> getScans() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('scans', orderBy: 'timestamp DESC');

    return List.generate(maps.length, (i) {
      return ScanModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteScan(int id) async {
    final db = await database;
    await db.delete(
      'scans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllScans() async {
    final db = await database;
    await db.delete('scans');
  }
}
