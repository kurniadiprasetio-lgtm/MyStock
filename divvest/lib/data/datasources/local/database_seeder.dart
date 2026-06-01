import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';
import 'stock_dao.dart';
import 'portfolio_dao.dart';
import 'dividend_dao.dart';
import '../../models/models.dart';

class DatabaseSeeder {
  static final _stockDAO = StockDAO();
  static final _portfolioDAO = PortfolioDAO();
  static final _dividendDAO = DividendDAO();

  static Future<void> seed() async {
    final db = await DatabaseHelper.instance.database;

    final stockCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM stocks'),
    );

    if (stockCount != null && stockCount > 0) {
      return;
    }

    await _createTablesIfNotExists();
  }

  static Future<void> _createTablesIfNotExists() async {
    await DatabaseHelper.instance.database;
  }

  static Future<void> seedFromApi(List<Stock> stocks) async {
    await _stockDAO.upsertAll(stocks);
  }
}
