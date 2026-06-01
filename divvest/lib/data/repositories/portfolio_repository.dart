import 'package:flutter/foundation.dart';
import '../datasources/local/portfolio_dao.dart';
import '../datasources/local/dividend_dao.dart';
import '../datasources/local/stock_dao.dart';
import '../datasources/remote/yahoo_finance_api.dart';
import '../models/models.dart';

class PortfolioRepository {
  final _stockDAO = StockDAO();
  final _portfolioDAO = PortfolioDAO();
  final _dividendDAO = DividendDAO();

  Future<Map<String, double>?> refreshPrices() async {
    final stocks = await _stockDAO.getAll();
    final tickers = stocks.map((s) => s.ticker).toList();
    return _fetchAndSavePrices(tickers);
  }

  Future<Map<String, double>?> refreshOwnedPrices() async {
    final entries = await _portfolioDAO.getAll();
    final tickers = entries.map((e) => e.ticker).toSet().toList();
    if (tickers.isEmpty) return null;
    return _fetchAndSavePrices(tickers);
  }

  Future<Map<String, double>?> _fetchAndSavePrices(List<String> tickers) async {
    if (tickers.isEmpty) return null;
    debugPrint('[refreshPrices] Fetching prices for: $tickers');

    final prices = await YahooFinanceApi.fetchPrices(tickers);
    if (prices == null) {
      debugPrint('[refreshPrices] Failed to fetch prices from Yahoo Finance');
      return null;
    }
    debugPrint('[refreshPrices] Fetched prices: $prices');

    for (final entry in prices.entries) {
      final ticker = entry.key;
      final newPrice = entry.value;

      var stock = await _stockDAO.getByTicker(ticker);
      if (stock != null) {
        final change = (newPrice - stock.currentPrice).toDouble();
        final changePercent = stock.currentPrice > 0
            ? (change / stock.currentPrice) * 100
            : 0.0;
        debugPrint('[refreshPrices] Updating $ticker: ${stock.currentPrice} -> $newPrice (change: $change, $changePercent%)');
        await _stockDAO.updatePrice(ticker, newPrice, change, changePercent);
      } else {
        debugPrint('[refreshPrices] Stock $ticker not found, creating placeholder');
        await _stockDAO.insert(Stock(
          ticker: ticker,
          name: ticker,
          currentPrice: newPrice,
          priceChange: 0,
          priceChangePercent: 0,
          lastUpdated: DateTime.now(),
        ));
      }
    }

    return prices;
  }

  Future<int> refreshStockList() async {
    debugPrint('[refreshStockList] Fetching all IDX stocks from Yahoo Finance...');
    final stocks = await YahooFinanceApi.fetchAllIDXStocks();
    if (stocks == null) {
      debugPrint('[refreshStockList] Failed to fetch stock list');
      return 0;
    }
    debugPrint('[refreshStockList] Fetched ${stocks.length} stocks, saving to SQLite...');
    await _stockDAO.upsertAll(stocks);
    debugPrint('[refreshStockList] Saved ${stocks.length} stocks to SQLite');
    return stocks.length;
  }

  Future<void> updateStockPrice(String ticker, double price, double change, double changePercent) async {
    await _stockDAO.updatePrice(ticker, price, change, changePercent);
  }

  Future<List<Stock>> getStocks() async {
    return await _stockDAO.getAll();
  }

  Future<Stock?> getStock(String ticker) async {
    return await _stockDAO.getByTicker(ticker);
  }

  Future<List<PortfolioEntry>> getEntries() async {
    return await _portfolioDAO.getAll();
  }

  Future<List<PortfolioEntry>> getEntriesByTicker(String ticker) async {
    return await _portfolioDAO.getByTicker(ticker);
  }

  Future<List<DividendRecord>> getDividends() async {
    return await _dividendDAO.getAll();
  }

  Future<List<DividendRecord>> getDividendsByTicker(String ticker) async {
    return await _dividendDAO.getByTicker(ticker);
  }

  Future<List<DividendRecord>> getUpcomingDividends() async {
    return await _dividendDAO.getUpcoming();
  }

  Future<List<DividendRecord>> getDividendsByMonth(int year, int month) async {
    return await _dividendDAO.getByMonth(year, month);
  }

  Future<PortfolioEntry> addEntry(PortfolioEntry entry) async {
    final id = await _portfolioDAO.insert(entry);
    return entry.copyWith(id: id);
  }

  Future<int> updateEntry(PortfolioEntry entry) async {
    return await _portfolioDAO.update(entry);
  }

  Future<int> deleteEntry(int id) async {
    return await _portfolioDAO.delete(id);
  }

