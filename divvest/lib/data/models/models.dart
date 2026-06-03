enum DividendType { cash, reinvest }
enum TransactionType { buy, sell }

class Stock {
  final String ticker;
  final String name;
  final String? sector;
  final double currentPrice;
  final double priceChange;
  final double priceChangePercent;
  final DateTime lastUpdated;

  const Stock({
    required this.ticker,
    required this.name,
    this.sector,
    required this.currentPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.lastUpdated,
  });

  bool get isPositive => priceChangePercent >= 0;

  Map<String, dynamic> toMap() {
    return {
      'ticker': ticker,
      'name': name,
      'sector': sector,
      'currentPrice': currentPrice,
      'priceChange': priceChange,
      'priceChangePercent': priceChangePercent,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      ticker: map['ticker'] as String,
      name: map['name'] as String,
      sector: map['sector'] as String?,
      currentPrice: (map['currentPrice'] as num).toDouble(),
      priceChange: (map['priceChange'] as num).toDouble(),
      priceChangePercent: (map['priceChangePercent'] as num).toDouble(),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }

  Stock copyWith({
    String? ticker,
    String? name,
    String? sector,
    double? currentPrice,
    double? priceChange,
    double? priceChangePercent,
    DateTime? lastUpdated,
  }) {
    return Stock(
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      sector: sector ?? this.sector,
      currentPrice: currentPrice ?? this.currentPrice,
      priceChange: priceChange ?? this.priceChange,
      priceChangePercent: priceChangePercent ?? this.priceChangePercent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class PortfolioEntry {
  final int id;
  final String ticker;
  final DateTime buyDate;
  final int lots;
  final double pricePerLot;
  final double fee;
  final bool isReinvested;
  final int? sourceDividendId;
  final String? notes;

  const PortfolioEntry({
    this.id = 0,
    required this.ticker,
    required this.buyDate,
    required this.lots,
    required this.pricePerLot,
    this.fee = 0,
    this.isReinvested = false,
    this.sourceDividendId,
    this.notes,
  });

  double get totalCost => (lots * 100 * pricePerLot) + fee;

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'ticker': ticker,
      'buyDate': buyDate.toIso8601String(),
      'lots': lots,
      'pricePerLot': pricePerLot,
      'fee': fee,
      'isReinvested': isReinvested ? 1 : 0,
      'sourceDividendId': sourceDividendId,
      'notes': notes,
    };
  }

  factory PortfolioEntry.fromMap(Map<String, dynamic> map) {
    return PortfolioEntry(
      id: (map['id'] as num).toInt(),
      ticker: map['ticker'] as String,
      buyDate: DateTime.parse(map['buyDate'] as String),
      lots: (map['lots'] as num).toInt(),
      pricePerLot: (map['pricePerLot'] as num).toDouble(),
      fee: (map['fee'] as num).toDouble(),
      isReinvested: (map['isReinvested'] as num) == 1,
      sourceDividendId: map['sourceDividendId'] != null
          ? (map['sourceDividendId'] as num).toInt()
          : null,
      notes: map['notes'] as String?,
    );
  }

  PortfolioEntry copyWith({
    int? id,
    String? ticker,
    DateTime? buyDate,
    int? lots,
    double? pricePerLot,
    double? fee,
    bool? isReinvested,
    int? sourceDividendId,
    String? notes,
  }) {
    return PortfolioEntry(
      id: id ?? this.id,
      ticker: ticker ?? this.ticker,
      buyDate: buyDate ?? this.buyDate,
      lots: lots ?? this.lots,
      pricePerLot: pricePerLot ?? this.pricePerLot,
      fee: fee ?? this.fee,
      isReinvested: isReinvested ?? this.isReinvested,
      sourceDividendId: sourceDividendId ?? this.sourceDividendId,
      notes: notes ?? this.notes,
    );
  }
}

class DividendRecord {
  final int id;
  final String ticker;
  final DateTime exDate;
  final DateTime paymentDate;
  final double dividendPerLot;
  final DividendType dividendType;
  final int lotsHeldAtExDate;
  final double taxRate;
  final int? reinvestEntryId;

  const DividendRecord({
    this.id = 0,
    required this.ticker,
    required this.exDate,
    required this.paymentDate,
    required this.dividendPerLot,
    required this.dividendType,
    required this.lotsHeldAtExDate,
    this.taxRate = 0.10,
    this.reinvestEntryId,
  });

  double get grossAmount => lotsHeldAtExDate * dividendPerLot * 100;
  double get tax => grossAmount * taxRate;
  double get netAmount => grossAmount - tax;

  int get reinvestLots {
    if (dividendType != DividendType.reinvest) return 0;
    return netAmount ~/ (100 * 100);
  }

  double get reinvestRemainder {
    if (dividendType != DividendType.reinvest) return 0;
    return netAmount % (100 * 100);
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'ticker': ticker,
      'exDate': exDate.toIso8601String(),
      'paymentDate': paymentDate.toIso8601String(),
      'dividendPerLot': dividendPerLot,
      'dividendType': dividendType.name,
      'lotsHeldAtExDate': lotsHeldAtExDate,
      'taxRate': taxRate,
      'reinvestEntryId': reinvestEntryId,
    };
  }

  factory DividendRecord.fromMap(Map<String, dynamic> map) {
    return DividendRecord(
      id: (map['id'] as num).toInt(),
      ticker: map['ticker'] as String,
      exDate: DateTime.parse(map['exDate'] as String),
      paymentDate: DateTime.parse(map['paymentDate'] as String),
      dividendPerLot: (map['dividendPerLot'] as num).toDouble(),
      dividendType:
          map['dividendType'] == 'reinvest'
              ? DividendType.reinvest
              : DividendType.cash,
      lotsHeldAtExDate: (map['lotsHeldAtExDate'] as num).toInt(),
      taxRate: (map['taxRate'] as num).toDouble(),
      reinvestEntryId: map['reinvestEntryId'] != null
          ? (map['reinvestEntryId'] as num).toInt()
          : null,
    );
  }

  DividendRecord copyWith({
    int? id,
    String? ticker,
    DateTime? exDate,
    DateTime? paymentDate,
    double? dividendPerLot,
    DividendType? dividendType,
    int? lotsHeldAtExDate,
    double? taxRate,
    int? reinvestEntryId,
  }) {
    return DividendRecord(
      id: id ?? this.id,
      ticker: ticker ?? this.ticker,
      exDate: exDate ?? this.exDate,
      paymentDate: paymentDate ?? this.paymentDate,
      dividendPerLot: dividendPerLot ?? this.dividendPerLot,
      dividendType: dividendType ?? this.dividendType,
      lotsHeldAtExDate: lotsHeldAtExDate ?? this.lotsHeldAtExDate,
      taxRate: taxRate ?? this.taxRate,
      reinvestEntryId: reinvestEntryId ?? this.reinvestEntryId,
    );
  }
}

class PortfolioSummary {
  final double totalInvested;
  final double currentValue;
  final double totalDividendsReceived;
  final double totalDividendsReinvested;
  final double unrealizedGainLoss;
  final double effectiveGain;

  const PortfolioSummary({
    required this.totalInvested,
    required this.currentValue,
    required this.totalDividendsReceived,
    required this.totalDividendsReinvested,
    this.unrealizedGainLoss = 0,
    this.effectiveGain = 0,
  });

  double get gainLossPercent {
    if (totalInvested == 0) return 0;
    return ((currentValue - totalInvested) / totalInvested) * 100;
  }

  bool get isProfitable => currentValue >= totalInvested;
}

class StockSummary {
  final Stock stock;
  final int totalLots;
  final double averagePrice;
  final double totalInvested;
  final double currentValue;
  final double dividendsReceived;
  final double bepProgress;

  const StockSummary({
    required this.stock,
    required this.totalLots,
    required this.averagePrice,
    required this.totalInvested,
    required this.currentValue,
    required this.dividendsReceived,
    required this.bepProgress,
  });

  double get gainLossPercent {
    if (totalInvested == 0) return 0;
    return ((currentValue - totalInvested) / totalInvested) * 100;
  }

  bool get isPositive => currentValue >= totalInvested;
}
