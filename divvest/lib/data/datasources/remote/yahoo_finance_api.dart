import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/models.dart';

class YahooFinanceApi {
  YahooFinanceApi._();

  static const String _baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart';

  static const List<Map<String, String>> _idxStocks = [
    {'ticker': 'BBCA', 'name': 'Bank Central Asia Tbk', 'sector': 'Financials'},
    {'ticker': 'BBRI', 'name': 'Bank Rakyat Indonesia Tbk', 'sector': 'Financials'},
    {'ticker': 'BMRI', 'name': 'Bank Mandiri Tbk', 'sector': 'Financials'},
    {'ticker': 'BBNI', 'name': 'Bank Negara Indonesia Tbk', 'sector': 'Financials'},
    {'ticker': 'BRIS', 'name': 'Bank Syariah Indonesia Tbk', 'sector': 'Financials'},
    {'ticker': 'BNGA', 'name': 'Bank CIMB Niaga Tbk', 'sector': 'Financials'},
    {'ticker': 'MEGA', 'name': 'Bank Mega Tbk', 'sector': 'Financials'},
    {'ticker': 'NISP', 'name': 'Bank OCBC NISP Tbk', 'sector': 'Financials'},
    {'ticker': 'BTPS', 'name': 'Bank BTPN Syariah Tbk', 'sector': 'Financials'},
    {'ticker': 'BBTN', 'name': 'Bank Tabungan Negara Tbk', 'sector': 'Financials'},
    {'ticker': 'TLKM', 'name': 'Telkom Indonesia Tbk', 'sector': 'Telecommunications'},
    {'ticker': 'ISAT', 'name': 'Indosat Ooredoo Hutchison Tbk', 'sector': 'Telecommunications'},
    {'ticker': 'EXCL', 'name': 'XL Axiata Tbk', 'sector': 'Telecommunications'},
    {'ticker': 'FREN', 'name': 'Smartfren Telecom Tbk', 'sector': 'Telecommunications'},
    {'ticker': 'ASII', 'name': 'Astra International Tbk', 'sector': 'Industrials'},
    {'ticker': 'UNTR', 'name': 'United Tractors Tbk', 'sector': 'Industrials'},
    {'ticker': 'INDF', 'name': 'Indofood Sukses Makmur Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'ICBP', 'name': 'Indofood CBP Sukses Makmur Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'MYOR', 'name': 'Mayora Indah Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'KLBF', 'name': 'Kalbe Farma Tbk', 'sector': 'Healthcare'},
    {'ticker': 'SIDO', 'name': 'Industri Jamu dan Farmasi Sido Muncul Tbk', 'sector': 'Healthcare'},
    {'ticker': 'UNVR', 'name': 'Unilever Indonesia Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'HMSP', 'name': 'HM Sampoerna Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'GGRM', 'name': 'Gudang Garam Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'PGAS', 'name': 'Perusahaan Gas Negara Tbk', 'sector': 'Energy'},
    {'ticker': 'ADRO', 'name': 'Adaro Energy Indonesia Tbk', 'sector': 'Energy'},
    {'ticker': 'PTBA', 'name': 'Bukit Asam Tbk', 'sector': 'Energy'},
    {'ticker': 'ITMG', 'name': 'Ind Tambangraya Megah Tbk', 'sector': 'Energy'},
    {'ticker': 'ANTM', 'name': 'Aneka Tambang Tbk', 'sector': 'Materials'},
    {'ticker': 'INCO', 'name': 'Vale Indonesia Tbk', 'sector': 'Materials'},
    {'ticker': 'MDKA', 'name': 'Merdeka Copper Gold Tbk', 'sector': 'Materials'},
    {'ticker': 'AMMN', 'name': 'Amman Mineral Internasional Tbk', 'sector': 'Materials'},
    {'ticker': 'TINS', 'name': 'Timah Tbk', 'sector': 'Materials'},
    {'ticker': 'SMGR', 'name': 'Semen Indonesia Tbk', 'sector': 'Materials'},
    {'ticker': 'INDY', 'name': 'Indika Energy Tbk', 'sector': 'Energy'},
    {'ticker': 'MEDC', 'name': 'Medco Energi Internasional Tbk', 'sector': 'Energy'},
    {'ticker': 'AKRA', 'name': 'AKR Corporindo Tbk', 'sector': 'Energy'},
    {'ticker': 'PWON', 'name': 'Pakuwon Jati Tbk', 'sector': 'Real Estate'},
    {'ticker': 'BSDE', 'name': 'Bumi Serpong Damai Tbk', 'sector': 'Real Estate'},
    {'ticker': 'CTRA', 'name': 'Ciputra Development Tbk', 'sector': 'Real Estate'},
    {'ticker': 'SMRA', 'name': 'Summarecon Agung Tbk', 'sector': 'Real Estate'},
    {'ticker': 'JPFA', 'name': 'Japfa Comfeed Indonesia Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'CPIN', 'name': 'Charoen Pokphand Indonesia Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'AALI', 'name': 'Astra Agro Lestari Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'LSIP', 'name': 'PP London Sumatra Indonesia Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'SIMP', 'name': 'Salim Ivomas Pratama Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'UNSP', 'name': 'Bakrie Sumatra Plantations Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'GOTO', 'name': 'GoTo Gojek Tokopedia Tbk', 'sector': 'Technology'},
    {'ticker': 'BUKA', 'name': 'Bukalapak.com Tbk', 'sector': 'Technology'},
    {'ticker': 'EMTK', 'name': 'Elang Mahkota Teknologi Tbk', 'sector': 'Technology'},
    {'ticker': 'KBLV', 'name': 'First Media Tbk', 'sector': 'Telecommunications'},
    {'ticker': 'MNCN', 'name': 'Media Nusantara Citra Tbk', 'sector': 'Communication Services'},
    {'ticker': 'SCMA', 'name': 'Surya Citra Media Tbk', 'sector': 'Communication Services'},
    {'ticker': 'LINK', 'name': 'Link Net Tbk', 'sector': 'Telecommunications'},
    {'ticker': 'TOWR', 'name': 'Sarana Menara Nusantara Tbk', 'sector': 'Infrastructure'},
    {'ticker': 'TBIG', 'name': 'Tower Bersama Infrastructure Tbk', 'sector': 'Infrastructure'},
    {'ticker': 'WIKA', 'name': 'Wijaya Karya Tbk', 'sector': 'Industrials'},
    {'ticker': 'WSKT', 'name': 'Waskita Karya Tbk', 'sector': 'Industrials'},
    {'ticker': 'PTPP', 'name': 'PP (Persero) Tbk', 'sector': 'Industrials'},
    {'ticker': 'ADHI', 'name': 'Adhi Karya Tbk', 'sector': 'Industrials'},
    {'ticker': 'JSMR', 'name': 'Jasa Marga Tbk', 'sector': 'Infrastructure'},
    {'ticker': 'GIAA', 'name': 'Garuda Indonesia Tbk', 'sector': 'Industrials'},
    {'ticker': 'LPPF', 'name': 'Matahari Department Store Tbk', 'sector': 'Consumer Discretionary'},
    {'ticker': 'ACES', 'name': 'Ace Hardware Indonesia Tbk', 'sector': 'Consumer Discretionary'},
    {'ticker': 'ERAA', 'name': 'Erajaya Swadharma Tbk', 'sector': 'Consumer Discretionary'},
    {'ticker': 'MAPA', 'name': 'MAP Aktif Adiperkasa Tbk', 'sector': 'Consumer Discretionary'},
    {'ticker': 'MAPI', 'name': 'Mitra Adiperkasa Tbk', 'sector': 'Consumer Discretionary'},
    {'ticker': 'AMRT', 'name': 'Sumber Alfaria Trijaya Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'MINA', 'name': 'Nippon Indosari Corpindo Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'ROTI', 'name': 'Nippon Indosari Corpindo Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'TBLA', 'name': 'Tunas Baru Lampung Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'DSNG', 'name': 'Dharma Satya Nusantara Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'BIMA', 'name': 'Prima Andalan Mandiri Tbk', 'sector': 'Financials'},
    {'ticker': 'PANR', 'name': 'Panin Insurance Tbk', 'sector': 'Financials'},
    {'ticker': 'LPGI', 'name': 'Lippo General Insurance Tbk', 'sector': 'Financials'},
    {'ticker': 'ASRM', 'name': 'Asuransi Rama Sakti', 'sector': 'Financials'},
    {'ticker': 'MREI', 'name': 'Maskapai Reasuransi Indonesia Tbk', 'sector': 'Financials'},
    {'ticker': 'SMMT', 'name': 'Golden Eagle Energy Tbk', 'sector': 'Energy'},
    {'ticker': 'RALS', 'name': 'Dharma Polimetal Tbk', 'sector': 'Consumer Discretionary'},
    {'ticker': 'BULL', 'name': 'Buana Lintas Lautan Tbk', 'sector': 'Industrials'},
    {'ticker': 'DUTI', 'name': 'Duta Pertiwi Tbk', 'sector': 'Real Estate'},
    {'ticker': 'CASH', 'name': 'Cashlez Worldwide Indonesia Tbk', 'sector': 'Technology'},
    {'ticker': 'DCII', 'name': 'DCI Indonesia Tbk', 'sector': 'Technology'},
    {'ticker': 'DIVA', 'name': 'Distribusi Voucher Nusantara Tbk', 'sector': 'Technology'},
    {'ticker': 'EDGE', 'name': 'Indosterling Technomedia Tbk', 'sector': 'Technology'},
    {'ticker': 'FUTR', 'name': 'Solusi Sinergi Digital Tbk', 'sector': 'Technology'},
    {'ticker': 'KIOS', 'name': 'Kioson Komersial Indonesia Tbk', 'sector': 'Technology'},
    {'ticker': 'MTDL', 'name': 'Metrodata Electronics Tbk', 'sector': 'Technology'},
    {'ticker': 'NETV', 'name': 'Net Visi Media Tbk', 'sector': 'Communication Services'},
    {'ticker': 'NFCX', 'name': 'NFC Indonesia Tbk', 'sector': 'Technology'},
    {'ticker': 'PGJO', 'name': 'Prajogo International Tbk', 'sector': 'Materials'},
    {'ticker': 'PGLI', 'name': 'Penta Gemilang Internusa Tbk', 'sector': 'Industrials'},
    {'ticker': 'PSAB', 'name': 'J Resources Asia Pasifik Tbk', 'sector': 'Materials'},
    {'ticker': 'PTPS', 'name': 'Pulau Sambu Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'SMMZ', 'name': 'Merkur Karya Utama Tbk', 'sector': 'Energy'},
    {'ticker': 'TPIA', 'name': 'Chandra Asri Pacific Tbk', 'sector': 'Materials'},
    {'ticker': 'TRIM', 'name': 'Trias Sentosa Tbk', 'sector': 'Materials'},
    {'ticker': 'ULTJ', 'name': 'Ultrajaya Milk Industry & Trading Tbk', 'sector': 'Consumer Staples'},
    {'ticker': 'WIFI', 'name': 'Solusi Sinergi Digital Tbk', 'sector': 'Infrastructure'},
    {'ticker': 'BREN', 'name': 'Barito Renewables Energy Tbk', 'sector': 'Energy'},
  ];

  static List<Map<String, String>> get idxStockList => _idxStocks;

  static Future<List<Stock>?> fetchAllIDXStocks() async {
    final stocks = <Stock>[];
    final now = DateTime.now();

    for (final item in _idxStocks) {
      final ticker = item['ticker']!;
      final name = item['name']!;
      final sector = item['sector']!;

      debugPrint('[YahooFinanceApi] Fetching $ticker...');
      final detail = await fetchStockDetail(ticker);
      if (detail != null) {
        final price = detail['price'] as double;
        final change = detail['change'] as double;
        final changePercent = detail['changePercent'] as double;
        stocks.add(Stock(
          ticker: ticker,
          name: name,
          sector: sector,
          currentPrice: price,
          priceChange: change,
          priceChangePercent: changePercent,
          lastUpdated: now,
        ));
        debugPrint('[YahooFinanceApi] $ticker: $price');
      } else {
        stocks.add(Stock(
          ticker: ticker,
          name: name,
          sector: sector,
          currentPrice: 0,
          priceChange: 0,
          priceChangePercent: 0,
          lastUpdated: now,
        ));
        debugPrint('[YahooFinanceApi] Failed to fetch $ticker, using placeholder');
      }
    }

    return stocks.isEmpty ? null : stocks;
  }

  static Future<Map<String, double>?> fetchPrices(List<String> tickers) async {
    if (tickers.isEmpty) return null;

    final prices = <String, double>{};

    for (final ticker in tickers) {
      debugPrint('[YahooFinanceApi] Fetching $ticker...');
      final detail = await fetchStockDetail(ticker);
      if (detail != null) {
        prices[ticker] = detail['price'] as double;
        debugPrint('[YahooFinanceApi] $ticker: ${detail['price']}');
      } else {
        debugPrint('[YahooFinanceApi] Failed to fetch $ticker');
      }
    }

    return prices.isEmpty ? null : prices;
  }

  static Future<Map<String, dynamic>?> fetchStockDetail(String ticker) async {
    final symbol = '${ticker.toUpperCase()}.JK';
    final url = Uri.parse('$_baseUrl/$symbol?interval=1d&range=5d');

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      final result = data['chart']['result'] as List?;
      if (result == null || result.isEmpty) {
        return null;
      }

      final meta = result[0]['meta'] as Map<String, dynamic>;
      final price = (meta['regularMarketPrice'] as num).toDouble();
      final previousClose = (meta['chartPreviousClose'] ?? meta['previousClose'] ?? price) as num;
      final prevCloseDouble = previousClose.toDouble();

      final change = price - prevCloseDouble;
      final changePercent = prevCloseDouble > 0 ? (change / prevCloseDouble) * 100 : 0;

      return {
        'price': price,
        'change': change,
        'changePercent': changePercent,
        'previousClose': prevCloseDouble,
      };
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchPriceHistory(String ticker, {String range = '3mo'}) async {
    final symbol = '${ticker.toUpperCase()}.JK';
    final url = Uri.parse('$_baseUrl/$symbol?interval=1d&range=$range');

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final data = json.decode(response.body);
      final result = data['chart']['result'] as List?;
      if (result == null || result.isEmpty) {
        return null;
      }

      final item = result[0] as Map<String, dynamic>;
      final timestamps = item['timestamp'] as List?;
      final quotes = item['indicators']?['quote'] as List?;
      if (timestamps == null || quotes == null || quotes.isEmpty) {
        return null;
      }

      final quote = quotes[0] as Map<String, dynamic>;
      final closes = quote['close'] as List?;
      if (closes == null) {
        return null;
      }

      final history = <Map<String, dynamic>>[];
      for (int i = 0; i < timestamps.length; i++) {
        final close = closes[i];
        if (close != null) {
          history.add({
            'date': DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
            'price': (close as num).toDouble(),
          });
        }
      }

      return history.isEmpty ? null : history;
    } catch (e) {
      return null;
    }
  }
}