  Future<void> deleteAllForTicker(String ticker) async {
    debugPrint('[deleteAllForTicker] Deleting all entries and dividends for $ticker');
    await _dividendDAO.deleteByTicker(ticker);
    await _portfolioDAO.deleteByTicker(ticker);
    debugPrint('[deleteAllForTicker] Deleted all data for $ticker');
  }

  Future<DividendRecord> addDividend(DividendRecord record) async {
    final id = await _dividendDAO.insert(record);
    return record.copyWith(id: id);
  }

  Future<int> updateDividend(DividendRecord record) async {
    return await _dividendDAO.update(record);
  }

  Future<int> deleteDividend(int id) async {
    return await _dividendDAO.delete(id);
  }

  Future<StockSummary> getStockSummary(String ticker) async {
    final stock = await getStock(ticker);
    if (stock == null) {
      throw Exception('Stock $ticker not found');
    }

    final entries = await getEntriesByTicker(ticker);
    final dividends = await getDividendsByTicker(ticker);

    final totalLots = entries.fold<int>(0, (sum, e) => sum + e.lots);
    final totalInvested = entries.fold<double>(0, (sum, e) => sum + e.totalCost);
    final averagePrice = totalLots > 0 ? (totalInvested / (totalLots * 100)).toDouble() : 0.0;
    final currentValue = (totalLots * 100 * stock.currentPrice).toDouble();
    final dividendsReceived = dividends.fold<double>(0, (sum, d) => sum + d.netAmount);

    debugPrint('[getStockSummary] $ticker: currentPrice=${stock.currentPrice}, avgPrice=$averagePrice, lots=$totalLots, currentValue=$currentValue, invested=$totalInvested');

    final totalDividendCoverage = dividendsReceived;
    final bepProgress = totalInvested > 0
        ? (totalDividendCoverage / totalInvested * 100).clamp(0.0, 100.0).toDouble()
        : 0.0;

    return StockSummary(
      stock: stock,
      totalLots: totalLots,
      averagePrice: averagePrice,
      totalInvested: totalInvested,
      currentValue: currentValue,
      dividendsReceived: dividendsReceived,
      bepProgress: bepProgress,
    );
  }

  Future<List<StockSummary>> getAllStockSummaries() async {
    final entries = await getEntries();
    final tickers = entries.map((e) => e.ticker).toSet();
    final summaries = <StockSummary>[];

    for (final ticker in tickers) {
      try {
        final summary = await getStockSummary(ticker);
        summaries.add(summary);
      } catch (e) {
        // Skip stocks that don't exist in the stock table
      }
    }

    return summaries;
  }

  Future<PortfolioSummary> getPortfolioSummary() async {
    final summaries = await getAllStockSummaries();

    final totalInvested = summaries.fold<double>(0, (sum, s) => sum + s.totalInvested);
    final currentValue = summaries.fold<double>(0, (sum, s) => sum + s.currentValue);
    final totalDividendsReceived = summaries.fold<double>(0, (sum, s) => sum + s.dividendsReceived);

    debugPrint('[PortfolioSummary] totalInvested: $totalInvested, currentValue: $currentValue, totalDividendsReceived: $totalDividendsReceived');
    for (final s in summaries) {
      debugPrint('[PortfolioSummary] ${s.stock.ticker}: price=${s.stock.currentPrice}, lots=${s.totalLots}, currentValue=${s.currentValue}, invested=${s.totalInvested}');
    }

    final allDividends = await getDividends();
    final reinvestedDividends = allDividends
        .where((d) => d.dividendType == DividendType.reinvest)
        .fold<double>(0, (sum, d) => sum + d.netAmount);

    final unrealizedGainLoss = currentValue - totalInvested;
    final effectiveGain = unrealizedGainLoss + totalDividendsReceived;

    return PortfolioSummary(
      totalInvested: totalInvested,
      currentValue: currentValue,
      totalDividendsReceived: totalDividendsReceived,
      totalDividendsReinvested: reinvestedDividends,
      unrealizedGainLoss: unrealizedGainLoss,
      effectiveGain: effectiveGain,
    );
  }

  Future<double> getMonthlyIncome() async {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    final allDividends = await getDividends();
    return allDividends
        .where((d) =>
            d.exDate.month == currentMonth && d.exDate.year == currentYear)
        .fold<double>(0, (sum, d) => sum + d.netAmount);
  }

  Future<double> getYieldOnCost() async {
    final summary = await getPortfolioSummary();
    if (summary.totalInvested == 0) return 0;

    final allDividends = await getDividends();
    final annualDividends = allDividends
        .where((d) => d.exDate.year == DateTime.now().year)
        .fold<double>(0, (sum, d) => sum + d.netAmount);

    return (annualDividends / summary.totalInvested) * 100;
  }
}
