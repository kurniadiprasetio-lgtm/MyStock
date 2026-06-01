import 'database_helper.dart';
import '../../models/models.dart';

class PortfolioDAO {
  Future<int> insert(PortfolioEntry entry) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('portfolio_entries', entry.toMap());
  }

  Future<PortfolioEntry?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'portfolio_entries',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return PortfolioEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PortfolioEntry>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'portfolio_entries',
      orderBy: 'buyDate DESC',
    );

    return List.generate(maps.length, (i) {
      return PortfolioEntry.fromMap(maps[i]);
    });
  }

  Future<List<PortfolioEntry>> getByTicker(String ticker) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'portfolio_entries',
      where: 'ticker = ?',
      whereArgs: [ticker],
      orderBy: 'buyDate DESC',
    );

    return List.generate(maps.length, (i) {
      return PortfolioEntry.fromMap(maps[i]);
    });
  }

  Future<int> update(PortfolioEntry entry) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'portfolio_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'portfolio_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteByTicker(String ticker) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'portfolio_entries',
      where: 'ticker = ?',
      whereArgs: [ticker],
    );
  }
}
