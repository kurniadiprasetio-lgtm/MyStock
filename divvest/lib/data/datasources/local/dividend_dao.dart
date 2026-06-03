import 'database_helper.dart';
import '../../models/models.dart';

class DividendDAO {
  Future<int> insert(DividendRecord record) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('dividend_records', record.toMap());
  }

  Future<DividendRecord?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'dividend_records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DividendRecord.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DividendRecord>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'dividend_records',
      orderBy: 'exDate DESC',
    );

    return List.generate(maps.length, (i) {
      return DividendRecord.fromMap(maps[i]);
    });
  }

  Future<DividendRecord?> getByTickerAndDate(String ticker, DateTime exDate) async {
    final db = await DatabaseHelper.instance.database;
    final dateStr = exDate.toIso8601String();
    final maps = await db.query(
      'dividend_records',
      where: 'ticker = ? AND exDate = ?',
      whereArgs: [ticker, dateStr],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return DividendRecord.fromMap(maps.first);
    }
    return null;
  }

  Future<List<DividendRecord>> getByTicker(String ticker) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'dividend_records',
      where: 'ticker = ?',
      whereArgs: [ticker],
      orderBy: 'exDate DESC',
    );

    return List.generate(maps.length, (i) {
      return DividendRecord.fromMap(maps[i]);
    });
  }

  Future<List<DividendRecord>> getUpcoming({int limit = 20}) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'dividend_records',
      where: 'exDate >= ?',
      whereArgs: [now],
      orderBy: 'exDate ASC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return DividendRecord.fromMap(maps[i]);
    });
  }

  Future<List<DividendRecord>> getByMonth(int year, int month) async {
    final db = await DatabaseHelper.instance.database;
    final startOfMonth = DateTime(year, month, 1).toIso8601String();
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();
    final maps = await db.query(
      'dividend_records',
      where: 'exDate >= ? AND exDate <= ?',
      whereArgs: [startOfMonth, endOfMonth],
      orderBy: 'exDate ASC',
    );

    return List.generate(maps.length, (i) {
      return DividendRecord.fromMap(maps[i]);
    });
  }

  Future<int> updateByTickerAndExDate(String ticker, DateTime exDate, Map<String, dynamic> values) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'dividend_records',
      values,
      where: 'ticker = ? AND exDate = ?',
      whereArgs: [ticker, exDate.toIso8601String()],
    );
  }

  Future<int> update(DividendRecord record) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'dividend_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'dividend_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteByTicker(String ticker) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'dividend_records',
      where: 'ticker = ?',
      whereArgs: [ticker],
    );
  }
}
