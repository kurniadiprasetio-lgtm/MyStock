import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static const String addTransaction = '/add-transaction';
  static const String editTransaction = '/edit-transaction';
  static const String addDividend = '/add-dividend';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String stockDetail = '/stock-detail';
}

class AppRouter {
  AppRouter._();

  static Future<T?> push<T>(BuildContext context, String route, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, route, arguments: arguments);
  }

  static void pushReplacement(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
