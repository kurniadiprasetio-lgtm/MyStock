import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/components/components.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isLoading = false;
  String _loadingMessage = '';

  void _setLoading(bool loading, [String message = '']) {
    setState(() {
      _isLoading = loading;
      _loadingMessage = message;
    });
  }

  Future<void> _exportBackup() async {
    _setLoading(true, 'Creating backup file...');
    try {
      final db = await DatabaseHelper.instance.database;

      // Fetch all records from database tables
      final stocks = await db.query('stocks');
      final entries = await db.query('portfolio_entries');
      final dividends = await db.query('dividend_records');

      final backupData = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'stocks': stocks,
        'portfolio_entries': entries,
        'dividend_records': dividends,
      };

      final jsonString = jsonEncode(backupData);

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final backupFile = File(
        '${tempDir.path}/divvest_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await backupFile.writeAsString(jsonString);

      _setLoading(false);

      // Share backup file
      final xFile = XFile(backupFile.path, mimeType: 'application/json');
      try {
        await Share.shareXFiles(
          [xFile],
          text: 'DivVest Portfolio Backup - ${DateTime.now().toLocal().toString().split('.')[0]}',
        );
      } catch (shareError, shareStack) {
        debugPrint('Sharing backup failed: $shareError\n$shareStack');
        if (mounted) {
          AppSnackBar.showError(
            context,
            'Cannot share backup directly. Find the file at ${backupFile.path}',
          );
        }
      }
    } catch (e, stack) {
      _setLoading(false);
      // Log error details for debugging
      debugPrint('Backup export failed: $e\n$stack');
      if (mounted) {
        // Show a user‑friendly message without technical details
        AppSnackBar.showError(context, 'Failed to create backup. Please try again.');
      }
    }
  }

  Future<void> _importRestore() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return; // User canceled the picker
      }

      final filePath = result.files.single.path!;
      final file = File(filePath);
      final jsonString = await file.readAsString();

      final backupData = jsonDecode(jsonString);
      if (backupData is! Map<String, dynamic> ||
          !backupData.containsKey('stocks') ||
          !backupData.containsKey('portfolio_entries') ||
          !backupData.containsKey('dividend_records')) {
        if (mounted) {
          AppSnackBar.showError(context, 'Invalid backup file format.');
        }
        return;
      }

      if (!mounted) return;

      final confirm = await AppDialog.showConfirmation(
        context: context,
        title: 'Restore Backup?',
        message: 'This will replace all your current portfolio data, transactions, and dividends with the data from the backup file. This action cannot be undone.',
        confirmLabel: 'Restore',
        cancelLabel: 'Cancel',
      );

      if (confirm != true) return;

      _setLoading(true, 'Restoring database records...');

      final db = await DatabaseHelper.instance.database;

      await db.transaction((txn) async {
        // Disable foreign keys temporarily for batch deletion/insertion
        await txn.execute('PRAGMA foreign_keys = OFF;');

        await txn.execute('DELETE FROM stocks');
        await txn.execute('DELETE FROM portfolio_entries');
        await txn.execute('DELETE FROM dividend_records');

        // Insert stocks
        final stocksList = backupData['stocks'] as List;
        for (final stock in stocksList) {
          if (stock is Map<String, dynamic>) {
            await txn.insert('stocks', stock);
          }
        }

        // Insert portfolio entries
        final entriesList = backupData['portfolio_entries'] as List;
        for (final entry in entriesList) {
          if (entry is Map<String, dynamic>) {
            await txn.insert('portfolio_entries', entry);
          }
        }

        // Insert dividend records
        final dividendsList = backupData['dividend_records'] as List;
        for (final dividend in dividendsList) {
          if (dividend is Map<String, dynamic>) {
            await txn.insert('dividend_records', dividend);
          }
        }

        await txn.execute('PRAGMA foreign_keys = ON;');
      });

      // Reload provider state
      if (mounted) {
        await context.read<PortfolioProvider>().loadPortfolio();
        _setLoading(false);
        AppSnackBar.showSuccess(context, 'Database restored successfully!');
      }
    } catch (e) {
      _setLoading(false);
      if (mounted) {
        AppSnackBar.showError(context, 'Restore failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Backup & Restore',
      body: AppLoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(isDark),
                  const SizedBox(height: 16),
                  _buildBackupCard(isDark),
                  const SizedBox(height: 16),
                  _buildRestoreCard(isDark),
                  if (_isLoading) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        _loadingMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: AppCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Platform.isIOS ? CupertinoIcons.shield : Icons.security_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Secure Your Data',
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Export portfolio data to a generic JSON file or restore a backup file anytime.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Platform.isIOS ? CupertinoIcons.cloud_upload : Icons.cloud_upload_outlined,
                  size: 24,
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Backup Data',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Backup all your portfolio data, transactions, and dividend history into a single JSON file. This file can be shared directly via WhatsApp, email, Google Drive, or copied to your computer to be edited.',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Export & Share Backup File',
              onPressed: _exportBackup,
              icon: Icon(Platform.isIOS ? CupertinoIcons.share : Icons.share_outlined, size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Platform.isIOS ? CupertinoIcons.arrow_counterclockwise : Icons.settings_backup_restore_outlined,
                  size: 24,
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Restore Data',
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Select a backup file (.json) from your device to restore all portfolio data. All current transaction data in the app will be overwritten with the data from the backup file.',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Select & Restore Backup',
              onPressed: _importRestore,
              type: AppButtonType.secondary,
              icon: Icon(
                Platform.isIOS ? CupertinoIcons.folder : Icons.folder_open_outlined,
                size: 18,
                color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
