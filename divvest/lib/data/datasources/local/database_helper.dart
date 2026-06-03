import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('divvest.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      debugPrint('[Database] Migrating dividend records: converting dividendPerLot to per-share...');
      await db.execute('UPDATE dividend_records SET dividendPerLot = dividendPerLot / 100.0');
      debugPrint('[Database] Migration complete');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const intTypeNullable = 'INTEGER';
    const realType = 'REAL NOT NULL';

    await db.execute('''
CREATE TABLE stocks (
  ticker $textType PRIMARY KEY,
  name $textType,
  sector $textTypeNullable,
  currentPrice $realType,
  priceChange $realType,
  priceChangePercent $realType,
  lastUpdated $textType
)
''');

    await db.execute('''
CREATE TABLE portfolio_entries (
  id $idType,
  ticker $textType,
  buyDate $textType,
  lots $intType,
  pricePerLot $realType,
  fee $realType,
  isReinvested $intType,
  sourceDividendId $intTypeNullable,
  notes $textTypeNullable,
  FOREIGN KEY (ticker) REFERENCES stocks (ticker)
)
''');

    await db.execute('''
CREATE TABLE dividend_records (
  id $idType,
  ticker $textType,
  exDate $textType,
  paymentDate $textType,
  dividendPerLot $realType,
  dividendType $textType,
  lotsHeldAtExDate $intType,
  taxRate $realType,
  reinvestEntryId $intTypeNullable,
  FOREIGN KEY (ticker) REFERENCES stocks (ticker)
)
''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
