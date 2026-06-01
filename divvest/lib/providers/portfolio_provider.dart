import 'package:flutter/foundation.dart';
import '../../data/models/models.dart';
import '../../data/repositories/portfolio_repository.dart';

class PortfolioProvider extends ChangeNotifier {
  final PortfolioRepository _repository = PortfolioRepository();

  List<StockSummary> _stockSummaries = [];
  PortfolioSummary? _portfolioSummary;
  double _monthlyIncome = 0;
  double _yieldOnCost = 0;
  bool _isLoading = false;

  List<StockSummary> get stockSummaries => _stockSummaries;
  PortfolioSummary? get portfolioSummary => _portfolioSummary;
  double get monthlyIncome => _monthlyIncome;
  double get yieldOnCost => _yieldOnCost;
  bool get isLoading => _isLoading;

  Future<void> loadPortfolio() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stockSummaries = await _repository.getAllStockSummaries();
      _portfolioSummary = await _repository.getPortfolioSummary();
      _monthlyIncome = await _repository.getMonthlyIncome();
      _yieldOnCost = await _repository.getYieldOnCost();
    } catch (e) {
      debugPrint('Error loading portfolio: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshPrices() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.refreshPrices();
      await loadPortfolio();
    } catch (e) {
      debugPrint('Error refreshing prices: $e');
    }
  }

  Future<void> refreshOwnedPrices() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.refreshOwnedPrices();
      await loadPortfolio();
    } catch (e) {
      debugPrint('Error refreshing owned prices: $e');
    }
  }

  Future<int> refreshStockList() async {
    _isLoading = true;
    notifyListeners();

    try {
      final count = await _repository.refreshStockList();
      await loadPortfolio();
      return count;
    } catch (e) {
      debugPrint('Error refreshing stock list: $e');
      return 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Stock>> getAllStocks() async {
    return await _repository.getStocks();
  }

  Future<StockSummary> getStockSummary(String ticker) async {
    return await _repository.getStockSummary(ticker);
  }

  Future<List<PortfolioEntry>> getEntriesByTicker(String ticker) async {
    return await _repository.getEntriesByTicker(ticker);
  }

  Future<List<DividendRecord>> getDividendsByTicker(String ticker) async {
    return await _repository.getDividendsByTicker(ticker);
  }

  Future<Stock?> getStock(String ticker) async {
    return await _repository.getStock(ticker);
  }

  Future<List<DividendRecord>> getUpcomingDividends() async {
    return await _repository.getUpcomingDividends();
  }

  Future<List<DividendRecord>> getDividendsByMonth(int year, int month) async {
    return await _repository.getDividendsByMonth(year, month);
  }

  Future<List<DividendRecord>> getAllDividends() async {
    return await _repository.getDividends();
  }

  Future<PortfolioEntry> addEntry(PortfolioEntry entry) async {
    final newEntry = await _repository.addEntry(entry);
    await loadPortfolio();
    return newEntry;
  }

  Future<int> updateEntry(PortfolioEntry entry) async {
    final result = await _repository.updateEntry(entry);
    await loadPortfolio();
    return result;
  }

  Future<int> deleteEntry(int id) async {
    final result = await _repository.deleteEntry(id);
    await loadPortfolio();
    return result;
  }

  Future<void> deleteAllForTicker(String ticker) async {
    await _repository.deleteAllForTicker(ticker);
    await loadPortfolio();
  }

  Future<DividendRecord> addDividend(DividendRecord record) async {
    final newRecord = await _repository.addDividend(record);
    await loadPortfolio();
    return newRecord;
  }

  Future<int> updateDividend(DividendRecord record) async {
    final result = await _repository.updateDividend(record);
    await loadPortfolio();
    return result;
  }

  Future<int> deleteDividend(int id) async {
    final result = await _repository.deleteDividend(id);
    await loadPortfolio();
    return result;
  }
}
