import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/local/database_helper.dart';
import 'data/datasources/local/database_seeder.dart';
import 'data/models/models.dart';
import 'providers/portfolio_provider.dart';
import 'providers/theme_provider.dart';
import 'routes/app_router.dart';
import 'screens/stock_detail/stock_detail_screen.dart';
import 'screens/add_transaction/add_transaction_screen.dart';
import 'screens/edit_transaction/edit_transaction_screen.dart';
import 'screens/add_dividend/add_dividend_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/about/about_screen.dart';
import 'screens/backup_restore/backup_restore_screen.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;
  await DatabaseSeeder.seed();

  final provider = PortfolioProvider();
  await provider.refreshOwnedPrices();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const DivVestApp(),
    ),
  );
}

class DivVestApp extends StatelessWidget {
  const DivVestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: themeProvider.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case AppRoutes.addTransaction:
                  return MaterialPageRoute(builder: (_) => const AddTransactionScreen());
                case AppRoutes.editTransaction:
                  final entry = settings.arguments as PortfolioEntry;
                  return MaterialPageRoute(builder: (_) => EditTransactionScreen(entry: entry));
                case AppRoutes.addDividend:
                  return MaterialPageRoute(builder: (_) => const AddDividendScreen());
                case AppRoutes.settings:
                  return MaterialPageRoute(builder: (_) => const SettingsScreen());
                case AppRoutes.about:
                  return MaterialPageRoute(builder: (_) => const AboutScreen());
                case AppRoutes.backupRestore:
                  return MaterialPageRoute(builder: (_) => const BackupRestoreScreen());
                default:
                  if (settings.name?.startsWith(AppRoutes.stockDetail) ?? false) {
                    final uri = Uri.parse(settings.name!);
                    final ticker = uri.queryParameters['ticker'] ?? '';
                    return MaterialPageRoute(
                      builder: (_) => StockDetailScreen(ticker: ticker),
                    );
                  }
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}
