import 'database_helper.dart';
import '../../models/models.dart';

class StockDAO {
  Future<int> insert(Stock stock) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('stocks', stock.toMap());
  }

  Future<Stock?> getByTicker(String ticker) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'stocks',
      where: 'ticker = ?',
      whereArgs: [ticker],
    );

    if (maps.isNotEmpty) {
      return Stock.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Stock>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('stocks', orderBy: 'ticker ASC');

    return List.generate(maps.length, (i) {
      return Stock.fromMap(maps[i]);
    });
  }

  Future<int> update(Stock stock) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'stocks',
      stock.toMap(),
      where: 'ticker = ?',
      whereArgs: [stock.ticker],
    );
  }

  Future<int> updatePrice(String ticker, double price, double change, double changePercent) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'stocks',
      {
        'currentPrice': price,
        'priceChange': change,
        'priceChangePercent': changePercent,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'ticker = ?',
      whereArgs: [ticker],
    );
  }

  Future<int> delete(String ticker) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(
      'stocks',
      where: 'ticker = ?',
      whereArgs: [ticker],
    );
  }

  Future<void> upsert(Stock stock) async {
    final db = await DatabaseHelper.instance.database;
    final existing = await db.query(
      'stocks',
      where: 'ticker = ?',
      whereArgs: [stock.ticker],
    );

    if (existing.isEmpty) {
      await db.insert('stocks', stock.toMap());
    } else {
      await db.update(
        'stocks',
        stock.toMap(),
        where: 'ticker = ?',
        whereArgs: [stock.ticker],
      );
    }
  }

  Future<void> upsertAll(List<Stock> stocks) async {
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();

    for (final stock in stocks) {
      final existing = await db.query(
        'stocks',
        columns: ['ticker'],
        where: 'ticker = ?',
        whereArgs: [stock.ticker],
      );

      if (existing.isEmpty) {
        batch.insert('stocks', stock.toMap());
      } else {
        batch.update(
          'stocks',
          stock.toMap(),
          where: 'ticker = ?',
          whereArgs: [stock.ticker],
        );
      }
    }

    await batch.commit(noResult: true);
  }
}
