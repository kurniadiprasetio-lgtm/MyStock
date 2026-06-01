import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}
