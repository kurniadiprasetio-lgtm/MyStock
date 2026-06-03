import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/portfolio/portfolio_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PortfolioScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color.fromRGBO(255, 255, 255, 0.08)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          boxShadow: isDark
              ? null
              : [
                  const BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Platform.isIOS ? CupertinoIcons.home : Icons.home_outlined, size: 24),
              activeIcon: Icon(Platform.isIOS ? CupertinoIcons.house_fill : Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Platform.isIOS ? CupertinoIcons.folder : Icons.folder_outlined, size: 24),
              activeIcon: Icon(Platform.isIOS ? CupertinoIcons.folder_fill : Icons.folder, size: 24),
              label: 'Portfolio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Platform.isIOS ? CupertinoIcons.calendar : Icons.calendar_today_outlined, size: 24),
              activeIcon: Icon(Platform.isIOS ? CupertinoIcons.calendar : Icons.calendar_today, size: 24),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Platform.isIOS ? CupertinoIcons.settings : Icons.settings_outlined, size: 24),
              activeIcon: Icon(Platform.isIOS ? CupertinoIcons.settings_solid : Icons.settings, size: 24),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
